import 'package:flutter/material.dart';
import 'package:mashwar_customer/app/app.dart';
import 'package:mashwar_customer/app/di/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  runApp(const MashwarApp());
}
