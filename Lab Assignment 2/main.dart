import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Music Style Guessing Game',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme).apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      ),
      home: const GameHomeScreen(),
    );
  }
}

// --- 1. HOME / INPUT SCREEN ---
class GameHomeScreen extends StatefulWidget {
  const GameHomeScreen({super.key});

  @override
  State<GameHomeScreen> createState() => _GameHomeScreenState();
}

class _GameHomeScreenState extends State<GameHomeScreen> {
  final TextEditingController _controller = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  int _targetNumber = Random().nextInt(100) + 1;

  void _submitGuess() async {
    if (_controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a number!")),
      );
      return;
    }

    int? guess = int.tryParse(_controller.text);
    if (guess == null || guess < 1 || guess > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a number between 1 and 100")),
      );
      return;
    }

    String resultStatus;
    if (guess == _targetNumber) {
      resultStatus = "Correct!";
    } else if (guess > _targetNumber) {
      resultStatus = "Too High";
    } else {
      resultStatus = "Too Low";
    }

    // Save to SQLite
    String timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    await _dbHelper.insertResult(guess, resultStatus, timestamp);

    // Navigate to Result Screen
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          guess: guess,
          target: _targetNumber,
          status: resultStatus,
          onReset: _resetGame,
        ),
      ),
    );
    _controller.clear();
  }

  void _resetGame() {
    setState(() {
      _targetNumber = Random().nextInt(100) + 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2B3363), Color(0xFF1C1C2E)], // Music player dark blue
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.history, color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const HistoryScreen()),
                        );
                      },
                    ),
                    const Text("GUESS TRACK", style: TextStyle(letterSpacing: 2)),
                    const Icon(Icons.more_horiz, color: Colors.white),
                  ],
                ),
              ),

              const Spacer(),

              // Circular "Album Art" Placeholder for the Game
              Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6A5AE0), Color(0xFF9887FC)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6A5AE0).withOpacity(0.5),
                      blurRadius: 30,
                      spreadRadius: 10,
                    )
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black26
                    ),
                    child: const Icon(Icons.question_mark, size: 80, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Song Title Style Text
              const Text(
                "Guess the Number",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Text(
                "Between 1 and 100",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),

              const Spacer(),

              // Input Field styled nicely
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: "Enter your guess",
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Player Controls (Submit Button)
              Padding(
                padding: const EdgeInsets.only(bottom: 50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Submit / Play Button
                    GestureDetector(
                      onTap: _submitGuess,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))
                            ]
                        ),
                        child: const Icon(Icons.play_arrow_rounded, color: Color(0xFF2B3363), size: 50),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- 2. RESULT SCREEN ---
class ResultScreen extends StatelessWidget {
  final int guess;
  final int target;
  final String status;
  final VoidCallback onReset;

  const ResultScreen({
    super.key,
    required this.guess,
    required this.target,
    required this.status,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    bool isCorrect = status == "Correct!";

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF422F61), Color(0xFF1C1C2E)],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Back Button
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const Spacer(),

              // Result Image/Icon
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: isCorrect
                        ? [Colors.greenAccent, Colors.green]
                        : [Colors.orangeAccent, Colors.deepOrange],
                  ),
                  border: Border.all(
                      color: isCorrect ? Colors.greenAccent : Colors.orangeAccent,
                      width: 4),
                  boxShadow: [
                    BoxShadow(
                        color:
                        (isCorrect ? Colors.green : Colors.orange).withOpacity(0.4),
                        blurRadius: 40)
                  ],
                ),
                child: Center(
                  child: Text(
                    "$guess",
                    style: const TextStyle(
                        fontSize: 60, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),


              const SizedBox(height: 30),
              Text(
                status.toUpperCase(),
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isCorrect ? Colors.greenAccent : Colors.orangeAccent
                ),
              ),
              const SizedBox(height: 10),
              Text(
                isCorrect ? "You guessed the number!" : "Try again...",
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),

              const Spacer(),

              // Logic to handle Play Again
              Padding(
                padding: const EdgeInsets.only(bottom: 50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white, size: 30),
                      onPressed: () {
                        // Just try again (pop back)
                        Navigator.pop(context);
                      },
                    ),
                    if (isCorrect)
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6A5AE0),
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
                        ),
                        onPressed: () {
                          onReset();
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.star, color: Colors.white),
                        label: const Text("New Game", style: TextStyle(color: Colors.white)),
                      )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// --- 3. HISTORY SCREEN (SQLite Data) ---
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C2E),
      appBar: AppBar(
        title: const Text("Game History"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseHelper().getHistory(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF6A5AE0)));
          }
          final data = snapshot.data!;
          if (data.isEmpty) {
            return const Center(child: Text("No games played yet."));
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              final isCorrect = item['result'] == "Correct!";

              // Styled like a song list item
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isCorrect ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        "${item['guess']}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isCorrect ? Colors.greenAccent : Colors.orangeAccent
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    item['result'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    item['timestamp'],
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  trailing: Icon(
                    isCorrect ? Icons.check_circle : Icons.warning_amber_rounded,
                    color: isCorrect ? Colors.green : Colors.orange,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}