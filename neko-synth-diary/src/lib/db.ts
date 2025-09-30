import Dexie, { Table } from 'dexie';

export interface JournalEntry {
  id?: string;
  createdAt: Date;
  title: string;
  audioBlob?: Blob;
  audioDuration: number;
  transcript?: string;
  aiReflection?: string;
  mood?: string;
  isProcessed: boolean;
  isUploaded: boolean;
}

export interface DailyUsage {
  date: string; // YYYY-MM-DD
  count: number;
}

class NekoDatabase extends Dexie {
  entries!: Table<JournalEntry, string>;
  dailyUsage!: Table<DailyUsage, string>;

  constructor() {
    super('NekoSynthDiary');
    this.version(1).stores({
      entries: 'id, createdAt, title, isProcessed',
      dailyUsage: 'date'
    });
  }
}

export const db = new NekoDatabase(); 