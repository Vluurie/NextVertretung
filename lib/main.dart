import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:next_cloud_plans/bloc/api/api_service.dart';
import 'package:next_cloud_plans/bloc/api/update_checker.dart';
import 'package:next_cloud_plans/bloc/login/login_bloc.dart';
import 'package:next_cloud_plans/bloc/notification/notification_service.dart';
import 'package:next_cloud_plans/database/database.dart';
import 'package:next_cloud_plans/repository/user_repository.dart';
import 'package:next_cloud_plans/ui/pages/login_page.dart';
import 'package:next_cloud_plans/utils/storage.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  StorageItems storageItems = StorageItems();
  bool? isNotificationEnabled = await storageItems.getNotificationBool();
  if (isNotificationEnabled == true) {
    await initWorkManager();
  }
  runApp(const NextVertretung());
}

Future<void> initWorkManager() async {
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: kDebugMode,
  );

  await Workmanager().registerPeriodicTask(
    "updateCheckTask",
    "checkUpdatesInBackground",
    backoffPolicy: BackoffPolicy.exponential,
    backoffPolicyDelay: const Duration(seconds: 10),
    frequency: const Duration(minutes: 45),
    constraints: Constraints(networkType: NetworkType.connected),
  );

  await checkNotificationPermissionInit();
}

Future<void> cancelWorkManagerTasks() async {
  await Workmanager().cancelAll();
}

Future<void> checkNotificationPermissionInit() async {
  StorageItems storageItems = StorageItems();
  bool? isNotificationEnabled = await storageItems.getNotificationBool();
  if (isNotificationEnabled == true) {
    NotificationService().initNotification();
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      await dotenv.load(fileName: ".env");
      const storage = FlutterSecureStorage();
      final apiService = ApiService(storage: storage);
      final dbHelper = DatabaseHelper.instance;
      final userRepository = UserRepository();
      final storageItems = StorageItems();

      UpdateChecker updateChecker =
          UpdateChecker(apiService, dbHelper, userRepository, storageItems);
      await updateChecker.initcheckUpdate();

      return Future.value(true);
    } catch (error) {
      debugPrint("Error in background fetch: $error");
      return Future.value(false);
    }
  });
}

class NextVertretung extends StatelessWidget {
  const NextVertretung({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(userRepository: UserRepository()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const LoginPage(),
        theme: ThemeData.dark(),
      ),
    );
  }
}
