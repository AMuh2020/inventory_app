import 'package:flutter/material.dart';
import 'package:inventory_app/components/drawer_tile.dart';

class PremiumDrawerTile extends StatelessWidget {
  const PremiumDrawerTile({super.key});



  @override
  Widget build(BuildContext context) {
    return DrawerTile(
      text: 'Get Premium',
      icon: Icons.star,
      onTap: () {
        Navigator.pop(context);
        
      },
    );
  }
}