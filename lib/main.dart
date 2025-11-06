import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:wstore/Admin/add_product.dart';
import 'package:wstore/Admin/admin_login.dart';
import 'package:wstore/Admin/all_orders.dart';
import 'package:wstore/Admin/home_admin.dart';
import 'package:wstore/page/Order.dart';
import 'package:wstore/page/bottomnav.dart';
import 'package:wstore/page/category_product.dart';
import 'package:wstore/page/homepage.dart';
import 'package:wstore/page/login.dart';
import 'package:wstore/page/product_detail.dart';
import 'package:wstore/page/profile.dart';
import 'package:wstore/page/signup.dart';
import 'package:wstore/services/constant.dart';
import 'package:wstore/services/store_setup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = publishableKey;
  await Firebase.initializeApp();

  // ✅ Init store data
  await StoreSetup.initializeStoreData();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WStore',

      // ✅ ดาร์กโหมดอัตโนมัติ
      themeMode: ThemeMode.system,

      // 🌞 โหมดสว่าง
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),

      // 🌚 โหมดมืด
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFF1E1E1E),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),

      // ✅ หน้าเริ่มต้น
      home: const LogIn(),
    );
  }
}
