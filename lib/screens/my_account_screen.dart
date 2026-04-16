import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../utils/firebase_image_picker.dart';

class MyAccountScreen extends StatefulWidget {
  final double screenWidth;

  const MyAccountScreen({super.key, required this.screenWidth});

  @override
  State<MyAccountScreen> createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _emailController = TextEditingController();

  String? _profileImageUrl;
  bool _initialized = false;
  bool _saving = false;
  late Future<DocumentSnapshot<Map<String, dynamic>>> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfileDoc();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _loadProfileDoc() async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('User not signed in');

    final docRef = _firestore.collection('users').doc(user.uid);
    var doc = await docRef.get();

    // If doc doesn't exist, create it once
    if (!doc.exists) {
      String initialName = '';
      String initialDesc = '';
      String? initialImg;

      if (user.email != null) {
        final staffQuery = await _firestore
            .collection('staff')
            .where('email', isEqualTo: user.email)
            .limit(1)
            .get();

        if (staffQuery.docs.isNotEmpty) {
          final staffData = staffQuery.docs.first.data();
          initialName = staffData['name'] ?? '';
          initialDesc = staffData['specialization'] ?? '';
          initialImg = staffData['profileImageUrl'];
        }
      }

      await docRef.set({
        'email': user.email ?? '',
        'role': 'user',
        'name': initialName,
        'description': initialDesc,
        'profileImageUrl': initialImg,
        'createdAt': FieldValue.serverTimestamp(),
      });
      doc = await docRef.get();
    }
    return doc;
  }

  void _initializeFields(Map<String, dynamic> data) {
    if (_initialized) return;
    _initialized = true;
    _nameController.text = data['name'] ?? '';
    _descriptionController.text = data['description'] ?? '';
    _emailController.text = data['email'] ?? _auth.currentUser?.email ?? '';
    _profileImageUrl = data['profileImageUrl'];
  }

  Future<void> _pickProfileImage() async {
    final imageUrl = await FirebaseImagePicker.pickImageFromFirebase(
      context,
      folderPath: 'staff_profiles',
      title: 'Select Profile Photo',
    );
    if (imageUrl != null) {
      setState(() => _profileImageUrl = imageUrl);
    }
  }

  Future<void> _saveProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() => _saving = true);

    try {
      // Use the UID directly to ensure we are hitting the right document
      await _firestore.collection('users').doc(user.uid).update({
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'profileImageUrl': _profileImageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved successfully.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save profile: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Not logged in.')));
    }

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            appBar: AppBar(title: const Text('My Account')),
            body: Center(
              child: Text('Error: ${snapshot.error ?? "Profile not found"}'),
            ),
          );
        }

        final data = snapshot.data!.data()!;
        _initializeFields(data);

        return Scaffold(
          appBar: AppBar(title: const Text('My Account')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: InkWell(
                    onTap: _pickProfileImage,
                    borderRadius: BorderRadius.circular(80),
                    child: CircleAvatar(
                      radius: 68,
                      backgroundColor: Colors.blueGrey.shade100,
                      backgroundImage: _profileImageUrl != null
                          ? NetworkImage(_profileImageUrl!) as ImageProvider
                          : null,
                      child: _profileImageUrl == null
                          ? const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Tap the circle to change your picture',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Color(0xFFEEEEEE),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _saving ? null : _saveProfile,
                  child: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save Changes'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
