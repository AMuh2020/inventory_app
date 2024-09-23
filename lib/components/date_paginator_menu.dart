import 'package:flutter/material.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';

class PaginatorMenu extends StatefulWidget {
  const PaginatorMenu({super.key});

  @override
  State<PaginatorMenu> createState() => _PaginatorMenuState();
}



class _PaginatorMenuState extends State<PaginatorMenu> {
  int _currentPage = 1;
  int _totalPages = 1;
  int _itemsPerPage = 10;
  String? _selectedRange = 'Month';
  List<String> _range = ['Day', 'Week', 'Month', 'Year'];
  DateRange? selectedDateRange = DateRange(DateTime.now(), DateTime.now());

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              width: 250,
              child: DateRangeField(
                decoration: const InputDecoration(
                  label: Text("Date range picker"),
                  hintText: 'Please select a date range',
                ),
                onDateRangeSelected: (DateRange? value) {
                  print('Selected date range: $value');
                  setState(() {
                    selectedDateRange = value;
                  });
                },
                selectedDateRange: selectedDateRange,
                pickerBuilder: datePickerBuilder,
                
              ),
            ),
          ],
        ),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
            
        //     TextButton(
        //       onPressed: () => {
        //         showDateRangePickerDialogOnWidget(
        //           widgetContext: context,
        //           pickerBuilder: (context, onDateRangeChanged) => datePickerBuilder(
        //             context,
        //             onDateRangeChanged,
        //           ),
        //           delta: Offset(30, 130)
        //         )
        //       },
        //        child: Text('${selectedDateRange?.start} - ${selectedDateRange?.end}'),
        //     )
            
        //   ],
        // ),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     IconButton(
        //       icon: const Icon(Icons.arrow_back_ios),
        //       onPressed: () {
        //         if (_currentPage > 1) {
        //           setState(() {
        //             _currentPage -= 1;
        //           });
        //         }
        //       },
        //     ),
        //     Text('$_currentPage of $_totalPages'),
        //     IconButton(
        //       icon: const Icon(Icons.arrow_forward_ios),
        //       onPressed: () {
        //         if (_currentPage < _totalPages) {
        //           setState(() {
        //             _currentPage += 1;
        //           });
        //         }
        //       },
        //     ),
        //   ],
        // ),
      ],
    );
  }
  Widget datePickerBuilder(
    BuildContext context, dynamic Function(DateRange?) onDateRangeChanged,
    [bool doubleMonth = false]) {
    return DateRangePickerWidget(
      doubleMonth: doubleMonth,
      // maximumDateRangeLength: 10,
      allowSingleTapDaySelection: true,
      // quickDateRanges: [
      //   QuickDateRange(dateRange: null, label: "Remove date range"),
      //   QuickDateRange(
      //     label: 'Last 3 days',
      //     dateRange: DateRange(
      //       DateTime.now().subtract(const Duration(days: 3)),
      //       DateTime.now(),
      //     ),
      //   ),
      //   QuickDateRange(
      //     label: 'Last 7 days',
      //     dateRange: DateRange(
      //       DateTime.now().subtract(const Duration(days: 7)),
      //       DateTime.now(),
      //     ),
      //   ),
      //   QuickDateRange(
      //     label: 'Last 30 days',
      //     dateRange: DateRange(
      //       DateTime.now().subtract(const Duration(days: 30)),
      //       DateTime.now(),
      //     ),
      //   ),
      //   QuickDateRange(
      //     label: 'Last 90 days',
      //     dateRange: DateRange(
      //       DateTime.now().subtract(const Duration(days: 90)),
      //       DateTime.now(),
      //     ),
      //   ),
      //   QuickDateRange(
      //     label: 'Last 180 days',
      //     dateRange: DateRange(
      //       DateTime.now().subtract(const Duration(days: 180)),
      //       DateTime.now(),
      //     ),
      //   ),
      // ],
      initialDateRange: selectedDateRange,
      disabledDates: [],
      initialDisplayedDate:
          selectedDateRange?.start ?? DateTime(2024, 11, 20),
      onDateRangeChanged: onDateRangeChanged,
      height: 350,
      theme: CalendarTheme(
        selectedColor: Theme.of(context).primaryColor,
        dayNameTextStyle: TextStyle(color: Colors.black45, fontSize: 10),
        inRangeColor: Color(0xFFD9EDFA),
        inRangeTextStyle: TextStyle(color: Theme.of(context).primaryColor),
        selectedTextStyle: TextStyle(color: Colors.white),
        todayTextStyle: TextStyle(fontWeight: FontWeight.bold),
        defaultTextStyle: TextStyle(color: Colors.black, fontSize: 12),
        radius: 10,
        tileSize: 40, // changing this size will make the calendar smaller
        disabledTextStyle: TextStyle(color: Colors.grey),
        quickDateRangeBackgroundColor: Color(0xFFFFF9F9),
        selectedQuickDateRangeColor: Colors.blue,
      ),
    );
  }
}