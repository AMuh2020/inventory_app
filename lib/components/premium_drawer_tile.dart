import 'package:flutter/material.dart';
import 'package:inventory_app/components/drawer_tile.dart';
import 'dart:io';
import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';


final bool _kAutoConsume = Platform.isIOS || true;

const String _kpremiumID = 'premium_one_time';
const List<String> _kProductIds = <String>[
  _kpremiumID,
];

class PremiumDrawerTile extends StatefulWidget {
  const PremiumDrawerTile({super.key});

  @override
  State<PremiumDrawerTile> createState() => _PremiumDrawerTileState();
}

class _PremiumDrawerTileState extends State<PremiumDrawerTile> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  final List _products = [];
  ProductDetails? _productDetails;

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
          // _handleError(purchaseDetails.error!);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                  purchaseDetails.status == PurchaseStatus.restored) {
          // bool valid = await _verifyPurchase(purchaseDetails);
          // if (valid) {
          //   _deliverProduct(purchaseDetails);
          // } else {
          //   _handleInvalidPurchase(purchaseDetails);
          // }
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
    return DrawerTile(
      text: 'Get Premium',
      icon: Icons.star,
      onTap: () {
        _buy();
        // Navigator.pop(context);
      },
    );
  }
}