import 'package:flutter/material.dart';
import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:inventory_app/globals.dart' as globals;
import 'dart:io';
import 'package:inventory_app/utils/utils.dart' as utils;

  

class GetPremiumPage extends StatefulWidget {
  const GetPremiumPage({super.key});

  @override
  State<GetPremiumPage> createState() => _GetPremiumPageState();
}

class _GetPremiumPageState extends State<GetPremiumPage> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  final List _products = [];
  ProductDetails? _productDetails;
  String price = '';

  final bool _kAutoConsume = Platform.isIOS || true;

  static const String _kpremiumID = 'premium_one_time';
  static const List<String> _kProductIds = <String>[
    _kpremiumID,
  ];


  @override
  void initState() {
    print('init state');
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        InAppPurchase.instance.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      print('purchase updated');
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      print('done');
      _subscription.cancel();
    }, onError: (error) {
      // handle error here.
    });
    initStore();
    super.initState();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    print('listen to purchase updated');
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      print(purchaseDetails.productID);
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // _showPendingUI();
        print('pending');
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          print('error');
          print(purchaseDetails.error);
          utils.showSnackBar(context,'Error: ${purchaseDetails.error!.message}');
          // _handleError(purchaseDetails.error!);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                  purchaseDetails.status == PurchaseStatus.restored) {
          // bool valid = await _verifyPurchase(purchaseDetails);
          utils.grantPremium();
          print('${purchaseDetails} purchased');
          utils.showSnackBar(context,'Purchase successful');
        }
        if (purchaseDetails.pendingCompletePurchase) {
          print('pending complete purchase');
          await InAppPurchase.instance
              .completePurchase(purchaseDetails);
        }
      }
    });
  }

  void initStore() async{
    final bool available = await InAppPurchase.instance.isAvailable();
    if (!available) {
      print('store not available');
      return;
    }
    print('store available');
    ProductDetailsResponse productDetailResponse = await _inAppPurchase.queryProductDetails(_kProductIds.toSet());
    if (productDetailResponse.error != null) {
      print('Error: ${productDetailResponse.error!.message}');
      return;
    }
    if (productDetailResponse.productDetails.isNotEmpty) {
      _productDetails = productDetailResponse.productDetails.first;
      setState(() {
        price = _productDetails!.price;
      });
      print('Product id: ${_productDetails!.id}');
      print('Product title: ${_productDetails!.title}');
      print('Product description: ${_productDetails!.description}');
      print('Product price: ${_productDetails!.price}');
    } else {
      print('Product not found');
    }
  }
  _buy() async {
    print('buying');
    final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(_kProductIds.toSet());
    print('response: $response');
    if (response.notFoundIDs.isNotEmpty) {
      print('Product not found: ${response.notFoundIDs}');
    }
    final ProductDetails productDetails = response.productDetails.first;
    print('Product id: ${productDetails.id}');
    print('Product id: ${productDetails.currencyCode}');
    print('Product id: ${productDetails.description}');
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);
    _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Get Premium'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Get premium to unlock more features and support the developer for just $price!!'),
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    const Text(
                      'Features include:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text('Product quantity graphs, to see how your inventory is doing'),
                    AspectRatio(
                      aspectRatio: 2.0,
                      child: Image.asset('assets/premium/product_quantity.png')
                    ),
                    const Text('Customize the app with your favorite color'),
                    AspectRatio(
                      aspectRatio: 2.0,
                      child: Image.asset('assets/premium/theme_color_picker.png')
                    ),
                    const Text('and more coming soon!'),
                    const Text('feature requests are also welcome!'),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              // color theme changer
              Center(
                child: globals.hasPremium ?
                  const Text(
                    'You already have premium',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                  :
                  ElevatedButton(
                    onPressed: _buy,
                    child: Text('Buy Premium $price'),
                  ),
              ),
              const SizedBox(height: 20),
              const Text('Getting premium also supports the developer (me) helping me to continue to build more features (and fix bugs!)'),
              const Text('Thank you for your support!'),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}