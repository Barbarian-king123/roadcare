import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  GoogleMapController? mapController;

  // Default camera position — used until real user location is available.
  static const CameraPosition _defaultPosition = CameraPosition(
    target: LatLng(28.6139, 77.2090), // New Delhi, placeholder center
    zoom: 13,
  );

  Set<Marker> markers = {};
  Set<IssueSeverity?> activeFilters = {
    IssueSeverity.high,
    IssueSeverity.medium,
    IssueSeverity.low,
    null, // null = Resolved filter
  };

  @override
  void initState() {
    super.initState();
    _buildMarkers();
  }

  void _buildMarkers() {
    final filtered = dummyIssues.where((issue) {
      if (issue.status == IssueStatus.resolved) {
        return activeFilters.contains(null);
      }
      return activeFilters.contains(issue.severity);
    }).toList();

    setState(() {
      markers = filtered
          .where((issue) => issue.latitude != null && issue.longitude != null)
          .map((issue) {
        return Marker(
          markerId: MarkerId(issue.id),
          position: LatLng(issue.latitude!, issue.longitude!),
          icon: BitmapDescriptor.defaultMarkerWithHue(_hueFor(issue)),
          infoWindow: InfoWindow(
            title: issue.title,
            snippet: issue.location,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => IssueDetailScreen(issue: issue)),
              );
            },
          ),
        );
      }).toSet();
    });
  }

  double _hueFor(Issue issue) {
    if (issue.status == IssueStatus.resolved) return BitmapDescriptor.hueGreen;
    switch (issue.severity) {
      case IssueSeverity.high:
        return BitmapDescriptor.hueRed;
      case IssueSeverity.medium:
        return BitmapDescriptor.hueOrange;
      case IssueSeverity.low:
        return BitmapDescriptor.hueGreen;
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
    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(position.latitude, position.longitude),
        15,
      ),
    );
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
    _buildMarkers();
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
          GoogleMap(
            initialCameraPosition: _defaultPosition,
            markers: markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (controller) => mapController = controller,
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
                ).then((_) => _buildMarkers());
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