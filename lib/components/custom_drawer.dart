import 'package:flutter/material.dart';
import 'package:inventory_app/components/drawer_tile.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Center(
              child: Text(
                'Inventory App',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
          ),
          DrawerTile(
            text: 'Settings',
            icon: Icons.settings,
            onTap: () {
              Navigator.pop(context);
            },
          ),
          DrawerTile(
            text: 'Feedback',
            icon: Icons.feedback,
            onTap: () {
              Navigator.pop(context);
            },
          ),
          Spacer(),
          Text(
            'Version 1.0.0',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}