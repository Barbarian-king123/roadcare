import 'dart:math';

enum IssueSeverity { high, medium, low }

enum IssueStatus { pending, inProgress, resolved }

class Issue {
  final String id;
  final String title;
  final String type; // Pothole, Broken Street Light, Water Leakage, etc.
  final String location;
  final DateTime reportedAt;
  final IssueSeverity severity;
  final IssueStatus status;
  final int upvotes;
  final String? imageUrl;
  final String? imageAsset; // for local/dummy data before Firebase Storage
  final String description;
  final String reportedBy;
  final String? reportedById;
  final double? latitude;
  final double? longitude;

  Issue({
    required this.id,
    required this.title,
    required this.type,
    required this.location,
    required this.reportedAt,
    required this.severity,
    required this.status,
    this.upvotes = 0,
    this.imageUrl,
    this.imageAsset,
    this.description = '',
    this.reportedBy = '',
    this.reportedById,
    this.latitude,
    this.longitude,
  });

  String get severityLabel {
    switch (severity) {
      case IssueSeverity.high:
        return 'High';
      case IssueSeverity.medium:
        return 'Medium';
      case IssueSeverity.low:
        return 'Low';
    }
  }

  String get statusLabel {
    switch (status) {
      case IssueStatus.pending:
        return 'Pending';
      case IssueStatus.inProgress:
        return 'In Progress';
      case IssueStatus.resolved:
        return 'Resolved';
    }
  }

  /// Calculates human readable distance from a user's location coordinates.
  String distanceFrom(double? userLat, double? userLng) {
    if (userLat == null || userLng == null || latitude == null || longitude == null) {
      return "Nearby";
    }
    const double p = 0.017453292519943295; // Math.PI / 180
    final double a = 0.5 -
        cos((latitude! - userLat) * p) / 2 +
        cos(userLat * p) *
            cos(latitude! * p) *
            (1 - cos((longitude! - userLng) * p)) /
            2;
    final double distKm = 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
    if (distKm < 1) {
      return "${(distKm * 1000).round()} m away";
    }
    return "${distKm.toStringAsFixed(1)} km away";
  }

  /// Relative time helper (e.g. "2 hrs ago", "Just now", "3 days ago")
  String get timeAgo {
    final diff = DateTime.now().difference(reportedAt);
    if (diff.inDays > 30) {
      return "${reportedAt.day}/${reportedAt.month}/${reportedAt.year}";
    } else if (diff.inDays >= 1) {
      return "${diff.inDays} ${diff.inDays == 1 ? 'day' : 'days'} ago";
    } else if (diff.inHours >= 1) {
      return "${diff.inHours} ${diff.inHours == 1 ? 'hr' : 'hrs'} ago";
    } else if (diff.inMinutes >= 1) {
      return "${diff.inMinutes} ${diff.inMinutes == 1 ? 'min' : 'mins'} ago";
    } else {
      return "Just now";
    }
  }

  Issue copyWith({
    String? id,
    String? title,
    String? type,
    String? location,
    DateTime? reportedAt,
    IssueSeverity? severity,
    IssueStatus? status,
    int? upvotes,
    String? imageUrl,
    String? imageAsset,
    String? description,
    String? reportedBy,
    String? reportedById,
    double? latitude,
    double? longitude,
  }) {
    return Issue(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      location: location ?? this.location,
      reportedAt: reportedAt ?? this.reportedAt,
      severity: severity ?? this.severity,
      status: status ?? this.status,
      upvotes: upvotes ?? this.upvotes,
      imageUrl: imageUrl ?? this.imageUrl,
      imageAsset: imageAsset ?? this.imageAsset,
      description: description ?? this.description,
      reportedBy: reportedBy ?? this.reportedBy,
      reportedById: reportedById ?? this.reportedById,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  // --- Firestore serialization ---

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "type": type,
      "location": location,
      "reportedAt": reportedAt.toIso8601String(),
      "severity": severity.name,
      "status": status.name,
      "upvotes": upvotes,
      "imageUrl": imageUrl,
      "imageAsset": imageAsset,
      "description": description,
      "reportedBy": reportedBy,
      "reportedById": reportedById,
      "latitude": latitude,
      "longitude": longitude,
    };
  }

  factory Issue.fromJson(String id, Map<String, dynamic> json) {
    return Issue(
      id: id,
      title: json["title"] ?? '',
      type: json["type"] ?? '',
      location: json["location"] ?? '',
      reportedAt: json["reportedAt"] != null
          ? DateTime.tryParse(json["reportedAt"]) ?? DateTime.now()
          : DateTime.now(),
      severity: IssueSeverity.values.firstWhere(
        (e) => e.name == json["severity"],
        orElse: () => IssueSeverity.medium,
      ),
      status: IssueStatus.values.firstWhere(
        (e) => e.name == json["status"],
        orElse: () => IssueStatus.pending,
      ),
      upvotes: (json["upvotes"] as num?)?.toInt() ?? 0,
      imageUrl: json["imageUrl"],
      imageAsset: json["imageAsset"],
      description: json["description"] ?? '',
      reportedBy: json["reportedBy"] ?? '',
      reportedById: json["reportedById"],
      latitude: (json["latitude"] as num?)?.toDouble(),
      longitude: (json["longitude"] as num?)?.toDouble(),
    );
  }
}

// --- Realistic initial issues with GPS coordinates (Default / Initial Seed) ---

List<Issue> dummyIssues = [
  Issue(
    id: '1',
    title: 'Large Pothole on Main Road',
    type: 'Pothole',
    location: 'Main Street, Model Town, Delhi',
    reportedAt: DateTime.now().subtract(const Duration(hours: 2)),
    severity: IssueSeverity.high,
    status: IssueStatus.pending,
    upvotes: 32,
    imageUrl: 'https://images.unsplash.com/photo-1515162816999-a0c47dc192f7?auto=format&fit=crop&w=600&q=80',
    description: 'Deep pothole across the left lane causing major slow down and tire damage.',
    reportedBy: 'Rahul Sharma',
    reportedById: 'sample_user_1',
    latitude: 28.6139,
    longitude: 77.2090,
  ),
  Issue(
    id: '2',
    title: 'Broken Street Light',
    type: 'Broken Street Light',
    location: 'MG Road, Near Metro Gate 2',
    reportedAt: DateTime.now().subtract(const Duration(hours: 5)),
    severity: IssueSeverity.medium,
    status: IssueStatus.inProgress,
    upvotes: 18,
    imageUrl: 'https://images.unsplash.com/photo-1508873696983-2df5293cb32b?auto=format&fit=crop&w=600&q=80',
    description: 'Street light has been malfunctioning for a week, creating poor visibility at night.',
    reportedBy: 'Priya Nair',
    reportedById: 'sample_user_2',
    latitude: 28.6250,
    longitude: 77.2180,
  ),
  Issue(
    id: '3',
    title: 'Water Pipe Leakage',
    type: 'Water Leakage',
    location: 'Civil Lines, Near Community Park',
    reportedAt: DateTime.now().subtract(const Duration(hours: 14)),
    severity: IssueSeverity.medium,
    status: IssueStatus.pending,
    upvotes: 12,
    imageUrl: 'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?auto=format&fit=crop&w=600&q=80',
    description: 'Continuous fresh water leakage from broken underground pipe flooding pedestrian walkway.',
    reportedBy: 'Amit Verma',
    reportedById: 'sample_user_3',
    latitude: 28.6050,
    longitude: 77.1980,
  ),
  Issue(
    id: '4',
    title: 'Damaged Manhole Cover',
    type: 'Damaged Manhole',
    location: 'Green Avenue, Block B Sector 14',
    reportedAt: DateTime.now().subtract(const Duration(days: 1)),
    severity: IssueSeverity.high,
    status: IssueStatus.resolved,
    upvotes: 45,
    imageUrl: 'https://images.unsplash.com/photo-1578885136359-16c8bd4d3a8e?auto=format&fit=crop&w=600&q=80',
    description: 'Cracked concrete cover replaced with reinforced iron lid by municipal team.',
    reportedBy: 'Sneha Reddy',
    reportedById: 'sample_user_4',
    latitude: 28.6320,
    longitude: 77.2250,
  ),
  Issue(
    id: '5',
    title: 'Damaged Footpath & Curb',
    type: 'Damaged Footpath',
    location: 'Ring Road, Near Bus Shelter 4',
    reportedAt: DateTime.now().subtract(const Duration(days: 2)),
    severity: IssueSeverity.low,
    status: IssueStatus.inProgress,
    upvotes: 8,
    imageUrl: 'https://images.unsplash.com/photo-1584467735815-f778f274e296?auto=format&fit=crop&w=600&q=80',
    description: 'Broken paving blocks creating tripping hazard for elderly and morning walkers.',
    reportedBy: 'Rohan Gupta',
    reportedById: 'sample_user_5',
    latitude: 28.5980,
    longitude: 77.2150,
  ),
];