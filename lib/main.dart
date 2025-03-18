import 'package:flutter/material.dart';
import 'package:icafeplay/home_route.dart';
import 'package:icafeplay/loading_route.dart';
import 'package:icafeplay/transaction_success_route.dart';

void main() {
  runApp(const Master());
}

class Master extends StatelessWidget {
  const Master({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "ICafe Play",
      theme: ThemeData(
        primaryColor: Colors.black,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const Main(title: "ICafePlay App"),
        "/transaction-success": (context) => const SuccessfulTransactionRoute()
      },
      // onGenerateInitialRoutes: (String initialRoute) {
      //   print(initialRoute);
      //   return [MaterialPageRoute(builder: (context) => const SuccessfulTransactionRoute())];
      // },
      // onGenerateRoute: (RouteSettings settings) {
      //   Uri? uri = Uri.tryParse(settings.name ?? '');
      //   print(settings.arguments);
      //   print(uri);
      //   // return MaterialPageRoute(builder: (context) => const Main(title: "ICafePlay App"));
      //   return MaterialPageRoute(builder: (context) => const SuccessfulTransactionRoute());
      // },
    );
  }
}

class Main extends StatefulWidget {
  const Main({super.key, required this.title});

  final String title;

  @override
  State<Main> createState() => MainState();
}

class MainState extends State<Main> {
  @override
  Widget build(BuildContext context) {
    return const HomeRoute();
  }
}
