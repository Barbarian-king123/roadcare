import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:share_plus/share_plus.dart';
import '../models/issue.dart';
import '../services/issue_service.dart';

class IssueDetailScreen extends StatefulWidget {
  final Issue issue;
  const IssueDetailScreen({super.key, required this.issue});

  @override
  State<IssueDetailScreen> createState() => _IssueDetailScreenState();
}

class _IssueDetailScreenState extends State<IssueDetailScreen> {
  final IssueService _issueService = IssueService();
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
        return const Color(0xFFDC2626);
      case IssueSeverity.medium:
        return const Color(0xFFEA580C);
      case IssueSeverity.low:
        return const Color(0xFF2563EB);
    }
  }

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
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '${date.day} ${months[date.month - 1]} ${date.year} \u00b7 $hour:$minute $period';
  }

  void _toggleUpvote() {
    setState(() {
      if (hasUpvoted) {
        upvotes = upvotes > 0 ? upvotes - 1 : 0;
        hasUpvoted = false;
      } else {
        upvotes++;
        hasUpvoted = true;
      }
    });

    _issueService.toggleUpvote(widget.issue.id, hasUpvoted);
  }

  Future<void> _share() async {
    final issue = widget.issue;
    final text = 'Road Hazard Report on RoadCare:\n'
        '• Issue: ${issue.title} (${issue.type})\n'
        '• Location: ${issue.location}\n'
        '• Status: ${issue.statusLabel}\n'
        '• Description: ${issue.description.isEmpty ? "Hazard reported by community member" : issue.description}\n'
        'Help verify and upvote this report on RoadCare app!';

    await Share.share(text, subject: 'RoadCare — ${issue.title}');
  }

  @override
  Widget build(BuildContext context) {
    final issue = widget.issue;
    final LatLng issueLocation = LatLng(
      issue.latitude ?? 28.6139,
      issue.longitude ?? 77.2090,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: const Color(0xFF1E293B),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.share, color: Colors.white, size: 20),
                ),
                onPressed: _share,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: issue.imageUrl != null && issue.imageUrl!.isNotEmpty
                  ? Image.network(
                      issue.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildFallbackHeaderImage(),
                    )
                  : _buildFallbackHeaderImage(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Status Badges
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          issue.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _statusColor(issue.status),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          issue.statusLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Location Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on, size: 18, color: Color(0xFF2563EB)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          issue.location,
                          style: const TextStyle(
                            color: Color(0xFF334155),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Date Row
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded, size: 16, color: Colors.grey.shade500),
                      const SizedBox(width: 6),
                      Text(
                        _formatDate(issue.reportedAt),
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _severityColor(issue.severity).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "${issue.severityLabel} Priority",
                          style: TextStyle(
                            color: _severityColor(issue.severity),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Description Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Description",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          issue.description.isEmpty
                              ? "No additional description provided."
                              : issue.description,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Mini Interactive Map Preview
                  const Text(
                    "Location Map",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Container(
                    width: double.infinity,
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        FlutterMap(
                          options: MapOptions(
                            initialCenter: issueLocation,
                            initialZoom: 15,
                            interactionOptions: const InteractionOptions(
                              flags: InteractiveFlag.none,
                            ),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.example.roadcare',
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: issueLocation,
                                  width: 40,
                                  height: 40,
                                  child: Icon(
                                    Icons.location_on,
                                    color: _severityColor(issue.severity),
                                    size: 38,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.gps_fixed, size: 12, color: Color(0xFF2563EB)),
                                const SizedBox(width: 4),
                                Text(
                                  "${issueLocation.latitude.toStringAsFixed(4)}, ${issueLocation.longitude.toStringAsFixed(4)}",
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Reported By Info
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: const Color(0xFFDBEAFE),
                          child: const Icon(Icons.person, color: Color(0xFF2563EB)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Reported by",
                                style: TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                              Text(
                                issue.reportedBy.isEmpty ? "Community Volunteer" : issue.reportedBy,
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.thumb_up_alt_rounded, size: 14, color: Color(0xFF2563EB)),
                              const SizedBox(width: 6),
                              Text(
                                "$upvotes Upvotes",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _toggleUpvote,
                          icon: Icon(
                            hasUpvoted ? Icons.thumb_up : Icons.thumb_up_outlined,
                            size: 18,
                            color: Colors.white,
                          ),
                          label: Text(hasUpvoted ? "Upvoted ($upvotes)" : "Upvote Issue"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _share,
                          icon: const Icon(Icons.share, size: 18, color: Color(0xFF2563EB)),
                          label: const Text(
                            "Share",
                            style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            side: const BorderSide(color: Color(0xFF2563EB)),
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

  Widget _buildFallbackHeaderImage() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.report_problem_rounded, size: 64, color: Colors.white70),
            SizedBox(height: 8),
            Text(
              "RoadCare Issue Report",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}