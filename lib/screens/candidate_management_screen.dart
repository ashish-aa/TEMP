import 'package:flutter/material.dart';
import '../models/candidate_model.dart';
import '../services/database_service.dart';

class CandidateManagementScreen extends StatefulWidget {
  const CandidateManagementScreen({super.key});

  @override
  State<CandidateManagementScreen> createState() =>
      _CandidateManagementScreenState();
}

class _CandidateManagementScreenState extends State<CandidateManagementScreen> {
  final DatabaseService _dbService = DatabaseService();
  String _searchQuery = "";
  String _statusFilter = "All Status";

  final Color primaryPurple = const Color(0xFF9333EA);
  final Color primaryBlue = const Color(0xFF2563EB);
  final Color textDark = const Color(0xFF0F172A);
  final Color textGrey = const Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: primaryPurple,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "IH",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              "Candidate Management",
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: const Text(
                "Back to Dashboard",
                style: TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _dbService.streamAllCandidates(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allMaps = snapshot.data ?? [];
          final all = allMaps
              .map((m) => CandidateModel.fromMap(m, m['id'] ?? ''))
              .toList();

          final filtered = all.where((c) {
            final matchesSearch =
                c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                c.email.toLowerCase().contains(_searchQuery.toLowerCase());
            final matchesStatus =
                _statusFilter == "All Status" || c.statusLabel == _statusFilter;
            return matchesSearch && matchesStatus;
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatsGrid(all),
                const SizedBox(height: 32),
                _buildFilterToolbar(),
                const SizedBox(height: 24),
                _buildCandidateTable(filtered),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsGrid(List<CandidateModel> candidates) {
    final hired = candidates
        .where((c) => c.status == CandidateStatus.hired)
        .length;
    final interviewing = candidates
        .where((c) => c.status == CandidateStatus.interview)
        .length;
    double avgRating = candidates.isEmpty
        ? 0.0
        : candidates.fold(0.0, (sum, item) => sum + item.rating) /
              candidates.length;

    return Column(
      children: [
        _StatSummaryCard(
          title: "Total Candidates",
          value: candidates.length.toString(),
          subtitle: "All applicants",
        ),
        const SizedBox(height: 16),
        _StatSummaryCard(
          title: "In Interview",
          value: interviewing.toString(),
          subtitle: "Active interviews",
          valueColor: primaryBlue,
        ),
        const SizedBox(height: 16),
        _StatSummaryCard(
          title: "Hired",
          value: hired.toString(),
          subtitle: "Offers made",
          valueColor: Colors.green.shade600,
        ),
        const SizedBox(height: 16),
        _StatSummaryCard(
          title: "Avg Rating",
          value: avgRating.toStringAsFixed(1),
          subtitle: "Out of 5.0",
          valueColor: Colors.orange.shade600,
        ),
      ],
    );
  }

  Widget _buildFilterToolbar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          TextField(
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: "Search by name, email, position...",
              prefixIcon: const Icon(
                Icons.search,
                size: 20,
                color: Color(0xFF94A3B8),
              ),
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _DropdownSmall(
                  value: _statusFilter,
                  items: const [
                    "All Status",
                    "Pending",
                    "Hired",
                    "Rejected",
                    "Interview",
                  ],
                  onChanged: (v) => setState(() => _statusFilter = v!),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DropdownSmall(
                  value: "Sort by Name",
                  items: const [
                    "Sort by Name",
                    "Sort by Date",
                    "Sort by Rating",
                  ],
                  onChanged: (v) {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.file_upload_outlined, size: 18),
              label: const Text("Export"),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCandidateTable(List<CandidateModel> candidates) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          const _TableHeader(),
          if (candidates.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                "No candidates found",
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: candidates.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
              itemBuilder: (context, index) =>
                  _CandidateRowItem(candidate: candidates[index]),
            ),
        ],
      ),
    );
  }
}

class _StatSummaryCard extends StatelessWidget {
  final String title, value, subtitle;
  final Color? valueColor;
  const _StatSummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: valueColor ?? const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_box_outline_blank,
            size: 18,
            color: Color(0xFF94A3B8),
          ),
          const SizedBox(width: 12),
          Expanded(flex: 3, child: _HeaderCell("Name")),
          Expanded(flex: 3, child: _HeaderCell("Position")),
          Expanded(flex: 1, child: _HeaderCell("Rating")),
          Expanded(flex: 2, child: _HeaderCell("Status")),
          const Icon(Icons.more_vert, size: 18, color: Colors.transparent),
        ],
      ),
    );
  }

  Widget _HeaderCell(String text) => Text(
    text,
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
      color: Color(0xFF64748B),
    ),
  );
}

class _CandidateRowItem extends StatelessWidget {
  final CandidateModel candidate;
  const _CandidateRowItem({required this.candidate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_box_outline_blank,
                size: 18,
                color: Color(0xFFCBD5E1),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      candidate.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      candidate.email,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      candidate.position,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const Text(
                      "San Francisco, CA",
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      candidate.rating.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: _StatusBadge(status: candidate.statusLabel),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _ActionIcon(Icons.calendar_today_outlined, Colors.blue),
              const SizedBox(width: 16),
              _ActionIcon(Icons.visibility_outlined, Colors.blue),
              const SizedBox(width: 16),
              _ActionIcon(Icons.chat_bubble_outline, Colors.blue),
              const SizedBox(width: 16),
              const Icon(Icons.more_vert, size: 18, color: Color(0xFF94A3B8)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _ActionIcon(IconData icon, Color color) => Container(
    padding: const EdgeInsets.all(6),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Icon(icon, size: 16, color: color),
  );
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color = status == 'Hired'
        ? Colors.green
        : (status == 'Rejected' ? Colors.red : Colors.orange);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _DropdownSmall extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  const _DropdownSmall({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: const TextStyle(fontSize: 12)),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
