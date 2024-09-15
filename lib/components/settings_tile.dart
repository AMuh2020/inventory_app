import 'package:flutter/material.dart';

class SettingsTile extends StatefulWidget {
  final String text;
  final String helperText;
  final IconData icon;
  final Widget trailing;
  final void Function() onTap;
  const SettingsTile({
    super.key,
    required this.text,
    required this.helperText,
    required this.icon,
    required this.trailing,
    required this.onTap,
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
      subtitle: Text(widget.helperText),
      leading: Icon(
        widget.icon,
        size: 30,
      ),
      trailing: widget.trailing,
      onTap: widget.onTap,
    );
  }
}