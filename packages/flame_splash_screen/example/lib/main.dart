import 'package:flame_splash_screen/flame_splash_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const SplashScreenGame(),
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class OtherScreen extends StatelessWidget {
  const OtherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: const Text('Come again'),
          onPressed: () {
            Navigator.push<void>(
              context,
              MaterialPageRoute(builder: (context) => const SplashScreenGame()),
            );
          },
        ),
      ),
    );
  }
}

class SplashScreenGame extends StatefulWidget {
  const SplashScreenGame({super.key});

  @override
  SplashScreenGameState createState() => SplashScreenGameState();
}

class SplashScreenGameState extends State<SplashScreenGame> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlameSplashScreen(
        showBefore: (BuildContext context) {
          return const Text('Before logo');
        },
        showAfter: (BuildContext context) {
          return const Text('After logo');
        },
        theme: FlameSplashTheme.dark,
        onFinish: (context) => Navigator.pushReplacement<void, void>(
          context,
          MaterialPageRoute(builder: (context) => const OtherScreen()),
        ),
      ),
    );
  }
}
