import * as React from "react";
import { Slot } from "@radix-ui/react-slot";
import { cva, type VariantProps } from "class-variance-authority";

import { cn } from "@/lib/utils";

const buttonVariants = cva(
  "inline-flex items-center justify-center gap-2 whitespace-nowrap text-sm font-medium ring-offset-background transition-all focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:size-4 [&_svg]:shrink-0 font-pixel uppercase",
  {
    variants: {
      variant: {
        default: "bg-primary text-primary-foreground hover:bg-primary/90 rounded-pixel border-2 border-primary",
        destructive: "bg-destructive text-destructive-foreground hover:bg-destructive/90 rounded-pixel border-2 border-destructive",
        outline: "border-2 border-primary bg-transparent text-foreground hover:bg-primary/10 rounded-pixel",
        secondary: "bg-secondary text-secondary-foreground hover:bg-secondary/80 rounded-pixel border-2 border-secondary",
        ghost: "hover:bg-accent hover:text-accent-foreground rounded-pixel",
        link: "text-primary underline-offset-4 hover:underline",
        neon: "bg-transparent border-2 border-primary text-foreground hover:bg-primary hover:text-primary-foreground rounded-pixel shadow-neon-pink hover:shadow-neon-blue transition-all duration-300",
        pixel: "bg-card border-4 border-primary text-foreground hover:translate-y-[-2px] rounded-pixel shadow-lg hover:shadow-neon-pink",
        hero: "bg-gradient-to-r from-primary to-secondary text-primary-foreground border-2 border-primary rounded-pixel shadow-neon-pink hover:shadow-neon-blue hover:scale-105 transition-all duration-300",
      },
      size: {
        default: "h-12 px-6 py-3 text-xs",
        sm: "h-10 px-4 text-[10px]",
        lg: "h-14 px-8 text-sm",
        icon: "h-12 w-12",
      },
    },
    defaultVariants: {
      variant: "default",
      size: "default",
    },
  },
);

export interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
  asChild?: boolean;
}

const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant, size, asChild = false, ...props }, ref) => {
    const Comp = asChild ? Slot : "button";
    return <Comp className={cn(buttonVariants({ variant, size, className }))} ref={ref} {...props} />;
  },
);
Button.displayName = "Button";

export { Button, buttonVariants };
