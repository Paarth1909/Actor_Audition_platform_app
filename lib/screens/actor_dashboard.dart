import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// ── Firestore reference ────────────────────────────────────────────────────────
final _db = FirebaseFirestore.instance;

// ─────────────────────────────────────────────────────────────────────────────
// Actor Dashboard – root shell with bottom nav
// ─────────────────────────────────────────────────────────────────────────────

class ActorDashboard extends StatefulWidget {
  const ActorDashboard({super.key});

  @override
  State<ActorDashboard> createState() => _ActorDashboardState();
}

class _ActorDashboardState extends State<ActorDashboard>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  // Keep pages alive so streams don't re-subscribe on tab switch
  final List<Widget> _pages = const [
    _BrowseAuditionsTab(),
    _MyApplicationsTab(),
    _ActorProfileTab(),
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeInOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _onTabTap(int index) {
    if (_currentIndex == index) return;
    _fadeCtrl.reset();
    setState(() => _currentIndex = index);
    _fadeCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D0D1A), Color(0xFF12122B), Color(0xFF1A1040)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    // Avatar circle
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7C3AED), Color(0xFFDB2777)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          (user?.email?.substring(0, 1) ?? 'A').toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ACTOR PORTAL',
                            style: TextStyle(
                              color: Color(0xFFA78BFA),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                            ),
                          ),
                          Text(
                            user?.email?.split('@').first ?? 'Actor',
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
                    // Logout button
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

              const SizedBox(height: 20),

              // ── Tab navigation pills ─────────────────────────────────
              _TabPills(currentIndex: _currentIndex, onTap: _onTabTap),

              const SizedBox(height: 16),

              // ── Page body ────────────────────────────────────────────
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: IndexedStack(
                    index: _currentIndex,
                    children: _pages,
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

// ─────────────────────────────────────────────────────────────────────────────
// Tab Pills
// ─────────────────────────────────────────────────────────────────────────────

class _TabPills extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const _TabPills({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const tabs = [
      (icon: Icons.search_rounded, label: 'Browse'),
      (icon: Icons.assignment_outlined, label: 'Applied'),
      (icon: Icons.person_outline_rounded, label: 'Profile'),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0x12FFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final isSelected = i == currentIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFF7C3AED), Color(0xFFDB2777)],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                          const BoxShadow(
                            color: Color(0x447C3AED),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          )
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      tabs[i].icon,
                      size: 16,
                      color: isSelected ? Colors.white : Colors.white38,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      tabs[i].label,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white38,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 1 – Browse Auditions
// ─────────────────────────────────────────────────────────────────────────────

class _BrowseAuditionsTab extends StatefulWidget {
  const _BrowseAuditionsTab();

  @override
  State<_BrowseAuditionsTab> createState() => _BrowseAuditionsTabState();
}

class _BrowseAuditionsTabState extends State<_BrowseAuditionsTab> {
  String _searchQuery = '';
  String _selectedType = 'All';
  final _searchCtrl = TextEditingController();

  final List<String> _types = [
    'All',
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
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Search bar ───────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0x12FFFFFF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white10),
            ),
            child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search auditions, roles, locations...',
                hintStyle:
                    const TextStyle(color: Colors.white30, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Color(0xFFA78BFA)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                        child: const Icon(Icons.clear, color: Colors.white38),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // ── Filter chips ─────────────────────────────────────────────
        SizedBox(
          height: 36,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: _types.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final isActive = _selectedType == _types[i];
              return GestureDetector(
                onTap: () => setState(() => _selectedType = _types[i]),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: isActive
                        ? const LinearGradient(
                            colors: [Color(0xFF7C3AED), Color(0xFFDB2777)],
                          )
                        : null,
                    color: isActive ? null : const Color(0x12FFFFFF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          isActive ? Colors.transparent : Colors.white12,
                    ),
                  ),
                  child: Text(
                    _types[i],
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.white54,
                      fontWeight: isActive
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        // ── Auditions stream ─────────────────────────────────────────
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            // orderBy removed — sorting client-side to avoid composite index requirement
            stream: _db
                .collection('auditions')
                .where('status', isEqualTo: 'active')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF7C3AED),
                  ),
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
              var docs = [...(snapshot.data?.docs ?? [])]
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

              // Client-side filter
              docs = docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final title =
                    (data['title'] ?? '').toString().toLowerCase();
                final location =
                    (data['location'] ?? '').toString().toLowerCase();
                final desc =
                    (data['description'] ?? '').toString().toLowerCase();
                final type = data['project_type'] ?? '';

                final matchesSearch = _searchQuery.isEmpty ||
                    title.contains(_searchQuery) ||
                    location.contains(_searchQuery) ||
                    desc.contains(_searchQuery);

                final matchesType =
                    _selectedType == 'All' || type == _selectedType;

                return matchesSearch && matchesType;
              }).toList();

              if (docs.isEmpty) {
                return _emptyState(
                  icon: Icons.search_off_rounded,
                  title: 'No auditions found',
                  subtitle: 'Try a different search or filter',
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 4),
                itemCount: docs.length,
                itemBuilder: (ctx, i) {
                  final doc = docs[i];
                  final data = doc.data() as Map<String, dynamic>;
                  return _AuditionCard(
                    docId: doc.id,
                    data: data,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Audition Card (browse)
// ─────────────────────────────────────────────────────────────────────────────

class _AuditionCard extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> data;

  const _AuditionCard({required this.docId, required this.data});

  @override
  Widget build(BuildContext context) {
    final ts = data['audition_date'];
    String dateStr = 'TBA';
    if (ts is Timestamp) {
      final d = ts.toDate();
      dateStr = '${d.day}/${d.month}/${d.year}';
    }

    final type = data['project_type'] ?? 'Project';
    final hasFile = (data['file_url'] ?? '').toString().isNotEmpty;

    return GestureDetector(
      onTap: () => _showDetails(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: const Color(0x0FFFFFFF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Card header band ────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0x337C3AED), Color(0x33DB2777)],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  _TypeBadge(type: type),
                  const Spacer(),
                   if (hasFile)
                    const Icon(
                      Icons.attach_file,
                      color: Color(0xFFA78BFA),
                      size: 16,
                    ),
                  const SizedBox(width: 6),
                  // View Director button
                  GestureDetector(
                    onTap: () => _showDirectorProfile(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0x227C3AED),
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: const Color(0x557C3AED)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.person_search_rounded,
                              color: Color(0xFFA78BFA), size: 13),
                          SizedBox(width: 4),
                          Text(
                            'Director',
                            style: TextStyle(
                              color: Color(0xFFA78BFA),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.circle,
                    color: Color(0xFF34D399),
                    size: 8,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Active',
                    style: TextStyle(
                      color: Color(0xFF34D399),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // ── Card body ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['title'] ?? 'Untitled',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    data['description'] ?? '',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    children: [
                      _InfoChip(
                        icon: Icons.location_on_outlined,
                        label: data['location'] ?? 'N/A',
                      ),
                      _InfoChip(
                        icon: Icons.calendar_today_outlined,
                        label: dateStr,
                      ),
                      _InfoChip(
                        icon: Icons.people_outline,
                        label: data['gender'] ?? 'Any',
                      ),
                      if ((data['compensation'] ?? '').isNotEmpty)
                        _InfoChip(
                          icon: Icons.currency_rupee,
                          label: data['compensation'],
                          highlight: true,
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Read Script button (shown ABOVE Apply when file exists)
                  if (hasFile) ...[
                    _ScriptButton(fileUrl: data['file_url'] ?? ''),
                    const SizedBox(height: 10),
                  ],
                  // Apply button
                  _ApplyButton(docId: docId, data: data),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetails(BuildContext context) {
    final ts = data['audition_date'];
    String dateStr = 'TBA';
    if (ts is Timestamp) {
      final d = ts.toDate();
      dateStr = '${d.day}/${d.month}/${d.year}';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AuditionDetailsSheet(
        docId: docId,
        data: data,
        dateStr: dateStr,
      ),
    );
  }

  void _showDirectorProfile(BuildContext context) {
    final directorUid = data['director_uid'] ?? '';
    final directorEmail = data['director_email'] ?? 'Unknown';
    if (directorUid.isEmpty) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DirectorProfileViewSheet(
        uid: directorUid,
        email: directorEmail,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Apply Button (checks applied status from Firestore)
// ─────────────────────────────────────────────────────────────────────────────

class _ApplyButton extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> data;

  const _ApplyButton({required this.docId, required this.data});

  @override
  State<_ApplyButton> createState() => _ApplyButtonState();
}

class _ApplyButtonState extends State<_ApplyButton> {
  bool _loading = false;

  Future<void> _apply() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final email = FirebaseAuth.instance.currentUser?.email;
    if (uid == null) return;

    setState(() => _loading = true);

    try {
      // Check if already applied
      final existing = await _db
          .collection('applications')
          .where('audition_id', isEqualTo: widget.docId)
          .where('actor_uid', isEqualTo: uid)
          .limit(1)
          .get();

      if (!mounted) return;

      if (existing.docs.isNotEmpty) {
        _snack('You have already applied to this audition!',
            error: true);
        return;
      }

      await _db.collection('applications').add({
        'audition_id': widget.docId,
        'actor_uid': uid,
        'actor_email': email ?? '',
        'audition_title': widget.data['title'] ?? '',
        'director_uid': widget.data['director_uid'] ?? '',
        'status': 'pending',
        'applied_at': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      _snack('Application submitted! 🎭');
    } catch (e) {
      if (!mounted) return;
      _snack('Failed: $e', error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? Colors.redAccent : const Color(0xFF7C3AED),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return StreamBuilder<QuerySnapshot>(
      stream: _db
          .collection('applications')
          .where('audition_id', isEqualTo: widget.docId)
          .where('actor_uid', isEqualTo: uid)
          .snapshots(),
      builder: (context, snap) {
        final alreadyApplied =
            (snap.data?.docs ?? []).isNotEmpty;

        return GestureDetector(
          onTap: (alreadyApplied || _loading) ? null : _apply,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: 44,
            decoration: BoxDecoration(
              gradient: alreadyApplied
                  ? const LinearGradient(
                      colors: [Color(0xFF34D399), Color(0xFF059669)])
                  : const LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFFDB2777)]),
              borderRadius: BorderRadius.circular(12),
              boxShadow: alreadyApplied
                  ? []
                  : const [
                      BoxShadow(
                        color: Color(0x557C3AED),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
            ),
            child: Center(
              child: _loading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          alreadyApplied
                              ? Icons.check_circle_outline
                              : Icons.send_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          alreadyApplied
                              ? 'Applied ✓'
                              : 'Apply Now',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Audition Detail Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _AuditionDetailsSheet extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> data;
  final String dateStr;

  const _AuditionDetailsSheet({
    required this.docId,
    required this.data,
    required this.dateStr,
  });

  @override
  Widget build(BuildContext context) {
    final hasFile = (data['file_url'] ?? '').toString().isNotEmpty;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF12122B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(color: Color(0x337C3AED), width: 1),
          ),
        ),
        child: ListView(
          controller: controller,
          padding: const EdgeInsets.all(24),
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

            _TypeBadge(type: data['project_type'] ?? 'Project'),
            const SizedBox(height: 12),

            Text(
              data['title'] ?? 'Untitled',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () {
                final directorUid = data['director_uid'] ?? '';
                final directorEmail = data['director_email'] ?? 'Unknown';
                if (directorUid.isEmpty) return;
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => _DirectorProfileViewSheet(
                    uid: directorUid,
                    email: directorEmail,
                  ),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Posted by ${data['director_email']?.split('@').first ?? 'Director'}',
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0x227C3AED),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: const Color(0x447C3AED)),
                    ),
                    child: const Text(
                      'View Profile',
                      style: TextStyle(
                        color: Color(0xFFA78BFA),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            _sectionTitle('Description'),
            _sectionBody(data['description'] ?? '—'),

            if ((data['requirements'] ?? '').isNotEmpty) ...[
              const SizedBox(height: 16),
              _sectionTitle('Requirements & Skills'),
              _sectionBody(data['requirements']),
            ],

            const SizedBox(height: 20),
            // Detail chips grid
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _DetailTile(
                    icon: Icons.location_on,
                    label: 'Location',
                    value: data['location'] ?? 'N/A'),
                _DetailTile(
                    icon: Icons.calendar_today,
                    label: 'Audition Date',
                    value: dateStr),
                _DetailTile(
                    icon: Icons.people,
                    label: 'Gender',
                    value: data['gender'] ?? 'Any'),
                if ((data['compensation'] ?? '').isNotEmpty)
                  _DetailTile(
                      icon: Icons.currency_rupee,
                      label: 'Compensation',
                      value: data['compensation'],
                      highlight: true),
              ],
            ),

            // ── Script / Audition Sheet section ────────────────────
            if (hasFile) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0x1A7C3AED),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0x447C3AED)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.description_rounded,
                          color: Color(0xFFA78BFA),
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Script / Audition Sheet',
                          style: TextStyle(
                            color: Color(0xFFA78BFA),
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'The casting director has attached a script or audition sheet for this role.',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _ScriptButton(fileUrl: data['file_url'] ?? ''),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 28),
            _ApplyButton(docId: docId, data: data),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) => Text(
        t,
        style: const TextStyle(
          color: Color(0xFFA78BFA),
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      );

  Widget _sectionBody(String t) => Text(
        t,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
          height: 1.5,
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 2 – My Applications
// ─────────────────────────────────────────────────────────────────────────────

class _MyApplicationsTab extends StatelessWidget {
  const _MyApplicationsTab();

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return StreamBuilder<QuerySnapshot>(
      // orderBy removed — sorting client-side to avoid composite index requirement
      stream: _db
          .collection('applications')
          .where('actor_uid', isEqualTo: uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF7C3AED)),
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
          return _emptyState(
            icon: Icons.assignment_outlined,
            title: 'No applications yet',
            subtitle: 'Browse auditions and apply to get started',
          );
        }

        return ListView.builder(
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          itemCount: docs.length,
          itemBuilder: (_, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            return _ApplicationCard(data: data);
          },
        );
      },
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const _ApplicationCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final status = (data['status'] ?? 'pending') as String;
    final ts = data['applied_at'];
    String dateStr = '';
    if (ts is Timestamp) {
      final d = ts.toDate();
      dateStr = '${d.day}/${d.month}/${d.year}';
    }

    final statusColor = switch (status) {
      'shortlisted' => const Color(0xFF34D399),
      'accepted' => const Color(0xFF60A5FA),
      'rejected' => Colors.redAccent,
      _ => const Color(0xFFFBBF24),
    };

    final statusIcon = switch (status) {
      'shortlisted' => Icons.star_rounded,
      'accepted' => Icons.check_circle_rounded,
      'rejected' => Icons.cancel_outlined,
      _ => Icons.hourglass_empty_rounded,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x0FFFFFFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          // Status indicator bar
          Container(
            width: 4,
            height: 60,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['audition_title'] ?? 'Untitled Audition',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  dateStr.isNotEmpty
                      ? 'Applied on $dateStr'
                      : 'Applied recently',
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: statusColor.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, size: 13, color: statusColor),
                const SizedBox(width: 4),
                Text(
                  status[0].toUpperCase() + status.substring(1),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
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

// ─────────────────────────────────────────────────────────────────────────────
// Tab 3 – Actor Profile
// ─────────────────────────────────────────────────────────────────────────────

class _ActorProfileTab extends StatelessWidget {
  const _ActorProfileTab();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.email?.split('@').first ?? 'Actor';
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
                colors: [Color(0x447C3AED), Color(0x44DB2777)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0x337C3AED)),
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFFDB2777)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x667C3AED),
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
                // Stats row from Firestore
                _ProfileStatsRow(uid: user?.uid ?? ''),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Info tiles ───────────────────────────────────────────
          _ProfileInfoCard(
            icon: Icons.verified_user_outlined,
            title: 'Account Status',
            value: 'Active Actor',
            color: const Color(0xFF34D399),
          ),
          const SizedBox(height: 10),
          _ProfileInfoCard(
            icon: Icons.email_outlined,
            title: 'Email',
            value: user?.email ?? 'N/A',
            color: const Color(0xFFA78BFA),
          ),
          const SizedBox(height: 10),
          _ProfileInfoCard(
            icon: Icons.badge_outlined,
            title: 'User ID',
            value: user?.uid.substring(0, 12) ?? 'N/A',
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
                builder: (_) => _EditActorProfileSheet(uid: user?.uid ?? ''),
              );
            },
            child: Container(
              height: 52,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFFDB2777)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x447C3AED),
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

// ─────────────────────────────────────────────────────────────────────────────
// Profile Stats Row (live counts from Firestore)
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileStatsRow extends StatelessWidget {
  final String uid;
  const _ProfileStatsRow({required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _db
          .collection('applications')
          .where('actor_uid', isEqualTo: uid)
          .snapshots(),
      builder: (_, snap) {
        final docs = snap.data?.docs ?? [];
        final total = docs.length;
        final pending =
            docs.where((d) => (d['status'] ?? '') == 'pending').length;
        final accepted =
            docs.where((d) => (d['status'] ?? '') == 'accepted').length;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _StatChip(label: 'Applied', value: '$total'),
            Container(width: 1, height: 30, color: Colors.white12),
            _StatChip(label: 'Pending', value: '$pending'),
            Container(width: 1, height: 30, color: Colors.white12),
            _StatChip(label: 'Accepted', value: '$accepted'),
          ],
        );
      },
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  const _StatChip({required this.label, required this.value});

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

class _ProfileInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _ProfileInfoCard({
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

// ─────────────────────────────────────────────────────────────────────────────
// Script / File Button
// ─────────────────────────────────────────────────────────────────────────────

class _ScriptButton extends StatelessWidget {
  final String fileUrl;
  const _ScriptButton({required this.fileUrl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final url = Uri.tryParse(fileUrl);
        if (url != null && url.hasAbsolutePath && await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open the file. Try again later.'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7C3AED), Color(0xFFDB2777)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x557C3AED),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.description_rounded, color: Colors.white, size: 17),
              SizedBox(width: 8),
              Text(
                'View Script / Audition Sheet',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              SizedBox(width: 6),
              Icon(Icons.open_in_new, color: Colors.white70, size: 13),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared small widgets
// ─────────────────────────────────────────────────────────────────────────────

class _TypeBadge extends StatelessWidget {
  final String type;
  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0x337C3AED),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x667C3AED)),
      ),
      child: Text(
        type,
        style: const TextStyle(
          color: Color(0xFFA78BFA),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool highlight;

  const _InfoChip({
    required this.icon,
    required this.label,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 13,
          color: highlight ? const Color(0xFF34D399) : Colors.white38,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: highlight ? const Color(0xFF34D399) : Colors.white38,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _DetailTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool highlight;

  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = highlight ? const Color(0xFF34D399) : const Color(0xFFA78BFA);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: color.withValues(alpha: 0.7),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
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

// ─────────────────────────────────────────────────────────────────────────────
// Empty state helper
// ─────────────────────────────────────────────────────────────────────────────

Widget _emptyState({
  required IconData icon,
  required String title,
  required String subtitle,
}) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 70,
          color: Colors.white.withValues(alpha: 0.12),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(color: Colors.white54, fontSize: 16),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(color: Colors.white30, fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Edit Actor Profile Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _EditActorProfileSheet extends StatefulWidget {
  final String uid;
  const _EditActorProfileSheet({required this.uid});

  @override
  State<_EditActorProfileSheet> createState() => _EditActorProfileSheetState();
}

class _EditActorProfileSheetState extends State<_EditActorProfileSheet> {
  final _nameCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _skillsCtrl = TextEditingController();
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
      _cityCtrl.text = data['city'] ?? '';
      _ageCtrl.text = data['age']?.toString() ?? '';
      _bioCtrl.text = data['bio'] ?? '';
      _skillsCtrl.text = data['skills'] ?? '';
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await _db.collection('users').doc(widget.uid).set({
        'displayName': _nameCtrl.text.trim(),
        'city': _cityCtrl.text.trim(),
        'age': int.tryParse(_ageCtrl.text.trim()) ?? 0,
        'bio': _bioCtrl.text.trim(),
        'skills': _skillsCtrl.text.trim(),
        'role': 'actor',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated! ✅'),
            backgroundColor: const Color(0xFF7C3AED),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
    _cityCtrl.dispose();
    _ageCtrl.dispose();
    _bioCtrl.dispose();
    _skillsCtrl.dispose();
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
          color: Color(0xFF12122B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(
            top: BorderSide(color: Color(0x337C3AED), width: 1.5),
          ),
        ),
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF7C3AED)))
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

                  // Title
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF7C3AED), Color(0xFFDB2777)],
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
                              color: Color(0xFFA78BFA),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                            ),
                          ),
                          Text(
                            'Update your actor profile',
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

                  _sheetField(
                    controller: _nameCtrl,
                    label: 'Display Name',
                    hint: 'e.g. Rahul Sharma',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 14),
                  _sheetField(
                    controller: _cityCtrl,
                    label: 'City / Location',
                    hint: 'e.g. Mumbai',
                    icon: Icons.location_city_outlined,
                  ),
                  const SizedBox(height: 14),
                  _sheetField(
                    controller: _ageCtrl,
                    label: 'Age',
                    hint: 'e.g. 24',
                    icon: Icons.cake_outlined,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 14),
                  _sheetField(
                    controller: _skillsCtrl,
                    label: 'Skills',
                    hint: 'e.g. Dancing, Hindi, Martial Arts',
                    icon: Icons.star_outline_rounded,
                  ),
                  const SizedBox(height: 14),
                  _sheetField(
                    controller: _bioCtrl,
                    label: 'Bio',
                    hint: 'Tell casting directors about yourself...',
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
                              : const [Color(0xFF7C3AED), Color(0xFFDB2777)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: _saving
                            ? []
                            : const [
                                BoxShadow(
                                  color: Color(0x557C3AED),
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

  Widget _sheetField({
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
            prefixIcon: Icon(icon, color: const Color(0xFFA78BFA), size: 20),
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
              borderSide:
                  const BorderSide(color: Color(0xFF7C3AED), width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}

// ── Director Profile View Sheet (for Actors) ──────────────────────────────────

class _DirectorProfileViewSheet extends StatefulWidget {
  final String uid;
  final String email;
  const _DirectorProfileViewSheet({required this.uid, required this.email});

  @override
  State<_DirectorProfileViewSheet> createState() =>
      _DirectorProfileViewSheetState();
}

class _DirectorProfileViewSheetState
    extends State<_DirectorProfileViewSheet> {
  Map<String, dynamic>? _profile;
  int _totalAuditions = 0;
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
      final auditionsSnap = await _db
          .collection('auditions')
          .where('director_uid', isEqualTo: widget.uid)
          .get();
      if (mounted) {
        setState(() {
          _profile = profileDoc.data();
          _totalAuditions = auditionsSnap.docs.length;
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
          color: Color(0xFF12122B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(
            top: BorderSide(color: Color(0x337C3AED), width: 1.5),
          ),
        ),
        child: _loading
            ? const Center(
                child:
                    CircularProgressIndicator(color: Color(0xFF7C3AED)))
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
                        colors: [Color(0x337C3AED), Color(0x33DB2777)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: const Color(0x337C3AED)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF7C3AED),
                                Color(0xFFDB2777)
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x557C3AED),
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
                          mainAxisAlignment:
                              MainAxisAlignment.spaceEvenly,
                          children: [
                            _dirStat(
                                label: 'Auditions Posted',
                                value: '$_totalAuditions'),
                            Container(
                                width: 1,
                                height: 28,
                                color: Colors.white12),
                            _dirStat(
                                label: 'Exp (yrs)',
                                value: _profile?['experience'] != null &&
                                        _profile!['experience'] != 0
                                    ? '${_profile!['experience']}'
                                    : '—'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Detail rows
                  if ((_profile?['company'] ?? '').toString().isNotEmpty)
                    _dirRow(
                        icon: Icons.business_outlined,
                        label: 'Production Company',
                        value: _profile!['company'].toString()),

                  if ((_profile?['city'] ?? '').toString().isNotEmpty)
                    _dirRow(
                        icon: Icons.location_city_outlined,
                        label: 'City',
                        value: _profile!['city'].toString()),

                  if ((_profile?['bio'] ?? '').toString().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0x0FFFFFFF),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ABOUT',
                            style: TextStyle(
                              color: Color(0xFFA78BFA),
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
                          (_profile!['company'] ?? '').toString().isEmpty)
                    Center(
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: 24),
                        child: Column(
                          children: [
                            Icon(Icons.person_off_outlined,
                                size: 48,
                                color:
                                    Colors.white.withValues(alpha: 0.15)),
                            const SizedBox(height: 12),
                            const Text(
                              'Director hasn\'t filled their profile yet',
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

  Widget _dirStat({required String label, required String value}) {
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

  Widget _dirRow({
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
              color: const Color(0x227C3AED),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFFA78BFA), size: 16),
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
