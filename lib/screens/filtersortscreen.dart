import 'package:flutter/material.dart';

enum SortOption { mostRecent, mostUpvoted, nearest }

class FilterSortResult {
  final SortOption sortBy;
  final Set<String> issueTypes;

  FilterSortResult({required this.sortBy, required this.issueTypes});
}

class FilterSortScreen extends StatefulWidget {
  final SortOption initialSort;
  final Set<String> initialIssueTypes;

  const FilterSortScreen({
    super.key,
    this.initialSort = SortOption.mostRecent,
    this.initialIssueTypes = const {
      'Pothole',
      'Broken Street Light',
      'Water Leakage',
    },
  });

  @override
  State<FilterSortScreen> createState() => _FilterSortScreenState();
}

class _FilterSortScreenState extends State<FilterSortScreen> {
  late SortOption selectedSort;
  late Set<String> selectedTypes;

  final List<String> allIssueTypes = [
    'Pothole',
    'Broken Street Light',
    'Water Leakage',
    'Damaged Manhole',
    'Others',
  ];

  @override
  void initState() {
    super.initState();
    selectedSort = widget.initialSort;
    selectedTypes = Set.from(widget.initialIssueTypes);
  }

  void _reset() {
    setState(() {
      selectedSort = SortOption.mostRecent;
      selectedTypes = Set.from(allIssueTypes);
    });
  }

  void _apply() {
    Navigator.pop(
      context,
      FilterSortResult(sortBy: selectedSort, issueTypes: selectedTypes),
    );
  }

  Widget _sortRadio(String label, SortOption option) {
    return RadioListTile<SortOption>(
      value: option,
      groupValue: selectedSort,
      onChanged: (val) => setState(() => selectedSort = val!),
      title: Text(label, style: const TextStyle(fontSize: 15)),
      activeColor: const Color(0xFF2563EB),
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }

  Widget _typeCheckbox(String type) {
    final isChecked = selectedTypes.contains(type);
    return CheckboxListTile(
      value: isChecked,
      onChanged: (val) {
        setState(() {
          if (val == true) {
            selectedTypes.add(type);
          } else {
            selectedTypes.remove(type);
          }
        });
      },
      title: Text(type, style: const TextStyle(fontSize: 15)),
      activeColor: const Color(0xFF2563EB),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Filter & Sort",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text(
              "Sort By",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            _sortRadio("Most Recent", SortOption.mostRecent),
            _sortRadio("Most Upvoted", SortOption.mostUpvoted),
            _sortRadio("Nearest", SortOption.nearest),

            const SizedBox(height: 24),

            const Text(
              "Issue Type",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            ...allIssueTypes.map(_typeCheckbox),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _apply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "Apply Filters",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Center(
              child: TextButton(
                onPressed: _reset,
                child: const Text(
                  "Reset",
                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}