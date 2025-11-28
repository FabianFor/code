import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'providers/business_provider.dart';
import 'providers/product_provider.dart';
import 'providers/order_provider.dart';
import 'providers/invoice_provider.dart';
import 'providers/settings_provider.dart'; // ✅ NUEVO
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => SettingsProvider()..loadSettings()), // ✅ NUEVO
            ChangeNotifierProvider(create: (_) => BusinessProvider()..loadData()),
            ChangeNotifierProvider(create: (_) => ProductProvider()..loadProducts()),
            ChangeNotifierProvider(create: (_) => OrderProvider()..loadOrders()),
            ChangeNotifierProvider(create: (_) => InvoiceProvider()..loadInvoices()),
          ],
          child: Consumer<SettingsProvider>(
            builder: (context, settingsProvider, child) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'MiNegocio',
                
                // ✅ Configuración de idiomas
                locale: settingsProvider.locale,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [
                  Locale('es'), // Español
                  Locale('en'), // English
                  Locale('pt'), // Português
                  Locale('zh'), // 中文
                ],
                
                theme: ThemeData(
                  primarySwatch: Colors.blue,
                  fontFamily: 'Roboto',
                  useMaterial3: true,
                ),
                
                builder: (context, child) => ResponsiveBreakpoints.builder(
                  child: child!,
                  breakpoints: [
                    const Breakpoint(start: 0, end: 450, name: MOBILE),
                    const Breakpoint(start: 451, end: 800, name: TABLET),
                    const Breakpoint(start: 801, end: 1920, name: DESKTOP),
                  ],
                ),
                
                home: const DashboardScreen(),
              );
            },
          ),
        );
      },
    );
  }
}