import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../models/issue.dart';
import '../services/issue_service.dart';
import 'issue_detail_screen.dart';
import 'report_issue_screen.dart';
import 'notification_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final IssueService _issueService = IssueService();

  // Default center — used until real user location is available.
  static const LatLng _defaultCenter = LatLng(28.6139, 77.2090); // New Delhi
  LatLng? _userLocation;

  Set<IssueSeverity?> activeFilters = {
    IssueSeverity.high,
    IssueSeverity.medium,
    IssueSeverity.low,
    null, // null = Resolved filter
  };

  @override
  void initState() {
    super.initState();
    _initUserLocation();
  }

  Future<void> _initUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
        );
        if (mounted) {
          setState(() {
            _userLocation = LatLng(position.latitude, position.longitude);
          });
          _mapController.move(_userLocation!, 14);
        }
      }
    } catch (_) {
      // Graceful fallback to default center
    }
  }

  Future<void> _goToMyLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnack("Please enable location services");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnack("Location permission denied");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showSnack("Location permission permanently denied. Enable it in settings.");
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition();
      final latLng = LatLng(position.latitude, position.longitude);
      setState(() {
        _userLocation = latLng;
      });
      _mapController.move(latLng, 15);
    } catch (e) {
      _showSnack("Couldn't retrieve current location");
    }
  }

  Color _colorFor(Issue issue) {
    if (issue.status == IssueStatus.resolved) return const Color(0xFF16A34A);
    switch (issue.severity) {
      case IssueSeverity.high:
        return const Color(0xFFDC2626);
      case IssueSeverity.medium:
        return const Color(0xFFEA580C);
      case IssueSeverity.low:
        return const Color(0xFF2563EB);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _toggleFilter(IssueSeverity? severity) {
    setState(() {
      if (activeFilters.contains(severity)) {
        activeFilters.remove(severity);
      } else {
        activeFilters.add(severity);
      }
    });
  }

  void _showIssuePreviewBottomSheet(Issue issue) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 64,
                      height: 64,
                      color: const Color(0xFFDBEAFE),
                      child: issue.imageUrl != null && issue.imageUrl!.isNotEmpty
                          ? Image.network(
                              issue.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.warning_amber_rounded,
                                color: Color(0xFF2563EB),
                                size: 30,
                              ),
                            )
                          : const Icon(
                              Icons.location_on,
                              color: Color(0xFF2563EB),
                              size: 32,
                            ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          issue.title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.near_me, size: 13, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              issue.distanceFrom(
                                _userLocation?.latitude,
                                _userLocation?.longitude,
                              ),
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "• ${issue.timeAgo}",
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _colorFor(issue).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            issue.status == IssueStatus.resolved
                                ? "Resolved"
                                : "${issue.severityLabel} Severity",
                            style: TextStyle(
                              color: _colorFor(issue),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (issue.description.isNotEmpty)
                Text(
                  issue.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => IssueDetailScreen(issue: issue),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        "View Details",
                        style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _onMapTapped(TapPosition tapPosition, LatLng latLng) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_location_alt, size: 40, color: Color(0xFF2563EB)),
                const SizedBox(height: 12),
                const Text(
                  "Report Issue at Selected Location?",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  "Coordinates: ${latLng.latitude.toStringAsFixed(4)}, ${latLng.longitude.toStringAsFixed(4)}",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReportIssueScreen(
                            initialLatitude: latLng.latitude,
                            initialLongitude: latLng.longitude,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Report Here",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _legendDot(String label, Color color, IssueSeverity? severity) {
    final isActive = activeFilters.contains(severity);
    return GestureDetector(
      onTap: () => _toggleFilter(severity),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: isActive ? color : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? Colors.black87 : Colors.grey,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Issue>>(
      stream: _issueService.issuesStream,
      initialData: _issueService.currentIssues,
      builder: (context, snapshot) {
        final allIssues = snapshot.data ?? [];
        final filteredIssues = allIssues.where((issue) {
          if (issue.latitude == null || issue.longitude == null) return false;
          if (issue.status == IssueStatus.resolved) {
            return activeFilters.contains(null);
          }
          return activeFilters.contains(issue.severity);
        }).toList();

        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              "Live RoadCare Map",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                  );
                },
              ),
            ],
          ),
          body: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _userLocation ?? _defaultCenter,
                  initialZoom: 13,
                  onTap: _onMapTapped,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.roadcare',
                  ),
                  MarkerLayer(
                    markers: [
                      // User Current Location marker
                      if (_userLocation != null)
                        Marker(
                          point: _userLocation!,
                          width: 44,
                          height: 44,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2563EB),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Issue Markers
                      ...filteredIssues.map((issue) {
                        return Marker(
                          point: LatLng(issue.latitude!, issue.longitude!),
                          width: 46,
                          height: 46,
                          child: GestureDetector(
                            onTap: () => _showIssuePreviewBottomSheet(issue),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: _colorFor(issue),
                                    size: 44,
                                  ),
                                  Positioned(
                                    top: 8,
                                    child: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),

              // Instructions Chip
              Positioned(
                top: 12,
                left: 20,
                right: 20,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.touch_app, size: 16, color: Color(0xFF2563EB)),
                        const SizedBox(width: 6),
                        Text(
                          "Tap marker for info · Tap map to report",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Locate-me button
              Positioned(
                right: 16,
                bottom: 180,
                child: FloatingActionButton(
                  heroTag: "locate",
                  mini: true,
                  backgroundColor: Colors.white,
                  onPressed: _goToMyLocation,
                  child: const Icon(Icons.my_location, color: Color(0xFF2563EB)),
                ),
              ),

              // Report FAB
              Positioned(
                right: 16,
                bottom: 120,
                child: FloatingActionButton.extended(
                  heroTag: "report",
                  backgroundColor: const Color(0xFF2563EB),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ReportIssueScreen()),
                    );
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    "Report",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),

              // Legend
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _legendDot("High", const Color(0xFFDC2626), IssueSeverity.high),
                      _legendDot("Medium", const Color(0xFFEA580C), IssueSeverity.medium),
                      _legendDot("Low", const Color(0xFF2563EB), IssueSeverity.low),
                      _legendDot("Resolved", const Color(0xFF16A34A), null),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}