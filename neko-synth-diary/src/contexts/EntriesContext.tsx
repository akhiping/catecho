import React, { createContext, useContext, useState, useEffect, useCallback, ReactNode } from 'react';
import { db, JournalEntry } from '@/lib/db';
import { v4 as uuidv4 } from 'uuid';
import { transcriptionService } from '@/services/ai/transcription';
import { reflectionService } from '@/services/ai/reflection';
import { useLiveQuery } from 'dexie-react-hooks';

interface EntriesContextType {
  entries: JournalEntry[];
  isLoading: boolean;
  addEntry: (entry: Omit<JournalEntry, 'id' | 'createdAt'>) => Promise<string>;
  updateEntry: (id: string, updates: Partial<JournalEntry>) => Promise<void>;
  deleteEntry: (id: string) => Promise<void>;
  processEntry: (id: string) => Promise<void>;
  getEntry: (id: string) => JournalEntry | undefined;
}

const EntriesContext = createContext<EntriesContextType | undefined>(undefined);

export function EntriesProvider({ children }: { children: ReactNode }) {
  const [isLoading, setIsLoading] = useState(false);
  
  // Use Dexie's live query for reactive updates
  const entries = useLiveQuery(
    () => db.entries.orderBy('createdAt').reverse().toArray(),
    []
  ) ?? [];

  const addEntry = useCallback(async (entry: Omit<JournalEntry, 'id' | 'createdAt'>) => {
    const id = uuidv4();
    const newEntry: JournalEntry = {
      ...entry,
      id,
      createdAt: new Date(),
    };
    
    await db.entries.add(newEntry);
    
    // Process in background if not already processed
    if (!entry.isProcessed && entry.audioBlob) {
      processEntry(id).catch(console.error);
    }
    
    return id;
  }, []);

  const updateEntry = useCallback(async (id: string, updates: Partial<JournalEntry>) => {
    await db.entries.update(id, updates);
  }, []);

  const deleteEntry = useCallback(async (id: string) => {
    await db.entries.delete(id);
  }, []);

  const processEntry = useCallback(async (id: string) => {
    const entry = await db.entries.get(id);
    if (!entry || !entry.audioBlob || entry.isProcessed) return;

    try {
      // Transcribe audio
      const transcription = await transcriptionService.transcribe(entry.audioBlob);
      
      // Generate AI reflection
      const reflection = await reflectionService.generateReflection(transcription.text);
      
      // Update entry with results
      await db.entries.update(id, {
        transcript: transcription.text,
        aiReflection: reflection.reflection,
        mood: reflection.mood,
        isProcessed: true
      });
    } catch (error) {
      console.error('Failed to process entry:', error);
    }
  }, []);

  const getEntry = useCallback((id: string) => {
    return entries.find(e => e.id === id);
  }, [entries]);

  return (
    <EntriesContext.Provider value={{
      entries,
      isLoading,
      addEntry,
      updateEntry,
      deleteEntry,
      processEntry,
      getEntry
    }}>
      {children}
    </EntriesContext.Provider>
  );
}

export function useEntries() {
  const context = useContext(EntriesContext);
  if (!context) {
    throw new Error('useEntries must be used within EntriesProvider');
  }
  return context;
} 