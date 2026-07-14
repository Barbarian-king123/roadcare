import 'package:flutter/material.dart';
import '../models/issue.dart';
import '../widgets/bottom_nav_bar.dart';
import 'map_screen.dart';
import 'report_issue_screen.dart';
import 'my_reports_screen.dart';
import 'profile_screen.dart';
import 'issue_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedTabIndex = 0;
  final List<String> tabs = ["All", "Nearby", "Recent", "Popular"];

  int navIndex = 0;

  List<Issue> get filteredIssues {
    List<Issue> issues = List.from(dummyIssues);

    switch (selectedTabIndex) {
      case 2: // Recent
        issues.sort((a, b) => b.reportedAt.compareTo(a.reportedAt));
        break;
      case 3: // Popular
        issues.sort((a, b) => b.upvotes.compareTo(a.upvotes));
        break;
      default:
        break; // All / Nearby — no special sort for now (dummy data)
    }

    return issues;
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

  void _onNavTap(int index) {
    if (index == navIndex) return;

    setState(() => navIndex = index);

    switch (index) {
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const MapScreen()))
            .then((_) => setState(() => navIndex = 0));
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const MyReportsScreen()))
            .then((_) => setState(() => navIndex = 0));
        break;
      case 4:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()))
            .then((_) => setState(() => navIndex = 0));
        break;
    }
  }

  void _onReportTap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ReportIssueScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        elevation: 0,
        title: const Text(
          "RoadCare",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

          // Issue list
          Expanded(
            child: filteredIssues.isEmpty
                ? const Center(
                    child: Text(
                      "No issues reported yet.",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredIssues.length,
                    itemBuilder: (context, index) =>
                        _buildIssueCard(filteredIssues[index]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onReportTap,
        backgroundColor: const Color(0xFF2563EB),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: RoadCareBottomNav(
        currentIndex: navIndex,
        onTap: _onNavTap,
        onReportTap: _onReportTap,
      ),
    );
  }

  Widget _buildIssueCard(Issue issue) {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 70,
                height: 70,
                color: Colors.grey.shade200,
                child: Icon(
                  Icons.image_outlined,
                  color: Colors.grey.shade400,
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
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    issue.location,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(issue.reportedAt),
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _severityColor(issue.severity),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          issue.status == IssueStatus.resolved
                              ? "Resolved"
                              : issue.severityLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                const Icon(Icons.thumb_up_alt_outlined, size: 16, color: Colors.grey),
                const SizedBox(height: 2),
                Text(
                  "${issue.upvotes}",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}