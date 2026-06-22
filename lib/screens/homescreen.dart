import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Background gradient ────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0D0D0D),
                  Color(0xFF1a0533),
                  Color(0xFF2d1b00),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // ── Decorative blurred circles ─────────────────────────────
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0x55FF8C00), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            left: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0x446A0DAD), Colors.transparent],
                ),
              ),
            ),
          ),

          // ── Main content ───────────────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      const SizedBox(height: 50),

                      // Film reel icon badge
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Colors.orange, Colors.deepOrange],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x66FF8C00),
                              blurRadius: 28,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.movie_creation_rounded,
                          color: Colors.white,
                          size: 44,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // App name
                      const Text(
                        'CineAudition',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Tagline
                      const Text(
                        'Where Talent Meets Opportunity',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 15,
                          letterSpacing: 0.4,
                        ),
                      ),

                      const SizedBox(height: 50),

                      // ── Feature cards row ──────────────────────────
                      Row(
                        children: [
                          _featureCard(
                            Icons.people_alt_rounded,
                            'For Actors',
                            'Discover & apply to roles',
                            const Color(0xFF1a0533),
                            Colors.purpleAccent,
                          ),
                          const SizedBox(width: 14),
                          _featureCard(
                            Icons.video_camera_back_rounded,
                            'For Directors',
                            'Publish & manage auditions',
                            const Color(0xFF2d1b00),
                            Colors.orange,
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // ── Stats strip ────────────────────────────────
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 18, horizontal: 20),
                        decoration: BoxDecoration(
                          color: const Color(0x12FFFFFF),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _StatItem('500+', 'Auditions'),
                            _Divider(),
                            _StatItem('2K+', 'Actors'),
                            _Divider(),
                            _StatItem('120+', 'Directors'),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // ── Action Buttons ────────────────────────────
                      _primaryButton(
                        label: 'Login',
                        icon: Icons.login_rounded,
                        onTap: () => Navigator.pushNamed(context, '/login'),
                      ),

                      const SizedBox(height: 14),

                      _outlineButton(
                        label: 'Create Account',
                        icon: Icons.person_add_alt_1_rounded,
                        onTap: () => Navigator.pushNamed(context, '/signup'),
                      ),

                      const SizedBox(height: 22),

                      // ── Role quick-jump ───────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: _roleChip(
                              label: 'I\'m an Actor',
                              icon: Icons.person,
                              onTap: () =>
                                  Navigator.pushNamed(context, '/login'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _roleChip(
                              label: 'I\'m a Director',
                              icon: Icons.video_camera_back,
                              onTap: () =>
                                  Navigator.pushNamed(context, '/login'),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 36),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _featureCard(IconData icon, String title, String sub,
      Color bg, Color accent) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accent.withValues(alpha: 0.25)),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.12),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: accent, size: 22),
            ),
            const SizedBox(height: 12),
            Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
            const SizedBox(height: 4),
            Text(sub,
                style: const TextStyle(color: Colors.white38, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _primaryButton(
      {required String label,
      required IconData icon,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Colors.orange, Colors.deepOrange]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x55FF8C00),
              blurRadius: 18,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 0.4)),
          ],
        ),
      ),
    );
  }

  Widget _outlineButton(
      {required String label,
      required IconData icon,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.orange, width: 1.6),
          borderRadius: BorderRadius.circular(16),
          color: Colors.orange.withValues(alpha: 0.07),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.orange, size: 20),
            const SizedBox(width: 10),
            Text(label,
                style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 0.4)),
          ],
        ),
      ),
    );
  }

  Widget _roleChip(
      {required String label,
      required IconData icon,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0x12FFFFFF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white54, size: 16),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// ── Stat widgets ──────────────────────────────────────────────────────────────

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.w900,
                fontSize: 20)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(color: Colors.white38, fontSize: 12)),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 36, color: Colors.white10);
  }
}
