import { Link } from "react-router-dom";
import { Crown, Sparkles, Brain, Calendar, Palette, TrendingUp, ArrowLeft } from "lucide-react";
import { Button } from "@/components/ui/button";
import { useSubscription } from "@/contexts/SubscriptionContext";
import { toast } from "sonner";
import { useState } from "react";
import premiumCat from "@/assets/premium-cat.png";

const Premium = () => {
  const { offerings, purchasePackage, restorePurchases, isPremium, isLoading } = useSubscription();
  const [selectedPlan, setSelectedPlan] = useState<string | null>(null);

  const features = [
    { icon: Sparkles, text: "UNLIMITED ENTRIES" },
    { icon: Brain, text: "AI MOOD INSIGHTS" },
    { icon: Calendar, text: "MEMORY LANE THROWBACKS" },
    { icon: Palette, text: "EXCLUSIVE CAT SKINS" },
    { icon: TrendingUp, text: "ADVANCED ANALYTICS" },
  ];

  const defaultOffering = offerings[0];
  const subscriptions = defaultOffering?.packages.filter(p => p.packageType === 'monthly' || p.packageType === 'yearly') || [];
  const memoryPacks = defaultOffering?.packages.filter(p => p.packageType === 'consumable') || [];

  const handlePurchase = async (pkg: any) => {
    setSelectedPlan(pkg.identifier);
    try {
      await purchasePackage(pkg);
      toast.success('🎉 Purchase successful! Premium activated!');
    } catch (error) {
      console.error('Purchase failed:', error);
      // toast.error is already shown by the service
    } finally {
      setSelectedPlan(null);
    }
  };

  const handleRestore = async () => {
    try {
      await restorePurchases();
      toast.success('Purchases restored!');
    } catch (error) {
      toast.error('Failed to restore purchases');
    }
  };

  if (isPremium) {
    return (
      <div className="min-h-screen bg-background scanlines">
        <header className="border-b-2 border-primary bg-card/50 backdrop-blur">
          <div className="container mx-auto px-4 py-4">
            <Link to="/timeline">
              <Button variant="ghost" size="sm" className="gap-2">
                <ArrowLeft className="w-4 h-4" />
                BACK
              </Button>
            </Link>
          </div>
        </header>

        <main className="container mx-auto px-4 py-12 max-w-2xl">
          <div className="text-center space-y-8">
            <img
              src={premiumCat}
              alt="Premium Cat"
              className="w-40 h-40 animate-float mx-auto drop-shadow-[0_0_30px_rgba(255,16,240,0.5)]"
            />
            <h1 className="font-pixel text-2xl neon-glow">
              YOU'RE PREMIUM! 👑
            </h1>
            <p className="font-retro text-xl text-muted-foreground">
              Enjoy all the neko powers!
            </p>
            <Link to="/timeline">
              <Button variant="hero" size="lg">
                BACK TO TIMELINE
              </Button>
            </Link>
          </div>
        </main>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-background scanlines">
      {/* Header */}
      <header className="border-b-2 border-primary bg-card/50 backdrop-blur">
        <div className="container mx-auto px-4 py-4">
          <Link to="/timeline">
            <Button variant="ghost" size="sm" className="gap-2">
              <ArrowLeft className="w-4 h-4" />
              BACK
            </Button>
          </Link>
        </div>
      </header>

      {/* Main Content */}
      <main className="container mx-auto px-4 py-12 max-w-2xl">
        <div className="text-center space-y-8 animate-fade-in">
          {/* Crown Icon */}
          <div className="flex justify-center">
            <div className="pixel-border bg-card/80 p-4 inline-block">
              <Crown className="w-12 h-12 text-primary animate-pulse" />
            </div>
          </div>

          {/* Title */}
          <div>
            <h1 className="font-pixel text-xl md:text-2xl neon-glow mb-2">
              PREMIUM NEKO POWERS
            </h1>
            <div className="flex items-center justify-center gap-2">
              <div className="h-[2px] flex-1 bg-primary/30 max-w-[100px]"></div>
              <div className="h-[2px] flex-1 bg-primary/30 max-w-[100px]"></div>
            </div>
          </div>

          {/* Premium Cat */}
          <div className="flex justify-center">
            <img
              src={premiumCat}
              alt="Premium Cat"
              className="w-40 h-40 animate-float drop-shadow-[0_0_30px_rgba(255,16,240,0.5)]"
            />
          </div>

          {/* Features */}
          <div className="neon-border bg-card/80 backdrop-blur p-6 space-y-4">
            {features.map((feature, idx) => (
              <div
                key={idx}
                className="flex items-center gap-4 p-3 bg-background/50 rounded-pixel hover-scale transition-all"
              >
                <feature.icon className="w-6 h-6 text-secondary" />
                <span className="font-pixel text-xs text-foreground flex-1 text-left">
                  {feature.text}
                </span>
              </div>
            ))}
          </div>

          {/* Subscription Plans */}
          <div className="space-y-4">
            {subscriptions.map((plan) => (
              <div
                key={plan.identifier}
                className={`neon-border bg-gradient-to-r from-card/80 to-muted/40 backdrop-blur p-6 hover-scale transition-all cursor-pointer ${
                  plan.packageType === 'yearly' ? 'border-accent shadow-neon-pink' : ''
                }`}
                onClick={() => !isLoading && handlePurchase(plan)}
              >
                <div className="flex items-center justify-between mb-2">
                  <div className="flex items-center gap-2">
                    <span className="text-2xl">{plan.packageType === 'yearly' ? '🌟' : '💎'}</span>
                    <span className="font-pixel text-sm text-primary">{plan.title.toUpperCase()}</span>
                  </div>
                  <span className="font-pixel text-lg text-secondary">{plan.price}</span>
                </div>
                <p className="font-retro text-base text-muted-foreground">
                  {plan.description}
                </p>
                {plan.packageType === 'yearly' && (
                  <div className="mt-2 font-pixel text-xs text-accent">
                    [SAVE 33% + BONUS CAT!]
                  </div>
                )}
                {selectedPlan === plan.identifier && (
                  <div className="mt-2 font-pixel text-xs text-secondary animate-pulse">
                    Processing...
                  </div>
                )}
              </div>
            ))}
          </div>

          {/* Memory Packs */}
          {memoryPacks.length > 0 && (
            <>
              <div className="flex items-center justify-center gap-4">
                <div className="h-[2px] flex-1 bg-primary/30"></div>
                <span className="font-pixel text-xs text-primary">MEMORY PACKS (ONE-TIME)</span>
                <div className="h-[2px] flex-1 bg-primary/30"></div>
              </div>

              <div className="grid grid-cols-3 gap-3">
                {memoryPacks.map((pack) => (
                  <Button
                    key={pack.identifier}
                    variant="outline"
                    className="flex flex-col gap-2 h-auto py-4"
                    onClick={() => !isLoading && handlePurchase(pack)}
                    disabled={isLoading && selectedPlan === pack.identifier}
                  >
                    <span className="text-2xl">{pack.identifier.includes('bronze') ? '🥉' : pack.identifier.includes('silver') ? '🥈' : '🥇'}</span>
                    <span className="font-pixel text-[10px]">{pack.title.split(' ')[0]}</span>
                    <span className="font-pixel text-xs text-primary">{pack.price}</span>
                  </Button>
                ))}
              </div>
            </>
          )}

          {/* Purchase Button */}
          <Button 
            variant="hero" 
            size="lg" 
            className="w-full max-w-md"
            disabled={isLoading}
          >
            {isLoading ? 'PROCESSING...' : 'UNLOCK PREMIUM POWERS'}
          </Button>

          {/* Restore Purchases */}
          <Button 
            variant="ghost" 
            onClick={handleRestore}
            disabled={isLoading}
          >
            Restore Purchases
          </Button>
        </div>
      </main>
    </div>
  );
};

export default Premium;
