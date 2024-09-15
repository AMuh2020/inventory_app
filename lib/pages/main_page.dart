import 'package:flutter/material.dart';
import 'package:inventory_app/components/custom_drawer.dart';
import 'package:inventory_app/pages/cart_page.dart';
import 'package:inventory_app/pages/sales_page.dart';
import 'package:inventory_app/pages/products_page.dart';
import 'package:inventory_app/utils/export.dart';
import 'package:badges/badges.dart' as badges;
import 'package:provider/provider.dart';
import 'package:inventory_app/main.dart';
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
    'Sales',
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

  int totalItemsInCart(BuildContext context) {
    final cart = Provider.of<CartModel>(context);
    // get the quantity of the product using the product id
    return cart.totalCartItems;
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
            tabs: [
              Tab(
                icon: Icon(Icons.inventory),
                text: 'Products',
              ),
              Tab(
                icon: badges.Badge(
                    showBadge: totalItemsInCart(context) > 0,
                    badgeStyle: badges.BadgeStyle(
                      badgeColor: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    badgeContent: Text('${totalItemsInCart(context)}'),
                    child: const Icon(Icons.point_of_sale),
                  ),
                text: 'Sell',
              ),
              Tab(
                icon: Icon(Icons.list),
                text: 'Sales',
              ),
            ],
          ),
          body: TabBarView(
            controller: _tabController,
            children: const  [
              ProductsPage(),
              CartPage(),
              SalesPage(),
            ],
          )
        );
      }
    );
  }
  List<Widget> _getCurrentAction(BuildContext context) {
    if (_tabController.index == 0) {
      return [
        // IconButton(
        //   icon: const Icon(Icons.add),
        //   onPressed: () {
        //     print('Add product button clicked!');
        //   },
        // ),
        // IconButton(
        //   icon: const Icon(Icons.search),
        //   onPressed: () {
        //     print('Search button clicked!');
        //     // add search functionality
        //     // a dropdown showing the search bar
        //   },
        // ),
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
        //     await writeOrdersCsv();
            
        //   },
        // ),
        // search button
        // IconButton(
        //   icon: const Icon(Icons.search),
        //   onPressed: () {
        //     print('Search button clicked!');
        //   },
        // ),
      ];
    } else {
      return [];
    }
  }
}