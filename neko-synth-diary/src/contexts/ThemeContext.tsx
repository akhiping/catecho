import { createContext, useContext, useState, useEffect, ReactNode } from "react";

type Theme = "cat" | "dog" | "rainforest";

interface ThemeContextType {
  theme: Theme;
  setTheme: (theme: Theme) => void;
  getMascot: () => string;
}

const ThemeContext = createContext<ThemeContextType | undefined>(undefined);

export const ThemeProvider = ({ children }: { children: ReactNode }) => {
  const [theme, setThemeState] = useState<Theme>(() => {
    const saved = localStorage.getItem("catecho-theme");
    return (saved as Theme) || "cat";
  });

  useEffect(() => {
    const root = document.documentElement;
    // Remove all theme classes
    root.classList.remove("theme-dog", "theme-rainforest");
    
    // Add new theme class if not default
    if (theme === "dog") {
      root.classList.add("theme-dog");
    } else if (theme === "rainforest") {
      root.classList.add("theme-rainforest");
    }
    
    localStorage.setItem("catecho-theme", theme);
  }, [theme]);

  const setTheme = (newTheme: Theme) => {
    setThemeState(newTheme);
  };

  const getMascot = () => {
    const mascots = {
      cat: "/src/assets/echo-cat.png",
      dog: "/src/assets/dog-mascot.png",
      rainforest: "/src/assets/rainforest-mascot.png",
    };
    return mascots[theme];
  };

  return (
    <ThemeContext.Provider value={{ theme, setTheme, getMascot }}>
      {children}
    </ThemeContext.Provider>
  );
};

export const useTheme = () => {
  const context = useContext(ThemeContext);
  if (!context) {
    throw new Error("useTheme must be used within ThemeProvider");
  }
  return context;
};
