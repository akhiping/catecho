import { Link } from "react-router-dom";
import { Play, Sparkles, Settings, Crown, Trash2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import { useTheme } from "@/contexts/ThemeContext";
import { useEntries } from "@/contexts/EntriesContext";
import { useSubscription } from "@/contexts/SubscriptionContext";
import { format, isToday, isYesterday } from "date-fns";
import { toast } from "sonner";
import echoCat from "@/assets/echo-cat.png";
import dogMascot from "@/assets/dog-mascot.png";
import rainforestMascot from "@/assets/rainforest-mascot.png";

const Timeline = () => {
  const { theme } = useTheme();
  const { entries, deleteEntry } = useEntries();
  const { isPremium } = useSubscription();
  
  const getCurrentMascot = () => {
    if (theme === "dog") return dogMascot;
    if (theme === "rainforest") return rainforestMascot;
    return echoCat;
  };

  const handleDelete = async (id: string, e: React.MouseEvent) => {
    e.preventDefault();
    e.stopPropagation();
    
    if (confirm("Delete this entry?")) {
      await deleteEntry(id);
      toast.success("Entry deleted");
    }
  };

  const formatDuration = (ms: number) => {
    const seconds = Math.floor(ms / 1000);
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins}m ${secs}s`;
  };

  const getDateLabel = (date: Date) => {
    if (isToday(date)) return "TODAY";
    if (isYesterday(date)) return "YESTERDAY";
    return format(date, "MMM d, yyyy").toUpperCase();
  };

  // Group entries by date
  const groupedEntries = entries.reduce((acc, entry) => {
    const dateLabel = getDateLabel(entry.createdAt);
    if (!acc[dateLabel]) {
      acc[dateLabel] = [];
    }
    acc[dateLabel].push(entry);
    return acc;
  }, {} as Record<string, typeof entries>);

  const randomEntry = entries.length > 7 ? entries[Math.floor(Math.random() * Math.min(entries.length, entries.length - 7))] : null;

  return (
    <div className="min-h-screen bg-background scanlines">
      {/* Header */}
      <header className="border-b-2 border-primary bg-card/50 backdrop-blur">
        <div className="container mx-auto px-4 py-4 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <img src={getCurrentMascot()} alt="Mascot" className="w-10 h-10 animate-float" />
            <h1 className="font-pixel text-sm md:text-base neon-glow">CATECHO</h1>
          </div>
          <div className="flex items-center gap-2">
            <Link to="/premium">
              <Button variant="neon" size="sm" className="gap-1">
                <Crown className="w-3 h-3" />
                <span className="hidden sm:inline">{isPremium ? "PREMIUM" : "UPGRADE"}</span>
              </Button>
            </Link>
            <Link to="/settings">
              <Button variant="ghost" size="icon">
                <Settings className="w-4 h-4" />
              </Button>
            </Link>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="container mx-auto px-4 py-8 max-w-3xl">
        {/* Throwback Memory Card - Only for premium with entries */}
        {isPremium && randomEntry && (
          <div className="mb-8 pixel-border bg-card/80 backdrop-blur p-6 animate-fade-in">
            <div className="flex items-center gap-2 mb-3">
              <Sparkles className="w-5 h-5 text-secondary animate-pulse" />
              <h2 className="font-pixel text-xs text-secondary">THROWBACK MEMORY</h2>
            </div>
            <p className="font-retro text-lg text-muted-foreground">
              "{randomEntry.transcript?.substring(0, 100)}..."
            </p>
            <Link to={`/entry/${randomEntry.id}`}>
              <Button variant="outline" size="sm" className="mt-4">
                VIEW MEMORY
              </Button>
            </Link>
          </div>
        )}

        {/* Timeline Entries */}
        {entries.length === 0 ? (
          <div className="text-center py-12">
            <p className="font-retro text-2xl text-muted-foreground mb-6">
              No entries yet! Start recording your thoughts.
            </p>
            <Link to="/record">
              <Button variant="hero" size="lg">
                ⚡ RECORD FIRST ENTRY
              </Button>
            </Link>
          </div>
        ) : (
          <div className="space-y-8">
            {Object.entries(groupedEntries).map(([dateLabel, dateEntries]) => (
              <div key={dateLabel}>
                <div className="flex items-center gap-4 mb-4">
                  <div className="flex-1 h-[2px] bg-primary/30"></div>
                  <span className="font-pixel text-xs text-primary">{dateLabel}</span>
                  <div className="flex-1 h-[2px] bg-primary/30"></div>
                </div>

                <div className="space-y-4">
                  {dateEntries.map((entry) => (
                    <Link key={entry.id} to={`/entry/${entry.id}`}>
                      <div className="neon-border bg-card/80 backdrop-blur p-6 hover-scale cursor-pointer transition-all duration-300 hover:shadow-neon-pink">
                        <div className="flex items-start justify-between mb-4">
                          <div className="flex-1">
                            <h3 className="font-pixel text-sm mb-2 text-primary">{entry.title}</h3>
                            <div className="flex items-center gap-2 font-retro text-muted-foreground text-lg">
                              <span>{format(entry.createdAt, "h:mm a")}</span>
                              <span>•</span>
                              <span>{formatDuration(entry.audioDuration)}</span>
                              {entry.mood && (
                                <>
                                  <span>•</span>
                                  <span>{getMoodEmoji(entry.mood)}</span>
                                </>
                              )}
                            </div>
                          </div>
                          <div className="flex items-center gap-2">
                            <img src={getCurrentMascot()} alt="Cat" className="w-8 h-8" />
                            <Button
                              variant="ghost"
                              size="icon"
                              className="h-8 w-8"
                              onClick={(e) => handleDelete(entry.id!, e)}
                            >
                              <Trash2 className="w-4 h-4" />
                            </Button>
                          </div>
                        </div>

                        {/* Pixel Waveform Preview */}
                        <div className="flex items-center gap-1 h-12 mb-4">
                          {Array.from({ length: 20 }).map((_, i) => (
                            <div
                              key={i}
                              className="flex-1 bg-secondary/50 rounded-sm"
                              style={{
                                height: `${20 + Math.random() * 80}%`,
                              }}
                            />
                          ))}
                        </div>

                        {entry.transcript && (
                          <p className="font-retro text-lg text-foreground/80 mb-4 line-clamp-2">
                            {entry.transcript}
                          </p>
                        )}

                        <div className="flex items-center gap-2">
                          <Button variant="neon" size="sm" className="gap-2">
                            <Play className="w-3 h-3" />
                            PLAY
                          </Button>
                          {entry.aiReflection && isPremium && (
                            <Button variant="outline" size="sm">
                              AI INSIGHT
                            </Button>
                          )}
                          {!entry.isProcessed && (
                            <span className="font-pixel text-xs text-muted-foreground">
                              Processing...
                            </span>
                          )}
                        </div>
                      </div>
                    </Link>
                  ))}
                </div>
              </div>
            ))}
          </div>
        )}
      </main>

      {/* Floating Action Button */}
      <Link to="/record">
        <Button
          variant="hero"
          size="lg"
          className="fixed bottom-8 right-8 rounded-full w-16 h-16 shadow-neon-pink animate-pulse-glow"
        >
          <span className="text-2xl">⚡</span>
        </Button>
      </Link>
    </div>
  );
};

const getMoodEmoji = (mood: string) => {
  const moods: Record<string, string> = {
    happy: "😺",
    thoughtful: "🤔",
    chill: "😎",
    excited: "⭐",
    sleepy: "😴",
  };
  return moods[mood] || "😺";
};

export default Timeline;
