export type RecordingState = 'idle' | 'recording' | 'paused';

export interface RecordingResult {
  audioBlob: Blob;
  durationMs: number;
}

class AudioRecorderService {
  private mediaRecorder: MediaRecorder | null = null;
  private audioChunks: Blob[] = [];
  private startTime: number = 0;
  private pausedDuration: number = 0;
  private pauseStartTime: number = 0;
  private stream: MediaStream | null = null;
  
  private stateCallback: ((state: RecordingState) => void) | null = null;
  private amplitudeCallback: ((amplitude: number) => void) | null = null;
  private durationCallback: ((ms: number) => void) | null = null;
  
  private audioContext: AudioContext | null = null;
  private analyser: AnalyserNode | null = null;
  private animationFrameId: number | null = null;

  onStateChange(callback: (state: RecordingState) => void) {
    this.stateCallback = callback;
  }

  onAmplitudeChange(callback: (amplitude: number) => void) {
    this.amplitudeCallback = callback;
  }

  onDurationChange(callback: (ms: number) => void) {
    this.durationCallback = callback;
  }

  async requestPermission(): Promise<boolean> {
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
      stream.getTracks().forEach(track => track.stop());
      return true;
    } catch (error) {
      console.error('Microphone permission denied:', error);
      return false;
    }
  }

  async startRecording(): Promise<boolean> {
    try {
      this.stream = await navigator.mediaDevices.getUserMedia({ 
        audio: {
          echoCancellation: true,
          noiseSuppression: true,
          sampleRate: 44100
        } 
      });

      // Set up audio analysis
      this.audioContext = new AudioContext();
      const source = this.audioContext.createMediaStreamSource(this.stream);
      this.analyser = this.audioContext.createAnalyser();
      this.analyser.fftSize = 256;
      source.connect(this.analyser);
      
      this.mediaRecorder = new MediaRecorder(this.stream, {
        mimeType: 'audio/webm;codecs=opus'
      });
      
      this.audioChunks = [];
      this.startTime = Date.now();
      this.pausedDuration = 0;

      this.mediaRecorder.ondataavailable = (event) => {
        if (event.data.size > 0) {
          this.audioChunks.push(event.data);
        }
      };

      this.mediaRecorder.start(100); // Collect data every 100ms
      this.stateCallback?.('recording');
      this.startAmplitudeMonitoring();
      this.startDurationTracking();

      return true;
    } catch (error) {
      console.error('Failed to start recording:', error);
      return false;
    }
  }

  async stopRecording(): Promise<RecordingResult | null> {
    return new Promise((resolve) => {
      if (!this.mediaRecorder || this.mediaRecorder.state === 'inactive') {
        resolve(null);
        return;
      }

      this.mediaRecorder.onstop = () => {
        const audioBlob = new Blob(this.audioChunks, { type: 'audio/webm' });
        const durationMs = Date.now() - this.startTime - this.pausedDuration;
        
        this.cleanup();
        this.stateCallback?.('idle');
        
        resolve({ audioBlob, durationMs });
      };

      this.mediaRecorder.stop();
      this.stopAmplitudeMonitoring();
    });
  }

  pauseRecording(): void {
    if (this.mediaRecorder && this.mediaRecorder.state === 'recording') {
      this.mediaRecorder.pause();
      this.pauseStartTime = Date.now();
      this.stateCallback?.('paused');
      this.stopAmplitudeMonitoring();
    }
  }

  resumeRecording(): void {
    if (this.mediaRecorder && this.mediaRecorder.state === 'paused') {
      this.mediaRecorder.resume();
      this.pausedDuration += Date.now() - this.pauseStartTime;
      this.stateCallback?.('recording');
      this.startAmplitudeMonitoring();
    }
  }

  private startAmplitudeMonitoring(): void {
    if (!this.analyser) return;

    const bufferLength = this.analyser.frequencyBinCount;
    const dataArray = new Uint8Array(bufferLength);

    const updateAmplitude = () => {
      if (!this.analyser) return;
      
      this.analyser.getByteTimeDomainData(dataArray);
      
      let sum = 0;
      for (let i = 0; i < bufferLength; i++) {
        const normalized = (dataArray[i] - 128) / 128;
        sum += normalized * normalized;
      }
      const rms = Math.sqrt(sum / bufferLength);
      const amplitude = Math.min(rms * 10, 1); // Normalize to 0-1
      
      this.amplitudeCallback?.(amplitude);
      this.animationFrameId = requestAnimationFrame(updateAmplitude);
    };

    updateAmplitude();
  }

  private stopAmplitudeMonitoring(): void {
    if (this.animationFrameId !== null) {
      cancelAnimationFrame(this.animationFrameId);
      this.animationFrameId = null;
    }
    this.amplitudeCallback?.(0);
  }

  private startDurationTracking(): void {
    const interval = setInterval(() => {
      if (this.mediaRecorder?.state === 'recording') {
        const durationMs = Date.now() - this.startTime - this.pausedDuration;
        this.durationCallback?.(durationMs);
      } else {
        clearInterval(interval);
      }
    }, 100);
  }

  private cleanup(): void {
    this.stream?.getTracks().forEach(track => track.stop());
    this.stream = null;
    this.audioContext?.close();
    this.audioContext = null;
    this.analyser = null;
    this.mediaRecorder = null;
  }

  dispose(): void {
    this.stopAmplitudeMonitoring();
    this.cleanup();
  }
}

export const audioRecorder = new AudioRecorderService(); 