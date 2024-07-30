import 'package:flutter/material.dart';

class DrawerTile extends StatelessWidget {

  final String text;
  final IconData icon;
  final void Function() onTap;

  const DrawerTile({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 50.0),
      child: ListTile(
        title: Text(
          text,
        ),
        leading: Icon(
          icon,
          size: 30,
        ),
        onTap: onTap,
      ),
    );
  }
}