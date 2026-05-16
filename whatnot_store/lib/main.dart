import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_lock_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/banner_provider.dart';
import 'providers/brand_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/category_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/ledger_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/order_provider.dart';
import 'providers/product_provider.dart';
import 'providers/return_provider.dart';
import 'screens/cart/cart_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'widgets/applock/splash_screen_wrapper.dart';
import 'widgets/watermark_wrapper.dart';

// ✅ Make navigatorKey GLOBAL
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
// top of file
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();


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
        ChangeNotifierProvider(create: (_) => LedgerProvider()),
        ChangeNotifierProvider(create: (_) => ReturnProvider()),
        ChangeNotifierProvider(create: (_) => AppLockProvider()..loadLockSetting()),


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
  navigatorKey: navigatorKey,
  builder: (context, child) {
    return WatermarkWrapper(child: child!); // ✅ ADD THIS
  },
  navigatorObservers: [routeObserver],
  debugShowCheckedModeBanner: false,
  title: 'Customer App',
  theme: ThemeData(
  primarySwatch: Colors.blue,
  fontFamily: 'Gilroy',

  textTheme: Typography.blackMountainView.apply(
    fontFamily: 'Gilroy',
  ),
  
  appBarTheme: const AppBarTheme(
    titleTextStyle: TextStyle(
      fontFamily: 'Gilroy',
      fontSize: 18,
      color: Colors.black,
      fontWeight: FontWeight.w600,
    ),
  ),
),

  home: SplashScreenWrapper(),

  routes: {
    '/cart': (context) => const CartScreen(),
  },
);

      },
    );
  }
}
