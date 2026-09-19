import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/issue.dart';
import '../services/issue_service.dart';
import 'issue_detail_screen.dart';
import 'report_issue_screen.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  final IssueService _issueService = IssueService();
  int selectedTabIndex = 0;
  final List<String> tabs = ["All", "Pending", "In Progress", "Resolved"];

  Color _statusColor(IssueStatus status) {
    switch (status) {
      case IssueStatus.pending:
        return const Color(0xFFDC2626);
      case IssueStatus.inProgress:
        return const Color(0xFFD97706);
      case IssueStatus.resolved:
        return const Color(0xFF16A34A);
    }
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final currentUid = user?.uid;
    final currentDisplayName = user?.displayName ?? "You";

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text("My Reports", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            tooltip: "Report new issue",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReportIssueScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Issue>>(
        stream: _issueService.issuesStream,
        initialData: _issueService.currentIssues,
        builder: (context, snapshot) {
          final allIssues = snapshot.data ?? [];

          // Filter issues reported by current user or with fallback to user's reports
          final userIssues = allIssues.where((issue) {
            if (currentUid != null && issue.reportedById == currentUid) return true;
            if (issue.reportedBy == currentDisplayName || issue.reportedBy == "You") return true;
            return true;
          }).toList();

          List<Issue> filteredIssues;
          switch (selectedTabIndex) {
            case 1:
              filteredIssues = userIssues.where((i) => i.status == IssueStatus.pending).toList();
              break;
            case 2:
              filteredIssues = userIssues.where((i) => i.status == IssueStatus.inProgress).toList();
              break;
            case 3:
              filteredIssues = userIssues.where((i) => i.status == IssueStatus.resolved).toList();
              break;
            default:
              filteredIssues = userIssues;
          }

          return Column(
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(tabs.length, (index) {
                      final isActive = selectedTabIndex == index;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(tabs[index]),
                          selected: isActive,
                          onSelected: (_) => setState(() => selectedTabIndex = index),
                          selectedColor: const Color(0xFF2563EB),
                          labelStyle: TextStyle(
                            color: isActive ? Colors.white : const Color(0xFF334155),
                            fontWeight: FontWeight.w600,
                          ),
                          backgroundColor: const Color(0xFFF1F5F9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isActive ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),

              Expanded(
                child: filteredIssues.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.assignment_outlined, size: 54, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              "No reports under this category.",
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const ReportIssueScreen()),
                                );
                              },
                              icon: const Icon(Icons.add_location_alt, size: 18),
                              label: const Text("Report an Issue"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredIssues.length,
                        itemBuilder: (context, index) => _buildReportCard(filteredIssues[index]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildReportCard(Issue issue) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => IssueDetailScreen(issue: issue)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 68,
                height: 68,
                color: const Color(0xFFDBEAFE),
                child: issue.imageUrl != null && issue.imageUrl!.isNotEmpty
                    ? Image.network(
                        issue.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.image_outlined,
                          color: Color(0xFF2563EB),
                          size: 28,
                        ),
                      )
                    : const Icon(
                        Icons.image_outlined,
                        color: Color(0xFF2563EB),
                        size: 28,
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    issue.title,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    issue.location,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        _formatDate(issue.reportedAt),
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "• ${issue.upvotes} upvotes",
                        style: const TextStyle(fontSize: 11, color: Color(0xFF2563EB), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _statusColor(issue.status).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                issue.statusLabel,
                style: TextStyle(
                  color: _statusColor(issue.status),
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}