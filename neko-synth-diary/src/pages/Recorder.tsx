import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { Square } from "lucide-react";
import { Button } from "@/components/ui/button";
import { useTheme } from "@/contexts/ThemeContext";
import { useEntries } from "@/contexts/EntriesContext";
import { useSubscription } from "@/contexts/SubscriptionContext";
import { audioRecorder } from "@/services/audio/recorder";
import { toast } from "sonner";
import echoCat from "@/assets/echo-cat.png";
import dogMascot from "@/assets/dog-mascot.png";
import rainforestMascot from "@/assets/rainforest-mascot.png";
import pixelStars from "@/assets/pixel-stars.png";

const Recorder = () => {
  const navigate = useNavigate();
  const { theme } = useTheme();
  const { addEntry } = useEntries();
  const { isPremium } = useSubscription();
  const [isRecording, setIsRecording] = useState(false);
  const [duration, setDuration] = useState(0);
  const [amplitude, setAmplitude] = useState(0);
  const [waveformData, setWaveformData] = useState<number[]>(
    Array.from({ length: 20 }, () => 0)
  );

  const getCurrentMascot = () => {
    if (theme === "dog") return dogMascot;
    if (theme === "rainforest") return rainforestMascot;
    return echoCat;
  };

  useEffect(() => {
    // Set up audio recorder callbacks
    audioRecorder.onStateChange((state) => {
      setIsRecording(state === 'recording');
    });

    audioRecorder.onDurationChange((ms) => {
      setDuration(Math.floor(ms / 1000));
    });

    audioRecorder.onAmplitudeChange((amp) => {
      setAmplitude(amp);
      // Update waveform with new amplitude
      setWaveformData(prev => {
        const newData = [...prev.slice(1), amp * 100];
        return newData;
      });
    });

    return () => {
      audioRecorder.dispose();
    };
  }, []);

  const handleRecord = async () => {
    if (isRecording) {
      // Stop recording
      const result = await audioRecorder.stopRecording();
      if (result) {
        toast.success("Recording saved! Processing...");
        
        try {
          await addEntry({
            title: `Entry ${new Date().toLocaleDateString()}`,
            audioBlob: result.audioBlob,
            audioDuration: result.durationMs,
            isProcessed: false,
            isUploaded: false
          });

          setTimeout(() => {
            navigate("/timeline");
          }, 500);
        } catch (error) {
          toast.error("Failed to save recording");
          console.error(error);
        }
      }
    } else {
      // Check permissions and start recording
      const hasPermission = await audioRecorder.requestPermission();
      if (!hasPermission) {
        toast.error("Microphone permission denied");
        return;
      }

      const started = await audioRecorder.startRecording();
      if (!started) {
        toast.error("Failed to start recording");
      } else {
        setDuration(0);
        setWaveformData(Array.from({ length: 20 }, () => 0));
      }
    }
  };

  const formatTime = (seconds: number) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins.toString().padStart(2, "0")}:${secs.toString().padStart(2, "0")}`;
  };

  return (
    <div className="min-h-screen bg-background scanlines flex flex-col items-center justify-center p-4 relative overflow-hidden">
      {/* Floating particles */}
      {isRecording && (
        <div className="absolute inset-0 pointer-events-none">
          {Array.from({ length: 10 }).map((_, i) => (
            <img
              key={i}
              src={pixelStars}
              alt=""
              className="absolute w-4 h-4 animate-float opacity-50"
              style={{
                left: `${Math.random() * 100}%`,
                top: `${Math.random() * 100}%`,
                animationDelay: `${Math.random() * 2}s`,
                animationDuration: `${3 + Math.random() * 2}s`,
              }}
            />
          ))}
        </div>
      )}

      <div className="max-w-lg w-full space-y-8 relative z-10">
        {/* Header */}
        <div className="text-center">
          <h1 className="font-pixel text-base md:text-lg neon-glow mb-2">
            ⚡ RECORD ENTRY ⚡
          </h1>
        </div>

        {/* Mascot Character */}
        <div className="flex justify-center">
          <div className="relative">
            <img
              src={getCurrentMascot()}
              alt="Mascot"
              className={`w-32 h-32 md:w-40 md:h-40 ${
                isRecording ? "animate-float" : ""
              }`}
            />
            {isRecording && (
              <div className="absolute inset-0 rounded-full bg-primary/20 animate-pulse-glow"></div>
            )}
          </div>
        </div>

        {/* Cat Message */}
        <div className="text-center">
          <p className="font-retro text-2xl md:text-3xl text-secondary">
            {isRecording ? '"I\'m listening!"' : '"Ready to record?"'}
          </p>
        </div>

        {/* Waveform Display */}
        <div className="neon-border bg-card/50 backdrop-blur p-6">
          <div className="flex items-center justify-center gap-1 h-20">
            {waveformData.map((height, i) => (
              <div
                key={i}
                className={`flex-1 rounded-sm transition-all duration-100 ${
                  isRecording ? "bg-secondary" : "bg-muted"
                }`}
                style={{
                  height: isRecording ? `${Math.max(height, 20)}%` : "20%",
                }}
              />
            ))}
          </div>
        </div>

        {/* Timer */}
        <div className="text-center">
          <div className="neon-border bg-card/80 backdrop-blur inline-block px-8 py-4">
            <span className="font-pixel text-2xl md:text-3xl text-primary">
              {formatTime(duration)}
            </span>
          </div>
        </div>

        {/* Record Button */}
        <div className="flex flex-col items-center gap-4">
          <Button
            variant="hero"
            size="lg"
            onClick={handleRecord}
            className={`w-24 h-24 rounded-full text-4xl ${
              isRecording ? "animate-pulse-glow" : ""
            }`}
          >
            {isRecording ? <Square className="w-10 h-10" /> : "⬛"}
          </Button>
          <p className="font-pixel text-xs text-muted-foreground">
            {isRecording ? "PRESS TO STOP" : "PRESS TO START"}
          </p>
        </div>
      </div>
    </div>
  );
};

export default Recorder;
