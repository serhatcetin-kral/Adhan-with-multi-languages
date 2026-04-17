import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.support),
        centerTitle: true,
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            children: [

              const SizedBox(height: 10),

              // ❤️ IMAGE
              Image.asset(
                'assets/more/support.png',
                width: 150,
                height: 150,
              ),

              const SizedBox(height: 20),

              // 💬 TEXT
              Text(
                loc.supportMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 30),

              // 💰 BUTTONS
              buildButton("\$0.99"),
              buildButton("\$1.99"),
              buildButton("\$4.99"),

              const Spacer(),

              Text(
                loc.supportNote,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildButton(String price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),

      child: SizedBox(
        width: double.infinity,

        child: ElevatedButton(
          onPressed: () {
            // TODO: connect IAP
          },

          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),

          child: Text(
            "Donate $price",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}