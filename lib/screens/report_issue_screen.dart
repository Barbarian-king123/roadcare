import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/issue.dart';
import '../services/issue_service.dart';

class ReportIssueScreen extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;

  const ReportIssueScreen({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
  });

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  final IssueService _issueService = IssueService();

  XFile? _selectedImage;
  Uint8List? _imageBytes;
  String? selectedIssueType;
  bool _locating = false;
  bool _isSubmitting = false;

  double? _currentLatitude;
  double? _currentLongitude;

  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  final List<String> issueTypes = [
    'Pothole',
    'Broken Street Light',
    'Water Leakage',
    'Damaged Manhole',
    'Damaged Footpath',
    'Fallen Tree',
    'Garbage Dump',
    'Damaged Traffic Sign',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _currentLatitude = widget.initialLatitude;
      _currentLongitude = widget.initialLongitude;
      _reverseGeocode(widget.initialLatitude!, widget.initialLongitude!);
    }
  }

  Future<void> _reverseGeocode(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = [p.street, p.subLocality, p.locality, p.administrativeArea]
            .where((e) => e != null && e.trim().isNotEmpty)
            .toList();
        if (parts.isNotEmpty && mounted) {
          setState(() {
            locationController.text = parts.join(', ');
          });
          return;
        }
      }
    } catch (_) {
      // Fallback
    }

    if (mounted) {
      setState(() {
        locationController.text = "${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}";
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF2563EB)),
                title: const Text("Take a photo", style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFF2563EB)),
                title: const Text("Choose from gallery", style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    try {
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1600,
      );

      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _selectedImage = picked;
          _imageBytes = bytes;
        });
      }
    } catch (e) {
      _showSnack("Could not pick image: $e");
    }
  }

  /// Fetches device GPS coordinates and reverse geocodes into formatted location
  Future<void> _useCurrentLocation() async {
    setState(() => _locating = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnack("Please enable location services on your device");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnack("Location permission was denied");
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _showSnack("Location permission is permanently denied. Please enable in Settings.");
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      _currentLatitude = position.latitude;
      _currentLongitude = position.longitude;

      await _reverseGeocode(position.latitude, position.longitude);
    } catch (e) {
      _showSnack("Could not determine location. Please type it manually.");
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  IssueSeverity _severityFor(String? type) {
    switch (type) {
      case 'Pothole':
      case 'Damaged Manhole':
      case 'Fallen Tree':
        return IssueSeverity.high;
      case 'Broken Street Light':
      case 'Water Leakage':
      case 'Garbage Dump':
      case 'Damaged Traffic Sign':
        return IssueSeverity.medium;
      default:
        return IssueSeverity.low;
    }
  }

  Future<void> _submitReport() async {
    if (selectedIssueType == null) {
      _showSnack("Please select an issue type");
      return;
    }
    if (descriptionController.text.trim().isEmpty) {
      _showSnack("Please describe the issue");
      return;
    }
    if (locationController.text.trim().isEmpty) {
      _showSnack("Please enter or detect the location");
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final reporterName = user?.displayName ?? (user?.email != null ? user!.email!.split('@').first : "You");
      final reporterId = user?.uid ?? 'guest_user';

      // Fallback coordinate if GPS wasn't clicked (e.g. New Delhi default)
      final lat = _currentLatitude ?? 28.6139;
      final lng = _currentLongitude ?? 77.2090;

      await _issueService.createIssue(
        title: selectedIssueType!,
        type: selectedIssueType!,
        location: locationController.text.trim(),
        description: descriptionController.text.trim(),
        severity: _severityFor(selectedIssueType),
        reportedBy: reporterName,
        reportedById: reporterId,
        latitude: lat,
        longitude: lng,
        imageFile: _selectedImage,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Expanded(child: Text("Issue reported successfully! Thank you.")),
            ],
          ),
          backgroundColor: Color(0xFF16A34A),
          duration: Duration(seconds: 3),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      _showSnack("Failed to submit report. Please try again.");
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    descriptionController.dispose();
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text(
          "Report New Issue",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Upload Photo",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),

            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _imageBytes != null ? const Color(0xFF2563EB) : Colors.grey.shade300,
                    width: 1.5,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: _imageBytes != null
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.memory(
                            _imageBytes!,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.edit, color: Colors.white, size: 18),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: const BoxDecoration(
                              color: Color(0xFF2563EB),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 26),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Tap to take photo",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const Text(
                            "or upload from gallery",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "Issue Type",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedIssueType,
                  isExpanded: true,
                  hint: const Text("Select Issue Type"),
                  items: issueTypes
                      .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                      .toList(),
                  onChanged: (val) => setState(() => selectedIssueType = val),
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "Description",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Describe the issue details and hazards...",
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "Location",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: locationController,
              decoration: InputDecoration(
                hintText: "Street name, landmark or city",
                filled: true,
                fillColor: Colors.grey.shade50,
                suffixIcon: _locating
                    ? const Padding(
                        padding: EdgeInsets.all(14),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2563EB)),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.my_location, color: Color(0xFF2563EB)),
                        onPressed: _useCurrentLocation,
                        tooltip: "Use current GPS location",
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  disabledBackgroundColor: const Color(0xFF93C5FD),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isSubmitting
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            "Submitting Report...",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                        ],
                      )
                    : const Text(
                        "Submit Report",
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}