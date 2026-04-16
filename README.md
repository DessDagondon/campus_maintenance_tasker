# flutterfire01

# Campus Maintenance Tasker 
- Flutter Elective Final Exam Project
- A full-stack maintenance management system built with Flutter and Firebase. This application includes the process of reporting campus issues, assigning staff to assignments based on the assigned facility locations, and tracking work progress through real-time logs.

# Live Application (Backend Link)
- URL: https://campusmaintenance-f1b6e.web.app

# Core Features

# Facility-Specific Staffing:
Implemented a constraint-based system where Staff are manually assigned to specific Facilities. When a report is filed for a building, the system automatically filters the available workforce to only allow assigned staff to accept the task.

# Work Order Management:
- Comprehensive CRUD operations for maintenance tasks, including status updates from "Pending" to "Working" to "Completed."

# Automated Activity Logs:
- Every work order maintains a history of actions performed by Admins, Staff, or the System.

# Multi-Role Access: 
- Managed views for Users (Reporting), Staff (Execution), and Admins (Management).


# Tools:
- Frontend: Flutter Web (Dart)

- Backend: Firebase Auth & Cloud Firestore

- Hosting: Firebase Hosting

# Project Structure
- lib/models/: Data structures for Facilities, Staff, and Work Orders.

- lib/services/: Firebase Firestore logic and Auth services.

- lib/screens/: UI components for the different user roles.

- firebase_options.dart: Project configuration (Automated via FlutterFire).


# Project Screens


# Landing Page Screen:
![Landing Page](./lib/screenshots/landing_page.png)

# Create Account Screen:
![Create Account](./lib/screenshots/create_account.png)

# Log In Screen:
![Log In](./lib/screenshots/log_in.png)

# Dashboard Screen:
![Dashboard](./lib/screenshots/dashboard.png)

# Admin Settings Screen:
![Admin Settings](./lib/screenshots/admin_settings.png)

# MyAccount Screen:
![Myaccount](./lib/screenshots/myaccount.png)

# Staff Management Screen:
![Staff Management](./lib/screenshots/staff_management.png)

# Facility Screen:
![Facility](./lib/screenshots/facility.png)

# Reports Screen:
![Reports](./lib/screenshots/reports.png)

# Assignments Screen:
![Work Orders/Assignments](./lib/screenshots/assignments.png)

# Logs Screen:
![Logs](./lib/screenshots/logs.png)


# Final Note
This project was developed as part of the Flutter elective final exam.
