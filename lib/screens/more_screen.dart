import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  void shareApp(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final box = context.findRenderObject();

    if (box is RenderBox) {
      Share.share(
        loc.shareAppText,
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
      );
    } else {
      Share.share(loc.shareAppText);
    }
  }
  Future<void> rateApp() async {
    final iosUrl = Uri.parse(
      "https://apps.apple.com/us/app/sala-prayer-times/id6759267391",
    );

    final androidUrl = Uri.parse(
      "https://play.google.com/store/apps/details?id=com.your.package",
    );

    final url = Platform.isIOS ? iosUrl : androidUrl;

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

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

                // 🕌 DUA
                _buildItem(
                  context,
                  'assets/more/dua.png',
                  loc.dua,
                      () => Navigator.pushNamed(context, '/dua'),
                ),

                // 📿 ZIKR
                _buildItem(
                  context,
                  'assets/more/zikr.png',
                  loc.zikr,
                      () => Navigator.pushNamed(context, '/zikr'),
                ),

                // 📅 CALENDAR
                _buildItem(
                  context,
                  'assets/more/calendar.png',
                  loc.calendar,
                      () => Navigator.pushNamed(context, '/calendar'),
                ),

                // ℹ️ ABOUT
                // _buildItem(
                //   context,
                //   'assets/more/about.png',
                //   loc.about,
                //       () => Navigator.pushNamed(context, '/about'),
                // ),
                _buildItem(
                  context,
                  'assets/more/quran.png',
                  loc.quran,
                      () => Navigator.pushNamed(context, '/quran-test'),
                ),

                // 🔗 SHARE
                _buildItem(
                  context,
                  'assets/more/share.png',
                  loc.shareApp,
                      () {
                    shareApp(context);
                  },
                ),

                // ⭐ RATE
                _buildItem(
                  context,
                  'assets/more/rate.png',
                  loc.rateApp,
                      () {
                    rateApp();
                  },
                ),

                // 💖 SUPPORT
                // _buildItem(
                //   context,
                //   'assets/more/support.png',
                //   loc.support,
                //       () => Navigator.pushNamed(context, '/support'),
                // ),

                // 🕌 MOSQUE
                // _buildItem(
                //   context,
                //   'assets/more/mosque.png',
                //   "Mosques",
                //       () => Navigator.pushNamed(context, '/mosque'),
                // ),


              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🔥 REUSABLE ITEM (ALL SAME STYLE)
  Widget _buildItem(
      BuildContext context,
      String image,
      String title,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          // ICON + GLOW
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
              image,
              width: 95,
              height: 95,
            ),
          ),

          const SizedBox(height: 12),

          // TEXT
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}