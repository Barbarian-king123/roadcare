import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../models/issue.dart';
import 'storage_service.dart';

class IssueService {
  static final IssueService _instance = IssueService._internal();
  factory IssueService() => _instance;
  IssueService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageService _storageService = StorageService();

  // In-memory synchronized issue list seeded with initial data
  final List<Issue> _localIssues = List.from(dummyIssues);
  final StreamController<List<Issue>> _issuesStreamController =
      StreamController<List<Issue>>.broadcast();

  bool _initialized = false;
  StreamSubscription? _firestoreSubscription;

  /// Returns real-time stream of all issues, sorted by reported date descending
  Stream<List<Issue>> get issuesStream {
    _ensureInitialized();
    return _issuesStreamController.stream;
  }

  /// Current snapshot of issues
  List<Issue> get currentIssues => List.unmodifiable(_localIssues);

  void _ensureInitialized() {
    if (_initialized) return;
    _initialized = true;

    // Emit initial cached list immediately
    _issuesStreamController.add(List.from(_localIssues));

    try {
      _firestoreSubscription = _firestore
          .collection('issues')
          .orderBy('reportedAt', descending: true)
          .snapshots()
          .listen(
        (snapshot) {
          if (snapshot.docs.isNotEmpty) {
            final firestoreIssues = snapshot.docs.map((doc) {
              return Issue.fromJson(doc.id, doc.data());
            }).toList();

            // Merge with local list (avoiding duplicate IDs)
            final Set<String> firestoreIds = firestoreIssues.map((e) => e.id).toSet();
            final remainingLocal = _localIssues.where((e) => !firestoreIds.contains(e.id)).toList();

            _localIssues.clear();
            _localIssues.addAll([...firestoreIssues, ...remainingLocal]);
            _issuesStreamController.add(List.from(_localIssues));
          }
        },
        onError: (error) {
          // Firestore may be in offline mode or permissions pending; local issues remain intact
          _issuesStreamController.add(List.from(_localIssues));
        },
      );
    } catch (_) {
      _issuesStreamController.add(List.from(_localIssues));
    }
  }

  /// Creates and saves a new issue, with optional photo upload to Firebase Storage
  Future<Issue> createIssue({
    required String title,
    required String type,
    required String location,
    required String description,
    required IssueSeverity severity,
    required String reportedBy,
    String? reportedById,
    double? latitude,
    double? longitude,
    XFile? imageFile,
  }) async {
    String? uploadedImageUrl;

    // 1. Upload photo to Firebase Storage if provided
    if (imageFile != null) {
      try {
        uploadedImageUrl = await _storageService.uploadIssueImage(imageFile: imageFile);
      } catch (_) {
        // Fallback gracefully
      }
    }

    final String issueId = DateTime.now().millisecondsSinceEpoch.toString();

    final newIssue = Issue(
      id: issueId,
      title: title,
      type: type,
      location: location,
      reportedAt: DateTime.now(),
      severity: severity,
      status: IssueStatus.pending,
      upvotes: 0,
      imageUrl: uploadedImageUrl,
      description: description,
      reportedBy: reportedBy,
      reportedById: reportedById,
      latitude: latitude,
      longitude: longitude,
    );

    // 2. Insert into local memory and stream immediately for instant UI update
    _localIssues.insert(0, newIssue);
    _issuesStreamController.add(List.from(_localIssues));

    // 3. Persist to Cloud Firestore
    try {
      await _firestore.collection('issues').doc(issueId).set(newIssue.toJson());
    } catch (_) {
      // Offline fallback: issue is preserved in-memory
    }

    return newIssue;
  }

  /// Upvotes or removes upvote from an issue
  Future<void> toggleUpvote(String issueId, bool isUpvoting) async {
    final index = _localIssues.indexWhere((issue) => issue.id == issueId);
    if (index != -1) {
      final issue = _localIssues[index];
      final newCount = isUpvoting ? issue.upvotes + 1 : (issue.upvotes > 0 ? issue.upvotes - 1 : 0);
      _localIssues[index] = issue.copyWith(upvotes: newCount);
      _issuesStreamController.add(List.from(_localIssues));
    }

    try {
      await _firestore.collection('issues').doc(issueId).update({
        'upvotes': FieldValue.increment(isUpvoting ? 1 : -1),
      });
    } catch (_) {
      // Local state already updated
    }
  }

  /// Calculates statistics for the community dashboard
  Map<String, dynamic> calculateStatistics() {
    int fixedCount = 0;
    int inProgressCount = 0;
    int pendingCount = 0;

    for (final issue in _localIssues) {
      if (issue.status == IssueStatus.resolved) {
        fixedCount++;
      } else if (issue.status == IssueStatus.inProgress) {
        inProgressCount++;
      } else {
        pendingCount++;
      }
    }

    final total = _localIssues.length;
    final int resolvedPercentage = total > 0 ? ((fixedCount / total) * 100).round() : 0;

    return {
      'fixed': fixedCount,
      'inProgress': inProgressCount,
      'pending': pendingCount,
      'total': total,
      'resolvedRate': "$resolvedPercentage%",
    };
  }

  void dispose() {
    _firestoreSubscription?.cancel();
    _issuesStreamController.close();
  }
}
