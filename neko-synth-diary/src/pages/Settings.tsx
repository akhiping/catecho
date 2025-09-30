import { Link } from "react-router-dom";
import { ArrowLeft, User, RefreshCw, Palette, Moon, Bell, BookOpen } from "lucide-react";
import { Button } from "@/components/ui/button";
import { useTheme } from "@/contexts/ThemeContext";
import echoCat from "@/assets/echo-cat.png";
import dogMascot from "@/assets/dog-mascot.png";
import rainforestMascot from "@/assets/rainforest-mascot.png";

const Settings = () => {
  const { theme, setTheme } = useTheme();

  const accountSettings = [
    { icon: User, label: "Manage Subscription", action: "→" },
    { icon: RefreshCw, label: "Restore Purchases", action: "→" },
  ];

  const themes = [
    { id: "cat", name: "Echo Cat (Cyan)", emoji: "🐱", image: echoCat },
    { id: "dog", name: "Woof Buddy (Orange)", emoji: "🐶", image: dogMascot },
    { id: "rainforest", name: "Jungle Pal (Green)", emoji: "🐸", image: rainforestMascot },
  ];

  const customizeSettings = [
    { icon: Moon, label: "Dark Mode", toggle: true, value: true },
    { icon: Bell, label: "Notifications", toggle: true, value: true },
  ];

  return (
    <div className="min-h-screen bg-background scanlines">
      {/* Header */}
      <header className="border-b-2 border-primary bg-card/50 backdrop-blur">
        <div className="container mx-auto px-4 py-4 flex items-center justify-between">
          <Link to="/timeline">
            <Button variant="ghost" size="sm" className="gap-2">
              <ArrowLeft className="w-4 h-4" />
              BACK
            </Button>
          </Link>
          <h1 className="font-pixel text-sm">SETTINGS</h1>
          <div className="w-20"></div>
        </div>
      </header>

      {/* Main Content */}
      <main className="container mx-auto px-4 py-8 max-w-2xl">
        <div className="space-y-8 animate-fade-in">
          {/* Account Status */}
          <div className="neon-border bg-card/80 backdrop-blur p-6 text-center">
            <div className="flex items-center justify-center gap-2 mb-2">
              <span className="font-pixel text-sm text-muted-foreground">🔒 FREE PLAN</span>
            </div>
            <p className="font-retro text-lg text-muted-foreground mb-4">
              Upgrade for unlimited entries
            </p>
            <Link to="/premium">
              <Button variant="hero" size="sm">
                ⚡ UPGRADE ⚡
              </Button>
            </Link>
          </div>

          {/* Account Section */}
          <div>
            <div className="flex items-center gap-2 mb-4">
              <div className="h-[2px] flex-1 bg-primary/30"></div>
              <span className="font-pixel text-xs text-primary">ACCOUNT</span>
              <div className="h-[2px] flex-1 bg-primary/30"></div>
            </div>

            <div className="space-y-3">
              {accountSettings.map((setting, idx) => (
                <button
                  key={idx}
                  className="w-full pixel-border bg-card/80 backdrop-blur p-4 flex items-center gap-4 hover-scale transition-all hover:shadow-neon-pink"
                >
                  <setting.icon className="w-5 h-5 text-primary" />
                  <span className="font-retro text-lg flex-1 text-left">{setting.label}</span>
                  <span className="font-pixel text-xs text-muted-foreground">{setting.action}</span>
                </button>
              ))}
            </div>
          </div>

          {/* Theme Selector */}
          <div>
            <div className="flex items-center gap-2 mb-4">
              <div className="h-[2px] flex-1 bg-primary/30"></div>
              <span className="font-pixel text-xs text-primary">CHOOSE MASCOT</span>
              <div className="h-[2px] flex-1 bg-primary/30"></div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-3">
              {themes.map((themeOption) => (
                <button
                  key={themeOption.id}
                  onClick={() => setTheme(themeOption.id as any)}
                  className={`pixel-border backdrop-blur p-4 flex flex-col items-center gap-3 hover-scale transition-all ${
                    theme === themeOption.id
                      ? "bg-primary/20 border-primary shadow-neon-pink"
                      : "bg-card/80 hover:shadow-neon-blue"
                  }`}
                >
                  <img
                    src={themeOption.image}
                    alt={themeOption.name}
                    className="w-16 h-16 animate-float"
                  />
                  <div className="text-center">
                    <div className="text-2xl mb-1">{themeOption.emoji}</div>
                    <div className="font-retro text-sm">{themeOption.name}</div>
                  </div>
                  {theme === themeOption.id && (
                    <div className="font-pixel text-[8px] text-primary">✓ ACTIVE</div>
                  )}
                </button>
              ))}
            </div>
          </div>

          {/* Customize Section */}
          <div>
            <div className="flex items-center gap-2 mb-4">
              <div className="h-[2px] flex-1 bg-primary/30"></div>
              <span className="font-pixel text-xs text-primary">CUSTOMIZE</span>
              <div className="h-[2px] flex-1 bg-primary/30"></div>
            </div>

            <div className="space-y-3">
              {customizeSettings.map((setting, idx) => (
                <div
                  key={idx}
                  className="pixel-border bg-card/80 backdrop-blur p-4 flex items-center gap-4"
                >
                  <setting.icon className="w-5 h-5 text-secondary" />
                  <div className="flex-1">
                    <div className="font-retro text-lg">{setting.label}</div>
                    {setting.value && typeof setting.value === "string" && (
                      <div className="font-retro text-sm text-muted-foreground">
                        Current: {setting.value}
                      </div>
                    )}
                  </div>
                  <div
                    className={`w-12 h-6 rounded-full flex items-center px-1 cursor-pointer transition-colors ${
                      setting.value ? "bg-primary" : "bg-muted"
                    }`}
                  >
                    <div
                      className={`w-4 h-4 bg-foreground rounded-full transition-transform ${
                        setting.value ? "translate-x-6" : ""
                      }`}
                    ></div>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* About Section */}
          <div>
            <div className="flex items-center gap-2 mb-4">
              <div className="h-[2px] flex-1 bg-primary/30"></div>
              <span className="font-pixel text-xs text-primary">ABOUT</span>
              <div className="h-[2px] flex-1 bg-primary/30"></div>
            </div>

            <button className="w-full pixel-border bg-card/80 backdrop-blur p-4 flex items-center gap-4 hover-scale transition-all">
              <BookOpen className="w-5 h-5 text-accent" />
              <span className="font-retro text-lg flex-1 text-left">Version 1.0.0 (Neko)</span>
              <span className="font-pixel text-xs text-muted-foreground">→</span>
            </button>
          </div>

          {/* Decorative Mascot */}
          <div className="flex justify-center pt-8">
            <img
              src={theme === "dog" ? dogMascot : theme === "rainforest" ? rainforestMascot : echoCat}
              alt="Mascot"
              className="w-16 h-16 animate-float opacity-50"
            />
          </div>
        </div>
      </main>
    </div>
  );
};

export default Settings;
