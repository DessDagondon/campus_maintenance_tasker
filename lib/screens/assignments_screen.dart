import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class AssignmentsScreen extends StatefulWidget {
  final double screenWidth;
  const AssignmentsScreen({super.key, required this.screenWidth});

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
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
                'Work Assignments',
                style: TextStyle(
                  fontSize: widget.screenWidth < 600 ? 18 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isAdmin)
                ElevatedButton.icon(
                  onPressed: () => _showAssignmentDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('New Assignment'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Assign maintenance reports to staff members and track progress.',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: auth.assignmentsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(child: Text('No assignments found.'));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final assignment = docs[index].data();
                    final status = (assignment['status'] ?? 'pending')
                        .toString()
                        .toLowerCase();

                    final statusColor = (status == 'complete')
                        ? Colors.green
                        : (status == 'working')
                        ? Colors.orange
                        : Colors.red;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
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
                                            Icons.person,
                                            size: 18,
                                            color: Colors.grey.shade600,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            assignment['staffName'] ??
                                                'Unassigned',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        assignment['reportProblem'] ??
                                            'Unknown Issue',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black87,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    status.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: statusColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: Colors.grey.shade500,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  assignment['facilityName'] ??
                                      'Unknown Location',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                            if (isAdmin) ...[
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    onPressed: () => _showAssignmentDialog(
                                      context,
                                      docs[index],
                                    ),
                                    icon: const Icon(Icons.edit, size: 18),
                                    label: const Text('Edit'),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton.icon(
                                    onPressed: () => _showActivityLogDialog(
                                      context,
                                      docs[index].id,
                                      assignment,
                                    ),
                                    icon: const Icon(Icons.history, size: 18),
                                    label: const Text('Log'),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: () =>
                                        _confirmDelete(context, docs[index].id),
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                      size: 20,
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

  void _showAssignmentDialog(
    BuildContext context, [
    QueryDocumentSnapshot? doc,
  ]) {
    final data = doc?.data() as Map<String, dynamic>?;
    String? selectedReportId = data?['reportId'];
    String? selectedStaffId = data?['staffId'];
    String? selectedFacilityId = data?['facilityId'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(doc == null ? 'New Assignment' : 'Edit Assignment'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. MUST CHOOSE FACILITY FIRST
                  _buildDropdown(
                    collection: 'facilities',
                    hint: '1. Select Facility *',
                    value: selectedFacilityId,
                    onChanged: (val) {
                      setDialogState(() {
                        selectedFacilityId = val;
                        selectedReportId = null; // Reset dependent fields
                        selectedStaffId = null;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // 2. CHOOSE REPORT (LOCKED UNTIL FACILITY PICKED)
                  _buildDropdown(
                    collection: 'work_orders',
                    hint: selectedFacilityId == null
                        ? 'Select Facility First'
                        : '2. Select Report *',
                    value: selectedReportId,
                    onChanged: (val) =>
                        setDialogState(() => selectedReportId = val),
                    isReport: true,
                    filterFacilityId: selectedFacilityId,
                    isEnabled: selectedFacilityId != null,
                  ),
                  const SizedBox(height: 16),

                  // 3. CHOOSE STAFF (LOCKED UNTIL FACILITY PICKED)
                  _buildDropdown(
                    collection: 'staff',
                    hint: selectedFacilityId == null
                        ? 'Select Facility First'
                        : '3. Select Staff Member *',
                    value: selectedStaffId,
                    onChanged: (val) =>
                        setDialogState(() => selectedStaffId = val),
                    filterFacilityId: selectedFacilityId,
                    isEnabled: selectedFacilityId != null,
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
              onPressed: () => _saveAssignment(
                context,
                doc,
                selectedReportId,
                selectedStaffId,
                selectedFacilityId,
              ),
              child: Text(doc == null ? 'Create' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String collection,
    required String hint,
    required String? value,
    required Function(String?) onChanged,
    bool isReport = false,
    String? filterFacilityId,
    bool isEnabled = true,
  }) {
    Query query = _firestore.collection(collection);

    if (isReport) {
      query = query.where('type', isEqualTo: 'report');
    }

    // This is the core logic: filter the Firestore query by the facility ID
    if (filterFacilityId != null) {
      query = query.where('facilityId', isEqualTo: filterFacilityId);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: isEnabled ? query.snapshots() : const Stream.empty(),
      builder: (context, snapshot) {
        if (isEnabled && !snapshot.hasData) {
          return const LinearProgressIndicator();
        }

        final items = snapshot.data?.docs ?? [];
        String? validValue = items.any((d) => d.id == value) ? value : null;

        return DropdownButtonFormField<String>(
          initialValue: validValue,
          hint: Text(hint),
          isExpanded: true,
          onChanged: isEnabled ? onChanged : null,
          items: isEnabled
              ? items.map((d) {
                  final data = d.data() as Map<String, dynamic>;
                  return DropdownMenuItem(
                    value: d.id,
                    child: Text(data['problem'] ?? data['name'] ?? d.id),
                  );
                }).toList()
              : [],
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            filled: !isEnabled,
            fillColor: isEnabled ? Colors.transparent : Colors.grey.shade200,
          ),
        );
      },
    );
  }

  Future<void> _saveAssignment(
    BuildContext context,
    QueryDocumentSnapshot? doc,
    String? reportId,
    String? staffId,
    String? facilityId,
  ) async {
    if (reportId == null || staffId == null || facilityId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('All fields are required')));
      return;
    }

    try {
      final reportSnap = await _firestore
          .collection('work_orders')
          .doc(reportId)
          .get();
      final staffSnap = await _firestore.collection('staff').doc(staffId).get();
      final facSnap = await _firestore
          .collection('facilities')
          .doc(facilityId)
          .get();

      final data = {
        'reportId': reportId,
        'reportProblem':
            (reportSnap.data() as Map?)?['problem'] ?? 'Unknown Issue',
        'staffId': staffId,
        'staffName': (staffSnap.data() as Map?)?['name'] ?? 'Unknown Staff',
        'facilityId': facilityId,
        'facilityName': (facSnap.data() as Map?)?['name'] ?? 'Unknown Location',
        'status': doc == null ? 'pending' : (doc.data() as Map)['status'],
        'type': 'assignment',
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (doc == null) {
        data['createdAt'] = FieldValue.serverTimestamp();
        data['activityLogs'] = [
          {
            'timestamp': DateTime.now(),
            'status': 'pending',
            'notes': 'Assignment created',
            'addedBy': 'Admin',
          },
        ];
        await _firestore.collection('work_orders').add(data);
      } else {
        await _firestore.collection('work_orders').doc(doc.id).update(data);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showActivityLogDialog(
    BuildContext context,
    String id,
    Map<String, dynamic> assignment,
  ) {
    String selectedStatus = assignment['status'] ?? 'pending';
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Update Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: selectedStatus,
                items: ['pending', 'working', 'complete']
                    .map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text(s.toUpperCase()),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setDialogState(() => selectedStatus = val!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _addActivityLog(
                context,
                id,
                selectedStatus,
                notesController.text,
              ),
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addActivityLog(
    BuildContext context,
    String id,
    String status,
    String notes,
  ) async {
    try {
      await _firestore.collection('work_orders').doc(id).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
        'activityLogs': FieldValue.arrayUnion([
          {
            'timestamp': DateTime.now(),
            'status': status,
            'notes': notes.isEmpty ? 'Status updated' : notes,
            'addedBy': 'Admin',
          },
        ]),
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Assignment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _firestore.collection('work_orders').doc(id).delete();
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
