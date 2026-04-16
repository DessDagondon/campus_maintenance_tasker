import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'admin_settings_screen.dart';
import 'my_account_screen.dart';
import 'overview_screen.dart';
import 'reports_screen.dart';
import 'assignments_screen.dart';
import 'facilities_screen.dart';
import 'staff_screen.dart';
import 'logs_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedSection = 0;

  void _selectSection(int index) {
    setState(() {
      _selectedSection = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final isAdmin = auth.isAdmin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Maintenance Tasker'),
        actions: [
          TextButton.icon(
            onPressed: auth.signOut,
            icon: const Icon(Icons.logout, color: Colors.black),
            label: const Text('Logout', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Dashboard Menu',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(),
              _DrawerItem(
                icon: Icons.dashboard,
                title: 'Overview',
                selected: _selectedSection == 0,
                onTap: () {
                  _selectSection(0);
                  Navigator.pop(context);
                },
              ),
              _DrawerItem(
                icon: Icons.report_problem,
                title: 'Reports',
                selected: _selectedSection == 1,
                onTap: () {
                  _selectSection(1);
                  Navigator.pop(context);
                },
              ),
              _DrawerItem(
                icon: Icons.assignment_ind,
                title: 'Assignments',
                selected: _selectedSection == 2,
                onTap: () {
                  _selectSection(2);
                  Navigator.pop(context);
                },
              ),
              _DrawerItem(
                icon: Icons.apartment,
                title: 'Facilities',
                selected: _selectedSection == 3,
                onTap: () {
                  _selectSection(3);
                  Navigator.pop(context);
                },
              ),
              _DrawerItem(
                icon: Icons.history,
                title: 'Logs & Activity',
                selected: _selectedSection == 4,
                onTap: () {
                  _selectSection(4);
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              _DrawerItem(
                icon: Icons.group,
                title: 'Staff Management',
                selected: _selectedSection == 5,
                onTap: () {
                  _selectSection(5);
                  Navigator.pop(context);
                },
              ),
              _DrawerItem(
                icon: Icons.account_circle,
                title: 'My Account',
                selected: _selectedSection == 6,
                onTap: () {
                  _selectSection(6);
                  Navigator.pop(context);
                },
              ),
              if (isAdmin) ...[
                _DrawerItem(
                  icon: Icons.settings,
                  title: 'Admin Settings',
                  selected: _selectedSection == 7,
                  onTap: () {
                    _selectSection(7);
                    Navigator.pop(context);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final isSmallScreen = screenWidth < 900;

          final content = _getContent(auth, user, isAdmin, screenWidth);

          if (isSmallScreen) {
            return content;
          }

          return Row(
            children: [
              Container(
                width: 240,
                color: Colors.grey.shade100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Menu',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SidebarButton(
                      icon: Icons.dashboard,
                      title: 'Overview',
                      selected: _selectedSection == 0,
                      onTap: () => _selectSection(0),
                    ),
                    _SidebarButton(
                      icon: Icons.report_problem,
                      title: 'Reports',
                      selected: _selectedSection == 1,
                      onTap: () => _selectSection(1),
                    ),
                    _SidebarButton(
                      icon: Icons.assignment_ind,
                      title: 'Assignments',
                      selected: _selectedSection == 2,
                      onTap: () => _selectSection(2),
                    ),
                    _SidebarButton(
                      icon: Icons.apartment,
                      title: 'Facilities',
                      selected: _selectedSection == 3,
                      onTap: () => _selectSection(3),
                    ),
                    _SidebarButton(
                      icon: Icons.history,
                      title: 'Logs & Activity',
                      selected: _selectedSection == 4,
                      onTap: () => _selectSection(4),
                    ),
                    const Divider(),
                    _SidebarButton(
                      icon: Icons.group,
                      title: 'Staff Management',
                      selected: _selectedSection == 5,
                      onTap: () => _selectSection(5),
                    ),
                    _SidebarButton(
                      icon: Icons.account_circle,
                      title: 'My Account',
                      selected: _selectedSection == 6,
                      onTap: () => _selectSection(6),
                    ),
                    if (isAdmin) ...[
                      _SidebarButton(
                        icon: Icons.settings,
                        title: 'Admin Settings',
                        selected: _selectedSection == 7,
                        onTap: () => _selectSection(7),
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(child: content),
            ],
          );
        },
      ),
    );
  }

  Widget _getContent(
    AuthProvider auth,
    User? user,
    bool isAdmin,
    double screenWidth,
  ) {
    // For non-admin users, prevent access to Admin Settings only
    int section = _selectedSection;
    if (!isAdmin && section >= 7) {
      section = 0; // Fallback to overview
    }

    return switch (section) {
      0 => OverviewScreen(
        user: user,
        isAdmin: isAdmin,
        screenWidth: screenWidth,
      ),
      1 => ReportsScreen(screenWidth: screenWidth),
      2 => AssignmentsScreen(screenWidth: screenWidth),
      3 => FacilitiesScreen(screenWidth: screenWidth),
      4 => LogsScreen(screenWidth: screenWidth),
      5 => StaffScreen(screenWidth: screenWidth),
      6 => MyAccountScreen(screenWidth: screenWidth),
      7 =>
        isAdmin
            ? AdminSettingsScreen(auth: auth, screenWidth: screenWidth)
            : OverviewScreen(
                user: user,
                isAdmin: isAdmin,
                screenWidth: screenWidth,
              ),
      _ => OverviewScreen(
        user: user,
        isAdmin: isAdmin,
        screenWidth: screenWidth,
      ),
    };
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? Colors.blue.shade50 : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: selected ? Colors.blue : Colors.black54),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected ? Colors.blue : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarButton({
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? Colors.blue.shade50 : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: selected ? Colors.blue : Colors.black54),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected ? Colors.blue : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
