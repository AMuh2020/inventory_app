import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventory_app/components/settings_tile.dart';
import 'package:inventory_app/pages/main_page.dart';
import 'package:inventory_app/themes/theme_provider.dart';
import 'package:inventory_app/utils/utils.dart' as utils;
import 'package:provider/provider.dart';
import 'package:inventory_app/globals.dart' as globals;

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // instead of popping the context, remove stack and push homepage
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const MainPage()),
              (route) => false,
            );
          },
        ),
      ),
      body: Column(
        children: [
          // dark mode toggle
          SettingsTile(
            text: 'Dark Mode',
            helperText: 'Toggle dark mode',
            icon: Icons.dark_mode,
            trailing: Switch(
              value: globals.darkMode,
              onChanged: (value) {
                Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
                setState(() {
                  globals.darkMode = !globals.darkMode;
                });
              },
            ),
          ),
          // currency symbol
          SettingsTile(
            text: 'Currency Symbol',
            helperText: 'Set the currency symbol',
            icon: Icons.attach_money,
            trailing: Padding(
              padding: const EdgeInsets.all(10.0),
              child: DropdownButton(
                value: globals.currencySymbol,
                onChanged: (String? newValue) {
                  setState(() {
                    globals.currencySymbol = newValue!;
                  });
                },
                items: ['\$', '₹', '€', '£', '¥'].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
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
          // customer info fields toggle
          SettingsTile(
            text: 'Customer Info Fields',
            helperText: 'Adds the option to enter customer name and phone number when selling products',
            icon: Icons.person,
            trailing: Switch(
              value: globals.customerInfoFields,
              onChanged: (value) {
                // set the state with the new value
                setState(() {
                  // toggle the value
                  globals.customerInfoFields = !globals.customerInfoFields;
                });
                // function to save the value to shared preferences
                utils.toggleCustomerInfoFields(globals.customerInfoFields);
              },
            ),
          ),
          // delete all data
          SettingsTile(
            text: 'Delete All Data',
            helperText: 'Delete all data from the app',
            icon: Icons.delete_forever,
            trailing: IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: () {
                _deleteDialog();
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
  void _deleteDialog () {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete All Data'),
          content: const Text('Are you sure you want to delete all data? This action cannot be undone. The app will need to be restarted.'),
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
  }
}