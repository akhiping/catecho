import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatService {
  static const String _entitlementId = 'premium';
  static const String _defaultOfferingId = 'default';
  
  static RevenueCatService? _instance;
  static RevenueCatService get instance => _instance ??= RevenueCatService._();
  
  RevenueCatService._();

  final StreamController<CustomerInfo> _customerInfoController = 
      StreamController<CustomerInfo>.broadcast();

  Stream<CustomerInfo> get customerInfoStream => _customerInfoController.stream;

  Future<void> initialize() async {
    final apiKey = Platform.isIOS 
        ? dotenv.env['RC_API_KEY_IOS'] 
        : dotenv.env['RC_API_KEY_ANDROID'];
    
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('RevenueCat API key not found in environment variables');
    }

    PurchasesConfiguration configuration = PurchasesConfiguration(apiKey);
    await Purchases.configure(configuration);

    // Listen to customer info updates
    Purchases.addCustomerInfoUpdateListener((customerInfo) {
      _customerInfoController.add(customerInfo);
    });
  }

  Future<CustomerInfo> getCustomerInfo() async {
    return await Purchases.getCustomerInfo();
  }

  Future<bool> isPremium() async {
    try {
      final customerInfo = await getCustomerInfo();
      return customerInfo.entitlements.all[_entitlementId]?.isActive ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<Offerings?> getOfferings() async {
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      return null;
    }
  }

  Future<CustomerInfo?> purchasePackage(Package package) async {
    try {
      final purchaserInfo = await Purchases.purchasePackage(package);
      return purchaserInfo;
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        // Handle other errors
        rethrow;
      }
      return null;
    }
  }

  Future<CustomerInfo?> purchaseProduct(String productId) async {
    try {
      // Get products first, then purchase the matching one
      final products = await Purchases.getProducts([productId]);
      if (products.isEmpty) {
        return null;
      }
      final purchaserInfo = await Purchases.purchaseStoreProduct(products.first);
      return purchaserInfo;
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        // Handle other errors
        rethrow;
      }
      return null;
    }
  }

  Future<CustomerInfo?> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      return customerInfo;
    } catch (e) {
      return null;
    }
  }

  Future<List<StoreProduct>> getProducts(List<String> productIds) async {
    try {
      return await Purchases.getProducts(productIds);
    } catch (e) {
      return [];
    }
  }

  // Consumable purchases for Memory Packs
  Future<bool> purchaseMemoryPack(String packType) async {
    try {
      final productId = Platform.isIOS 
          ? 'com.echojournal.pack.$packType'
          : 'pack_$packType';
      
      final products = await getProducts([productId]);
      if (products.isEmpty) return false;

      final result = await Purchases.purchaseStoreProduct(products.first);
      return result.nonSubscriptionTransactions.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<bool> hasMemoryPack(String packType) async {
    try {
      final customerInfo = await getCustomerInfo();
      final productId = Platform.isIOS 
          ? 'com.echojournal.pack.$packType'
          : 'pack_$packType';
      
      // Check if user has purchased this pack
      return customerInfo.nonSubscriptionTransactions
          .any((transaction) => transaction.productIdentifier == productId);
    } catch (e) {
      return false;
    }
  }

  List<String> getAvailableMemoryPacks() {
    return ['gratitude', 'growth'];
  }

  Map<String, String> getMemoryPackDisplayNames() {
    return {
      'gratitude': 'Gratitude Pack',
      'growth': 'Growth Pack',
    };
  }

  Map<String, String> getMemoryPackDescriptions() {
    return {
      'gratitude': 'Transform your entries with gratitude-focused AI reflections',
      'growth': 'Unlock growth-oriented insights and personal development themes',
    };
  }

  String getProductId(String packType) {
    return Platform.isIOS 
        ? 'com.echojournal.pack.$packType'
        : 'pack_$packType';
  }

  void dispose() {
    _customerInfoController.close();
  }
} 