import { Link } from "react-router-dom";
import { Button } from "@/components/ui/button";
import { useTheme } from "@/contexts/ThemeContext";
import echoCat from "@/assets/echo-cat.png";
import dogMascot from "@/assets/dog-mascot.png";
import rainforestMascot from "@/assets/rainforest-mascot.png";
import pixelStars from "@/assets/pixel-stars.png";

const Index = () => {
  const { theme } = useTheme();
  
  const getCurrentMascot = () => {
    if (theme === "dog") return dogMascot;
    if (theme === "rainforest") return rainforestMascot;
    return echoCat;
  };

  return (
    <div className="min-h-screen bg-background scanlines crt-screen flex flex-col items-center justify-center p-4 relative overflow-hidden">
      {/* Background stars */}
      <div className="absolute inset-0 pointer-events-none opacity-30">
        {Array.from({ length: 15 }).map((_, i) => (
          <img
            key={i}
            src={pixelStars}
            alt=""
            className="absolute w-3 h-3 animate-float"
            style={{
              left: `${Math.random() * 100}%`,
              top: `${Math.random() * 100}%`,
              animationDelay: `${Math.random() * 3}s`,
              animationDuration: `${4 + Math.random() * 2}s`,
            }}
          />
        ))}
      </div>

      <div className="max-w-md w-full space-y-12 relative z-10 animate-fade-in">
        {/* Logo / Title */}
        <div className="text-center space-y-4">
          <div className="flex justify-center items-center gap-2 mb-6">
            <div className="h-[2px] w-16 bg-gradient-to-r from-transparent to-primary"></div>
            <span className="font-pixel text-xs text-primary">▄▄▄▄▄</span>
            <div className="h-[2px] w-16 bg-gradient-to-l from-transparent to-primary"></div>
          </div>
          
          <h1 className="font-pixel text-2xl md:text-3xl neon-glow leading-relaxed">
            CATECHO
            <br />
            JOURNAL
          </h1>
          
          <div className="flex justify-center items-center gap-2 mt-4">
            <div className="h-[2px] w-16 bg-gradient-to-r from-transparent to-secondary"></div>
            <span className="font-pixel text-xs text-secondary">▀▀▀▀▀</span>
            <div className="h-[2px] w-16 bg-gradient-to-l from-transparent to-secondary"></div>
          </div>
        </div>

        {/* Mascot */}
        <div className="flex justify-center">
          <div className="relative">
            <img
              src={getCurrentMascot()}
              alt="Mascot"
              className="w-32 h-32 md:w-40 md:h-40 animate-float drop-shadow-[0_0_30px_rgba(0,240,255,0.5)]"
            />
            <div className="absolute -bottom-2 left-1/2 -translate-x-1/2 w-24 h-2 bg-primary/20 rounded-full blur-sm"></div>
          </div>
        </div>

        {/* Welcome Message */}
        <div className="text-center">
          <p className="font-retro text-2xl md:text-3xl text-secondary animate-pulse">
            "MEOW! Ready to record?"
          </p>
        </div>

        {/* CTA Button */}
        <div className="flex flex-col items-center gap-6">
          <Link to="/timeline" className="w-full max-w-xs">
            <Button variant="hero" size="lg" className="w-full gap-2 text-sm">
              <span className="text-lg">▶</span>
              START RECORDING
            </Button>
          </Link>

          <div className="flex gap-4">
            <button className="font-retro text-lg text-muted-foreground hover:text-foreground transition-colors underline">
              RESTORE PURCHASES
            </button>
            <Link to="/settings">
              <button className="font-retro text-lg text-muted-foreground hover:text-foreground transition-colors underline">
                SETTINGS
              </button>
            </Link>
          </div>
        </div>

        {/* Decorative Elements */}
        <div className="flex justify-center gap-8 pt-4 opacity-50">
          <div className="font-pixel text-[8px] text-primary">★</div>
          <div className="font-pixel text-[8px] text-secondary">★</div>
          <div className="font-pixel text-[8px] text-accent">★</div>
        </div>
      </div>
    </div>
  );
};

export default Index;
