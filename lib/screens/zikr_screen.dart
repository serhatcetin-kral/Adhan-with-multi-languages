import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ZikrScreen extends StatefulWidget {
  const ZikrScreen({super.key});

  @override
  State<ZikrScreen> createState() => _ZikrScreenState();
}

class _ZikrScreenState extends State<ZikrScreen> {

  int _count = 0;
  int _target = 0;
  bool _isCompleted = false;


  Widget _buildProgressBar() {
    final progress =
    _target == 0 ? 0.0 : (_count / _target).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        alignment: Alignment.center,
        children: [

          // 🔳 BACKGROUND
          Container(
            height: 18,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.grey.shade300,
            ),
          ),

          // 🌈 PROGRESS (ANIMATED)
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            height: 18,
            width: MediaQuery.of(context).size.width * progress,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Colors.teal, Colors.green],
              ),
              boxShadow: [
                // ✨ GLOW EFFECT
                BoxShadow(
                  color: Colors.green.withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 1,
                )
              ],
            ),
          ),

          // 🔢 TEXT OVERLAY
          Text(
            _target == 0
                ? "0%"
                : "${(progress * 100).toInt()}%  ($_count / $_target)",
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // 🔄 LOAD DATA
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _count = prefs.getInt('zikr_count') ?? 0;
      _target = prefs.getInt('zikr_target') ?? 0;
      _isCompleted = prefs.getBool('zikr_done') ?? false;
    });
  }

  // 💾 SAVE DATA
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('zikr_count', _count);
    await prefs.setInt('zikr_target', _target);
    await prefs.setBool('zikr_done', _isCompleted);
  }

  // 🌍 LANGUAGE
  String get _langCode {
    final code = Localizations.localeOf(context).languageCode;
    if (['tr','ar','fr','de','ru','ur','hi','es'].contains(code)) return code;
    return 'en';
  }

  Map<String, String> get _t {
    switch (_langCode) {
      case 'es':
        return {
          'title': 'Dhikr',
          'tap': 'Tocar',
          'reset': 'Reiniciar',
          'target': 'Objetivo',
          'setTarget': 'Definir objetivo',
          'done': 'Completado',
        };
      case 'tr':
        return {
          'title': 'Zikir',
          'tap': 'Dokun',
          'reset': 'Sıfırla',
          'target': 'Hedef',
          'setTarget': 'Hedef Belirle',
          'done': 'Tamamlandı',
        };
      case 'ar':
        return {
          'title': 'الذكر',
          'tap': 'اضغط',
          'reset': 'إعادة',
          'target': 'الهدف',
          'setTarget': 'تحديد الهدف',
          'done': 'تم',
        };
      default:
        return {
          'title': 'Zikr',
          'tap': 'Tap',
          'reset': 'Reset',
          'target': 'Target',
          'setTarget': 'Set Target',
          'done': 'Completed',
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = _t;

    return Directionality(
      textDirection:
      (_langCode == 'ar' || _langCode == 'ur')
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7F9),

        appBar: AppBar(
          title: Text(t['title']!),
          centerTitle: true,
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),

        body: SafeArea(
          // 1. Add SingleChildScrollView to handle keyboard appearance
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10),

                // 🎯 TARGET + PROGRESS
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _target == 0
                              ? t['setTarget']!
                              : "${t['target']}: $_target",
                        ),
                        const SizedBox(height: 10),
                        _buildProgressBar(),
                      ],
                    ),
                  ),
                ),

                // 2. Reduced fixed heights slightly for better fit
                const SizedBox(height: 60),

                // 🔘 BIGGER & LOWER CIRCLE
                GestureDetector(
                  onTap: _onTap,
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Colors.teal, Colors.green],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.teal.withOpacity(0.3),
                          blurRadius: 25,
                        )
                      ],
                    ),
                    child: Center(
                      child: Text(
                        "$_count",
                        style: const TextStyle(
                          fontSize: 56,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // 🔁 BUTTONS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _count = 0;
                          _isCompleted = false;
                        });
                        _saveData();
                      },
                      child: Text(t['reset']!),
                    ),
                    ElevatedButton(
                      onPressed: _showTargetDialog,
                      child: Text(t['setTarget']!),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // ✅ COMPLETED
                if (_isCompleted)
                  Text(
                    t['done']!,
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🔘 TAP LOGIC
  void _onTap() async {
    if (_target == 0) {
      _showTargetDialog();
      return;
    }

    if (_isCompleted) return;

    setState(() {
      _count++;
    });

    if (_count >= _target) {
      _isCompleted = true;

      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 500);
      }
    }

    _saveData();
  }

  // 🎯 TARGET DIALOG
  void _showTargetDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(_t['setTarget']!),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: " "),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final value = int.tryParse(controller.text);

              if (value != null && value > 0) {
                setState(() {
                  _target = value;
                  _count = 0;
                  _isCompleted = false;
                });
                _saveData();
              }

              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}