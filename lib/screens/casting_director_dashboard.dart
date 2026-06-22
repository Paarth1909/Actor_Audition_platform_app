import 'dart:typed_data';

import 'package:actors_audition_platform_app/services/email_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // kept for file storage only
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';

// ── Firestore helper reference ────────────────────────────────────────────────
final _db = FirebaseFirestore.instance;

class CastingDirectorDashboard extends StatefulWidget {
  const CastingDirectorDashboard({super.key});

  @override
  State<CastingDirectorDashboard> createState() =>
      _CastingDirectorDashboardState();
}

class _CastingDirectorDashboardState extends State<CastingDirectorDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),   
                      decoration: BoxDecoration(
                        color: const Color(0x33FF8C00),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0x80FF8C00),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.movie_creation,
                        color: Colors.orange,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CASTING DIRECTOR',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                            ),
                          ),
                          Text(
                            user?.email?.split('@').first ?? 'Director',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        await FirebaseAuth.instance.signOut();
                        if (context.mounted) {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            '/home',
                            (route) => false,
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0x26FF4444),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0x66FF4444),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.logout,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Tab Bar ─────────────────────────────────────────────
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0x12FFFFFF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.orange, Colors.deepOrange],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  padding: const EdgeInsets.all(4),
                  labelPadding: EdgeInsets.zero,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: '📢 Publish'),
                    Tab(text: '🎬 Auditions'),
                    Tab(text: '👥 Applicants'),
                    Tab(text: '👤 Profile'),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: const [
                    PublishAuditionForm(),
                    MyAuditionsTab(),
                    ApplicantsTab(),
                    DirectorProfileTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Publish Audition Form ─────────────────────────────────────────────────────

class PublishAuditionForm extends StatefulWidget {
  const PublishAuditionForm({super.key});

  @override
  State<PublishAuditionForm> createState() => _PublishAuditionFormState();
}

class _PublishAuditionFormState extends State<PublishAuditionForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _compensationController = TextEditingController();

  String _gender = 'Any';
  String _projectType = 'Film';
  DateTime? _auditionDate;
  bool _isLoading = false;

  // Optional: uploaded media URL from Supabase Storage
  // bool _isLoading = false;

  String? _uploadedFileUrl;

  final List<String> _genders = ['Any', 'Male', 'Female', 'Non-binary'];
  final List<String> _projectTypes = [
    'Film',
    'TV Series',
    'Web Series',
    'Short Film',
    'Commercial',
    'Theatre',
    'Music Video',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    _requirementsController.dispose();
    _compensationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Colors.orange,
            onPrimary: Colors.white,
            surface: Color(0xFF1a1a2e),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _auditionDate = picked);
  }

  /// Upload a file to Supabase Storage and return its public URL.
  /// Call this before _publish() to attach a script/image to the audition.
  // ignore: unused_element
  Future<String?> _uploadFileToSupabase(
    Uint8List fileBytes,
    String fileName,
  ) async {
    try {
      final path = 'auditions/$fileName';
      await Supabase.instance.client.storage
          .from('audition-files') // bucket name in Supabase
          .uploadBinary(
            path,
            fileBytes,
            fileOptions: const FileOptions(upsert: true),
          );
      final url = Supabase.instance.client.storage
          .from('audition-files')
          .getPublicUrl(path);
      return url;
    } catch (e) {
      debugPrint('$e');
      _snack('File upload failed: $e', error: true);
      return null;
    }
  }

  Future<void> _pickAndUploadFile() async {
    // FilePicker.platform is the singleton instance — pickFiles() is an instance method
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      withData: true, // required on web/desktop to get bytes
    );

    if (result == null) return; // user cancelled

    final fileBytes = result.files.first.bytes;
    final fileName = result.files.first.name;

    if (fileBytes == null) {
      _snack('Could not read file bytes', error: true);
      return;
    }

    setState(() => _isLoading = true);
    final url = await _uploadFileToSupabase(fileBytes, fileName);
    if (!mounted) return;

    if (url != null) {
      setState(() => _uploadedFileUrl = url);
      _snack('File uploaded successfully ✅');
    }

    setState(() => _isLoading = false);
  }

  /// Saves audition data to Firestore → collection: "auditions"
  Future<void> _publish() async {
    if (!_formKey.currentState!.validate()) return;
    if (_auditionDate == null) {
      _snack('Please select an audition date', error: true);
      return;
    }

    // Start loading — safe to call synchronously here (no await yet)
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      // Write to Firestore (Firebase database)
      await _db.collection('auditions').add({
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'location': _locationController.text.trim(),
        'requirements': _requirementsController.text.trim(),
        'compensation': _compensationController.text.trim(),
        'gender': _gender,
        'project_type': _projectType,
        'audition_date': Timestamp.fromDate(_auditionDate!),
        'director_email': user?.email ?? '',
        'director_uid': user?.uid ?? '',
        'created_at': FieldValue.serverTimestamp(),
        'status': 'active',
        // file_url will be populated after Supabase Storage upload (if any)
        'file_url': _uploadedFileUrl ?? '',
      });

      // After await — must check mounted before touching state/context
      if (!mounted) return;
      _snack('Audition published successfully! 🎉');
      _clear();
    } catch (e) {
      debugPrint('Publish error: $e');
      if (!mounted) return;
      _snack('Failed: ${e.toString()}', error: true);
    } finally {
      // Always reset loading spinner, but only if widget is still alive
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _clear() {
    _titleController.clear();
    _descController.clear();
    _locationController.clear();
    _requirementsController.clear();
    _compensationController.clear();
    setState(() {
      _gender = 'Any';
      _projectType = 'Film';
      _auditionDate = null;
      _uploadedFileUrl = null;
      // Note: _isLoading is reset by the finally block in _publish()
      // Do NOT reset it here to avoid a double setState conflict
    });
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Project Title *'),
            _field(
              controller: _titleController,
              hint: 'e.g. Lead Role in Bollywood Drama',
              icon: Icons.title,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Title is required' : null,
            ),

            const SizedBox(height: 16),
            _label('Project Type *'),
            _dropdown(
              value: _projectType,
              items: _projectTypes,
              icon: Icons.movie,
              onChanged: (v) => setState(() => _projectType = v!),
            ),

            const SizedBox(height: 16),
            _label('Description / Role Details *'),
            _field(
              controller: _descController,
              hint: 'Describe the role, storyline, character traits...',
              icon: Icons.description,
              maxLines: 4,
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Description is required'
                  : null,
            ),

            const SizedBox(height: 16),
            _label('Location *'),
            _field(
              controller: _locationController,
              hint: 'e.g. Mumbai, Maharashtra',
              icon: Icons.location_on,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Location is required' : null,
            ),

            const SizedBox(height: 16),
            _label('Audition Date *'),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0x12FFFFFF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _auditionDate == null
                          ? 'Tap to select a date'
                          : '${_auditionDate!.day}/${_auditionDate!.month}/${_auditionDate!.year}',
                      style: TextStyle(
                        color: _auditionDate == null
                            ? Colors.white38
                            : Colors.white,
                        fontSize: 15,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_drop_down, color: Colors.white38),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            _label('Gender Preference'),
            _dropdown(
              value: _gender,
              items: _genders,
              icon: Icons.people,
              onChanged: (v) => setState(() => _gender = v!),
            ),

            const SizedBox(height: 16),
            _label('Requirements & Skills'),
            _field(
              controller: _requirementsController,
              hint: 'e.g. Age 18-30, fluent Hindi, dance skills...',
              icon: Icons.checklist,
              maxLines: 3,
            ),

            const SizedBox(height: 16),
            _label('Compensation / Pay'),
            _field(
              controller: _compensationController,
              hint: 'e.g. ₹50,000 per day / Negotiable',
              icon: Icons.currency_rupee,
            ),

            const SizedBox(height: 16),

            // ── Supabase File Storage hint banner ──────────────────
            GestureDetector(
              onTap: _pickAndUploadFile,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0x1A3ECF8E),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0x553ECF8E)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.cloud_upload_outlined,
                      color: Color(0xFF3ECF8E),
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Attach Script / Audition Sheet',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _uploadedFileUrl != null
                                ? '✅ File uploaded via Supabase Storage'
                                : 'Files are stored via Supabase Storage',
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 11,
                            ),
                          ),
                          if (_uploadedFileUrl != null) ...[
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () async {
                                final url =
                                    Uri.tryParse(_uploadedFileUrl ?? '');
                                if (url != null &&
                                    await canLaunchUrl(url)) {
                                  await launchUrl(
                                    url,
                                    mode: LaunchMode.externalApplication,
                                  );
                                } else if (context.mounted) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Could not open the file'),
                                      backgroundColor: Colors.redAccent,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0x1A3ECF8E),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: const Color(0x553ECF8E)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.description_outlined,
                                      color: Color(0xFF3ECF8E),
                                      size: 14,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Read Script / File',
                                      style: TextStyle(
                                        color: Color(0xFF3ECF8E),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.open_in_new,
                                      color: Color(0xFF3ECF8E),
                                      size: 12,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                ),
            ),

            const SizedBox(height: 32),

            // ── Publish Button ─────────────────────────────────────
            GestureDetector(
              onTap: _isLoading ? null : _publish,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 56,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isLoading
                        ? [Colors.grey.shade700, Colors.grey.shade600]
                        : [Colors.orange, Colors.deepOrange],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: _isLoading
                      ? []
                      : const [
                          BoxShadow(
                            color: Color(0x66FF8C00),
                            blurRadius: 16,
                            offset: Offset(0, 6),
                          ),
                        ],
                ),
                child: Center(
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.publish, color: Colors.white),
                            SizedBox(width: 10),
                            Text(
                              'Publish Audition',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      ),
    ),
  );

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) => TextFormField(
    controller: controller,
    maxLines: maxLines,
    validator: validator,
    style: const TextStyle(color: Colors.white, fontSize: 15),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.orange, size: 20),
      filled: true,
      fillColor: const Color(0x12FFFFFF),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.orange, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      errorStyle: const TextStyle(color: Colors.redAccent),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );

  Widget _dropdown({
    required String value,
    required List<String> items,
    required IconData icon,
    required void Function(String?) onChanged,
  }) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: const Color(0x12FFFFFF),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.white24),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        dropdownColor: const Color(0xFF16213e),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.orange),
        style: const TextStyle(color: Colors.white, fontSize: 15),
        items: items
            .map(
              (e) => DropdownMenuItem(
                value: e,
                child: Row(
                  children: [
                    Icon(icon, color: Colors.orange, size: 18),
                    const SizedBox(width: 10),
                    Text(e),
                  ],
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    ),
  );
}

// ── My Auditions Tab (real-time via Firestore stream) ────────────────────────

class MyAuditionsTab extends StatelessWidget {
  const MyAuditionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return StreamBuilder<QuerySnapshot>(
      // Real-time listener — Firestore pushes updates automatically
      // Note: orderBy removed to avoid requiring a composite index.
      // Sorting is done client-side after the data is fetched.
      stream: _db
          .collection('auditions')
          .where('director_uid', isEqualTo: uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.orange),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.redAccent),
            ),
          );
        }

        // Client-side sort by created_at descending
        final docs = [...(snapshot.data?.docs ?? [])]
          ..sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aTs = aData['created_at'];
            final bTs = bData['created_at'];
            if (aTs == null && bTs == null) return 0;
            if (aTs == null) return 1;
            if (bTs == null) return -1;
            return (bTs as Timestamp).compareTo(aTs as Timestamp);
          });

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.movie_filter_outlined,
                  size: 70,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No auditions yet',
                  style: TextStyle(color: Colors.white54, fontSize: 16),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Use the Publish tab to create one',
                  style: TextStyle(color: Colors.white30, fontSize: 13),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final doc = docs[i];
            final data = doc.data() as Map<String, dynamic>;

            final ts = data['audition_date'];
            String dateStr = 'N/A';
            if (ts is Timestamp) {
              final d = ts.toDate();
              dateStr = '${d.day}/${d.month}/${d.year}';
            }

            return _AuditionCard(docId: doc.id, data: data, dateStr: dateStr);
          },
        );
      },
    );
  }
}

// ── Audition Card ─────────────────────────────────────────────────────────────

class _AuditionCard extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> data;
  final String dateStr;

  const _AuditionCard({
    required this.docId,
    required this.data,
    required this.dateStr,
  });

  Future<void> _delete(BuildContext context) async {
    try {
      await _db.collection('auditions').doc(docId).delete();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Audition deleted'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasFile = (data['file_url'] ?? '').toString().isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0x10FFFFFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    data['title'] ?? 'Untitled',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0x3300CC66),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0x8000CC66)),
                  ),
                  child: Text(
                    data['status'] ?? 'active',
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _info(Icons.movie, data['project_type'] ?? ''),
            const SizedBox(height: 4),
            _info(Icons.location_on, data['location'] ?? ''),
            const SizedBox(height: 4),
            _info(Icons.calendar_today, dateStr),
            if (hasFile) ...[
              const SizedBox(height: 4),
              _info(Icons.attach_file, 'Script / File attached'),
            ],
            if ((data['description'] ?? '').toString().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                data['description'],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: const Color(0xFF16213e),
                    title: const Text(
                      'Delete Audition',
                      style: TextStyle(color: Colors.white),
                    ),
                    content: const Text(
                      'Are you sure you want to delete this audition?',
                      style: TextStyle(color: Colors.white70),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _delete(context);
                        },
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    ],
                  ),
                ),
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                  size: 18,
                ),
                label: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.redAccent, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _info(IconData icon, String text) => Row(
    children: [
      Icon(icon, color: Colors.orange, size: 14),
      const SizedBox(width: 6),
      Expanded(
        child: Text(
          text,
          style: const TextStyle(color: Colors.white60, fontSize: 13),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}

// ── Applicants Tab ─────────────────────────────────────────────────────────────

class ApplicantsTab extends StatelessWidget {
  const ApplicantsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final directorUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return StreamBuilder<QuerySnapshot>(
      // orderBy removed — sorting done client-side to avoid composite index requirement
      stream: _db
          .collection('applications')
          .where('director_uid', isEqualTo: directorUid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.orange),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.redAccent),
            ),
          );
        }

        // Client-side sort by applied_at descending
        final docs = [...(snapshot.data?.docs ?? [])]
          ..sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aTs = aData['applied_at'];
            final bTs = bData['applied_at'];
            if (aTs == null && bTs == null) return 0;
            if (aTs == null) return 1;
            if (bTs == null) return -1;
            return (bTs as Timestamp).compareTo(aTs as Timestamp);
          });

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 70,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No applications yet',
                  style: TextStyle(color: Colors.white54, fontSize: 16),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Actors who apply will appear here',
                  style: TextStyle(color: Colors.white30, fontSize: 13),
                ),
              ],
            ),
          );
        }

        // Group applications by audition title
        final Map<String, List<QueryDocumentSnapshot>> grouped = {};
        for (final doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final title = (data['audition_title'] ?? 'Untitled').toString();
          grouped.putIfAbsent(title, () => []).add(doc);
        }

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          children: [
            // Summary banner
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0x33FF8C00), Color(0x1AFF4500)],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0x55FF8C00)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.bar_chart, color: Colors.orange, size: 22),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${docs.length} Total Application${docs.length == 1 ? '' : 's'}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Across ${grouped.length} audition${grouped.length == 1 ? '' : 's'}',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Grouped sections
            ...grouped.entries.map((entry) => _AuditionApplicantsSection(
                  auditionTitle: entry.key,
                  applicationDocs: entry.value,
                )),
          ],
        );
      },
    );
  }
}

// ── Audition Applicants Section ───────────────────────────────────────────────

class _AuditionApplicantsSection extends StatefulWidget {
  final String auditionTitle;
  final List<QueryDocumentSnapshot> applicationDocs;

  const _AuditionApplicantsSection({
    required this.auditionTitle,
    required this.applicationDocs,
  });

  @override
  State<_AuditionApplicantsSection> createState() =>
      _AuditionApplicantsSectionState();
}

class _AuditionApplicantsSectionState
    extends State<_AuditionApplicantsSection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0x10FFFFFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          // Section header
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0x22FF8C00), Color(0x11FF4500)],
                ),
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(18),
                  bottom:
                      _expanded ? Radius.zero : const Radius.circular(18),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.movie_creation_outlined,
                    color: Colors.orange,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.auditionTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0x33FF8C00),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${widget.applicationDocs.length}',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.white54,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          // Applicant cards
          if (_expanded)
            ...widget.applicationDocs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return _ApplicantCard(docId: doc.id, data: data);
            }),
        ],
      ),
    );
  }
}

// ── Applicant Card ────────────────────────────────────────────────────────────

class _ApplicantCard extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> data;

  const _ApplicantCard({required this.docId, required this.data});

  Color _statusColor(String status) {
    switch (status) {
      case 'shortlisted':
        return const Color(0xFF34D399);
      case 'accepted':
        return const Color(0xFF60A5FA);
      case 'rejected':
        return Colors.redAccent;
      default:
        return Colors.orange;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'shortlisted':
        return Icons.star_rounded;
      case 'accepted':
        return Icons.check_circle_rounded;
      case 'rejected':
        return Icons.cancel_outlined;
      default:
        return Icons.hourglass_empty_rounded;
    }
  }

  Future<void> _updateStatus(BuildContext context, String newStatus, String auditionTitle) async {
    try {
      await _db
          .collection('applications')
          .doc(docId)
          .update({'status': newStatus});



      if (context.mounted) {
        EmailService.sendStatusNotification(toEmail: data['actor_email'], auditionTitle: auditionTitle, newStatus: newStatus, toName: data['actor_name'] ?? 'Actor');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status updated to $newStatus'),
            backgroundColor: _statusColor(newStatus),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }


    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Update failed: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _showStatusMenu(BuildContext context) {
    final currentStatus = (data['status'] ?? 'pending').toString();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF16213e),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(color: Color(0x55FF8C00), width: 1),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Update Application Status',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              data['actor_email'] ?? '',
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 20),
            for (final status in ['pending', 'shortlisted', 'accepted', 'rejected'])
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  if (status != currentStatus) {
                    _updateStatus(context, status, data['audition_title']);
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: currentStatus == status
                        ? _statusColor(status).withValues(alpha: 0.15)
                        : const Color(0x10FFFFFF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: currentStatus == status
                          ? _statusColor(status)
                          : Colors.white12,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _statusIcon(status),
                        color: _statusColor(status),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        status[0].toUpperCase() + status.substring(1),
                        style: TextStyle(
                          color: _statusColor(status),
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const Spacer(),
                      if (currentStatus == status)
                        Icon(
                          Icons.check_circle,
                          color: _statusColor(status),
                          size: 18,
                        ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = (data['status'] ?? 'pending').toString();
    final email = data['actor_email'] ?? 'Unknown';
    final appliedAt = data['applied_at'];
    String appliedDateStr = '';
    if (appliedAt is Timestamp) {
      final d = appliedAt.toDate();
      appliedDateStr =
          '${d.day}/${d.month}/${d.year}  ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    }

    final initial = email.isNotEmpty ? email[0].toUpperCase() : '?';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          // Avatar – tap to view profile
          GestureDetector(
            onTap: () => _showActorProfile(context),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _statusColor(status).withValues(alpha: 0.8),
                    _statusColor(status).withValues(alpha: 0.4),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  email,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (appliedDateStr.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    'Applied: $appliedDateStr',
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),

          // View Profile button
          GestureDetector(
            onTap: () => _showActorProfile(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0x22FF8C00),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0x55FF8C00)),
              ),
              child: const Icon(
                Icons.person_search_rounded,
                color: Colors.orange,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Status chip + tap to change
          GestureDetector(
            onTap: () => _showStatusMenu(context),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _statusColor(status).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: _statusColor(status).withValues(alpha: 0.6)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _statusIcon(status),
                    color: _statusColor(status),
                    size: 13,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    status[0].toUpperCase() + status.substring(1),
                    style: TextStyle(
                      color: _statusColor(status),
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_drop_down,
                    color: _statusColor(status),
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showActorProfile(BuildContext context) {
    final actorUid = data['actor_uid'] ?? '';
    final actorEmail = data['actor_email'] ?? 'Unknown';
    if (actorUid.isEmpty) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ActorProfileViewSheet(
        uid: actorUid,
        email: actorEmail,
      ),
    );
  }
}

// ── Director Profile Tab ──────────────────────────────────────────────────────

class DirectorProfileTab extends StatelessWidget {
  const DirectorProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.email?.split('@').first ?? 'Director';
    final initial = name.substring(0, 1).toUpperCase();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          // ── Profile hero ─────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0x44FF8C00), Color(0x44FF4500)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0x44FF8C00)),
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.orange, Colors.deepOrange],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x66FF8C00),
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                // Live audition stats
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('auditions')
                      .where('director_uid', isEqualTo: user?.uid ?? '')
                      .snapshots(),
                  builder: (_, snap) {
                    final total = snap.data?.docs.length ?? 0;
                    final active = snap.data?.docs
                            .where((d) => (d['status'] ?? '') == 'active')
                            .length ??
                        0;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _DirStatChip(label: 'Total', value: '$total'),
                        Container(width: 1, height: 30, color: Colors.white12),
                        _DirStatChip(label: 'Active', value: '$active'),
                        Container(width: 1, height: 30, color: Colors.white12),
                        _DirStatChip(label: 'Closed', value: '${total - active}'),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Info tiles ───────────────────────────────────────────
          _DirInfoCard(
            icon: Icons.verified_outlined,
            title: 'Account Status',
            value: 'Casting Director',
            color: Colors.orange,
          ),
          const SizedBox(height: 10),
          _DirInfoCard(
            icon: Icons.email_outlined,
            title: 'Email',
            value: user?.email ?? 'N/A',
            color: Colors.orangeAccent,
          ),
          const SizedBox(height: 10),
          _DirInfoCard(
            icon: Icons.badge_outlined,
            title: 'User ID',
            value: (user?.uid ?? 'N/A').substring(0, 12),
            color: const Color(0xFFFBBF24),
          ),

          const SizedBox(height: 28),

          // ── Edit Profile ─────────────────────────────────────────
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) =>
                    _EditDirectorProfileSheet(uid: user?.uid ?? ''),
              );
            },
            child: Container(
              height: 52,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.orange, Colors.deepOrange],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x55FF8C00),
                    blurRadius: 14,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit_outlined, color: Colors.white, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Edit Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Logout ───────────────────────────────────────────────
          GestureDetector(
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/home',
                  (route) => false,
                );
              }
            },
            child: Container(
              height: 52,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0x26FF4444),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0x66FF4444)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, color: Colors.redAccent, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Sign Out',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _DirStatChip extends StatelessWidget {
  final String label;
  final String value;
  const _DirStatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _DirInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _DirInfoCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0x0FFFFFFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Edit Director Profile Bottom Sheet ───────────────────────────────────────

class _EditDirectorProfileSheet extends StatefulWidget {
  final String uid;
  const _EditDirectorProfileSheet({required this.uid});

  @override
  State<_EditDirectorProfileSheet> createState() =>
      _EditDirectorProfileSheetState();
}

class _EditDirectorProfileSheetState
    extends State<_EditDirectorProfileSheet> {
  final _nameCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final doc = await _db.collection('users').doc(widget.uid).get();
      final data = doc.data() ?? {};
      _nameCtrl.text = data['displayName'] ?? '';
      _companyCtrl.text = data['company'] ?? '';
      _cityCtrl.text = data['city'] ?? '';
      _bioCtrl.text = data['bio'] ?? '';
      _expCtrl.text = data['experience']?.toString() ?? '';
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await _db.collection('users').doc(widget.uid).set({
        'displayName': _nameCtrl.text.trim(),
        'company': _companyCtrl.text.trim(),
        'city': _cityCtrl.text.trim(),
        'bio': _bioCtrl.text.trim(),
        'experience': int.tryParse(_expCtrl.text.trim()) ?? 0,
        'role': 'casting_director',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated! ✅'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _companyCtrl.dispose();
    _cityCtrl.dispose();
    _bioCtrl.dispose();
    _expCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF16213e),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(
            top: BorderSide(color: Color(0x55FF8C00), width: 1.5),
          ),
        ),
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.orange))
            : ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.orange, Colors.deepOrange],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.edit_outlined,
                            color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 14),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'EDIT PROFILE',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                            ),
                          ),
                          Text(
                            'Update your director profile',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  _dirField(
                    controller: _nameCtrl,
                    label: 'Display Name',
                    hint: 'e.g. Karan Johar',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 14),
                  _dirField(
                    controller: _companyCtrl,
                    label: 'Production Company',
                    hint: 'e.g. Dharma Productions',
                    icon: Icons.business_outlined,
                  ),
                  const SizedBox(height: 14),
                  _dirField(
                    controller: _cityCtrl,
                    label: 'City / Location',
                    hint: 'e.g. Mumbai',
                    icon: Icons.location_city_outlined,
                  ),
                  const SizedBox(height: 14),
                  _dirField(
                    controller: _expCtrl,
                    label: 'Years of Experience',
                    hint: 'e.g. 10',
                    icon: Icons.workspace_premium_outlined,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 14),
                  _dirField(
                    controller: _bioCtrl,
                    label: 'Bio / About',
                    hint: 'Tell actors about your work...',
                    icon: Icons.notes_rounded,
                    maxLines: 4,
                  ),

                  const SizedBox(height: 28),

                  // Save button
                  GestureDetector(
                    onTap: _saving ? null : _save,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _saving
                              ? [Colors.grey.shade700, Colors.grey.shade600]
                              : [Colors.orange, Colors.deepOrange],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: _saving
                            ? []
                            : const [
                                BoxShadow(
                                  color: Color(0x55FF8C00),
                                  blurRadius: 16,
                                  offset: Offset(0, 6),
                                ),
                              ],
                      ),
                      child: Center(
                        child: _saving
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.save_outlined,
                                      color: Colors.white, size: 20),
                                  SizedBox(width: 10),
                                  Text(
                                    'Save Changes',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _dirField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
            prefixIcon: Icon(icon, color: Colors.orange, size: 20),
            filled: true,
            fillColor: const Color(0x10FFFFFF),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.white12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.white12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.orange, width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}

// ── Actor Profile View Sheet (for Casting Director) ───────────────────────────

class _ActorProfileViewSheet extends StatefulWidget {
  final String uid;
  final String email;
  const _ActorProfileViewSheet({required this.uid, required this.email});

  @override
  State<_ActorProfileViewSheet> createState() => _ActorProfileViewSheetState();
}

class _ActorProfileViewSheetState extends State<_ActorProfileViewSheet> {
  Map<String, dynamic>? _profile;
  int _totalApplications = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final profileDoc =
          await _db.collection('users').doc(widget.uid).get();
      final appsSnap = await _db
          .collection('applications')
          .where('actor_uid', isEqualTo: widget.uid)
          .get();
      if (mounted) {
        setState(() {
          _profile = profileDoc.data();
          _totalApplications = appsSnap.docs.length;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _profile?['displayName']?.toString().isNotEmpty == true
        ? _profile!['displayName'].toString()
        : widget.email.split('@').first;
    final initial = name[0].toUpperCase();

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF16213e),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(
            top: BorderSide(color: Color(0x55FF8C00), width: 1.5),
          ),
        ),
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.orange))
            : ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Avatar + name hero
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0x33FF8C00), Color(0x1AFF4500)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0x44FF8C00)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.orange, Colors.deepOrange],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x55FF8C00),
                                blurRadius: 16,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              initial,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.email,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Stats row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _profileStat(
                                label: 'Auditions Applied',
                                value: '$_totalApplications'),
                            Container(
                                width: 1,
                                height: 28,
                                color: Colors.white12),
                            _profileStat(
                                label: 'Age',
                                value: _profile?['age'] != null &&
                                        _profile!['age'] != 0
                                    ? '${_profile!['age']}'
                                    : '—'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Detail rows
                  if ((_profile?['city'] ?? '').toString().isNotEmpty)
                    _profileRow(
                        icon: Icons.location_city_outlined,
                        label: 'City',
                        value: _profile!['city'].toString()),

                  if ((_profile?['skills'] ?? '').toString().isNotEmpty)
                    _profileRow(
                        icon: Icons.star_outline_rounded,
                        label: 'Skills',
                        value: _profile!['skills'].toString()),

                  if ((_profile?['bio'] ?? '').toString().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0x10FFFFFF),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'BIO',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _profile!['bio'].toString(),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              height: 1.55,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  if (_profile == null ||
                      (_profile!['displayName'] ?? '').toString().isEmpty &&
                          (_profile!['bio'] ?? '').toString().isEmpty &&
                          (_profile!['skills'] ?? '').toString().isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Column(
                          children: [
                            Icon(Icons.person_off_outlined,
                                size: 48,
                                color: Colors.white.withValues(alpha: 0.15)),
                            const SizedBox(height: 12),
                            const Text(
                              'Actor hasn\'t filled their profile yet',
                              style: TextStyle(
                                  color: Colors.white38, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _profileStat({required String label, required String value}) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Colors.white38, fontSize: 11),
        ),
      ],
    );
  }

  Widget _profileRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0x0FFFFFFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0x33FF8C00),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.orange, size: 16),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                      color: Colors.white38, fontSize: 11),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
