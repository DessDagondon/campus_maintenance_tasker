import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LogsScreen extends StatefulWidget {
  final double screenWidth;

  const LogsScreen({super.key, required this.screenWidth});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
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
          Text(
            'Activity & Assignment Logs',
            style: TextStyle(
              fontSize: widget.screenWidth < 600 ? 18 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Track maintenance assignments and their progress from start to completion.',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('work_orders')
                  .where('type', isEqualTo: 'assignment')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error loading logs: ${snapshot.error}'),
                  );
                }

                final docs = snapshot.data?.docs.toList() ?? [];
                docs.sort((a, b) {
                  final aTs = (a.data() as Map<String, dynamic>?)?['updatedAt'];
                  final bTs = (b.data() as Map<String, dynamic>?)?['updatedAt'];
                  if (aTs is Timestamp && bTs is Timestamp) {
                    return bTs.compareTo(aTs);
                  }
                  if (aTs is Timestamp) return -1;
                  if (bTs is Timestamp) return 1;
                  return 0;
                });
                if (docs.isEmpty) {
                  return const Center(child: Text('No assignments found.'));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final assignment =
                        docs[index].data() as Map<String, dynamic>;
                    final assignmentId = docs[index].id;
                    final staffName = assignment['staffName'] ?? 'Unassigned';
                    final reportProblem =
                        assignment['reportProblem'] ?? 'Unknown Issue';
                    final status = assignment['status'] ?? 'pending';
                    final activityLogs = assignment['activityLogs'] as List?;

                    final statusColor = (status == 'complete')
                        ? Colors.green
                        : (status == 'working')
                        ? Colors.orange
                        : Colors.red;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Assignment Header
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
                                            Icons.assignment_ind,
                                            size: 18,
                                            color: Colors.grey.shade600,
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              staffName,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        reportProblem,
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
                                    color: statusColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    _displayStatus(status),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: statusColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Divider(height: 1),
                            const SizedBox(height: 16),
                            // Activity Log Timeline
                            Text(
                              'Progress Timeline',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (activityLogs != null && activityLogs.isNotEmpty)
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: activityLogs.length,
                                itemBuilder: (context, logIndex) {
                                  final log =
                                      activityLogs[logIndex]
                                          as Map<String, dynamic>?;
                                  if (log == null) {
                                    return const SizedBox.shrink();
                                  }

                                  final logStatus = log['status'] ?? 'unknown';
                                  final notes = log['notes'] ?? '';
                                  final timestamp = log['timestamp'];
                                  final formattedTime = timestamp != null
                                      ? _formatTimestamp(timestamp)
                                      : 'Recently';

                                  final logStatusColor =
                                      (logStatus == 'complete')
                                      ? Colors.green
                                      : (logStatus == 'working')
                                      ? Colors.orange
                                      : Colors.red;

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: logStatusColor,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    _displayStatus(logStatus),
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: logStatusColor,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    formattedTime,
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color:
                                                          Colors.grey.shade500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              if (notes.isNotEmpty) ...[
                                                const SizedBox(height: 4),
                                                Text(
                                                  notes,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey.shade700,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              )
                            else
                              Text(
                                'No activity logged yet',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            const SizedBox(height: 12),
                            if (isAdmin)
                              Center(
                                child: ElevatedButton.icon(
                                  onPressed: () => _showAddLogDialog(
                                    context,
                                    assignmentId,
                                    assignment,
                                  ),
                                  icon: const Icon(Icons.add, size: 16),
                                  label: const Text('Add Progress Update'),
                                ),
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

  void _showAddLogDialog(
    BuildContext context,
    String assignmentId,
    Map<String, dynamic> assignment,
  ) {
    String selectedStatus = assignment['status'] ?? 'pending';
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Update Progress'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Staff: ${assignment['staffName'] ?? 'Unknown'}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          assignment['reportProblem'] ?? 'Unknown Issue',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: ['pending', 'working', 'complete']
                        .map(
                          (s) => DropdownMenuItem(
                            value: s,
                            child: Text(_displayStatus(s)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => selectedStatus = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                      border: OutlineInputBorder(),
                      hintText: 'e.g., Started work, 50% complete...',
                    ),
                    minLines: 3,
                    maxLines: 5,
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
              onPressed: () => _saveLogEntry(
                context,
                assignmentId,
                selectedStatus,
                notesController.text,
              ),
              child: const Text('Save Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveLogEntry(
    BuildContext context,
    String assignmentId,
    String status,
    String notes,
  ) async {
    try {
      final assignmentRef = _firestore
          .collection('work_orders')
          .doc(assignmentId);

      // Add log entry and update status
      await assignmentRef.update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
        'activityLogs': FieldValue.arrayUnion([
          {
            'timestamp': Timestamp.now(),
            'status': status,
            'notes': notes.isNotEmpty ? notes : 'Status updated to $status',
            'addedBy': 'system',
          },
        ]),
      });

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Progress update saved')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  String _displayStatus(String status) {
    if (status == 'working') {
      return 'IN PROGRESS';
    }
    return status.toUpperCase();
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Recently';

    DateTime dateTime;
    if (timestamp is Timestamp) {
      dateTime = timestamp.toDate();
    } else {
      return 'Recently';
    }

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      final month =
          <int, String>{
            1: 'Jan',
            2: 'Feb',
            3: 'Mar',
            4: 'Apr',
            5: 'May',
            6: 'Jun',
            7: 'Jul',
            8: 'Aug',
            9: 'Sep',
            10: 'Oct',
            11: 'Nov',
            12: 'Dec',
          }[dateTime.month] ??
          '';
      return '$month ${dateTime.day}';
    }
  }
}
