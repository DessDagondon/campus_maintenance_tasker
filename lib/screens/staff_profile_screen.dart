import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;

class StaffProfileScreen extends StatefulWidget {
  const StaffProfileScreen({super.key});

  @override
  State<StaffProfileScreen> createState() => _StaffProfileScreenState();
}

class _StaffProfileScreenState extends State<StaffProfileScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Not logged in')));
    }

    return FutureBuilder<DocumentSnapshot>(
      future: _firestore.collection('staff').doc(user.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          // Check if user has a staff record by querying with email
          return StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('staff')
                .where('email', isEqualTo: user.email)
                .snapshots(),
            builder: (context, emailSnapshot) {
              if (emailSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (emailSnapshot.data?.docs.isEmpty ?? true) {
                return Scaffold(
                  appBar: AppBar(title: const Text('My Profile')),
                  body: const Center(
                    child: Text('You do not have a staff profile yet.'),
                  ),
                );
              }

              final staffDoc = emailSnapshot.data!.docs.first;
              return _buildProfileUI(staffDoc);
            },
          );
        }

        return _buildProfileUI(snapshot.data!);
      },
    );
  }

  Widget _buildProfileUI(DocumentSnapshot staffDoc) {
    final data = staffDoc.data() as Map<String, dynamic>?;

    if (data == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Profile')),
        body: const Center(child: Text('No profile data found')),
      );
    }

    final name = data['name'] ?? 'Unknown';
    final role = data['role'] ?? 'Maintenance Worker';
    final email = data['email'] ?? 'N/A';
    final phone = data['phone'] ?? 'N/A';
    final specialization = data['specialization'] ?? 'General Maintenance';
    final profileImageUrl = data['profileImageUrl'];
    final status = data['status'] ?? 'active';

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile'), elevation: 0),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.blueGrey.shade50),
              child: Column(
                children: [
                  // Profile Image
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blueGrey, width: 3),
                      image: profileImageUrl != null
                          ? DecorationImage(
                              image: NetworkImage(profileImageUrl),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: profileImageUrl == null
                        ? const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.blueGrey,
                          )
                        : null,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.lightBlue.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      role,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Status: ${status[0].toUpperCase()}${status.substring(1)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Details Section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Contact Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailCard(
                    icon: Icons.email,
                    label: 'Email',
                    value: email,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailCard(
                    icon: Icons.phone,
                    label: 'Phone',
                    value: phone != 'N/A' ? phone : 'Not provided',
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Professional Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailCard(
                    icon: Icons.work,
                    label: 'Specialization',
                    value: specialization,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Edit profile feature coming soon',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit Profile'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
