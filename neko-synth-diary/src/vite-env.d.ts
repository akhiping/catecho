/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_REVENUECAT_API_KEY?: string;
  readonly VITE_TRANSCRIPTION_API_URL?: string;
  readonly VITE_TRANSCRIPTION_API_KEY?: string;
  readonly VITE_REFLECTION_API_URL?: string;
  readonly VITE_REFLECTION_API_KEY?: string;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}
