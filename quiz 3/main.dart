import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const BMIApp());
}

class BMIApp extends StatelessWidget {
  const BMIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dark BMI Calc',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1B1E2B), // Deep dark background from image
        primaryColor: const Color(0xFF00E5FF), // Cyan accent
        cardColor: const Color(0xFF262A40), // Card background
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white, fontFamily: 'Sans'),
        ),
      ),
      home: const BMIHomeScreen(),
    );
  }
}

class BMIHomeScreen extends StatefulWidget {
  const BMIHomeScreen({super.key});

  @override
  State<BMIHomeScreen> createState() => _BMIHomeScreenState();
}

class _BMIHomeScreenState extends State<BMIHomeScreen> {
  // Controllers
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  // State variables
  double? _bmiResult;
  String _bmiCategory = "";
  Color _categoryColor = Colors.white;
  String _errorMessage = "";

  // Logic
  void _calculateBMI() {
    setState(() {
      _errorMessage = "";
      _bmiResult = null;
      _bmiCategory = "";
    });

    String heightStr = _heightController.text;
    String weightStr = _weightController.text;

    if (heightStr.isEmpty || weightStr.isEmpty) {
      setState(() {
        _errorMessage = "Please enter both height and weight.";
      });
      return;
    }

    try {
      double heightCm = double.parse(heightStr);
      double weightKg = double.parse(weightStr);

      if (heightCm <= 0 || weightKg <= 0) {
        setState(() {
          _errorMessage = "Values must be greater than zero.";
        });
        return;
      }

      // Formula: kg / m^2
      double heightM = heightCm / 100;
      double bmi = weightKg / pow(heightM, 2);

      String category;
      Color color;

      // Categories
      if (bmi < 18.5) {
        category = "Underweight";
        color = const Color(0xFF00E5FF); // Cyan (from image accent)
      } else if (bmi < 24.9) {
        category = "Normal";
        color = const Color(0xFF00FF94); // Neon Green
      } else if (bmi < 29.9) {
        category = "Overweight";
        color = const Color(0xFFFFB800); // Yellow/Orange
      } else {
        category = "Obese";
        color = const Color(0xFFFF007F); // Neon Pink (from image accent)
      }

      setState(() {
        _bmiResult = bmi;
        _bmiCategory = category;
        _categoryColor = color;
      });

      // Dismiss keyboard
      FocusScope.of(context).unfocus();

    } catch (e) {
      setState(() {
        _errorMessage = "Invalid input format.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Custom Gradient AppBar effect
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "BMI Calculator",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        // Background gradient slightly visible behind everything
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1B1E2B),
              Color(0xFF13151C),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Result Display Area (Top Card - mimicks the 'Glory NFT' card)
              _buildResultCard(),

              const SizedBox(height: 40),

              // 2. Input Fields
              const Text(
                "Your Details",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),

              _buildNeonInput(
                controller: _heightController,
                label: "Height",
                suffix: "cm",
                icon: Icons.height,
              ),
              const SizedBox(height: 20),
              _buildNeonInput(
                controller: _weightController,
                label: "Weight",
                suffix: "kg",
                icon: Icons.monitor_weight_outlined,
              ),

              // Error Message Display
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.redAccent),
                        const SizedBox(width: 10),
                        Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 40),

              // 3. Gradient Button (Mimicks 'Publish' button)
              _buildGradientButton(
                onTap: _calculateBMI,
                text: "Calculate BMI",
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Custom Widgets to Match Design ---

  Widget _buildResultCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF262A40), // Card bg from image
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header inside card
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Your Health Status",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
              const Icon(Icons.favorite, color: Color(0xFFFF007F), size: 20),
            ],
          ),
          const SizedBox(height: 30),

          // Main Result Number
          Text(
            _bmiResult == null ? "--.-" : _bmiResult!.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Color(0xFF00E5FF),
                  blurRadius: 20,
                )
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Category Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: _bmiResult == null
                  ? Colors.white.withOpacity(0.1)
                  : _categoryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _bmiResult == null
                    ? Colors.transparent
                    : _categoryColor,
              ),
            ),
            child: Text(
              _bmiCategory.isEmpty ? "Enter Details" : _bmiCategory.toUpperCase(),
              style: TextStyle(
                color: _bmiResult == null ? Colors.white54 : _categoryColor,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildNeonInput({
    required TextEditingController controller,
    required String label,
    required String suffix,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF262A40),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white54),
          labelText: label,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          suffixText: suffix,
          suffixStyle: const TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xFF00E5FF), width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildGradientButton({required VoidCallback onTap, required String text}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 65,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          // Gradient matching the 'Publish' or 'Follow' buttons in image
          gradient: const LinearGradient(
            colors: [
              Color(0xFF2E3192), // Dark Blue
              Color(0xFF1BFFFF), // Cyan
            ],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1BFFFF).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}