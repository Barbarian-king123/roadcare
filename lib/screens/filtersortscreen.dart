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
      'Damaged Manhole',
      'Damaged Footpath',
      'Fallen Tree',
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
    'Damaged Footpath',
    'Fallen Tree',
    'Garbage Dump',
    'Damaged Traffic Sign',
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

  Widget _sortOptionTile(String label, SortOption option) {
    final isSelected = selectedSort == option;
    return InkWell(
      onTap: () => setState(() => selectedSort = option),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFDBEAFE) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? const Color(0xFF2563EB) : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? const Color(0xFF1E40AF) : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
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
      title: Text(
        type,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isChecked ? FontWeight.w600 : FontWeight.w400,
          color: const Color(0xFF0F172A),
        ),
      ),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Sort By",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 10),
            _sortOptionTile("Most Recent", SortOption.mostRecent),
            _sortOptionTile("Most Upvoted", SortOption.mostUpvoted),
            _sortOptionTile("Nearest to Me", SortOption.nearest),

            const SizedBox(height: 24),

            const Text(
              "Issue Type",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 8),
            ...allIssueTypes.map(_typeCheckbox),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 54,
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Center(
              child: TextButton(
                onPressed: _reset,
                child: const Text(
                  "Reset to Default",
                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600, fontSize: 14),
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