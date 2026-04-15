import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.more),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      // 🌈 PREMIUM BACKGROUND
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF2F6F9),
              Color(0xFFE3F2F1),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),

            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,

              children: [

                MoreItem(
                  image: 'assets/more/dua.png',
                  title: loc.dua,
                  route: '/dua',
                ),

                MoreItem(
                  image: 'assets/more/zikr.png',
                  title: loc.zikr,
                  route: '/zikr',
                ),

                MoreItem(
                  image: 'assets/more/calendar.png',
                  title: loc.calendar,
                  route: '/calendar',
                ),

                MoreItem(
                  image: 'assets/more/about.png',
                  title: loc.about,
                  route: '/about',
                ),

                MoreItem(
                  image: 'assets/more/share.png',
                  title: loc.shareApp,
                  route: '/share',
                ),

                MoreItem(
                  image: 'assets/more/rate.png',
                  title: loc.rateApp,
                  route: '/rate',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class MoreItem extends StatefulWidget {
  final String image;
  final String title;
  final String route;

  const MoreItem({
    super.key,
    required this.image,
    required this.title,
    required this.route,
  });

  @override
  State<MoreItem> createState() => _MoreItemState();
}

class _MoreItemState extends State<MoreItem>
    with SingleTickerProviderStateMixin {

  double scale = 1.0;
  late AnimationController _controller;
  late Animation<double> floatAnim;

  @override
  void initState() {
    super.initState();

    // 🔥 FLOATING ANIMATION
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    floatAnim = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void onTapDown(_) => setState(() => scale = 0.9);
  void onTapUp(_) {
    setState(() => scale = 1.0);
    Navigator.pushNamed(context, widget.route);
  }

  void onTapCancel() => setState(() => scale = 1.0);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,

      child: InkWell(
        onTap: () => Navigator.pushNamed(context, widget.route),
        onTapDown: onTapDown,
        onTapUp: onTapUp,
        onTapCancel: onTapCancel,
        borderRadius: BorderRadius.circular(20),

        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 150),

          child: AnimatedBuilder(
            animation: floatAnim,

            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, floatAnim.value),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    // 🔥 ICON WITH GLOW EFFECT
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.teal.withOpacity(0.25),
                            blurRadius: 20,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: Image.asset(
                        widget.image,
                        width: 95,
                        height: 95,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}