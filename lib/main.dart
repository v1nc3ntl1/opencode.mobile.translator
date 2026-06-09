import 'package:flutter/material.dart';
import 'app.dart';
import 'core/database_helper.dart';
import 'core/connectivity_monitor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DatabaseHelper().database;
  await ConnectivityMonitor().initialize();

  runApp(const TranslatorApp());
}
