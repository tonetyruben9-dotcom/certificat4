import 'package:certificat4/app.dart';
import 'package:certificat4/core/storage/hive_service.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await HiveService.instance.init();

  runApp(MyApp(appState: AppState()));
}
