import 'package:emababyspa/common/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:emababyspa/common/theme/app_theme.dart';
import 'package:emababyspa/utils/app_routes.dart';
import 'package:emababyspa/bindings/app_bindings.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

// localization
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

// IMPORTANT: ThemeController
import 'package:emababyspa/features/theme/controllers/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  await initializeDateFormatting('id_ID', null);
  Intl.defaultLocale = 'id_ID';

  OneSignal.initialize(AppConstants.appOneSignalId);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController =
        Get.isRegistered<ThemeController>()
            ? Get.find<ThemeController>()
            : Get.put(ThemeController(), permanent: true);

    return Obx(() {
      // ✅ HARUS Rx supaya Obx beneran rebuild
      final _ = themeController.forceRebuildRx.value;

      return GetMaterialApp(
        title: 'Ema Spa Manager',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeController.themeMode,
        initialBinding: AppBindings(),
        initialRoute: AppRoutes.splash,
        getPages: AppRoutes.pages,
        defaultTransition: Transition.fadeIn,
        locale: const Locale('id', 'ID'),
        supportedLocales: const [Locale('id', 'ID'), Locale('en', 'US')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      );
    });
  }
}
