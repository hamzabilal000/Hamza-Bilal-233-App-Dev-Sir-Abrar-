import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const ProfileApp());
}

class ProfileApp extends StatelessWidget {
  const ProfileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Profile UI",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(), // ✅ Attractive + formal
        useMaterial3: true,
      ),
      home: const ProfilePage(),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF50C9CE), // Robin Egg Blue
              Color(0xFF2E382E), // Black Olive
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),

                // ✅ Title
                Text(
                  "Hamza Bilal 233",
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 40),

                // ✅ Profile Picture
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF50C9CE), Color(0xFF2E382E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: const CircleAvatar(
                    radius: 70,
                    backgroundImage: AssetImage("images/my_image.png"),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  "Flutter Developer",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 25),

                // ✅ Edit Profile Button
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit, color: Colors.white),
                  label: Text(
                    "Edit Profile",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E382E), // Black Olive
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 14),
                    elevation: 8,
                  ),
                ),

                const SizedBox(height: 40),

                // ✅ Info Cards
                _buildInfoCard(Icons.email, "hamzabilal.cs.pk@gmail.com",
                    const Color(0xFF50C9CE)),
                _buildInfoCard(
                    Icons.phone, "+92-334-7348886", const Color(0xFF2E382E)),
                _buildInfoCard(
                    Icons.location_on,
                    "Ali Town, Westwood Colony, Lahore, Punjab, Pakistan",
                    const Color(0xFF50C9CE)),
              ],
            ),
          ),
        ),
      ),

      // ✅ Bottom Navigation (Full Width, No White)
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF50C9CE), // Robin Egg Blue
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          selectedItemColor: const Color(0xFF2E382E), // Black Olive
          unselectedItemColor: Colors.white70,
          currentIndex: 1,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: "Settings"),
          ],
        ),
      ),
    );
  }

  // ✅ Info Card (Gmail in one line)
  Widget _buildInfoCard(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.3), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: ListTile(
          leading: Icon(icon, color: color, size: 28),
          title: Text(
            text,
            overflow: TextOverflow.ellipsis, // ✅ Gmail stays single line
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        ),
      ),
    );
  }
}
