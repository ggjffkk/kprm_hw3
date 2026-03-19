import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const SolarProfitApp());
}

class SolarProfitApp extends StatelessWidget {
  const SolarProfitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Калькулятор прибутку СЕС',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final pcController = TextEditingController(text: "5");
  final priceController = TextEditingController(text: "7");
  final sigma1Controller = TextEditingController(text: "1");
  final sigma2Controller = TextEditingController(text: "0.25");

  String result = "";

  // PDF нормального розподілу
  double normalPDF(double x, double mean, double sigma) {
    return (1 / (sigma * sqrt(2 * pi))) * exp(-pow(x - mean, 2) / (2 * pow(sigma, 2)));
  }

  // Чисельне інтегрування методом прямокутників
  double integrate(double mean, double sigma, double a, double b) {
    int steps = 10000;
    double h = (b - a) / steps;
    double sum = 0;
    for (int i = 0; i < steps; i++) {
      double x = a + i * h;
      sum += normalPDF(x, mean, sigma) * h;
    }
    return sum;
  }

  void calculate() {
    double Pc = double.tryParse(pcController.text) ?? 0;
    double B = double.tryParse(priceController.text) ?? 0;
    double sigma1 = double.tryParse(sigma1Controller.text) ?? 0;
    double sigma2 = double.tryParse(sigma2Controller.text) ?? 0;

    double a = Pc * 0.95;
    double b = Pc * 1.05;

    double w1 = integrate(Pc, sigma1, a, b);
    double w2 = integrate(Pc, sigma2, a, b);

    double energyTotal = Pc * 24;

    double W1 = energyTotal * w1;
    double W2 = energyTotal * (1 - w1);
    double P1 = W1 * B;
    double S1 = W2 * B;

    double W3 = energyTotal * w2;
    double W4 = energyTotal * (1 - w2);
    double P2 = W3 * B;
    double S2 = W4 * B;

    double profit = P2 - S2;

    setState(() {
      result = """
Допустимий діапазон потужності: ${a.toStringAsFixed(2)} ... ${b.toStringAsFixed(2)} МВт

Частка енергії без небалансів:
До покращення: ${(w1*100).toStringAsFixed(2)} %
Після покращення: ${(w2*100).toStringAsFixed(2)} %

Загальна добова генерація: ${energyTotal.toStringAsFixed(2)} МВт·год

До покращення:
Енергія без штрафу: ${W1.toStringAsFixed(2)} МВт·год
Прибуток: ${P1.toStringAsFixed(2)} тис. грн
Енергія з небалансом: ${W2.toStringAsFixed(2)} МВт·год
Штраф: ${S1.toStringAsFixed(2)} тис. грн

Після покращення:
Енергія без штрафу: ${W3.toStringAsFixed(2)} МВт·год
Прибуток: ${P2.toStringAsFixed(2)} тис. грн
Енергія з небалансом: ${W4.toStringAsFixed(2)} МВт·год
Штраф: ${S2.toStringAsFixed(2)} тис. грн

Фінальний прибуток: ${profit.toStringAsFixed(2)} тис. грн
""";
    });
  }

  Widget inputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff0f2027), Color(0xff203a43), Color(0xff2c5364)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              children: [
                const Center(
                  child: Text(
                    "Калькулятор прибутку СЕС",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    "Розрахунок прибутку з урахуванням системи прогнозування",
                    style: TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 30),
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        inputField("Середня потужність Pc (МВт)", pcController),
                        inputField("Вартість електроенергії B (грн/кВт·год)", priceController),
                        inputField("Похибка прогнозу σ₁ (МВт)", sigma1Controller),
                        inputField("Похибка після покращення σ₂ (МВт)", sigma2Controller),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: calculate,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text("Розрахувати", style: TextStyle(fontSize: 18)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (result.isNotEmpty)
                  Card(
                    color: Colors.blue.shade50,
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(result, style: const TextStyle(fontSize: 16)),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}