import 'package:flutter/material.dart';
import 'report_page.dart'; // We'll create this next

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Civic Issue Reporter')),
      body: Center(
        child: ElevatedButton(
          child: const Text('Report an Issue'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ReportPage()),
            );
          },
        ),
      ),
    );
  }
}
