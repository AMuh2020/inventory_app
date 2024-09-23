import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventory_app/components/restore_purchase_tile.dart';
import 'package:inventory_app/components/settings_tile.dart';
import 'package:inventory_app/pages/main_page.dart';
import 'package:inventory_app/themes/theme_provider.dart';
import 'package:inventory_app/utils/utils.dart' as utils;
import 'package:provider/provider.dart';
import 'package:inventory_app/globals.dart' as globals;
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:inventory_app/main.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}



class _SettingsPageState extends State<SettingsPage> {
  Color currentColor = globals.seedColor;
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
            helperText: 'Toggle dark mode',
            icon: Icons.dark_mode,
            trailing: Switch(
              value: ThemeProvider().isDarkMode,
              onChanged: (value) {
                
                setState(() {
                  ThemeProvider().toggleTheme();
                  // ThemeProvider().isDarkMode = !ThemeProvider().isDarkMode;
                  // globals.darkMode = !globals.darkMode;
                });
              },
            ),
            onTap: () {
              
              setState(() {
                ThemeProvider().toggleTheme();
                // toggle the value
                // ThemeProvider().isDarkMode = !ThemeProvider().isDarkMode;
                // globals.darkMode = !globals.darkMode;
              });
            },
          ),
          
          if (globals.hasPremium)
            // color theme
            SettingsTile(
              text: 'Color Theme',
              helperText: 'Select the color theme',
              icon: Icons.color_lens,
              trailing: const SizedBox(),
              onTap: () {
                // show color picker
                _colorpickDialog(context);
              },
            ),

          // currency symbol
          SettingsTile(
            text: 'Currency Symbol',
            helperText: 'Set the currency symbol',
            icon: Icons.attach_money,
            trailing: Padding(
              padding: const EdgeInsets.all(10.0),
              child: DropdownButton(
                value: Provider.of<CurrencyProvider>(context).currencySymbol,
                onChanged: (String? newValue) {
                  setState(() {
                    CurrencyProvider().currencySymbol = newValue!;
                  });
                },
                items: ['\$', '₦', '₹', '€', '£', '¥',].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            onTap: () => {},
          ),

          // customer info fields toggle
          SettingsTile(
            text: 'Customer Info Fields',
            helperText: 'Adds the option to enter customer name and phone number when selling products',
            icon: Icons.person,
            trailing: Switch(
              value: Provider.of<CustomerInfoProvider>(context).customerInfoFields,
              onChanged: (value) {
                // set the state with the new value
                setState(() {
                  // toggle the value
                  CustomerInfoProvider().customerInfoFields = !CustomerInfoProvider().customerInfoFields;
                });
              },
            ),
            onTap: () => {},
          ),

          // reset settings
          SettingsTile(
            text: 'Reset Settings',
            helperText: 'Reset all settings to default',
            icon: Icons.settings_backup_restore,
            trailing: SizedBox(),
            onTap: () {
              // are you sure dialog
              // show dialog
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Reset Settings'),
                    content: const Text('Are you sure you want to reset all settings to default?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          // reset settings
                          await utils.resetSettings();
                          if (ThemeProvider().isDarkMode != globals.defaults['darkMode']) {
                            Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
                          }
                          if (globals.seedColor != globals.defaults['seedColor']) {
                            Provider.of<ThemeProvider>(context, listen: false).changeSeedColor(utils.hexToColor(globals.defaults['seedColor']));
                          }
                          if (CurrencyProvider().currencySymbol != globals.defaults['currencySymbol']) {
                            CurrencyProvider().currencySymbol = globals.defaults['currencySymbol'];
                          }
                          if (CustomerInfoProvider().customerInfoFields != globals.defaults['customerInfoFields']) {
                            CustomerInfoProvider().customerInfoFields = globals.defaults['customerInfoFields'];
                          }

                          // set the state to rebuild the page
                          setState(() {});
                          print('Settings reset, default settings loaded');
                        },
                        child: const Text('Reset'),
                      ),
                    ],
                  );
                }
              );
            },
          ),

          // delete all data
          SettingsTile(
            text: 'Delete All Data',
            helperText: 'Delete all data from the app',
            icon: Icons.delete_forever,
            trailing: SizedBox(),
            onTap: () {
              _deleteDialog();
            },
          ),
          RestorePurchaseTile(),
        ],
      )
    );
  }
  void _colorpickDialog (BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color!'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: currentColor,
              onColorChanged: (Color color) {
                print(color);
                ThemeProvider().changeSeedColor(color);
                setState(() {
                  currentColor = color;
                  globals.hexSeedColor = utils.colorToHexString(color);
                });
              },
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Got it'),
              onPressed: () {
                print('picked color: $currentColor');
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      }
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