import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/firebase_image_picker.dart';

class FacilitiesScreen extends StatefulWidget {
  final double screenWidth;

  const FacilitiesScreen({super.key, required this.screenWidth});

  @override
  State<FacilitiesScreen> createState() => _FacilitiesScreenState();
}

class _FacilitiesScreenState extends State<FacilitiesScreen> {
  final _firestore = FirebaseFirestore.instance;

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
                'Facilities Management',
                style: TextStyle(
                  fontSize: widget.screenWidth < 600 ? 18 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isAdmin)
                ElevatedButton.icon(
                  onPressed: () => _showFacilityDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Facility'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Monitor and manage campus facilities, equipment, and resources.',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: auth.facilitiesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(child: Text('No facilities found.'));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final facility = docs[index].data();
                    final name = facility['name'] ?? 'Unknown';
                    final equipment = facility['equipment'] ?? 'None';
                    final status = facility['status'] ?? 'good';
                    final imageUrl = facility['imageUrl'];

                    Color statusColor;
                    switch (status.toLowerCase()) {
                      case 'good':
                        statusColor = Colors.green;
                        break;
                      case 'maintenance_required':
                        statusColor = Colors.orange;
                        break;
                      case 'needs_attention':
                        statusColor = Colors.red;
                        break;
                      default:
                        statusColor = Colors.grey;
                    }

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (imageUrl != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  imageUrl,
                                  width: double.infinity,
                                  height: 180,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _imagePlaceholder(Icons.broken_image),
                                ),
                              )
                            else
                              _imagePlaceholder(Icons.image_not_supported),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                _statusBadge(status, statusColor),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Equipment/Description: $equipment',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: () =>
                                      _showFacilityDetails(context, facility),
                                  icon: const Icon(
                                    Icons.info_outline,
                                    size: 18,
                                  ),
                                  label: const Text('View Details'),
                                ),
                                if (isAdmin) ...[
                                  const SizedBox(width: 8),
                                  TextButton.icon(
                                    onPressed: () => _showFacilityDialog(
                                      context,
                                      docs[index],
                                    ),
                                    icon: const Icon(Icons.edit, size: 18),
                                    label: const Text('Edit'),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton.icon(
                                    onPressed: () => _deleteFacility(
                                      context,
                                      docs[index].id,
                                    ),
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
                              ],
                            ),
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

  Widget _imagePlaceholder(IconData icon) {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade200,
      ),
      child: Icon(icon, size: 50, color: Colors.grey),
    );
  }

  Widget _statusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  void _showFacilityDetails(
    BuildContext context,
    Map<String, dynamic> facility,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Details - ${facility['name'] ?? 'Unknown'}'),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (facility['imageUrl'] != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      facility['imageUrl'],
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  _imagePlaceholder(Icons.image_not_supported),
                const SizedBox(height: 16),
                _detailRow(
                  'Status',
                  (facility['status'] ?? 'good').toString().toUpperCase(),
                ),
                const SizedBox(height: 8),
                _detailRow(
                  'Equipment/Description',
                  facility['equipment'] ?? 'None',
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
      ],
    );
  }

  void _showFacilityDialog(BuildContext context, [QueryDocumentSnapshot? doc]) {
    final nameController = TextEditingController(text: doc?['name'] ?? '');
    final equipmentController = TextEditingController(
      text: doc?['equipment'] ?? '',
    );
    String selectedStatus = doc?['status'] ?? 'good';
    String? selectedImageUrl = doc?['imageUrl'];
    bool isUploading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(doc == null ? 'Add Facility' : 'Edit Facility'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: isUploading
                        ? null
                        : () async {
                            setDialogState(() => isUploading = true);
                            try {
                              final url =
                                  await FirebaseImagePicker.pickImageFromFirebase(
                                    context,
                                    folderPath: 'facility_images',
                                    title: 'Select Facility Image',
                                  );
                              if (url != null) {
                                setDialogState(() => selectedImageUrl = url);
                              }
                            } finally {
                              setDialogState(() => isUploading = false);
                            }
                          },
                    child: Container(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.blue.shade200,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade50,
                      ),
                      child: isUploading
                          ? const Center(child: CircularProgressIndicator())
                          : (selectedImageUrl != null
                                ? Image.network(
                                    selectedImageUrl!,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(
                                    Icons.add_a_photo,
                                    size: 40,
                                    color: Colors.blue,
                                  )),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Facility Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: equipmentController,
                    decoration: const InputDecoration(
                      labelText: 'Equipment/Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Current Status',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'good', child: Text('Good')),
                      DropdownMenuItem(
                        value: 'maintenance_required',
                        child: Text('Maintenance Required'),
                      ),
                      DropdownMenuItem(
                        value: 'needs_attention',
                        child: Text('Needs Attention'),
                      ),
                    ],
                    onChanged: (v) => setDialogState(() => selectedStatus = v!),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isUploading
                  ? null
                  : () async {
                      if (nameController.text.trim().isEmpty) return;
                      final data = {
                        'name': nameController.text.trim(),
                        'equipment': equipmentController.text.trim(),
                        'status': selectedStatus,
                        'imageUrl': selectedImageUrl,
                        'updatedAt': FieldValue.serverTimestamp(),
                      };
                      if (doc == null) {
                        await _firestore.collection('facilities').add({
                          ...data,
                          'createdAt': FieldValue.serverTimestamp(),
                        });
                      } else {
                        await _firestore
                            .collection('facilities')
                            .doc(doc.id)
                            .update(data);
                      }
                      if (context.mounted) Navigator.pop(context);
                    },
              child: Text(doc == null ? 'Save' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteFacility(BuildContext context, String id) {
    _firestore.collection('facilities').doc(id).delete();
  }
}
