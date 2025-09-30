import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../services/billing/revenuecat_service.dart';

// RevenueCat service provider
final revenueCatServiceProvider = Provider<RevenueCatService>((ref) {
  return RevenueCatService.instance;
});

// RevenueCat state notifier
final revenueCatProvider = StateNotifierProvider<RevenueCatNotifier, RevenueCatState>((ref) {
  return RevenueCatNotifier(ref.read(revenueCatServiceProvider));
});

// Customer info stream provider
final customerInfoStreamProvider = StreamProvider<CustomerInfo>((ref) {
  final service = ref.watch(revenueCatServiceProvider);
  return service.customerInfoStream;
});

// Premium status provider
final isPremiumProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(revenueCatServiceProvider);
  return await service.isPremium();
});

// Offerings provider
final offeringsProvider = FutureProvider<Offerings?>((ref) async {
  final service = ref.watch(revenueCatServiceProvider);
  return await service.getOfferings();
});

class RevenueCatState {
  final bool isPremium;
  final bool isLoading;
  final String? error;
  final CustomerInfo? customerInfo;
  final Offerings? offerings;

  const RevenueCatState({
    this.isPremium = false,
    this.isLoading = false,
    this.error,
    this.customerInfo,
    this.offerings,
  });

  RevenueCatState copyWith({
    bool? isPremium,
    bool? isLoading,
    String? error,
    CustomerInfo? customerInfo,
    Offerings? offerings,
  }) {
    return RevenueCatState(
      isPremium: isPremium ?? this.isPremium,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      customerInfo: customerInfo ?? this.customerInfo,
      offerings: offerings ?? this.offerings,
    );
  }
}

class RevenueCatNotifier extends StateNotifier<RevenueCatState> {
  final RevenueCatService _service;

  RevenueCatNotifier(this._service) : super(const RevenueCatState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);
    
    try {
      // Initialize RevenueCat
      await _service.initialize();
      
      // Get initial customer info
      await refreshCustomerInfo();
      
      // Load offerings
      await loadOfferings();
      
      // Listen to customer info updates
      _service.customerInfoStream.listen((customerInfo) {
        _updateCustomerInfo(customerInfo);
      });
      
      state = state.copyWith(isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refreshCustomerInfo() async {
    try {
      final customerInfo = await _service.getCustomerInfo();
      _updateCustomerInfo(customerInfo);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void _updateCustomerInfo(CustomerInfo customerInfo) {
    final isPremium = customerInfo.entitlements.all['premium']?.isActive ?? false;
    state = state.copyWith(
      customerInfo: customerInfo,
      isPremium: isPremium,
    );
  }

  Future<void> loadOfferings() async {
    try {
      final offerings = await _service.getOfferings();
      state = state.copyWith(offerings: offerings);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<bool> purchasePackage(Package package) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final customerInfo = await _service.purchasePackage(package);
      if (customerInfo != null) {
        _updateCustomerInfo(customerInfo);
        state = state.copyWith(isLoading: false);
        return true;
      } else {
        state = state.copyWith(isLoading: false);
        return false; // User cancelled
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> restorePurchases() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final customerInfo = await _service.restorePurchases();
      if (customerInfo != null) {
        _updateCustomerInfo(customerInfo);
      }
      state = state.copyWith(isLoading: false);
      return customerInfo != null;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> purchaseMemoryPack(String packType) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final success = await _service.purchaseMemoryPack(packType);
      if (success) {
        await refreshCustomerInfo(); // Refresh to get updated info
      }
      state = state.copyWith(isLoading: false);
      return success;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> hasMemoryPack(String packType) async {
    return await _service.hasMemoryPack(packType);
  }

  Future<bool> isPremium() async {
    return await _service.isPremium();
  }

  List<String> getAvailableMemoryPacks() {
    return _service.getAvailableMemoryPacks();
  }

  Map<String, String> getMemoryPackDisplayNames() {
    return _service.getMemoryPackDisplayNames();
  }

  Map<String, String> getMemoryPackDescriptions() {
    return _service.getMemoryPackDescriptions();
  }
} 