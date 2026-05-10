import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:waqas_brothers_eggs_merchants/firebase_options.dart';
import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/connectivity_service.dart';
import 'routes/app_routes.dart';
import 'services/data_service.dart';
import 'viewmodels/inventory_viewmodel.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  final connectivity = ConnectivityService();
  await connectivity.initialize();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ── ONE-TIME SEEDER — REMOVE THIS BLOCK AFTER FIRST RUN ──────────────────
  await _seedProductsOnce();
  // ─────────────────────────────────────────────────────────────────────────

  runApp(WaqasBrothersApp(connectivity: connectivity));
}

// ── ONE-TIME SEEDER — REMOVE THIS FUNCTION AFTER FIRST RUN ─────────────────
/// Writes the 4 starter products to Firestore if the /products collection is
/// empty. Safe to call repeatedly — skips if products already exist.
Future<void> _seedProductsOnce() async {
  final db = FirebaseFirestore.instance;
  final col = db.collection('products');

  final existing = await col.limit(1).get();
  if (existing.docs.isNotEmpty) return; // already seeded — do nothing

  // Each product gets a Firestore auto-generated document ID stored in its
  // own 'id' field so reads back via Product.fromJson work correctly.
  final rawProducts = [
    {
      'nameEn': 'Single Egg',
      'nameUr': 'انڈا',
      'price': 25.0,
      'stock': 5400,
      'sold': 50,
      'revenuePerUnit': 2.0,
      'stockAddedToday': 0,
      'lastStockDevice': 'KM LX1',
    },
    {
      'nameEn': 'Egg Dozen',
      'nameUr': 'درجن انڈے',
      'price': 250.0,
      'stock': 450,
      'sold': 120,
      'revenuePerUnit': 30.0,
      'stockAddedToday': 0,
      'lastStockDevice': 'JKM LX1',
    },
    {
      'nameEn': 'Egg Tray',
      'nameUr': 'انڈوں کی ٹرے',
      'price': 610.0,
      'stock': 60,
      'sold': 18,
      'revenuePerUnit': 72.0,
      'stockAddedToday': 0,
      'lastStockDevice': 'KM LX1',
    },
    {
      'nameEn': 'Patty',
      'nameUr': 'پیٹی',
      'price': 7260.0,
      'stock': 10,
      'sold': 2,
      'revenuePerUnit': 864.0,
      'stockAddedToday': 0,
      'lastStockDevice': 'JKM LX1',
    },
  ];

  final batch = db.batch();
  for (final p in rawProducts) {
    // col.doc() with no argument generates a Firestore auto-ID (20-char random string).
    final ref = col.doc();
    batch.set(ref, {
      ...p,
      'id': ref.id, // store the auto-generated ID inside the document
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
  await batch.commit();
}
// ── END OF ONE-TIME SEEDER ──────────────────────────────────────────────────

class WaqasBrothersApp extends StatelessWidget {
  final ConnectivityService connectivity;
  const WaqasBrothersApp({super.key, required this.connectivity});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ConnectivityService>.value(value: connectivity),
        Provider<DataService>(create: (_) => DataService()),
        ChangeNotifierProxyProvider<DataService, InventoryViewModel>(
          create: (ctx) => InventoryViewModel(ctx.read<DataService>()),
          update: (ctx, dataService, previous) =>
              previous ?? InventoryViewModel(dataService),
        ),
      ],
      child: MaterialApp.router(
        title: AppStrings.appName,
        theme: AppTheme.light,
        routerConfig: appRouter,
        debugShowCheckedModeBanner: true,
      ),
    );
  }
}
