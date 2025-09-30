import React, { createContext, useContext, useState, useEffect, useCallback, ReactNode } from 'react';
import { revenueCatService, CustomerInfo, Offering, PurchasePackage } from '@/services/billing/revenuecat';

interface SubscriptionContextType {
  customerInfo: CustomerInfo | null;
  offerings: Offering[];
  isLoading: boolean;
  isPremium: boolean;
  purchasePackage: (pkg: PurchasePackage) => Promise<void>;
  restorePurchases: () => Promise<void>;
  refreshCustomerInfo: () => Promise<void>;
}

const SubscriptionContext = createContext<SubscriptionContextType | undefined>(undefined);

export function SubscriptionProvider({ children }: { children: ReactNode }) {
  const [customerInfo, setCustomerInfo] = useState<CustomerInfo | null>(null);
  const [offerings, setOfferings] = useState<Offering[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  const refreshCustomerInfo = useCallback(async () => {
    try {
      const info = await revenueCatService.getCustomerInfo();
      setCustomerInfo(info);
    } catch (error) {
      console.error('Failed to fetch customer info:', error);
    }
  }, []);

  useEffect(() => {
    const initialize = async () => {
      setIsLoading(true);
      try {
        const [info, offers] = await Promise.all([
          revenueCatService.getCustomerInfo(),
          revenueCatService.getOfferings()
        ]);
        setCustomerInfo(info);
        setOfferings(offers);
      } catch (error) {
        console.error('Failed to initialize subscriptions:', error);
      } finally {
        setIsLoading(false);
      }
    };

    initialize();
  }, []);

  const purchasePackage = useCallback(async (pkg: PurchasePackage) => {
    setIsLoading(true);
    try {
      const info = await revenueCatService.purchasePackage(pkg.identifier);
      setCustomerInfo(info);
    } catch (error) {
      console.error('Purchase failed:', error);
      throw error;
    } finally {
      setIsLoading(false);
    }
  }, []);

  const restorePurchases = useCallback(async () => {
    setIsLoading(true);
    try {
      const info = await revenueCatService.restorePurchases();
      setCustomerInfo(info);
    } catch (error) {
      console.error('Restore failed:', error);
      throw error;
    } finally {
      setIsLoading(false);
    }
  }, []);

  return (
    <SubscriptionContext.Provider value={{
      customerInfo,
      offerings,
      isLoading,
      isPremium: customerInfo?.isPremium ?? false,
      purchasePackage,
      restorePurchases,
      refreshCustomerInfo
    }}>
      {children}
    </SubscriptionContext.Provider>
  );
}

export function useSubscription() {
  const context = useContext(SubscriptionContext);
  if (!context) {
    throw new Error('useSubscription must be used within SubscriptionProvider');
  }
  return context;
} 