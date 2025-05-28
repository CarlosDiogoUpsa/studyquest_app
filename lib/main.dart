import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // Import for localization

// Import your existing providers
import 'package:studyquest_app/providers/auth_provider.dart';
import 'package:studyquest_app/providers/streak_provider.dart';
import 'package:studyquest_app/providers/subject_provider.dart';
import 'package:studyquest_app/providers/task_provider.dart'; // Import your new TaskProvider

// Import your existing screens
import 'package:studyquest_app/screens/home_screen.dart';
import 'package:studyquest_app/screens/profile_screen.dart';
import 'package:studyquest_app/screens/quiz_screen.dart';
import 'package:studyquest_app/screens/subject_detail.dart';
import 'package:studyquest_app/screens/calendar_screen.dart'; // Import CalendarScreen

// Import your app theme
import 'package:studyquest_app/utils/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Your existing AuthProvider
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // Your existing SubjectProvider with initialization
        ChangeNotifierProvider(
          create: (_) => SubjectProvider(),
          builder: (context, child) {
            final provider = Provider.of<SubjectProvider>(
              context,
              listen: false,
            );
            provider.initialize();
            return child!;
          },
        ),

        // Your existing StreakProvider with initialization
        ChangeNotifierProvider(
          create: (_) => StreakProvider(),
          builder: (context, child) {
            final provider = Provider.of<StreakProvider>(
              context,
              listen: false,
            );
            provider.loadStreak();
            return child!;
          },
        ),

        // !!! ADDED TASKPROVIDER HERE !!!
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: MaterialApp(
        title: 'Study Quest',
        debugShowCheckedModeBanner: false,
        // Use your existing AppTheme for consistency
        theme: AppTheme.lightTheme,

        // !!! ADDED LOCALIZATION DELEGATES FOR CALENDAR !!!
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', 'US'), // English (optional but recommended)
          Locale('es', 'ES'), // Spanish
          // Add more locales if your app supports other languages
        ],

        home: const HomeScreen(), // Your main entry screen
        // !!! MERGED ROUTES !!!
        routes: {
          '/subject-detail': (context) => const SubjectDetailScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/quiz': (context) => const QuizScreen(),
          '/calendar':
              (context) => const CalendarScreen(), // Your Calendar Screen route
          // If you have TaskDetailScreen for adding/editing tasks, define it here:
          // '/task-detail': (context) => const TaskDetailScreen(),
        },
        // If you plan to pass complex objects like 'Task' via arguments and need
        // a specific screen setup, you might use onGenerateRoute.
        // Example for task detail:
        // onGenerateRoute: (settings) {
        //   if (settings.name == '/task-detail') {
        //     final taskId = settings.arguments as String?;
        //     return MaterialPageRoute(builder: (context) {
        //       return TaskDetailScreen(taskId: taskId); // Pass the ID to fetch task
        //     });
        //   }
        //   // Handle other routes
        //   return null;
        // },
      ),
    );
  }
}
