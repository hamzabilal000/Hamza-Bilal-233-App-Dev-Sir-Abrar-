// Flutter Doctor App (UI-first)
// File: lib/main.dart
// Dependencies (add to pubspec.yaml):
//   flutter:
//     sdk: flutter
//   cupertino_icons: ^1.0.2
//   google_fonts: ^5.0.0
//   lottie: ^2.2.0
//   image_picker: ^0.8.7+3
//   path_provider: ^2.0.15
//   sqflite: ^2.2.5
// Note: This file contains a polished, world-class UI built with in-memory fake data.
// TODOs are left in code where SQLite/file-storage integration should be added.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const DoctorApp());
}

class DoctorApp extends StatelessWidget {
  const DoctorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData base = ThemeData.light();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Doctor App',
      theme: base.copyWith(
        colorScheme: base.colorScheme.copyWith(
          primary: const Color(0xFF1E88E5),
          secondary: const Color(0xFF42A5F5),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).apply(
          bodyColor: const Color(0xFF212121),
          displayColor: const Color(0xFF212121),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          ),
        ),
      ),
      home: const RootScreen(),
    );
  }
}

class RootScreen extends StatefulWidget {
  const RootScreen({Key? key}) : super(key: key);

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    DashboardScreen(),
    PatientListScreen(),
    SettingsScreen(),
  ];

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: CustomBottomNav(
        selectedIndex: _selectedIndex,
        onTap: _onNavTap,
      ),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton.extended(
        onPressed: () async {
          final newPatient = await Navigator.of(context).push<Patient?>(
            MaterialPageRoute(builder: (_) => const AddEditPatientScreen()),
          );
          if (newPatient != null) {
            // We use InMemoryDatabase singleton for this UI demo
            InMemoryDatabase.instance.addPatient(newPatient);
            setState(() {});
          }
        },
        label: const Text('Add Patient'),
        icon: const Icon(Icons.add),
      )
          : null,
    );
  }
}

class CustomBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;
  const CustomBottomNav({Key? key, required this.selectedIndex, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavButton(icon: Icons.dashboard, label: 'Dashboard', index: 0, selectedIndex: selectedIndex, onTap: onTap),
          _NavButton(icon: Icons.people, label: 'Patients', index: 1, selectedIndex: selectedIndex, onTap: onTap),
          _NavButton(icon: Icons.settings, label: 'Settings', index: 2, selectedIndex: selectedIndex, onTap: onTap),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int selectedIndex;
  final Function(int) onTap;

  const _NavButton({required this.icon, required this.label, required this.index, required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool active = index == selectedIndex;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: active ? const Color(0xFF1E88E5) : Colors.grey[400]),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: active ? const Color(0xFF1E88E5) : Colors.grey[400])),
        ],
      ),
    );
  }
}

// ----------------------------
// Dashboard Screen
// ----------------------------
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final total = InMemoryDatabase.instance.patients.length;
    final docs = InMemoryDatabase.instance.countDocuments();
    final upcoming = InMemoryDatabase.instance.patients.where((p) => p.hasUpcoming).length;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Good Morning,', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                    const SizedBox(height: 6),
                    Text('Dr. Hamza', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  ],
                ),
                CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFF1E88E5),
                  child: const Icon(Icons.person, color: Colors.white, size: 28),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _SummaryCard(title: 'Total Patients', value: '$total')),
                const SizedBox(width: 12),
                Expanded(child: _SummaryCard(title: 'Upcoming', value: '$upcoming')),
                const SizedBox(width: 12),
                Expanded(child: _SummaryCard(title: 'Documents', value: '$docs')),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 18, offset: const Offset(0, 8))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Recent Patients', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Expanded(child: _RecentPatientsList()),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  const _SummaryCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.grey[700])),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _RecentPatientsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final patients = InMemoryDatabase.instance.patients.reversed.take(5).toList();
    if (patients.isEmpty) {
      return Center(child: Lottie.asset('assets/empty.json', width: 160, height: 160));
    }
    return ListView.separated(
      itemCount: patients.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, idx) {
        final p = patients[idx];
        return ListTile(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => PatientDetailScreen(patient: p)));
          },
          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          leading: Hero(tag: 'avatar_${p.id}', child: CircleAvatar(radius: 28, backgroundImage: p.avatarImage != null ? FileImage(p.avatarImage!) : null, child: p.avatarImage == null ? const Icon(Icons.person) : null)),
          title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text('${p.age} • ${p.condition}'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        );
      },
    );
  }
}

// ----------------------------
// Patient List Screen
// ----------------------------
class PatientListScreen extends StatefulWidget {
  const PatientListScreen({Key? key}) : super(key: key);

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final patients = InMemoryDatabase.instance.search(query);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (v) => setState(() => query = v),
                    decoration: InputDecoration(
                      hintText: 'Search patients',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    final newPatient = await Navigator.of(context).push<Patient?>(
                      MaterialPageRoute(builder: (_) => const AddEditPatientScreen()),
                    );
                    if (newPatient != null) {
                      InMemoryDatabase.instance.addPatient(newPatient);
                      setState(() {});
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('New'),
                )
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: patients.isEmpty
                  ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset('assets/empty.json', width: 220, height: 220),
                  const SizedBox(height: 8),
                  const Text('No patients found. Tap "New" to add one.'),
                ],
              )
                  : ListView.builder(
                itemCount: patients.length,
                itemBuilder: (context, index) {
                  final p = patients[index];
                  return Dismissible(
                    key: Key(p.id.toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(color: Colors.red[400], borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) {
                      InMemoryDatabase.instance.deletePatient(p.id);
                      setState(() {});
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        onTap: () async {
                          final updated = await Navigator.of(context).push<Patient?>(
                            MaterialPageRoute(builder: (_) => PatientDetailScreen(patient: p)),
                          );
                          if (updated != null) setState(() {});
                        },
                        leading: Hero(tag: 'avatar_${p.id}', child: CircleAvatar(radius: 26, backgroundImage: p.avatarImage != null ? FileImage(p.avatarImage!) : null, child: p.avatarImage == null ? const Icon(Icons.person) : null)),
                        title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text('${p.age} • ${p.condition}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () async {
                            final edited = await Navigator.of(context).push<Patient?>(
                              MaterialPageRoute(builder: (_) => AddEditPatientScreen(patient: p)),
                            );
                            if (edited != null) setState(() {});
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ----------------------------
// Add / Edit Patient Screen
// ----------------------------
class AddEditPatientScreen extends StatefulWidget {
  final Patient? patient;
  const AddEditPatientScreen({Key? key, this.patient}) : super(key: key);

  @override
  State<AddEditPatientScreen> createState() => _AddEditPatientScreenState();
}

class _AddEditPatientScreenState extends State<AddEditPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  late String name;
  late String condition;
  late int age;
  String gender = 'Male';
  File? avatar;

  @override
  void initState() {
    super.initState();
    if (widget.patient != null) {
      name = widget.patient!.name;
      condition = widget.patient!.condition;
      age = widget.patient!.age;
      gender = widget.patient!.gender;
      avatar = widget.patient!.avatarImage;
    } else {
      name = '';
      condition = '';
      age = 30;
    }
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 800, imageQuality: 80);
    if (picked != null) {
      setState(() {
        avatar = File(picked.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.patient != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Patient' : 'Add Patient'), elevation: 0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Center(
                  child: GestureDetector(
                    onTap: pickImage,
                    child: Hero(
                      tag: 'avatar_${widget.patient?.id ?? 'new'}',
                      child: CircleAvatar(
                        radius: 52,
                        backgroundImage: avatar != null ? FileImage(avatar!) : null,
                        child: avatar == null ? const Icon(Icons.camera_alt, size: 30) : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: name,
                  decoration: InputDecoration(labelText: 'Full Name', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter name' : null,
                  onSaved: (v) => name = v!.trim(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: age.toString(),
                        decoration: InputDecoration(labelText: 'Age', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                        keyboardType: TextInputType.number,
                        validator: (v) => (v == null || int.tryParse(v) == null) ? 'Enter valid age' : null,
                        onSaved: (v) => age = int.parse(v!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: gender,
                        items: const [
                          DropdownMenuItem(value: 'Male', child: Text('Male')),
                          DropdownMenuItem(value: 'Female', child: Text('Female')),
                          DropdownMenuItem(value: 'Other', child: Text('Other')),
                        ],
                        onChanged: (v) => setState(() => gender = v!),
                        decoration: InputDecoration(labelText: 'Gender', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: condition,
                  decoration: InputDecoration(labelText: 'Condition / Diagnosis', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                  minLines: 2,
                  maxLines: 5,
                  onSaved: (v) => condition = v ?? '',
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            final p = Patient(
                              id: widget.patient?.id ?? InMemoryDatabase.instance.nextId(),
                              name: name,
                              age: age,
                              gender: gender,
                              condition: condition,
                              avatarImage: avatar,
                            );
                            Navigator.of(context).pop(p);
                          }
                        },
                        icon: const Icon(Icons.save),
                        label: Text(isEdit ? 'Save Changes' : 'Create Patient'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (isEdit)
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14)),
                        onPressed: () {
                          InMemoryDatabase.instance.deletePatient(widget.patient!.id);
                          Navigator.of(context).pop(null);
                        },
                        child: const Text('Delete'),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('File Management (Preview)', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text('You can attach documents/images to a patient profile. Integrate with local file storage and save file paths in SQLite.'),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    // Implement file picker & storage
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File picker not implemented in UI demo')));
                  },
                  icon: const Icon(Icons.attach_file),
                  label: const Text('Attach Document'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ----------------------------
// Patient Detail Screen
// ----------------------------
class PatientDetailScreen extends StatelessWidget {
  final Patient patient;
  const PatientDetailScreen({Key? key, required this.patient}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Patient Details'), elevation: 0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Hero(tag: 'avatar_${patient.id}', child: CircleAvatar(radius: 44, backgroundImage: patient.avatarImage != null ? FileImage(patient.avatarImage!) : null, child: patient.avatarImage == null ? const Icon(Icons.person, size: 36) : null)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(patient.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text('${patient.age} years • ${patient.gender}'),
                        const SizedBox(height: 6),
                        Chip(label: Text(patient.condition), backgroundColor: Colors.blue[50]),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 18),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6))]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Files & Documents', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      Expanded(child: _DocumentGrid(patient: patient)),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final edited = await Navigator.of(context).push<Patient?>(MaterialPageRoute(builder: (_) => AddEditPatientScreen(patient: patient)));
          if (edited != null) {
            InMemoryDatabase.instance.updatePatient(edited);
            Navigator.of(context).pop(edited);
          }
        },
        child: const Icon(Icons.edit),
      ),
    );
  }
}

class _DocumentGrid extends StatelessWidget {
  final Patient patient;
  const _DocumentGrid({required this.patient});

  @override
  Widget build(BuildContext context) {
    final docs = patient.documents;
    if (docs.isEmpty) {
      return Center(child: Text('No documents yet. Use Edit to attach files.'));
    }
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
      itemCount: docs.length,
      itemBuilder: (context, idx) {
        final f = docs[idx];
        return GestureDetector(
          onTap: () {
            // Open viewer
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Open document: ${f.name} (not implemented in demo)')));
          },
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey[100]),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.insert_drive_file, size: 34),
                const SizedBox(height: 8),
                Text(f.name, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ----------------------------
// Settings Screen
// ----------------------------
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Doctor Profile'),
              subtitle: const Text('Dr. Hamza — Cardiology'),
              trailing: const Icon(Icons.edit),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.cloud_upload),
              title: const Text('Backup & Restore'),
              subtitle: const Text('Export patient data and documents'),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.palette),
              title: const Text('Theme'),
              subtitle: const Text('Blue & White (default)'),
              onTap: () {},
            ),
          ),
        ]),
      ),
    );
  }
}

// ----------------------------
// Data Models & In-Memory DB
// ----------------------------
class Patient {
  final int id;
  String name;
  int age;
  String gender;
  String condition;
  File? avatarImage;
  List<PatientFile> documents;
  bool hasUpcoming;

  Patient({required this.id, required this.name, required this.age, required this.gender, required this.condition, this.avatarImage, List<PatientFile>? documents, this.hasUpcoming = false}) : documents = documents ?? [];

  Patient copyWith({int? id, String? name, int? age, String? gender, String? condition, File? avatarImage, List<PatientFile>? documents, bool? hasUpcoming}) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      condition: condition ?? this.condition,
      avatarImage: avatarImage ?? this.avatarImage,
      documents: documents ?? this.documents,
      hasUpcoming: hasUpcoming ?? this.hasUpcoming,
    );
  }
}

class PatientFile {
  final String name;
  final String path;
  PatientFile({required this.name, required this.path});
}

class InMemoryDatabase {
  InMemoryDatabase._internal() {
    // seed
    _patients = [
      Patient(id: 1, name: 'Aisha Khan', age: 29, gender: 'Female', condition: 'Hypertension', hasUpcoming: true),
      Patient(id: 2, name: 'Ali Raza', age: 44, gender: 'Male', condition: 'Type II Diabetes'),
      Patient(id: 3, name: 'Sara Ahmed', age: 33, gender: 'Female', condition: 'Asthma'),
    ];
  }

  static final InMemoryDatabase instance = InMemoryDatabase._internal();
  late List<Patient> _patients;

  List<Patient> get patients => _patients;

  int nextId() => (_patients.map((p) => p.id).fold<int>(0, (prev, e) => prev > e ? prev : e)) + 1;

  void addPatient(Patient p) => _patients.add(p);

  void updatePatient(Patient p) {
    final idx = _patients.indexWhere((x) => x.id == p.id);
    if (idx >= 0) _patients[idx] = p;
  }

  void deletePatient(int id) => _patients.removeWhere((p) => p.id == id);

  List<Patient> search(String q) {
    if (q.trim().isEmpty) return _patients;
    final low = q.toLowerCase();
    return _patients.where((p) => p.name.toLowerCase().contains(low) || p.condition.toLowerCase().contains(low)).toList();
  }

  int countDocuments() => _patients.expand((p) => p.documents).length;
}

// ----------------------------
// End of file
// ----------------------------

// NOTES / NEXT STEPS:
// 1) Add dependencies in pubspec.yaml (sqflite, path_provider, image_picker, lottie, google_fonts).
// 2) Add a local asset `assets/empty.json` (Lottie) and register it in pubspec.yaml under assets: [].
// 3) Integrate SQLite: create a Patient table and save file paths for images/documents. Replace InMemoryDatabase with a DB service.
// 4) Implement file copies: when user picks an image/document, copy it into the app documents directory (use path_provider) and save path in DB.
// 5) Add proper error handling and tests.
// If you want, I can now extend this code to include full SQLite integration and file storage.
