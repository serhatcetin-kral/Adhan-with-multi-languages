import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DuaScreen extends StatefulWidget {
  const DuaScreen({super.key});

  @override
  State<DuaScreen> createState() => _DuaScreenState();
}

class _DuaScreenState extends State<DuaScreen> {
  List allDuas = [];
  List filteredDuas = [];
  bool isLoading = true;
  String searchText = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadDuas();
  }

  Future<void> loadDuas() async {
    final locale = Localizations.localeOf(context).languageCode;

    try {
      final data =
      await rootBundle.loadString('assets/duas/duas_$locale.json');

      setState(() {
        allDuas = json.decode(data);
        filteredDuas = allDuas;
        isLoading = false;
      });
    } catch (e) {
      // 🔁 fallback to English
      final data =
      await rootBundle.loadString('assets/duas/duas_en.json');

      setState(() {
        allDuas = json.decode(data);
        filteredDuas = allDuas;
        isLoading = false;
      });
    }
  }

  void filterDuas(String query) {
    final lowerQuery = query.toLowerCase();

    setState(() {
      searchText = query;
      filteredDuas = allDuas.where((dua) {
        final title = dua['title'].toLowerCase();
        final translation = dua['translation'].toLowerCase();

        return title.contains(lowerQuery) ||
            translation.contains(lowerQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Duas"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [

          // 🔍 SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: filterDuas,
              decoration: InputDecoration(
                hintText: "Search dua...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          // 📜 LIST
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: filteredDuas.length,
              itemBuilder: (context, index) {
                final dua = filteredDuas[index];

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // 🟦 TITLE
                        Text(
                          dua['title'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.start,
                        ),

                        const SizedBox(height: 12),

                        // 🟩 ARABIC
                        Text(
                          dua['arabic'],
                          style: const TextStyle(
                            fontSize: 20,
                            height: 1.6,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 12),

                        // 🟨 TRANSLATION
                        Text(
                          dua['translation'],
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: Colors.grey[700],
                          ),
                          textAlign: isRTL
                              ? TextAlign.right
                              : TextAlign.left,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}