import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'qibla_screen.dart';

class QiblaSelectionScreen extends StatelessWidget {
  const QiblaSelectionScreen({super.key});

  Future<void> openGoogleQibla(BuildContext context) async {
    final url = Uri.parse('https://qiblafinder.withgoogle.com');

    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cannot open Google Qibla")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Qibla Finder"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [

            const SizedBox(height: 20),

            // 🔹 Welcome text
            const Text(
              "Welcome",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            // 🧭 COMPASS CARD
            buildCard(
              icon: Icons.explore,
              iconColor: Colors.teal,
              text: "Compass Qibla",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const QiblaScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // 🌍 GOOGLE CARD
            buildCard(
              icon: Icons.public,
              iconColor: Colors.blue,
              text: "Google Qibla Finder",
              onTap: () => openGoogleQibla(context),
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 CARD WIDGET
  Widget buildCard({
    required IconData icon,
    required Color iconColor,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 25),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [

            // 🔵 ICON CIRCLE
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 30,
                color: iconColor,
              ),
            ),

            const SizedBox(height: 15),

            // 🔤 TEXT
            Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}