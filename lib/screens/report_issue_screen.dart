import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/issue.dart';

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  File? selectedImage;
  String? selectedIssueType;
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
    'Other',
  ];

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
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF2563EB)),
                title: const Text("Take a photo"),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFF2563EB)),
                title: const Text("Choose from gallery"),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    final picked = await picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
      });
    }
  }

  IssueSeverity _severityFor(String? type) {
    // Simple default mapping — can be made smarter later.
    switch (type) {
      case 'Pothole':
      case 'Damaged Manhole':
      case 'Fallen Tree':
        return IssueSeverity.high;
      case 'Broken Street Light':
      case 'Water Leakage':
      case 'Garbage Dump':
        return IssueSeverity.medium;
      default:
        return IssueSeverity.low;
    }
  }

  void _submitReport() {
    if (selectedIssueType == null) {
      _showSnack("Please select an issue type");
      return;
    }
    if (descriptionController.text.trim().isEmpty) {
      _showSnack("Please describe the issue");
      return;
    }
    if (locationController.text.trim().isEmpty) {
      _showSnack("Please add a location");
      return;
    }

    final newIssue = Issue(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: selectedIssueType!,
      type: selectedIssueType!,
      location: locationController.text.trim(),
      reportedAt: DateTime.now(),
      severity: _severityFor(selectedIssueType),
      status: IssueStatus.pending,
      upvotes: 0,
      description: descriptionController.text.trim(),
      reportedBy: "You",
    );

    // Dummy data for now — will be replaced with a Firestore write.
    dummyIssues.insert(0, newIssue);

    Navigator.pop(context);
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
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1.5,
                    style: BorderStyle.solid,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: selectedImage != null
                    ? Image.file(selectedImage!, fit: BoxFit.cover)
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
                hintText: "Describe the issue...",
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
                hintText: "Model Town, Main Street",
                filled: true,
                fillColor: Colors.grey.shade50,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.my_location, color: Color(0xFF2563EB)),
                  onPressed: () {
                    // Placeholder — will use geolocator to auto-fill current location.
                    _showSnack("Auto-location coming soon");
                  },
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
                onPressed: _submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "Submit Report",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white),
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