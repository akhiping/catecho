export type PlayerState = 'idle' | 'playing' | 'paused' | 'loading';

class AudioPlayerService {
  private audio: HTMLAudioElement | null = null;
  private stateCallback: ((state: PlayerState) => void) | null = null;
  private positionCallback: ((position: number) => void) | null = null;
  private durationCallback: ((duration: number) => void) | null = null;

  onStateChange(callback: (state: PlayerState) => void) {
    this.stateCallback = callback;
  }

  onPositionChange(callback: (position: number) => void) {
    this.positionCallback = callback;
  }

  onDurationChange(callback: (duration: number) => void) {
    this.durationCallback = callback;
  }

  async load(audioBlob: Blob): Promise<void> {
    this.stateCallback?.('loading');
    
    if (this.audio) {
      this.audio.pause();
      this.audio.src = '';
    }

    this.audio = new Audio();
    this.audio.src = URL.createObjectURL(audioBlob);

    this.audio.addEventListener('loadedmetadata', () => {
      this.durationCallback?.(this.audio!.duration * 1000);
      this.stateCallback?.('idle');
    });

    this.audio.addEventListener('timeupdate', () => {
      this.positionCallback?.(this.audio!.currentTime * 1000);
    });

    this.audio.addEventListener('ended', () => {
      this.stateCallback?.('idle');
      this.positionCallback?.(0);
    });

    this.audio.addEventListener('play', () => {
      this.stateCallback?.('playing');
    });

    this.audio.addEventListener('pause', () => {
      if (this.audio!.currentTime < this.audio!.duration) {
        this.stateCallback?.('paused');
      }
    });

    await this.audio.load();
  }

  play(): void {
    this.audio?.play().catch(err => {
      console.error('Playback error:', err);
    });
  }

  pause(): void {
    this.audio?.pause();
  }

  stop(): void {
    if (this.audio) {
      this.audio.pause();
      this.audio.currentTime = 0;
      this.stateCallback?.('idle');
    }
  }

  seek(positionMs: number): void {
    if (this.audio) {
      this.audio.currentTime = positionMs / 1000;
    }
  }

  dispose(): void {
    if (this.audio) {
      this.audio.pause();
      this.audio.src = '';
      this.audio = null;
    }
  }
}

export const audioPlayer = new AudioPlayerService(); 