import 'package:flutter/material.dart';
import 'package:flutter_app/result_page.dart';
import 'predict_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crime Prediction App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/predict': (context) => PredictPage(),
        '/result': (context) => ResultPage(
          prediction: ModalRoute.of(context)?.settings.arguments as String,
          explanation: null, 
        ),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: ElevatedButton(
          child: const Text('Go to Prediction'),
          onPressed: () {
            Navigator.pushNamed(context, '/predict');
          },
        ),
      ),
    );
  }
}
