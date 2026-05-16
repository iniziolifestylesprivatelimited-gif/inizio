import 'package:flutter/material.dart';
import 'package:frontend/providers/banner_provider.dart';
import 'package:frontend/providers/cart_provider.dart';
import 'package:frontend/providers/category_provider.dart';
import 'package:frontend/providers/product_provider.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/brand_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/order_provider.dart';
import 'screens/authentication/login_screen.dart';
import 'screens/cart/cart_screen.dart';
import 'screens/homescreen/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'screens/splash/splash_screen.dart';
import 'services/notification_service.dart';

// ✅ Make navigatorKey GLOBAL
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> _backgroundHandler(RemoteMessage message) async {
  print("📩 Background Notification: ${message.notification?.title}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
  await NotificationService.init();

  // ✅ Load saved session
  final authProvider = AuthProvider();
  await authProvider.loadUserFromPrefs();

  await FirebaseMessaging.instance.requestPermission();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => authProvider),
        ChangeNotifierProvider(create: (_) => BrandProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => BannerProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return MaterialApp(
          navigatorKey: navigatorKey, // ✅ Works now
          debugShowCheckedModeBanner: false,
          title: 'Customer App',
          theme: ThemeData(primarySwatch: Colors.blue),
          // home: auth.token != null ? const HomeScreen() : LoginScreen(),
          home: const SplashScreen(),

          routes: {
            '/cart': (context) => const CartScreen(),
          },
        );
      },
    );
  }
}
