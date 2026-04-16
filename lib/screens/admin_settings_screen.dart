import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../providers/auth_provider.dart';

class AdminSettingsScreen extends StatelessWidget {
  final AuthProvider auth;
  final double screenWidth;

  const AdminSettingsScreen({
    super.key,
    required this.auth,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = screenWidth < 600;
    final padding = isSmallScreen ? 16.0 : 24.0;

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Admin Settings',
            style: TextStyle(
              fontSize: isSmallScreen ? 22 : 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Manage system users. Disable temporarily disables active users. Delete permanently removes them from the system.',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: auth.usersStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Failed to load users: ${snapshot.error}'),
                  );
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(child: Text('No users found.'));
                }

                return isSmallScreen
                    ? _buildCardLayout(docs, context)
                    : _buildTableLayout(docs, context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableLayout(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    BuildContext context,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Email')),
          DataColumn(label: Text('Role')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Joined')),
          DataColumn(label: Text('Actions')),
        ],
        rows: docs.map((doc) {
          final data = doc.data();
          final email = data['email']?.toString() ?? 'Unknown';
          final role = data['role']?.toString() ?? 'user';
          final disabled = data['disabled'] == true;
          final createdAt = data['createdAt'];
          final joined = createdAt is Timestamp
              ? DateTime.fromMillisecondsSinceEpoch(
                  createdAt.millisecondsSinceEpoch,
                )
              : null;

          return DataRow(
            cells: [
              DataCell(Text(email)),
              DataCell(Text(role)),
              DataCell(Text(disabled ? 'Disabled' : 'Active')),
              DataCell(
                Text(
                  joined != null
                      ? '${joined.year}-${joined.month.toString().padLeft(2, '0')}-${joined.day.toString().padLeft(2, '0')}'
                      : 'Unknown',
                ),
              ),
              DataCell(
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (disabled)
                        _buildReEnableButton(context, doc, email)
                      else if (role != 'admin')
                        Row(
                          children: [
                            _buildDisableButton(context, doc, email),
                            const SizedBox(width: 4),
                            _buildDeleteButton(context, doc, email),
                          ],
                        )
                      else
                        const Text('-'),
                    ],
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCardLayout(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    BuildContext context,
  ) {
    return ListView.builder(
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final doc = docs[index];
        final data = doc.data();
        final email = data['email']?.toString() ?? 'Unknown';
        final role = data['role']?.toString() ?? 'user';
        final disabled = data['disabled'] == true;
        final createdAt = data['createdAt'];
        final joined = createdAt is Timestamp
            ? DateTime.fromMillisecondsSinceEpoch(
                createdAt.millisecondsSinceEpoch,
              )
            : null;
        final joinedStr = joined != null
            ? '${joined.year}-${joined.month.toString().padLeft(2, '0')}-${joined.day.toString().padLeft(2, '0')}'
            : 'Unknown';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            email,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Role: $role',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Chip(
                      label: Text(
                        disabled ? 'Disabled' : 'Active',
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                      backgroundColor: disabled ? Colors.red : Colors.green,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Joined: $joinedStr',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (disabled)
                      _buildReEnableButton(context, doc, email)
                    else if (role != 'admin') ...[
                      _buildDisableButton(context, doc, email),
                      _buildDeleteButton(context, doc, email),
                    ] else
                      const Chip(label: Text('-')),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReEnableButton(
    BuildContext context,
    QueryDocumentSnapshot doc,
    String email,
  ) {
    return TextButton(
      onPressed: () async {
        final messenger = ScaffoldMessenger.of(context);
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Re-Enable User'),
              content: Text('Re-enable $email? This will restore the account.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Re-Enable'),
                ),
              ],
            );
          },
        );
        if (confirmed == true) {
          await auth.forceEnableUser(doc.id);
          if (!context.mounted) return;
          if (auth.errorMessage != null) {
            messenger.showSnackBar(SnackBar(content: Text(auth.errorMessage!)));
          }
        }
      },
      child: const Text('Re-Enable'),
    );
  }

  Widget _buildDisableButton(
    BuildContext context,
    QueryDocumentSnapshot doc,
    String email,
  ) {
    return TextButton(
      onPressed: () async {
        final messenger = ScaffoldMessenger.of(context);
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Disable User'),
              content: Text(
                'Disable $email? The user will not be able to log in, but can be re-enabled later.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Disable'),
                ),
              ],
            );
          },
        );
        if (confirmed == true) {
          await auth.disableUser(doc.id);
          if (!context.mounted) return;
          if (auth.errorMessage != null) {
            messenger.showSnackBar(SnackBar(content: Text(auth.errorMessage!)));
          }
        }
      },
      child: const Text('Disable'),
    );
  }

  Widget _buildDeleteButton(
    BuildContext context,
    QueryDocumentSnapshot doc,
    String email,
  ) {
    return TextButton(
      onPressed: () async {
        final messenger = ScaffoldMessenger.of(context);
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delete User'),
              content: Text(
                'Are you sure you want to permanently delete $email? This cannot be undone.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        );
        if (confirmed == true) {
          await auth.removeNonAdminUser(doc.id);
          if (!context.mounted) return;
          if (auth.errorMessage != null) {
            messenger.showSnackBar(SnackBar(content: Text(auth.errorMessage!)));
          }
        }
      },
      child: const Text('Delete'),
    );
  }
}
