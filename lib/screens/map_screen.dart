import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../models/issue.dart';
import 'issue_detail_screen.dart';
import 'report_issue_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  // Default center — used until real user location is available.
  static const LatLng _defaultCenter = LatLng(28.6139, 77.2090); // New Delhi

  Set<IssueSeverity?> activeFilters = {
    IssueSeverity.high,
    IssueSeverity.medium,
    IssueSeverity.low,
    null, // null = Resolved filter
  };

  List<Issue> get _filteredIssues {
    return dummyIssues.where((issue) {
      if (issue.latitude == null || issue.longitude == null) return false;
      if (issue.status == IssueStatus.resolved) {
        return activeFilters.contains(null);
      }
      return activeFilters.contains(issue.severity);
    }).toList();
  }

  Color _colorFor(Issue issue) {
    if (issue.status == IssueStatus.resolved) return Colors.blueGrey;
    switch (issue.severity) {
      case IssueSeverity.high:
        return Colors.red;
      case IssueSeverity.medium:
        return Colors.orange;
      case IssueSeverity.low:
        return Colors.green;
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

    final position = await Geolocator.getCurrentPosition();
    _mapController.move(LatLng(position.latitude, position.longitude), 15);
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        elevation: 0,
        title: const Text("RoadCare", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: _defaultCenter,
              initialZoom: 13,
            ),
            children: [
              // Free OpenStreetMap tiles — no API key, no billing.
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                // REQUIRED by OSM's usage policy — set this to your actual
                // app id (e.g. com.yourcompany.roadcare), not a placeholder,
                // before you ship.
                userAgentPackageName: 'com.example.roadcare',
              ),
              MarkerLayer(
                markers: _filteredIssues.map((issue) {
                  return Marker(
                    point: LatLng(issue.latitude!, issue.longitude!),
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => IssueDetailScreen(issue: issue)),
                      ),
                      child: Icon(
                        Icons.location_on,
                        color: _colorFor(issue),
                        size: 38,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
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
            child: FloatingActionButton(
              heroTag: "report",
              backgroundColor: const Color(0xFF2563EB),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ReportIssueScreen()),
                ).then((_) => setState(() {}));
              },
              child: const Icon(Icons.add, color: Colors.white),
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
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _legendDot("High", Colors.red, IssueSeverity.high),
                  _legendDot("Medium", Colors.orange, IssueSeverity.medium),
                  _legendDot("Low", Colors.green, IssueSeverity.low),
                  _legendDot("Resolved", Colors.blueGrey, null),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}