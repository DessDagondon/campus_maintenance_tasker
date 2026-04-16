import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OverviewScreen extends StatefulWidget {
  final User? user;
  final bool isAdmin;
  final double screenWidth;

  const OverviewScreen({
    super.key,
    required this.user,
    required this.isAdmin,
    required this.screenWidth,
  });

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  late Future<int> reportsCount;
  late Future<int> assignmentsCount;
  late Future<int> facilitiesCount;
  late Future<int> staffCount;

  @override
  void initState() {
    super.initState();
    final firestore = FirebaseFirestore.instance;
    reportsCount = firestore
        .collection('work_orders')
        .where('type', isEqualTo: 'report')
        .get()
        .then((snap) => snap.docs.length);
    assignmentsCount = firestore
        .collection('work_orders')
        .where('type', isEqualTo: 'assignment')
        .get()
        .then((snap) => snap.docs.length);
    facilitiesCount = firestore
        .collection('facilities')
        .get()
        .then((snap) => snap.docs.length);
    staffCount = firestore
        .collection('staff')
        .get()
        .then((snap) => snap.docs.length);
  }

  @override
  Widget build(BuildContext context) {
    final sectionPadding = widget.screenWidth < 600 ? 16.0 : 24.0;
    final crossAxisCount = widget.screenWidth < 600
        ? 1
        : widget.screenWidth < 900
        ? 2
        : 3;
    final childAspectRatio = widget.screenWidth < 600 ? 2.0 : 1.4;

    return Padding(
      padding: EdgeInsets.all(sectionPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Welcome to Campus Maintenance Tasker',
            style: TextStyle(
              fontSize: widget.screenWidth < 600 ? 18 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Signed in as: ${widget.user?.email ?? 'Unknown'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Role: ${widget.isAdmin ? 'Administrator' : 'Facility Staff'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (widget.isAdmin) ...[
                    const SizedBox(height: 10),
                    const Text(
                      'Admin access enabled. Use the sidebar to manage users, view reports, and configure facilities.',
                      style: TextStyle(color: Colors.black87),
                    ),
                  ] else ...[
                    const SizedBox(height: 10),
                    const Text(
                      'You can view assigned work orders, report issues, and track facility maintenance tasks.',
                      style: TextStyle(color: Colors.black87),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.count(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 18,
              mainAxisSpacing: 18,
              childAspectRatio: childAspectRatio,
              children: [
                FutureBuilder<int>(
                  future: reportsCount,
                  builder: (context, snapshot) => _OverviewCard(
                    title: 'Maintenance Requests',
                    description: 'Reported issues (broken AC, lights, etc.)',
                    icon: Icons.report_problem,
                    color: Colors.orange,
                    count: snapshot.data?.toString() ?? '0',
                  ),
                ),
                FutureBuilder<int>(
                  future: assignmentsCount,
                  builder: (context, snapshot) => _OverviewCard(
                    title: 'Work Orders',
                    description: 'Active assignments and repairs',
                    icon: Icons.assignment_ind,
                    color: Colors.blue,
                    count: snapshot.data?.toString() ?? '0',
                  ),
                ),
                FutureBuilder<int>(
                  future: facilitiesCount,
                  builder: (context, snapshot) => _OverviewCard(
                    title: 'Facilities',
                    description: 'Buildings, classrooms, equipment',
                    icon: Icons.apartment,
                    color: Colors.green,
                    count: snapshot.data?.toString() ?? '0',
                  ),
                ),
                if (widget.isAdmin)
                  FutureBuilder<int>(
                    future: staffCount,
                    builder: (context, snapshot) => _OverviewCard(
                      title: 'Active Staff',
                      description: 'Assigned facility managers',
                      icon: Icons.people,
                      color: Colors.purple,
                      count: snapshot.data?.toString() ?? '0',
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

class _OverviewCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String count;

  const _OverviewCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 34, color: color),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withAlpha(51),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    count,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
