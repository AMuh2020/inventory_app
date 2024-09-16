import 'package:flutter/material.dart';
import 'package:inventory_app/components/drawer_tile.dart';
import 'package:inventory_app/pages/analytics_page.dart';
import 'package:inventory_app/pages/feedback_page.dart';
import 'package:inventory_app/pages/get_premium_page.dart';
import 'package:inventory_app/pages/settings_page.dart';
import 'package:inventory_app/globals.dart' as globals;

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              // color from the theme
              color: Theme.of(context).primaryColor,
            ),
            child: const Center(
              child: Text(
                'Inventory App',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
          ),
          // analytics - not implemented, for next update
          if (globals.hasPremium)
            DrawerTile(
              text: 'Analytics',
              icon: Icons.analytics,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AnalyticsPage(),
                  ),
                );
              },
            ),
          const Spacer(),
          // premium drawer tile
          DrawerTile(
            text: 'Premium',
            icon: Icons.star,
            onTap: () {
              Navigator.push(context,
              MaterialPageRoute(
                builder: (context) => const GetPremiumPage(),
              ),
            );
            },
          ),
          DrawerTile(
            text: 'Feedback',
            icon: Icons.feedback,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FeedbackPage(),
                ),
              );
            },
          ),
          DrawerTile(
            text: 'Settings',
            icon: Icons.settings,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Text(
            'Version ${globals.defaults['version']}',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}