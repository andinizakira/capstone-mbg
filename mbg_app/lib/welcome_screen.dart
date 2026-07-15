import 'package:flutter/material.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: const Text(
          "Mbg",
          style: TextStyle(
            color: Colors.yellow,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            const SizedBox(height: 20),

            const Text(
              "Sistem rekomendasi menu makanan bergizi "
              "untuk program makan bergizi gratis "
              "menggunakan algoritma KNN dan Naive Bayes.",
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 15),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Info"),
                    content: const Text(
                      "Aplikasi ini membantu menentukan menu bergizi sesuai umur dan jenis kelamin."
                    ),
                  ),
                );
              },
              child: const Text("Info"),
            ),

            const SizedBox(height: 20),

            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
              ),
              child: Image.asset(
                "assets/images/makanan.png",
                fit: BoxFit.cover,
              ),
            ),

            const Spacer(),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HomeScreen(),
                  ),
                );
              },
              child: const Text(
                "Coba Sekarang",
                style: TextStyle(color: Colors.black),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}