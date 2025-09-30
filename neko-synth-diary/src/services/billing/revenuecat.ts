import axios from 'axios';

export interface CustomerInfo {
  isPremium: boolean;
  activeSubscriptions: string[];
  expirationDate?: Date;
  memoryPacksCount: number;
}

export interface Offering {
  identifier: string;
  packages: PurchasePackage[];
}

export interface PurchasePackage {
  identifier: string;
  productId: string;
  title: string;
  description: string;
  price: string;
  priceAmount: number;
  currency: string;
  packageType: 'monthly' | 'yearly' | 'consumable';
}

class RevenueCatService {
  private apiKey: string;
  private appUserId: string;
  private baseUrl = 'https://api.revenuecat.com/v1';
  
  constructor() {
    this.apiKey = import.meta.env.VITE_REVENUECAT_API_KEY || '';
    this.appUserId = this.getOrCreateUserId();
  }

  private getOrCreateUserId(): string {
    let userId = localStorage.getItem('rc_user_id');
    if (!userId) {
      userId = `web_user_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
      localStorage.setItem('rc_user_id', userId);
    }
    return userId;
  }

  async getCustomerInfo(): Promise<CustomerInfo> {
    try {
      if (!this.apiKey) {
        // Return mock premium for development
        return {
          isPremium: true,
          activeSubscriptions: ['premium_monthly'],
          memoryPacksCount: 5
        };
      }

      const response = await axios.get(
        `${this.baseUrl}/subscribers/${this.appUserId}`,
        {
          headers: {
            'Authorization': `Bearer ${this.apiKey}`,
            'Content-Type': 'application/json'
          }
        }
      );

      const subscriber = response.data.subscriber;
      const entitlements = subscriber.entitlements || {};
      const premiumEntitlement = entitlements['premium'];

      return {
        isPremium: premiumEntitlement && new Date(premiumEntitlement.expires_date) > new Date(),
        activeSubscriptions: Object.keys(subscriber.subscriptions || {}),
        expirationDate: premiumEntitlement ? new Date(premiumEntitlement.expires_date) : undefined,
        memoryPacksCount: Object.keys(subscriber.non_subscriptions || {}).length
      };
    } catch (error) {
      console.error('Failed to get customer info:', error);
      // Return free tier on error
      return {
        isPremium: false,
        activeSubscriptions: [],
        memoryPacksCount: 0
      };
    }
  }

  async getOfferings(): Promise<Offering[]> {
    // For web, we'll return hardcoded offerings
    // In production, you'd fetch these from RevenueCat API
    return [
      {
        identifier: 'default',
        packages: [
          {
            identifier: 'monthly',
            productId: 'premium_monthly',
            title: 'Monthly Premium',
            description: 'Unlimited entries and AI insights',
            price: '$4.99',
            priceAmount: 4.99,
            currency: 'USD',
            packageType: 'monthly'
          },
          {
            identifier: 'annual',
            productId: 'premium_annual',
            title: 'Annual Premium',
            description: 'Unlimited entries and AI insights - Save 33%!',
            price: '$39.99',
            priceAmount: 39.99,
            currency: 'USD',
            packageType: 'yearly'
          },
          {
            identifier: 'memory_pack_bronze',
            productId: 'memory_pack_bronze',
            title: 'Bronze Memory Pack',
            description: '10 extra entries',
            price: '$0.99',
            priceAmount: 0.99,
            currency: 'USD',
            packageType: 'consumable'
          },
          {
            identifier: 'memory_pack_silver',
            productId: 'memory_pack_silver',
            title: 'Silver Memory Pack',
            description: '30 extra entries',
            price: '$2.99',
            priceAmount: 2.99,
            currency: 'USD',
            packageType: 'consumable'
          },
          {
            identifier: 'memory_pack_gold',
            productId: 'memory_pack_gold',
            title: 'Gold Memory Pack',
            description: '100 extra entries',
            price: '$4.99',
            priceAmount: 4.99,
            currency: 'USD',
            packageType: 'consumable'
          }
        ]
      }
    ];
  }

  async purchasePackage(packageIdentifier: string): Promise<CustomerInfo> {
    try {
      // For web implementation, you'd redirect to Stripe/Payment gateway
      // Then call RevenueCat API to record the purchase
      console.log('Initiating purchase for:', packageIdentifier);
      
      // For demo purposes, simulate successful purchase
      if (!this.apiKey) {
        alert('Purchase simulation! In production, this would redirect to payment gateway.');
        return {
          isPremium: true,
          activeSubscriptions: [packageIdentifier],
          memoryPacksCount: 0
        };
      }

      // In production, implement actual payment flow with Stripe or other gateway
      throw new Error('Payment gateway not configured');
    } catch (error) {
      console.error('Purchase failed:', error);
      throw error;
    }
  }

  async restorePurchases(): Promise<CustomerInfo> {
    // Fetch latest customer info from RevenueCat
    return this.getCustomerInfo();
  }
}

export const revenueCatService = new RevenueCatService(); 