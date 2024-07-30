import 'package:flutter/material.dart';

class SettingsTile extends StatefulWidget {
  final String text;
  final IconData icon;
  final Widget button;
  const SettingsTile({
    super.key,
    required this.text,
    required this.icon,
    required this.button,
  });

  @override
  State<SettingsTile> createState() => _SettingsTileState();
}

class _SettingsTileState extends State<SettingsTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        widget.text,
      ),
      leading: Icon(
        widget.icon,
        size: 30,
      ),
      trailing: widget.button,
    );
  }
}