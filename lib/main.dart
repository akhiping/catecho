import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'app.dart';
import 'data/local/hive_boxes.dart';
import 'data/models/journal_entry.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: '.env');
  
  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(JournalEntryAdapter());
  await HiveBoxes.init();
  
  // Initialize Sentry if DSN is provided
  final sentryDsn = dotenv.env['SENTRY_DSN'];
  if (sentryDsn != null && sentryDsn.isNotEmpty) {
    await SentryFlutter.init(
      (options) {
        options.dsn = sentryDsn;
        options.environment = 'development';
      },
      appRunner: () => runApp(
        ProviderScope(
          child: EchoJournalApp(),
        ),
      ),
    );
  } else {
    runApp(
      ProviderScope(
        child: EchoJournalApp(),
      ),
    );
  }
} 