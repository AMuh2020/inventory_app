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
    return ListTile(
      leading: Icon(
        icon,
        size: 30,
      ),
      title: Text(
        text,
      ),
      onTap: onTap,
    );
  }
  //   return GestureDetector(
  //     onTap: onTap,
  //     child: Row(
  //       children: [
  //         Icon(
  //           icon,
  //           size: 30,
  //         ),
  //         Text(
  //           text,
  //         ),
  //       ],
  //     ),
  //   );
  // }
}