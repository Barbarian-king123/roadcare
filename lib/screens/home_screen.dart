import 'package:flutter/material.dart';
import 'package:roadcare/theme.dart';
import '../models/issue.dart';
import '../services/issue_service.dart';
import 'my_reports_screen.dart';
import 'notification_screen.dart';
import 'profile_screen.dart';
import 'report_issue_screen.dart';
import 'map_screen.dart';
import 'issue_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final IssueService _issueService = IssueService();
  int _currentTab = 0;

  Color _statusColor(IssueStatus status) {
    switch (status) {
      case IssueStatus.resolved:
        return RoadCareColors.success;
      case IssueStatus.inProgress:
        return RoadCareColors.warning;
      case IssueStatus.pending:
        return RoadCareColors.primary;
    }
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case "Pothole":
        return Icons.warning_amber_rounded;
      case "Broken Street Light":
      case "Streetlight":
        return Icons.lightbulb_outline_rounded;
      case "Water Leakage":
        return Icons.water_drop_outlined;
      case "Damaged Traffic Sign":
      case "Traffic Sign":
        return Icons.signpost_outlined;
      case "Damaged Manhole":
        return Icons.album_outlined;
      default:
        return Icons.report_problem_outlined;
    }
  }

  void _onTabTapped(int index) {
    if (index == _currentTab) return;

    setState(() => _currentTab = index);

    Widget? destination;
    switch (index) {
      case 1:
        destination = const MyReportsScreen();
        break;
      case 2:
        destination = const NotificationsScreen();
        break;
      case 3:
        destination = const ProfileScreen();
        break;
    }

    if (destination != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => destination!),
      ).then((_) {
        if (mounted) setState(() => _currentTab = 0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Issue>>(
      stream: _issueService.issuesStream,
      initialData: _issueService.currentIssues,
      builder: (context, snapshot) {
        final issues = snapshot.data ?? [];
        final stats = _issueService.calculateStatistics();
        final recentIssues = issues.take(5).toList();

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: SafeArea(
            top: false,
            child: CustomScrollView(
              slivers: [
                // Blue Hero Banner Header
                SliverToBoxAdapter(
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(
                      22,
                      MediaQuery.of(context).padding.top + 16,
                      22,
                      28,
                    ),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF2563EB), // Vibrant Blue
                          Color(0xFF1D4ED8), // Deep Blue
                        ],
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x332563EB),
                          blurRadius: 20,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'ROADCARE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  "Make your streets safer together",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),

                            // Notifications icon
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                onPressed: () => _onTabTapped(2),
                                icon: const Icon(
                                  Icons.notifications_outlined,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Primary White Action Button inside Blue Header
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ReportIssueScreen(),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.add_location_alt_rounded,
                              color: Color(0xFF2563EB),
                              size: 24,
                            ),
                            label: const Text(
                              "Report a Road Hazard",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              elevation: 2,
                              shadowColor: Colors.black.withValues(alpha: 0.1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Quick Actions Grid
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.map_outlined,
                            label: "Live Map",
                            color: const Color(0xFF2563EB),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const MapScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.assignment_outlined,
                            label: "My Reports",
                            color: const Color(0xFF1D4ED8),
                            onTap: () => _onTabTapped(1),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.shield_outlined,
                            label: "Safety Status",
                            color: const Color(0xFF0284C7),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("All systems operational. Municipal response active."),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Community Impact Card
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatColumn(
                            count: "${stats['fixed']}",
                            label: "Fixed",
                            color: RoadCareColors.success,
                          ),
                          Container(height: 36, width: 1, color: const Color(0xFFE2E8F0)),
                          _StatColumn(
                            count: "${stats['inProgress']}",
                            label: "In Progress",
                            color: RoadCareColors.warning,
                          ),
                          Container(height: 36, width: 1, color: const Color(0xFFE2E8F0)),
                          _StatColumn(
                            count: "${stats['resolvedRate']}",
                            label: "Resolved",
                            color: const Color(0xFF2563EB),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Recent Reports Section Header
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Recent Nearby Reports",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        TextButton(
                          onPressed: () => _onTabTapped(1),
                          child: const Text(
                            "See all",
                            style: TextStyle(
                              color: Color(0xFF2563EB),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Recent Reports Cards
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  sliver: recentIssues.isEmpty
                      ? SliverToBoxAdapter(
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            alignment: Alignment.center,
                            child: Column(
                              children: const [
                                Icon(Icons.check_circle_outline, size: 40, color: Colors.grey),
                                SizedBox(height: 8),
                                Text(
                                  "No hazards reported recently in this area.",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        )
                      : SliverList.separated(
                          itemCount: recentIssues.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final issue = recentIssues[index];
                            final status = issue.statusLabel;

                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => IssueDetailScreen(issue: issue),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(18),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
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
                                      borderRadius: BorderRadius.circular(14),
                                      child: Container(
                                        width: 52,
                                        height: 52,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFDBEAFE),
                                        ),
                                        child: issue.imageUrl != null && issue.imageUrl!.isNotEmpty
                                            ? Image.network(
                                                issue.imageUrl!,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) => Icon(
                                                  _categoryIcon(issue.type),
                                                  color: const Color(0xFF2563EB),
                                                  size: 26,
                                                ),
                                              )
                                            : Icon(
                                                _categoryIcon(issue.type),
                                                color: const Color(0xFF2563EB),
                                                size: 26,
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
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15,
                                              color: Color(0xFF0F172A),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.near_me_outlined,
                                                size: 13,
                                                color: Colors.grey.shade600,
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  issue.location,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                "• ${issue.timeAgo}",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _statusColor(issue.status).withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        status,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: _statusColor(issue.status),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentTab,
            onTap: _onTabTapped,
            selectedItemColor: const Color(0xFF2563EB),
            unselectedItemColor: const Color(0xFF64748B),
            backgroundColor: Colors.white,
            elevation: 10,
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_rounded),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.assignment_outlined),
                activeIcon: Icon(Icons.assignment_rounded),
                label: "My Reports",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications_outlined),
                activeIcon: Icon(Icons.notifications_rounded),
                label: "Alerts",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person_rounded),
                label: "Profile",
              ),
            ],
          ),
        );
      },
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String count;
  final String label;
  final Color color;

  const _StatColumn({
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}