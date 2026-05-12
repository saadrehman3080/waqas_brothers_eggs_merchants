import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/connectivity_service.dart';
import 'firebase_options.dart';
import 'routes/app_routes.dart';
import 'services/data_service.dart';
import 'viewmodels/inventory_viewmodel.dart';

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

  runApp(WaqasBrothersApp(connectivity: connectivity));
}

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
