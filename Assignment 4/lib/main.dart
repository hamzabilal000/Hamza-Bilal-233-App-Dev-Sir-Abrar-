import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui'; // For image filters (Blur)

// TODO: REPLACE WITH YOUR ACTUAL KEYS
const String supabaseUrl = 'https://phmjqwknrzokybhmixtg.supabase.co';
const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBobWpxd2tucnpva3liaG1peHRnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUzOTI5OTgsImV4cCI6MjA4MDk2ODk5OH0.c7S5qS43U6NiD-hn4GAlUYO42mUC8Hv7gPyMzhfoohI';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Glass Form App',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF6C63FF),
        scaffoldBackgroundColor: const Color(0xFF1A1A2E),
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        useMaterial3: true,
      ),
      home: const SubmissionsListScreen(),
    );
  }
}

// ---------------------------------------------------------
// REUSABLE WIDGETS (THEME & UI)
// ---------------------------------------------------------

// A widget to create the beautiful gradient background from your image
class GradientBackground extends StatelessWidget {
  final Widget child;
  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2E1C59), // Deep Purple
            Color(0xFF533483), // Lighter Purple
            Color(0xFF0F3460), // Deep Blue
          ],
        ),
      ),
      child: SafeArea(child: child),
    );
  }
}

// Glassmorphism Card Style
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double opacity;

  const GlassCard(
      {super.key, required this.child, this.padding, this.opacity = 0.15});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(opacity),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// SCREEN 1: SUBMISSIONS LIST (READ & DELETE)
// ---------------------------------------------------------

class SubmissionsListScreen extends StatefulWidget {
  const SubmissionsListScreen({super.key});

  @override
  State<SubmissionsListScreen> createState() => _SubmissionsListScreenState();
}

class _SubmissionsListScreenState extends State<SubmissionsListScreen> {
  final _supabase = Supabase.instance.client;

  // Stream to listen to database changes in real-time
  late Stream<List<Map<String, dynamic>>> _stream;

  @override
  void initState() {
    super.initState();
    _stream = _supabase.from('submissions').stream(primaryKey: ['id']).order('id');
  }

  Future<void> _deleteSubmission(int id) async {
    try {
      await _supabase.from('submissions').delete().match({'id': id});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Record deleted successfully!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: GradientBackground(
        child: Column(
          children: [
            // Custom Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Dashboard",
                          style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      Text("Manage Submissions",
                          style: GoogleFonts.poppins(
                              color: Colors.white70, fontSize: 14)),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SubmissionFormScreen()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE94560),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                              color: const Color(0xFFE94560).withOpacity(0.5),
                              blurRadius: 15)
                        ],
                      ),
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  )
                ],
              ),
            ),

            // List of Data
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _stream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final submissions = snapshot.data!;

                  if (submissions.isEmpty) {
                    return Center(child: Text("No records found", style: TextStyle(color: Colors.white70),));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: submissions.length,
                    itemBuilder: (context, index) {
                      final item = submissions[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item['full_name'] ?? 'No Name',
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      item['gender'] ?? 'N/A',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 8),
                              _infoRow(Icons.email, item['email']),
                              _infoRow(Icons.phone, item['phone']),
                              _infoRow(Icons.location_on, item['address']),
                              const SizedBox(height: 15),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blueAccent),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              SubmissionFormScreen(
                                                  existingData: item),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.redAccent),
                                    onPressed: () =>
                                        _deleteSubmission(item['id']),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String? text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.white70),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text ?? '',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// SCREEN 2: SUBMISSION FORM (CREATE & UPDATE)
// ---------------------------------------------------------

class SubmissionFormScreen extends StatefulWidget {
  final Map<String, dynamic>? existingData; // If null, we are creating. If not, we are editing.

  const SubmissionFormScreen({super.key, this.existingData});

  @override
  State<SubmissionFormScreen> createState() => _SubmissionFormScreenState();
}

class _SubmissionFormScreenState extends State<SubmissionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  String? _selectedGender;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingData != null) {
      _nameController.text = widget.existingData!['full_name'];
      _emailController.text = widget.existingData!['email'];
      _phoneController.text = widget.existingData!['phone'];
      _addressController.text = widget.existingData!['address'];
      _selectedGender = widget.existingData!['gender'];
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedGender == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please select a gender')));
      return;
    }

    setState(() => _isLoading = true);

    final data = {
      'full_name': _nameController.text,
      'email': _emailController.text,
      'phone': _phoneController.text,
      'address': _addressController.text,
      'gender': _selectedGender,
    };

    try {
      if (widget.existingData == null) {
        // Create
        await _supabase.from('submissions').insert(data);
      } else {
        // Update
        await _supabase
            .from('submissions')
            .update(data)
            .match({'id': widget.existingData!['id']});
      }

      if (mounted) {
        Navigator.pop(context); // Go back to list
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GradientBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  widget.existingData == null ? "New Entry" : "Edit Entry",
                  style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 20),
                GlassCard(
                  opacity: 0.1,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextField("Full Name", Icons.person, _nameController),
                        const SizedBox(height: 15),
                        _buildTextField("Email", Icons.email, _emailController),
                        const SizedBox(height: 15),
                        _buildTextField("Phone", Icons.phone, _phoneController, isNumber: true),
                        const SizedBox(height: 15),
                        _buildTextField("Address", Icons.home, _addressController),
                        const SizedBox(height: 15),

                        // Custom Gender Dropdown
                        DropdownButtonFormField<String>(
                          dropdownColor: const Color(0xFF2E1C59),
                          value: _selectedGender,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration("Gender", Icons.wc),
                          items: ['Male', 'Female', 'Other']
                              .map((label) => DropdownMenuItem(
                            value: label,
                            child: Text(label),
                          ))
                              .toList(),
                          onChanged: (value) => setState(() => _selectedGender = value),
                        ),

                        const SizedBox(height: 30),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE94560),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              elevation: 10,
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text(
                              widget.existingData == null
                                  ? "Submit Data"
                                  : "Update Data",
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller, {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
      validator: (value) => value!.isEmpty ? "Required" : null,
      decoration: _inputDecoration(label, icon),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFE94560)),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
    );
  }
}