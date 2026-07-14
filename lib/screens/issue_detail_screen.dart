import 'package:flutter/material.dart';
import '../models/issue.dart';

class IssueDetailScreen extends StatefulWidget {
  final Issue issue;
  const IssueDetailScreen({super.key, required this.issue});

  @override
  State<IssueDetailScreen> createState() => _IssueDetailScreenState();
}

class _IssueDetailScreenState extends State<IssueDetailScreen> {
  late int upvotes;
  bool hasUpvoted = false;

  @override
  void initState() {
    super.initState();
    upvotes = widget.issue.upvotes;
  }

  Color _severityColor(IssueSeverity severity) {
    switch (severity) {
      case IssueSeverity.high:
        return Colors.red;
      case IssueSeverity.medium:
        return Colors.orange;
      case IssueSeverity.low:
        return Colors.green;
    }
  }

  String _formatDate(DateTime date) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '${date.day} ${months[date.month - 1]} ${date.year} \u00b7 $hour:$minute $period';
  }

  void _toggleUpvote() {
    setState(() {
      if (hasUpvoted) {
        upvotes--;
      } else {
        upvotes++;
      }
      hasUpvoted = !hasUpvoted;
    });
    // TODO: persist upvote to Firestore once backend is wired up.
  }

  void _share() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Share coming soon")),
    );
    // TODO: use share_plus package for real sharing.
  }

  @override
  Widget build(BuildContext context) {
    final issue = widget.issue;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: Colors.black,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.share, color: Colors.white),
                ),
                onPressed: _share,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Colors.grey.shade300,
                child: Icon(
                  Icons.image_outlined,
                  size: 60,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          issue.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: issue.status == IssueStatus.resolved
                              ? Colors.green
                              : _severityColor(issue.severity),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          issue.status == IssueStatus.resolved
                              ? "Resolved"
                              : issue.severityLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          issue.location,
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(issue.reportedAt),
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Text(
                    issue.description.isEmpty
                        ? "No description provided."
                        : issue.description,
                    style: const TextStyle(fontSize: 15, height: 1.5),
                  ),

                  const SizedBox(height: 20),

                  // Small map preview placeholder
                  Container(
                    width: double.infinity,
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Icon(Icons.map_outlined, size: 40, color: Colors.grey.shade500),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.grey.shade300,
                        child: const Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Reported by",
                              style: TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                            Text(
                              issue.reportedBy.isEmpty ? "Anonymous" : issue.reportedBy,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.thumb_up_alt_outlined, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text("$upvotes", style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _toggleUpvote,
                          icon: Icon(
                            hasUpvoted ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
                            size: 18,
                            color: Colors.white,
                          ),
                          label: Text(hasUpvoted ? "Upvoted" : "Upvote"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _share,
                          icon: const Icon(Icons.share, size: 18),
                          label: const Text("Share"),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(color: Colors.grey.shade400),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}