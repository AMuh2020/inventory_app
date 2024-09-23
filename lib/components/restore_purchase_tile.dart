import 'package:flutter/material.dart';
import 'package:inventory_app/components/settings_tile.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'dart:io';
import 'dart:async';
import 'package:inventory_app/utils/utils.dart' as utils;

class RestorePurchaseTile extends StatefulWidget {
  const RestorePurchaseTile({super.key});

  @override
  State<RestorePurchaseTile> createState() => _RestorePurchaseTileState();
}

class _RestorePurchaseTileState extends State<RestorePurchaseTile> {
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
          _showSnackBar('Error: ${purchaseDetails.error!.message}');
          // _handleError(purchaseDetails.error!);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                  purchaseDetails.status == PurchaseStatus.restored) {
          // bool valid = await _verifyPurchase(purchaseDetails);
          utils.grantPremium();
          _showSnackBar('AMAL Inventory manager - Premium Restored');
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
  void _retorePurchase() async {
    // restore purchase
    print('restore purchase');
    await InAppPurchase.instance.restorePurchases();
  }
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      text: 'Restore Purchases',
      helperText: 'Restore your purchases',
      icon: Icons.restore,
      onTap: () {
        // restore purchase
        _retorePurchase();
      },
    );
  }
}