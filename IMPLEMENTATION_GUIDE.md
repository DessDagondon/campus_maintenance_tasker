# Campus Maintenance Tasker - New Features Implementation Guide

## Overview

This document outlines all the new features added to the Campus Maintenance Tasker application, including staff management, improved facility selection, and image upload capabilities.

---

## New Features Summary

### 1. ✅ Staff Management Screen
- **Access**: Admin users only → Dashboard → "Staff Management"
- **Features**:
  - View all staff members with profile pictures
  - Add new staff members with detailed information
  - Edit existing staff member details
  - Upload/manage staff profile photos
  - Delete staff records

### 2. ✅ Staff Profile/Account Screen
- **Access**: All users → Dashboard → "My Profile"
- **Features**:
  - View personal profile information
  - Display profile photo (if uploaded)
  - Show role, specialization, contact details
  - View current employment status

### 3. ✅ Facility Dropdown in Reports
- **Location**: Create/Edit Report → "Facility" field
- **Features**:
  - Dropdown selection instead of manual text entry
  - Automatically loads all facilities from Firestore
  - Displays facility name with formatted styling
  - Stores both facility ID and name for reference

### 4. ✅ Facility Dropdown in Assignments
- **Location**: Create/Edit Assignment → "Facility" field
- **Features**:
  - Same functionality as reports
  - Ensures consistency across the application
  - Better data integrity with facility references

### 5. ✅ Image Upload for Assignments
- **Location**: Create/Edit Assignment → Image section
- **Features**:
  - Upload images of work areas or damaged items
  - Visual preview before saving
  - Images stored in Firebase Storage
  - Download URL saved in work order
  - Supports editing and replacing images

### 6. ✅ Image Upload for Reports
- **Location**: Create/Edit Report → Damage Photo section
- **Features**:
  - Upload damage/problem photos
  - Same functionality as assignment images
  - Stored separately for damage documentation
  - Helps speed up assessment and repair

---

## File Structure

### New Dart Files Created

```
lib/screens/
├── staff_screen.dart              (NEW) Staff management interface
└── staff_profile_screen.dart       (NEW) Staff profile/account view
```

### Modified Dart Files

```
lib/screens/
├── assignments_screen.dart         (UPDATED) Added facility dropdown + image upload
├── reports_screen.dart             (UPDATED) Added facility dropdown + image upload
└── dashboard_screen.dart           (UPDATED) Added navigation for new screens
```

### Documentation Files

```
FIREBASE_SCHEMA.md                  (NEW) Complete Firebase schema documentation
IMPLEMENTATION_GUIDE.md             (THIS FILE)
```

---

## Dependency Changes

### New Packages Added to pubspec.yaml

```yaml
dependencies:
  firebase_storage: ^12.3.0         # Cloud storage for images
  image_picker: ^1.0.4              # Image selection from gallery
```

### Installation

Run the following command in your project directory:

```bash
flutter pub get
```

Or for iOS:

```bash
cd ios
pod install
cd ..
```

---

## Firebase Setup Required

### 1. Enable Cloud Storage

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Go to **Storage** in the left menu
4. Click **Get Started**
5. Set up storage rules (see [FIREBASE_SCHEMA.md](FIREBASE_SCHEMA.md) for rules)

### 2. Create Firestore Collections

Run these steps in Firebase Console:

```
1. Firestore Database → Create Collection
2. Create: users, staff, facilities, work_orders, logs
```

### 3. Set Storage Security Rules

In Firebase Console → Storage → Rules, paste:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /staff_profiles/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.resource.size < 5 * 1024 * 1024;
    }
    
    match /assignment_images/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.resource.size < 5 * 1024 * 1024;
    }
    
    match /damage_images/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.resource.size < 5 * 1024 * 1024;
    }
  }
}
```

---

## Data Structure Changes

### Staff Collection Schema

```dart
Staff Document {
  name: String (Required)           // Full name
  role: String (Required)           // Job title
  email: String (Required)          // Email address
  phone: String (Optional)          // Contact number
  specialization: String (Optional) // Area of expertise
  profileImageUrl: String           // Firebase Storage URL
  status: String                    // "active" or "inactive"
  createdAt: Timestamp              // Creation timestamp
  updatedAt: Timestamp              // Last update timestamp
}
```

### Work Orders - Enhanced Fields

#### Reports:
```dart
Work Order (Report) {
  type: "report"                    // Identifies as report
  facility: String (Required)       // Facility name
  facilityId: String (Required)     // Reference to facilities collection
  problem: String (Required)        // Problem description
  damageImageUrl: String (Optional) // URL to damage photo
  status: String                    // "pending", "in_progress", "fixed"
  createdAt: Timestamp
  updatedAt: Timestamp
}
```

#### Assignments:
```dart
Work Order (Assignment) {
  type: "assignment"                // Identifies as assignment
  staff: String (Required)          // Staff member name
  task: String (Required)           // Task description
  facility: String (Required)       // Facility name
  facilityId: String (Required)     // Reference to facilities collection
  imageUrl: String (Optional)       // URL to work area/damage image
  priority: String                  // "Low", "Medium", "High"
  status: String                    // "assigned", "in_progress", "completed"
  createdAt: Timestamp
  updatedAt: Timestamp
}
```

---

## User Interface Changes

### Dashboard Navigation

```
Dashboard Menu
├── Overview (all users)
├── Reports (all users)
├── Assignments (all users)
├── Facilities (all users)
├── My Profile (all users)
├── Staff Management (ADMIN ONLY - NEW)
└── Admin Settings (ADMIN ONLY)
```

### Report/Assignment Creation Dialog

**Before:**
- Manual text input for facility/location
- No image upload
- Simple text fields

**After:**
- Facility dropdown (populated from Firestore)
- Image upload section with preview
- Better validation (marked required fields with *)
- Visual feedback while uploading

---

## Usage Guide

### For Staff Members

#### Creating a Report

1. Navigate to **Reports** section
2. Click **"Report Issue"** button
3. Fill in:
   - **Facility** (select from dropdown)
   - **Problem Description** (required)
   - **Damage Photo** (tap to upload image)
   - **Status** (defaults to "pending")
4. Click **"Submit"**

#### Viewing Profile

1. Navigate to **My Profile** (in dashboard menu)
2. View your information:
   - Profile photo
   - Role/position
   - Contact information
   - Status

---

### For Admin Users

#### Managing Staff

1. Navigate to **Staff Management** (admin section)
2. Click **"Add Staff Member"** to create new staff
3. Fill in required fields:
   - Full Name (required)
   - Role/Title (required) - e.g., "Technician"
   - Email Address (required)
   - Phone Number (optional)
   - Specialization (optional)
   - Profile Photo (tap to upload)
4. Click **"Add"** to save

#### Editing Staff

1. In **Staff Management**, find the staff member
2. Click **"Edit"** on their card
3. Modify details as needed
4. Click **"Update"** to save

#### Creating Work Assignments

1. Navigate to **Assignments**
2. Click **"New Assignment"**
3. Fill in:
   - **Staff Name** (required)
   - **Task Description** (required)
   - **Facility** (select from dropdown)
   - **Priority** (Low/Medium/High)
   - **Work Area Image** (optional - tap to upload)
4. Click **"Create"**

---

## Image Upload Details

### Supported Features

- **Format**: JPG, PNG
- **Max Size**: 5 MB
- **Quality**: Auto-compressed to 80% quality
- **Storage Location**:
  - Staff profiles: `staff_profiles/{timestamp}.jpg`
  - Assignment images: `assignment_images/{timestamp}.jpg`
  - Damage photos: `damage_images/{timestamp}.jpg`

### Image Upload Flow

```
User selects image from gallery
           ↓
ImagePicker processes selection
           ↓
Image compressed to 80% quality
           ↓
Uploaded to Firebase Storage
           ↓
Download URL retrieved
           ↓
URL stored in Firestore document
           ↓
Image URL displayed in app
```

---

## Testing Checklist

- [ ] Create a test staff member with profile photo
- [ ] View staff profile in "Staff Management"
- [ ] Create a report with facility dropdown
- [ ] Upload damage image with report
- [ ] View uploaded image in report details
- [ ] Create assignment with facility dropdown
- [ ] Upload work area image with assignment
- [ ] Edit existing report/assignment (change image)
- [ ] Delete staff member
- [ ] Verify facility dropdown shows all facilities
- [ ] Test on both mobile and tablet layouts
- [ ] Verify image permissions (Android/iOS)

---

## Troubleshooting

### Images Not Uploading

**Problem**: Image upload fails silently
**Solution**:
1. Check Firebase Storage rules are correctly set
2. Verify `firebase_storage` package is up to date
3. Check device storage permission
4. Review Firebase Console for errors

### Facility Dropdown Empty

**Problem**: No facilities showing in dropdown
**Solution**:
1. Ensure `facilities` collection exists in Firestore
2. Add at least one facility document
3. Verify Firestore rules allow reading facilities
4. Check browser console for errors

### Staff Not Appearing

**Problem**: Staff members not showing in management
**Solution**:
1. Ensure `staff` collection exists
2. Verify documents are properly formatted
3. Check Firebase rules allow reading staff
4. Ensure user has admin role

### Image Download URL Not Working

**Problem**: Images show broken icon
**Solution**:
1. Check Firebase Storage path matches folder structure
2. Verify storage is accessible (check rules)
3. Ensure image upload completed successfully
4. Try downloading URL directly in browser

---

## Performance Considerations

### Image Optimization

- Images compressed to 80% quality before upload
- Reduced file size improves load times
- Smaller downloads use less bandwidth

### Firestore Queries

- Facility dropdown loads on-demand
- Consider adding indexes for large datasets
- Current implementation suitable for < 1000 facilities

### Storage Limits

- Default Firebase Storage: 5 GB free
- Each image: ~200-500 KB (after compression)
- Calculate storage needs accordingly

---

## Security Notes

### Access Control

- **Users**: Can read their own profile, view facilities
- **Staff**: Can view other staff, create reports/assignments
- **Admins**: Can manage all staff, create assignments, access admin settings

### Image Security

- All images require authentication to upload
- Images have 5 MB size limit to prevent abuse
- Download URLs expire after a period (Firebase managed)

### Data Validation

- Required fields: Name, Email, Role (staff), Facility (reports), Task (assignments)
- Email format validated by Firebase Authentication
- Image type validated by ImagePicker package

---

## Future Enhancements

Consider these improvements:

1. **Image Gallery**: View all assignment/damage photos
2. **Image Compression**: Further optimize image size
3. **Batch Operations**: Bulk edit/delete staff
4. **Advanced Search**: Filter by staff specialization
5. **Image Annotations**: Add markups to damage photos
6. **Progress Tracking**: Visual timeline of assignments
7. **Mobile Notifications**: Alert staff of new assignments
8. **Offline Mode**: Save assignments locally, sync when online

---

## Support & Questions

For issues with:
- **Flutter/Dart**: Check [Flutter docs](https://flutter.dev/docs)
- **Firebase**: See [Firebase docs](https://firebase.google.com/docs)
- **Image Picker**: Visit [image_picker package](https://pub.dev/packages/image_picker)
- **Firebase Storage**: Check [Storage docs](https://firebase.google.com/docs/storage)

---

## Changelog

### Version 1.1.0 (Current)

**Added:**
- Staff Management Screen
- Staff Profile/Account Screen
- Facility dropdown in Reports
- Facility dropdown in Assignments
- Image upload for Assignments
- Image upload for Reports
- Profile photo for staff members

**Modified:**
- Dashboard navigation (added Staff & Profile sections)
- Work order data structure (added facilityId, image URLs)
- Dialog UIs for better user experience

**Dependencies:**
- Added `firebase_storage: ^12.3.0`
- Added `image_picker: ^1.0.4`

---

## Document Version

- **Created**: April 11, 2026
- **Last Updated**: April 11, 2026
- **Status**: Active
- **Maintained By**: Development Team
