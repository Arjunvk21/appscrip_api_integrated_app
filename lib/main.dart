import 'package:appscrip_task_management_app/consts/attributes.dart';
import 'package:appscrip_task_management_app/consts/boxes.dart';
import 'package:appscrip_task_management_app/model/hive_model.dart';
import 'package:appscrip_task_management_app/provider/auth_provider.dart';
import 'package:appscrip_task_management_app/provider/task_provider.dart';
import 'package:appscrip_task_management_app/screens/login_screen.dart';
import 'package:appscrip_task_management_app/screens/register_screen.dart';
import 'package:appscrip_task_management_app/screens/splash_screen.dart';
import 'package:appscrip_task_management_app/screens/task_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(hivemodelAdapter());
  boxTask = await Hive.openBox<hive_model>('taskBox');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => TaskProvider(),
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          hintColor: textcolor,
          buttonTheme: const ButtonThemeData(
              buttonColor: Color.fromARGB(255, 244, 242, 198)),
          inputDecorationTheme: const InputDecorationTheme(
              iconColor: Color.fromARGB(255, 244, 242, 198)),
          listTileTheme: const ListTileThemeData(
              tileColor: Color.fromARGB(255, 84, 154, 240)),
          appBarTheme: const AppBarTheme(
              actionsIconTheme: IconThemeData(color: Colors.white),
              color: Color.fromARGB(255, 84, 154, 240)),
          iconTheme:
              const IconThemeData(color: Color.fromARGB(255, 244, 242, 198)),
          scaffoldBackgroundColor: Color.fromARGB(255, 246, 246, 246),
          useMaterial3: true,
        ),
        routes: {
          '/registerUser': (context) => const RegisterUser(),
          '/loginUser': (context) => const LoginUser(),
          '/splashScreen': (context) => const SplashScreen(),
          '/TaskAddForm': (context) => const TaskManagementPage(),
        },
        initialRoute: '/splashScreen',
      ),
    );
  }
}
