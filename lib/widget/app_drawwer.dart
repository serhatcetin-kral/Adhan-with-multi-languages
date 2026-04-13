import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [

          // 🔵 HEADER
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.teal,
            ),
            child: Center(
              child: Text(
                loc.appTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // 🏠 HOME
          // buildTile(
          //   context,
          //   icon: Icons.home,
          //   text: loc.home,
          //   route: '/home',
          // ),

          // 🧭 COMPASS QIBLA
          buildTile(
            context,
            icon: Icons.explore,
            text: loc.compassQibla,
            route: '/compass',
          ),

          // 🌍 GOOGLE QIBLA
          buildTile(
            context,
            icon: Icons.public,
            text: loc.googleQibla,
            route: '/google',
          ),

          const Divider(),

          // ⚙️ SETTINGS
          buildTile(
            context,
            icon: Icons.settings,
            text: loc.settings,
            route: '/settings',
          ),

          // ℹ️ ABOUT
          buildTile(
            context,
            icon: Icons.info_outline,
            text: loc.about,
            route: '/about',
          ),

          const Divider(),

          // ❤️ SUPPORT
          ListTile(
            leading: const Icon(Icons.favorite, color: Colors.red),
            title: Text(loc.support ?? "Support"),
            onTap: () {
              Navigator.pushNamed(context, '/support');
            },
          ),
        ],
      ),
    );
  }

  // 🔥 REUSABLE TILE
  Widget buildTile(
      BuildContext context, {
        required IconData icon,
        required String text,
        required String route,
      }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      onTap: () {
        Navigator.pop(context); // close drawer
        Navigator.pushReplacementNamed(context, route);
      },
    );
  }
}