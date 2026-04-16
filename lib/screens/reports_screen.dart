import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../utils/firebase_image_picker.dart';

class ReportsScreen extends StatefulWidget {
  final double screenWidth;

  const ReportsScreen({super.key, required this.screenWidth});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
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
                'Maintenance Reports',
                style: TextStyle(
                  fontSize: widget.screenWidth < 600 ? 18 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showReportDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Report Issue'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Track reported issues and their resolution status.',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: auth.reportsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Failed to load reports: ${snapshot.error}'),
                  );
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(child: Text('No reports found.'));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final reportDoc = docs[index];
                    final report = reportDoc.data();

                    // Fix: Use facilityId to reference the correct facility
                    final facilityId = report['facilityId'];

                    final issue =
                        report['problem'] ??
                        report['issue'] ??
                        report['description'] ??
                        'Unknown';
                    final status = report['status'] ?? 'Pending';
                    final statusColor =
                        (status == 'Completed' || status == 'fixed')
                        ? Colors.green
                        : (status == 'In Progress' || status == 'in_progress')
                        ? Colors.orange
                        : Colors.red;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            size: 18,
                                            color: Colors.grey.shade600,
                                          ),
                                          const SizedBox(width: 6),
                                          // Fix: Fetch facility name dynamically
                                          StreamBuilder<DocumentSnapshot>(
                                            stream: _firestore
                                                .collection('facilities')
                                                .doc(facilityId)
                                                .snapshots(),
                                            builder: (context, facSnapshot) {
                                              String displayName = "Loading...";
                                              if (facSnapshot.hasData &&
                                                  facSnapshot.data!.exists) {
                                                displayName =
                                                    facSnapshot.data!['name'] ??
                                                    facSnapshot.data!.id;
                                              } else if (facSnapshot.hasError ||
                                                  (facSnapshot.hasData &&
                                                      !facSnapshot
                                                          .data!
                                                          .exists)) {
                                                displayName = "Room Unknown";
                                              }
                                              return Text(
                                                displayName,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        issue,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withAlpha(51),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: statusColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: () =>
                                      _showReportDetails(context, reportDoc),
                                  icon: const Icon(
                                    Icons.info_outline,
                                    size: 18,
                                  ),
                                  label: const Text('View Details'),
                                ),
                                if (isAdmin) ...[
                                  const SizedBox(width: 8),
                                  TextButton.icon(
                                    onPressed: () =>
                                        _showReportDialog(context, docs[index]),
                                    icon: const Icon(Icons.edit, size: 18),
                                    label: const Text('Edit'),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton.icon(
                                    onPressed: () =>
                                        _deleteReport(context, docs[index].id),
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

  void _showReportDetails(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final report = doc.data();
    final issue =
        report['problem'] ?? report['issue'] ?? 'No description provided.';
    final status = report['status'] ?? 'pending';
    final damageImageUrl = report['damageImageUrl'];
    final facilityId = report['facilityId'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Details'),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Facility',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                StreamBuilder<DocumentSnapshot>(
                  stream: _firestore
                      .collection('facilities')
                      .doc(facilityId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    String facilityName = "Loading...";
                    if (snapshot.hasData && snapshot.data!.exists) {
                      facilityName =
                          snapshot.data!['name'] ?? snapshot.data!.id;
                    } else if (snapshot.hasError ||
                        (snapshot.hasData && !snapshot.data!.exists)) {
                      facilityName = "Room Unknown";
                    }
                    return Text(
                      facilityName,
                      style: const TextStyle(fontSize: 16),
                    );
                  },
                ),
                const SizedBox(height: 16),

                const Text(
                  'Problem Description',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(issue, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 16),

                const Divider(),
                const SizedBox(height: 8),

                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade50,
                  ),
                  child: damageImageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            damageImageUrl,
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const SizedBox(
                                  height: 150,
                                  child: Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                  ),
                                ),
                          ),
                        )
                      : const SizedBox(
                          height: 150,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_not_supported,
                                size: 40,
                                color: Colors.grey,
                              ),
                              Text(
                                'No damage photo',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
                const SizedBox(height: 16),

                const Text(
                  'Status',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: (status == 'fixed') ? Colors.green : Colors.orange,
                  ),
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

  void _showReportDialog(BuildContext context, [QueryDocumentSnapshot? doc]) {
    final problemController = TextEditingController(
      text: doc?['problem'] ?? doc?['issue'] ?? '',
    );
    final statusController = TextEditingController(
      text: doc?['status'] ?? 'pending',
    );
    String? selectedFacilityId = doc?['facilityId'];
    String? selectedImageUrl = doc?['damageImageUrl'];
    bool isUploading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(doc == null ? 'Report Issue' : 'Edit Report'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('facilities').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }
                    final facilities = snapshot.data!.docs;
                    return DropdownButtonFormField<String>(
                      initialValue: selectedFacilityId,
                      hint: const Text('Select Facility *'),
                      decoration: const InputDecoration(labelText: 'Facility'),
                      items: facilities.map((f) {
                        final name = f['name'] ?? f.id;
                        return DropdownMenuItem(
                          value: f.id,
                          child: Text(name.toString()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedFacilityId = value;
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: problemController,
                  decoration: const InputDecoration(
                    labelText: 'Problem Description *',
                  ),
                  minLines: 2,
                  maxLines: 4,
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: isUploading
                      ? null
                      : () async {
                          setDialogState(() => isUploading = true);
                          final imageUrl =
                              await FirebaseImagePicker.pickImageFromFirebase(
                                context,
                                folderPath: 'damage_images',
                                title: 'Select Damage Photo',
                              );
                          if (imageUrl != null) {
                            setDialogState(() {
                              selectedImageUrl = imageUrl;
                            });
                          }
                          setDialogState(() => isUploading = false);
                        },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300, width: 2),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade50,
                    ),
                    child: isUploading
                        ? const Center(child: CircularProgressIndicator())
                        : (selectedImageUrl != null
                              ? Column(
                                  children: [
                                    Image.network(
                                      selectedImageUrl!,
                                      height: 150,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(Icons.broken_image),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Tap to change damage photo',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                )
                              : const Column(
                                  children: [
                                    Icon(
                                      Icons.image_not_supported,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Tap to upload damage photo',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                )),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: statusController.text,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: ['pending', 'in_progress', 'fixed']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (value) =>
                      statusController.text = value ?? 'pending',
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
              onPressed: isUploading
                  ? null
                  : () => _saveReport(
                      context,
                      doc,
                      selectedFacilityId,
                      problemController.text,
                      statusController.text,
                      selectedImageUrl,
                    ),
              child: Text(doc == null ? 'Submit' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveReport(
    BuildContext context,
    QueryDocumentSnapshot? doc,
    String? facilityId,
    String problem,
    String status,
    String? damageImageUrl,
  ) async {
    if (problem.isEmpty || facilityId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    try {
      final reportData = {
        'type': 'report',
        'facilityId': facilityId,
        'problem': problem,
        'status': status,
        'damageImageUrl': damageImageUrl,
        if (doc == null) 'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (doc == null) {
        await _firestore.collection('work_orders').add(reportData);
      } else {
        await _firestore
            .collection('work_orders')
            .doc(doc.id)
            .update(reportData);
      }

      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _deleteReport(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Report'),
        content: const Text('Are you sure you want to delete this report?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _firestore.collection('work_orders').doc(id).delete();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
