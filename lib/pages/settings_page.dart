import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventory_app/components/settings_tile.dart';
import 'package:inventory_app/themes/theme_providor.dart';
import 'package:inventory_app/utils/utils.dart' as utils;
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkMode = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Column(
        children: [
          // dark mode toggle
          SettingsTile(
            text: 'Dark Mode',
            icon: Icons.dark_mode,
            button: Switch(
              value: isDarkMode,
              onChanged: (value) {
                Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
                setState(() {
                  isDarkMode = !isDarkMode;
                });
              },
            ),
          ),
          // color picker for theme
          // const SettingsTile(
          //   text: 'Theme Color',
          //   icon: Icons.color_lens,
          //   button: const Icon(Icons.arrow_forward),
          // ),
          // SettingsTile(
          //   text: 'Reset Settings',
          //   icon: Icons.settings_backup_restore,
          //   button: const Icon(Icons.arrow_forward),
          // ),
          // delete all data
          SettingsTile(
            text: 'Delete All Data',
            icon: Icons.delete_forever,
            button: IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Delete All Data'),
                      content: const Text('Are you sure you want to delete all data? This action cannot be undone. The app will be close after deleting all data.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            // delete all data
                            utils.deleteDatabaseFile();

                            // rebuild the previous page
                            SystemNavigator.pop();
                          },
                          child: const Text('Delete'),
                        ),
                      ],
                    );
                  }
                );
              },
            ),
          ),
          // Center(
          //   child: ElevatedButton(
          //     child: const Text('Reset Settings'),
          //     onPressed: () {
          //       setState(() {
          //         // isDarkMode = false;
          //       });
          //     },
          //   )
          // )
        ],
      )
    );
  }
}