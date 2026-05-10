import 'package:flutter/material.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with SingleTickerProviderStateMixin {
  String selectedRole = "";
  
void selectRole(String role) {
  setState(() {
    selectedRole = role;
  });

  Future.delayed(Duration(milliseconds: 300), () {
    Navigator.pushReplacementNamed(context, '/home');
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange, Colors.purple, Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 80),

            // Title
            const Text(
              "Choose Your Role",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Select how you want to continue",
              style: TextStyle(color: Colors.white70),
            ),

            const SizedBox(height: 50),

            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(60),
                    topRight: Radius.circular(60),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 30),

                    // 🎭 Actor Card
                    buildRoleCard(
                      title: "Actor",
                      icon: Icons.theater_comedy,
                      role: "actor",
                    ),

                    const SizedBox(height: 30),

                    // 🎬 Casting Director Card
                    buildRoleCard(
                      title: "Casting Director",
                      icon: Icons.video_camera_back,
                      role: "casting",
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

  Widget buildRoleCard({
    required String title,
    required IconData icon,
    required String role,
  }) {
    bool isSelected = selectedRole == role;

    return GestureDetector(
      onTap: () => selectRole(role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        transform: Matrix4.identity()
          ..scale(isSelected ? 1.05 : 1.0), // 🔥 scale animation
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepOrange.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.deepOrange : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Colors.deepOrange),
            const SizedBox(width: 20),

            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? Colors.deepOrange : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}