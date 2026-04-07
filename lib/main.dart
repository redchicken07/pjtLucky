import 'package:flutter/widgets.dart';

import 'app.dart';
import 'services/firebase_init.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseInit.initialize();
  runApp(const FortuneApp());
}
