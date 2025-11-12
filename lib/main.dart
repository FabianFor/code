import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'providers/business_provider.dart';
import 'providers/product_provider.dart';
import 'providers/order_provider.dart';
import 'providers/invoice_provider.dart';
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
            ChangeNotifierProvider(create: (_) => BusinessProvider()..loadData()),
            ChangeNotifierProvider(create: (_) => ProductProvider()..loadProducts()),
            ChangeNotifierProvider(create: (_) => OrderProvider()..loadOrders()),
            ChangeNotifierProvider(create: (_) => InvoiceProvider()..loadInvoices()),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'MiNegocio',
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
          ),
        );
      },
    );
  }
}