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
      "description": description,
      "reportedBy": reportedBy,
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
          ? DateTime.parse(json["reportedAt"])
          : DateTime.now(),
      severity: IssueSeverity.values.firstWhere(
        (e) => e.name == json["severity"],
        orElse: () => IssueSeverity.medium,
      ),
      status: IssueStatus.values.firstWhere(
        (e) => e.name == json["status"],
        orElse: () => IssueStatus.pending,
      ),
      upvotes: json["upvotes"] ?? 0,
      imageUrl: json["imageUrl"],
      description: json["description"] ?? '',
      reportedBy: json["reportedBy"] ?? '',
      latitude: json["latitude"]?.toDouble(),
      longitude: json["longitude"]?.toDouble(),
    );
  }
}

// --- Dummy data (used until Firestore is wired up) ---

List<Issue> dummyIssues = [
  Issue(
    id: '1',
    title: 'Pothole',
    type: 'Pothole',
    location: 'Main Street, Model Town',
    reportedAt: DateTime(2024, 5, 20, 10, 30),
    severity: IssueSeverity.high,
    status: IssueStatus.pending,
    upvotes: 32,
    imageAsset: 'assets/pothole1.jpg',
    description: 'Large pothole on the left side of the road. Causing difficulty for vehicles.',
    reportedBy: 'Rahul Sharma',
  ),
  Issue(
    id: '2',
    title: 'Broken Street Light',
    type: 'Broken Street Light',
    location: 'MG Road, Near Metro Station',
    reportedAt: DateTime(2024, 5, 19, 20, 15),
    severity: IssueSeverity.medium,
    status: IssueStatus.pending,
    upvotes: 18,
    imageAsset: 'assets/streetlight1.jpg',
    description: 'Street light has been out for a week, making the area unsafe at night.',
    reportedBy: 'Priya Nair',
  ),
  Issue(
    id: '3',
    title: 'Water Leakage',
    type: 'Water Leakage',
    location: 'Civil Lines, Near Park',
    reportedAt: DateTime(2024, 5, 19, 16, 45),
    severity: IssueSeverity.medium,
    status: IssueStatus.pending,
    upvotes: 12,
    imageAsset: 'assets/waterleak1.jpg',
    description: 'Continuous water leakage from a broken pipe near the park entrance.',
    reportedBy: 'Amit Verma',
  ),
  Issue(
    id: '4',
    title: 'Damaged Manhole',
    type: 'Damaged Manhole',
    location: 'Green Avenue, Block B',
    reportedAt: DateTime(2024, 5, 18, 11, 20),
    severity: IssueSeverity.high,
    status: IssueStatus.resolved,
    upvotes: 25,
    imageAsset: 'assets/manhole1.jpg',
    description: 'Manhole cover is broken and poses a serious safety hazard.',
    reportedBy: 'Sneha Reddy',
  ),
];