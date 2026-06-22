import 'package:actors_audition_platform_app/screens/actor_dashboard.dart';
import 'package:actors_audition_platform_app/screens/casting_director_dashboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String selectedRole = "";
  bool _loading = false;

  Future<void> _selectRole(String role) async {
    setState(() {
      selectedRole = role;
      _loading = true;
    });

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        // Persist the role to Firestore
        await FirebaseFirestore.instance.collection('users').doc(uid).set(
          {'role': role},
          SetOptions(merge: true),
        );
      }

      if (!mounted) return;

      if (role == "Casting Director") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CastingDirectorDashboard()),
        );
      } else if (role == "Actor") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ActorDashboard()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save role: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange, Colors.deepPurple, Colors.black],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  const Text(
                    "Who are you?",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Select your role to continue",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 50),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(50),
                          topRight: Radius.circular(50),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(30),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _roleCard(
                              "Actor",
                              Icons.person,
                              "Browse & apply to auditions",
                            ),
                            const SizedBox(height: 20),
                            _roleCard(
                              "Casting Director",
                              Icons.video_camera_back,
                              "Publish & manage auditions",
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_loading)
            const ColoredBox(
              color: Color(0x80000000),
              child: Center(
                child: CircularProgressIndicator(color: Colors.orange),
              ),
            ),
        ],
      ),
    );
  }

  Widget _roleCard(String role, IconData icon, String subtitle) {
    final bool isSelected = selectedRole == role;

    return GestureDetector(
      onTap: _loading ? null : () => _selectRole(role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(colors: [Colors.orange, Colors.deepOrange])
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.orange, width: 2),
          boxShadow: [
            BoxShadow(
              blurRadius: isSelected ? 16 : 8,
              color: isSelected
                  ? const Color(0x59FF8C00)
                  : const Color(0x1AFF8C00),
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0x33FFFFFF)
                    : const Color(0x1AFF8C00),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon,
                  size: 32,
                  color: isSelected ? Colors.white : Colors.orange),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isSelected ? Colors.white70 : Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 16,
                color: isSelected ? Colors.white70 : Colors.black38),
          ],
        ),
      ),
    );
  }
}
