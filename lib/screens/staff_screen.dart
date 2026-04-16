import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/firebase_image_picker.dart';

class StaffScreen extends StatefulWidget {
  final double screenWidth;

  const StaffScreen({super.key, required this.screenWidth});

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  final _firestore = FirebaseFirestore.instance;
  int? _expandedIndex;

  // Define the standard roles
  final List<String> _roles = [
    'Electrician',
    'Plumber',
    'Carpenter',
    'HVAC',
    'General',
  ];

  @override
  Widget build(BuildContext context) {
    final sectionPadding = widget.screenWidth < 600 ? 16.0 : 24.0;
    final auth = context.watch<AuthProvider>();
    final isAdmin = auth.isAdmin;

    return Padding(
      padding: EdgeInsets.all(sectionPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Staff Management',
                style: TextStyle(
                  fontSize: widget.screenWidth < 600 ? 18 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isAdmin)
                ElevatedButton.icon(
                  onPressed: () => _showStaffDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Staff Member'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Manage maintenance staff members and their details.',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _firestore.collection('staff').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Failed to load staff: ${snapshot.error}'),
                  );
                }

                // Updated filter: Only require 'name' to show the card. Email is now optional.
                final docs = (snapshot.data?.docs ?? []).where((doc) {
                  final data = doc.data();
                  return data['name'] != null;
                }).toList();

                if (docs.isEmpty) {
                  return const Center(child: Text('No staff members found.'));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final staff = docs[index].data();
                    final isExpanded = _expandedIndex == index;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () => setState(
                                () =>
                                    _expandedIndex = isExpanded ? null : index,
                              ),
                              child: Row(
                                children: [
                                  _buildProfileImage(staff['profileImageUrl']),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          staff['name'] ?? 'Unknown',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        _buildBadge(staff['role'] ?? 'Unknown'),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    isExpanded
                                        ? Icons.expand_less
                                        : Icons.expand_more,
                                  ),
                                ],
                              ),
                            ),
                            if (isExpanded) ...[
                              const Divider(height: 16),
                              _buildInfoRow(
                                Icons.email,
                                staff['email'] ?? 'No Email Provided',
                              ),
                              const SizedBox(height: 8),
                              _buildInfoRow(
                                Icons.phone,
                                staff['phone'] ?? 'N/A',
                              ),
                              const SizedBox(height: 8),
                              _buildInfoRow(
                                Icons.business,
                                staff['facilityName'] ?? 'No Facility Assigned',
                              ),
                              const SizedBox(height: 8),
                              _buildInfoRow(
                                Icons.work,
                                staff['specialization'] ?? 'N/A',
                              ),
                              const SizedBox(height: 12),
                              if (isAdmin)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () => _showStaffDialog(
                                        context,
                                        docs[index],
                                      ),
                                      icon: const Icon(Icons.edit, size: 18),
                                      label: const Text('Edit'),
                                    ),
                                    const SizedBox(width: 8),
                                    TextButton.icon(
                                      onPressed: () =>
                                          _deleteStaff(context, docs[index].id),
                                      icon: const Icon(
                                        Icons.delete,
                                        size: 18,
                                        color: Colors.red,
                                      ),
                                      label: const Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
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
    );
  }

  void _showStaffDialog(BuildContext context, [QueryDocumentSnapshot? doc]) {
    final data = doc?.data() as Map<String, dynamic>?;

    final nameController = TextEditingController(text: data?['name'] ?? '');
    final emailController = TextEditingController(text: data?['email'] ?? '');
    final phoneController = TextEditingController(text: data?['phone'] ?? '');
    final specializationController = TextEditingController(
      text: data?['specialization'] ?? '',
    );

    String? selectedImageUrl = data?['profileImageUrl'];
    String? selectedFacilityId = data?['facilityId'];
    String? selectedFacilityName = data?['facilityName'];

    String? selectedRole = (data != null && _roles.contains(data['role']))
        ? data['role']
        : null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(doc == null ? 'Add Staff Member' : 'Edit Staff Member'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildImagePicker(
                  selectedImageUrl,
                  (url) => setDialogState(() => selectedImageUrl = url),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Role/Title *',
                    border: OutlineInputBorder(),
                  ),
                  items: _roles
                      .map(
                        (role) =>
                            DropdownMenuItem(value: role, child: Text(role)),
                      )
                      .toList(),
                  onChanged: (val) => setDialogState(() => selectedRole = val),
                ),
                const SizedBox(height: 12),
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _firestore.collection('facilities').snapshots(),
                  builder: (context, snapshot) {
                    List<DropdownMenuItem<String>> items = [
                      const DropdownMenuItem(
                        value: null,
                        child: Text("No Facility Assigned"),
                      ),
                    ];
                    if (snapshot.hasData) {
                      for (var fDoc in snapshot.data!.docs) {
                        items.add(
                          DropdownMenuItem(
                            value: fDoc.id,
                            child: Text(
                              fDoc.data()['name'] ?? 'Unnamed Facility',
                            ),
                          ),
                        );
                      }
                    }
                    return DropdownButtonFormField<String>(
                      initialValue: selectedFacilityId,
                      decoration: const InputDecoration(
                        labelText: 'Assigned Facility',
                        border: OutlineInputBorder(),
                      ),
                      items: items,
                      onChanged: (val) {
                        setDialogState(() {
                          selectedFacilityId = val;
                          selectedFacilityName = val == null
                              ? null
                              : snapshot.data!.docs
                                    .firstWhere((d) => d.id == val)
                                    .data()['name'];
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email Address (Optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: specializationController,
                  decoration: const InputDecoration(
                    labelText: 'Specialization',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _saveStaff(
                context,
                doc,
                nameController.text,
                selectedRole ?? '',
                emailController.text,
                phoneController.text,
                specializationController.text,
                selectedImageUrl,
                selectedFacilityId,
                selectedFacilityName,
              ),
              child: Text(doc == null ? 'Add' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  // --- HELPER METHODS ---

  Widget _buildProfileImage(String? url) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blueGrey.shade300,
        image: url != null
            ? DecorationImage(image: NetworkImage(url), fit: BoxFit.cover)
            : null,
      ),
      child: url == null
          ? const Icon(Icons.person, size: 30, color: Colors.white)
          : null,
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.lightBlue.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.blue,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePicker(String? url, Function(String) onPicked) {
    return GestureDetector(
      onTap: () async {
        final imageUrl = await FirebaseImagePicker.pickImageFromFirebase(
          context,
          folderPath: 'staff_profiles',
          title: 'Select Staff Photo',
        );
        if (imageUrl != null) onPicked(imageUrl);
      },
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.blueGrey, width: 2),
        ),
        child: url != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.network(url, fit: BoxFit.cover),
              )
            : const Icon(Icons.camera_alt, size: 40, color: Colors.blueGrey),
      ),
    );
  }

  Future<void> _saveStaff(
    BuildContext context,
    QueryDocumentSnapshot? doc,
    String name,
    String role,
    String email,
    String phone,
    String specialization,
    String? profileImageUrl,
    String? facilityId,
    String? facilityName,
  ) async {
    // Email is no longer in this check
    if (name.isEmpty || role.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and Role are required')),
      );
      return;
    }

    try {
      final staffData = {
        'name': name,
        'role': role,
        'email': email.isNotEmpty ? email : null, // Handle optional email
        'phone': phone.isNotEmpty ? phone : null,
        'specialization': specialization.isNotEmpty ? specialization : null,
        'profileImageUrl': profileImageUrl,
        'facilityId': facilityId,
        'facilityName': facilityName,
        'status': 'active',
        if (doc == null) 'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (doc == null) {
        await _firestore.collection('staff').add(staffData);
      } else {
        await _firestore.collection('staff').doc(doc.id).update(staffData);
      }

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(doc == null ? 'Staff added!' : 'Staff updated!'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _deleteStaff(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Staff Member'),
        content: const Text(
          'Are you sure you want to delete this staff member?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _firestore.collection('staff').doc(id).delete();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Staff member deleted')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
