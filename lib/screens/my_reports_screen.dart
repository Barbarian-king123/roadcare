import 'package:flutter/material.dart';
import '../models/issue.dart';
import 'issue_detail_screen.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  int selectedTabIndex = 0;
  final List<String> tabs = ["All", "Pending", "In Progress", "Resolved"];

  List<Issue> get myIssues {
    // Filtered to issues reported by the current user.
    // Will be replaced with a Firestore query filtered by user id.
    final all = dummyIssues.where((issue) => issue.reportedBy == "You").toList();

    switch (selectedTabIndex) {
      case 1:
        return all.where((i) => i.status == IssueStatus.pending).toList();
      case 2:
        return all.where((i) => i.status == IssueStatus.inProgress).toList();
      case 3:
        return all.where((i) => i.status == IssueStatus.resolved).toList();
      default:
        return all;
    }
  }

  Color _statusColor(IssueStatus status) {
    switch (status) {
      case IssueStatus.pending:
        return Colors.red;
      case IssueStatus.inProgress:
        return Colors.orange;
      case IssueStatus.resolved:
        return Colors.green;
    }
  }

  String _formatDate(DateTime date) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        elevation: 0,
        title: const Text("My Reports", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Padding(
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
                        color: isActive ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isActive ? const Color(0xFF2563EB) : Colors.grey.shade300,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          Expanded(
            child: myIssues.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment_outlined, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          "No reports here yet.",
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: myIssues.length,
                    itemBuilder: (context, index) => _buildReportCard(myIssues[index]),
                  ),
          ),
        ],
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
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 65,
                height: 65,
                color: Colors.grey.shade200,
                child: Icon(Icons.image_outlined, color: Colors.grey.shade400, size: 26),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    issue.title,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    issue.location,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(issue.reportedAt),
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _statusColor(issue.status).withOpacity(0.15),
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