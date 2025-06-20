import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/screens/create_note_screen.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/screens/note_details_screen.dart';
import 'package:frontend/screens/user_management_screen.dart';
import 'package:frontend/screens/notification_screen.dart';
import 'package:frontend/screens/admin_dashboard_screen.dart';
import 'package:frontend/providers/notification_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/utils/route_observer.dart';
import 'package:frontend/providers/refresh_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => RefreshProvider()),
        FutureProvider<String?>(
          initialData: null,
          create: (_) async {
            const storage = FlutterSecureStorage();
            return storage.read(key: 'jwt_token');
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tokenAsync = Provider.of<String?>(context);
    final refreshProvider = Provider.of<RefreshProvider>(context);

    return MaterialApp(
      title: 'STEG LOTO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          primary: Colors.blue,
          secondary: Colors.orange,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      navigatorObservers: [
        AppRouteObserver(onRoutePopped: () {
          refreshProvider.triggerRefresh();
        }),
      ],
      home: tokenAsync == null ? const LoginScreen() : const HomeScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/create_note': (context) => const CreateNoteScreen(),
        '/user_management': (context) => const UserManagementScreen(),
        '/notifications': (context) => NotificationScreen(),
        '/admin_dashboard': (context) => AdminDashboardScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/note_details') {
          final String noteId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => NoteDetailsScreen(noteId: noteId),
          );
        }
        return null;
      },
    );
  }
}
