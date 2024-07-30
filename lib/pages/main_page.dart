import 'package:flutter/material.dart';
import 'package:inventory_app/components/custom_drawer.dart';
import 'package:inventory_app/pages/cart_page.dart';
import 'package:inventory_app/pages/orders_page.dart';
import 'package:inventory_app/pages/products_page.dart';
// import 'package:inventory_app/utils/export.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin {
  final List<String> _titles = const [
    'Products',
    'Sell',
    'Orders',
  ];

  late String _title;
  
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _title = _titles[_tabController.index];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        _tabController.addListener(() {
          setState(() {
            _title = _titles[_tabController.index];
          });
        });
        return Scaffold(
          drawer: const CustomDrawer(),
          appBar: AppBar(
            leading: Builder(
              builder: (context) {
                return IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                );
              }
            ),
            title: Text(_title),
            actions: _getCurrentAction(context),
          ),
          bottomNavigationBar: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(
                icon: Icon(Icons.inventory),
                text: 'Products',
              ),
              Tab(
                icon: Icon(Icons.point_of_sale),
                text: 'Sell',
              ),
              Tab(
                icon: Icon(Icons.list),
                text: 'Orders',
              ),
            ],
          ),
          body: TabBarView(
            controller: _tabController,
            children: const  [
              ProductsPage(),
              CartPage(),
              OrdersPage(),
            ],
          )
        );
      }
    );
  }
  List<Widget> _getCurrentAction(BuildContext context) {
    if (_tabController.index == 0) {
      return [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            print('Add product button clicked!');
          },
        ),
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            print('Search button clicked!');
          },
        ),
      ];
    } else if (_tabController.index == 1) {
      return [];
    } else if (_tabController.index == 2) {
      return [
        // export button
        // IconButton(
        //   icon: const Icon(Icons.download),
        //   onPressed: () async {
        //     print('Export button clicked!');
        //     final result = await exportOrdersToCsv();
        //     print(result);
        //     if (result['success']) {
        //       ScaffoldMessenger.of(context).showSnackBar(
        //         const SnackBar(
        //           content: Text('Orders exported successfully!'),
        //         ),
        //       );
        //     } else {
        //       ScaffoldMessenger.of(context).showSnackBar(
        //         const SnackBar(
        //           content: Text('Failed to export orders!'),
        //         ),
        //       );
        //     }
        //   },
        // ),
        // search button
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            print('Search button clicked!');
          },
        ),
      ];
    } else {
      return [];
    }
  }
}