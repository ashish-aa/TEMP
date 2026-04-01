import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart';
import '../services/database_service.dart';

class ScheduleInterviewScreen extends StatefulWidget {
  const ScheduleInterviewScreen({super.key});

  @override
  State<ScheduleInterviewScreen> createState() =>
      _ScheduleInterviewScreenState();
}

class _ScheduleInterviewScreenState extends State<ScheduleInterviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _dbService = DatabaseService();

  late Stream<List<Map<String, dynamic>>> _candidatesStream;

  String _selectedType = 'Technical';
  String _topic = '';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _duration = 30;

  String? _selectedCandidateId;
  List<Map<String, dynamic>> _candidates = [];

  final List<String> _types = [
    'Technical',
    'HR',
    'Behavioral',
    'System Design',
  ];

  @override
  void initState() {
    super.initState();
    _candidatesStream = _dbService.streamAllCandidates();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _submit() async {
    if (!_formKey.currentState!.validate() ||
        _selectedDate == null ||
        _selectedTime == null ||
        _selectedCandidateId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields and select a candidate"),
        ),
      );
      return;
    }

    _formKey.currentState!.save();
    final auth = Provider.of<AppAuthProvider>(context, listen: false);

    final selectedCandidate = _candidates.firstWhere(
      (c) => c['id'] == _selectedCandidateId,
    );

    final startDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    // Generate roomId using document ID reference
    final docRef = FirebaseFirestore.instance.collection('interviews').doc();
    final roomId = docRef.id;

    final interviewData = {
      'interviewerId': auth.user?.uid,
      'candidateId': selectedCandidate['id'],
      'candidateName':
          "${selectedCandidate['firstName']} ${selectedCandidate['lastName']}",
      'type': _selectedType,
      'title': _selectedType,
      'topic': _topic,
      'position': _topic,
      'startTime': Timestamp.fromDate(startDateTime),
      'endTime': Timestamp.fromDate(
        startDateTime.add(Duration(minutes: _duration)),
      ),
      'duration': _duration,
      'status': 'scheduled',
      'createdAt': FieldValue.serverTimestamp(),
      'roomId': roomId, // FIX: Automatically generated from doc ID
    };

    try {
      await docRef.set(interviewData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Interview Scheduled Successfully!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF2563EB);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Schedule Interview",
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Select Candidate",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 12),
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: _candidatesStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LinearProgressIndicator(color: primaryBlue);
                  }

                  _candidates = snapshot.data ?? [];

                  if (_selectedCandidateId != null &&
                      !_candidates.any(
                        (c) => c['id'] == _selectedCandidateId,
                      )) {
                    _selectedCandidateId = null;
                  }

                  return DropdownButtonFormField<String>(
                    value: _selectedCandidateId,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    items: _candidates
                        .map(
                          (c) => DropdownMenuItem<String>(
                            value: c['id'],
                            child: Text("${c['firstName']} ${c['lastName']}"),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedCandidateId = val;
                      });
                    },
                    hint: const Text("Choose a candidate"),
                    validator: (val) => val == null ? "Required" : null,
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text(
                "Interview Details",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: InputDecoration(
                  labelText: "Interview Type",
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _types
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedType = val!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Topic / Job Position",
                  hintText: "e.g. Senior Frontend Developer",
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSaved: (val) => _topic = val ?? '',
                validator: (val) =>
                    val == null || val.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 24),
              const Text(
                "Date & Time",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: Text(
                        _selectedDate == null
                            ? "Pick Date"
                            : DateFormat('MMM dd, yyyy').format(_selectedDate!),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickTime,
                      icon: const Icon(Icons.access_time, size: 18),
                      label: Text(
                        _selectedTime == null
                            ? "Pick Time"
                            : _selectedTime!.format(context),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Duration",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    "$_duration min",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                ],
              ),
              Slider(
                value: _duration.toDouble(),
                min: 15,
                max: 120,
                divisions: 7,
                activeColor: primaryBlue,
                inactiveColor: const Color(0xFFE2E8F0),
                onChanged: (val) => setState(() => _duration = val.toInt()),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Schedule Interview",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
