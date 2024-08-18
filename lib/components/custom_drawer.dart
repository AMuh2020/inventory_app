import 'package:flutter/material.dart';
import 'package:inventory_app/components/drawer_tile.dart';
import 'package:inventory_app/pages/feedback_page.dart';
import 'package:inventory_app/pages/settings_page.dart';

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
          // DrawerTile(
          //   text: 'Analytics',
          //   icon: Icons.analytics,
          //   onTap: () {
          //     Navigator.pop(context);
          //   },
          // ),
          // settings
          DrawerTile(
            text: 'Settings',
            icon: Icons.settings,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
                ),
              );
            },
          ),
          DrawerTile(
            text: 'Feedback',
            icon: Icons.feedback,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FeedbackPage(),
                ),
              );
            },
          ),
          const Spacer(),
          const Text(
            'Version 1.0.0',
            style: TextStyle(
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