import { useParams, useNavigate } from "react-router-dom";
import { ArrowLeft, Play, Pause, Edit, Share2, Trash2, Brain } from "lucide-react";
import { Button } from "@/components/ui/button";
import { useEntries } from "@/contexts/EntriesContext";
import { useSubscription } from "@/contexts/SubscriptionContext";
import { audioPlayer } from "@/services/audio/player";
import { useState, useEffect } from "react";
import { format } from "date-fns";
import { toast } from "sonner";
import echoCat from "@/assets/echo-cat.png";
import dogMascot from "@/assets/dog-mascot.png";
import rainforestMascot from "@/assets/rainforest-mascot.png";
import { useTheme } from "@/contexts/ThemeContext";

const EntryDetail = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const { getEntry, deleteEntry } = useEntries();
  const { isPremium } = useSubscription();
  const { theme } = useTheme();
  const [isPlaying, setIsPlaying] = useState(false);
  const [position, setPosition] = useState(0);
  const [duration, setDuration] = useState(0);

  const entry = getEntry(id!);

  const getCurrentMascot = () => {
    if (theme === "dog") return dogMascot;
    if (theme === "rainforest") return rainforestMascot;
    return echoCat;
  };

  useEffect(() => {
    if (!entry?.audioBlob) return;

    // Set up audio player callbacks
    audioPlayer.onStateChange((state) => {
      setIsPlaying(state === 'playing');
    });

    audioPlayer.onPositionChange((pos) => {
      setPosition(pos);
    });

    audioPlayer.onDurationChange((dur) => {
      setDuration(dur);
    });

    // Load the audio
    audioPlayer.load(entry.audioBlob).catch((err) => {
      console.error('Failed to load audio:', err);
      toast.error('Failed to load audio');
    });

    return () => {
      audioPlayer.dispose();
    };
  }, [entry?.audioBlob]);

  const handlePlayPause = () => {
    if (isPlaying) {
      audioPlayer.pause();
    } else {
      audioPlayer.play();
    }
  };

  const handleDelete = async () => {
    if (confirm('Delete this entry?')) {
      await deleteEntry(id!);
      toast.success('Entry deleted');
      navigate('/timeline');
    }
  };

  const formatDuration = (ms: number) => {
    const seconds = Math.floor(ms / 1000);
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins}m ${secs}s`;
  };

  const formatPosition = (ms: number) => {
    const seconds = Math.floor(ms / 1000);
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  };

  const getMoodEmoji = (mood?: string) => {
    const moods: Record<string, string> = {
      happy: "😺",
      thoughtful: "🤔",
      chill: "😎",
      excited: "⭐",
      sleepy: "😴",
    };
    return moods[mood || ''] || "😺";
  };

  if (!entry) {
    return (
      <div className="min-h-screen bg-background scanlines flex items-center justify-center">
        <div className="text-center">
          <p className="font-retro text-2xl text-muted-foreground mb-4">Entry not found</p>
          <Button onClick={() => navigate('/timeline')}>Go Back</Button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-background scanlines">
      {/* Header */}
      <header className="border-b-2 border-primary bg-card/50 backdrop-blur sticky top-0 z-10">
        <div className="container mx-auto px-4 py-4 flex items-center justify-between">
          <Button variant="ghost" size="sm" className="gap-2" onClick={() => navigate("/timeline")}>
            <ArrowLeft className="w-4 h-4" />
            BACK
          </Button>
          <h1 className="font-pixel text-xs">ENTRY DETAIL</h1>
          <Button variant="ghost" size="icon">
            <span className="text-lg">⋯</span>
          </Button>
        </div>
      </header>

      {/* Main Content */}
      <main className="container mx-auto px-4 py-8 max-w-2xl">
        <div className="space-y-6 animate-fade-in">
          {/* Entry Header */}
          <div className="flex items-start gap-4">
            <img src={getCurrentMascot()} alt="Mascot" className="w-12 h-12 animate-float" />
            <div className="flex-1">
              <h2 className="font-pixel text-base text-primary mb-2">{entry.title}</h2>
              <div className="flex items-center gap-2 font-retro text-lg text-muted-foreground flex-wrap">
                <span>{format(entry.createdAt, 'EEEE, MMM d • h:mm a')}</span>
                <span>•</span>
                <span>🎵 {formatDuration(entry.audioDuration)}</span>
                <span>•</span>
                <span>{getMoodEmoji(entry.mood)}</span>
              </div>
            </div>
          </div>

          {/* Processing Status */}
          {!entry.isProcessed && (
            <div className="pixel-border bg-card/80 backdrop-blur p-4 text-center">
              <p className="font-pixel text-xs text-secondary animate-pulse">
                🤖 Processing your entry...
              </p>
            </div>
          )}

          {/* Transcript Section */}
          {entry.transcript && (
            <div className="neon-border bg-card/80 backdrop-blur p-6">
              <div className="flex items-center gap-2 mb-4">
                <span className="font-pixel text-xs text-secondary">💭 TRANSCRIPT</span>
              </div>
              <div className="h-[1px] bg-primary/30 mb-4"></div>
              <p className="font-retro text-lg leading-relaxed text-foreground/90">
                {entry.transcript}
              </p>
            </div>
          )}

          {/* AI Reflection Section */}
          {entry.aiReflection && (
            <div className="neon-border bg-gradient-to-br from-card/80 to-muted/20 backdrop-blur p-6">
              <div className="flex items-center gap-2 mb-4">
                <Brain className="w-4 h-4 text-accent animate-pulse" />
                <span className="font-pixel text-xs text-accent">🤖 AI REFLECTION</span>
                {isPremium && (
                  <span className="font-pixel text-[8px] text-primary">(PREMIUM)</span>
                )}
              </div>
              <div className="h-[1px] bg-accent/30 mb-4"></div>
              <p className="font-retro text-lg leading-relaxed text-foreground/80">
                {entry.aiReflection}
              </p>
            </div>
          )}

          {/* Audio Player Section */}
          <div className="pixel-border bg-card/80 backdrop-blur p-6">
            <div className="flex items-center gap-2 mb-4">
              <span className="font-pixel text-xs text-primary">🎵 AUDIO PLAYER</span>
            </div>
            
            {/* Waveform Visualization */}
            <div className="flex items-center gap-1 h-16 mb-4">
              {Array.from({ length: 30 }).map((_, i) => {
                const progress = duration > 0 ? position / duration : 0;
                const isActive = i / 30 < progress;
                return (
                  <div
                    key={i}
                    className={`flex-1 rounded-sm transition-colors ${
                      isActive ? 'bg-secondary' : 'bg-secondary/30'
                    }`}
                    style={{
                      height: `${20 + Math.random() * 80}%`,
                    }}
                  />
                );
              })}
            </div>

            {/* Player Controls */}
            <div className="flex items-center gap-4">
              <Button variant="neon" size="icon" onClick={handlePlayPause}>
                {isPlaying ? <Pause className="w-4 h-4" /> : <Play className="w-4 h-4" />}
              </Button>
              <div className="flex-1 flex items-center gap-2">
                <span className="font-pixel text-[10px] text-muted-foreground min-w-[40px]">
                  {formatPosition(position)}
                </span>
                <div className="h-1 flex-1 bg-muted rounded-full overflow-hidden">
                  <div 
                    className="h-full bg-primary transition-all duration-100"
                    style={{ width: `${duration > 0 ? (position / duration) * 100 : 0}%` }}
                  ></div>
                </div>
                <span className="font-pixel text-[10px] text-muted-foreground min-w-[40px]">
                  {formatPosition(duration)}
                </span>
              </div>
            </div>
          </div>

          {/* Action Buttons */}
          <div className="grid grid-cols-3 gap-3">
            <Button variant="outline" className="gap-2" onClick={() => toast.info('Edit feature coming soon!')}>
              <Edit className="w-4 h-4" />
              EDIT
            </Button>
            <Button variant="outline" className="gap-2" onClick={() => toast.info('Share feature coming soon!')}>
              <Share2 className="w-4 h-4" />
              SHARE
            </Button>
            <Button variant="destructive" className="gap-2" onClick={handleDelete}>
              <Trash2 className="w-4 h-4" />
              DELETE
            </Button>
          </div>
        </div>
      </main>
    </div>
  );
};

export default EntryDetail;

