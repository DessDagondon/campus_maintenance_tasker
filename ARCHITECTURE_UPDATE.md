# Campus Maintenance Tasker - Architecture Update

## ✅ COMPLETED FIXES

### 1. Removed Incorrect "My Profile" Navigation ✅
- **Issue**: User profiles were incorrectly added to the sidebar/main menu
- **Resolution**: 
  - Removed "My Profile" drawer item from dashboard_screen.dart
  - Removed "My Profile" sidebar button  
  - Removed staff_profile_screen.dart import
  - Renumbered menu sections (Admin sections now 4 & 5 instead of 5 & 6)

### 2. Firebase Image Picker Utility Created ✅
- **File**: `lib/utils/firebase_image_picker.dart`
- **Purpose**: Select images from Firebase Storage instead of local device
- **Features**:
  - Browse existing images in Firebase Storage folders
  - Grid view of available images with thumbnails
  - Select and return download URL
  - Works with any folder path (assignment_images, damage_images, facility_images, etc.)

### 3. Updated Image Handling in All Screens ✅

#### assignments_screen.dart
- Removed: ImagePicker (local device gallery)
- Added: FirebaseImagePicker for selecting from Firebase Storage
- Folder: `assignment_images/`
- Fixed syntax error: `'imageUrl': ?imageUrl` → conditional map entry

#### reports_screen.dart
- Removed: ImagePicker (local device gallery)
- Added: FirebaseImagePicker for selecting from Firebase Storage
- Folder: `damage_images/`
- Fixed syntax error: `'damageImageUrl': ?damageImageUrl` → conditional map entry

### 4. Code Quality ✅
- `flutter analyze` result: **2 info-level hints** (no errors or warnings)
- All BuildContext async gaps fixed
- All imports resolved
- Code compiles successfully

---

## 🔄 IN PROGRESS / TODO

### Remaining Architecture Clarifications

The user specified:
> "REQUIRED ARE FACILITIES, WORK REPORTS, LOGS AND STAFF (EACH STAFF HAS AN PROFILE) PROFILES ARE NOT RELATED TO THE USERS THAT LOG IN THEY ARE SEPARATE FROM THE STAFF WHO HAVE PROFILES"

**Current Status by Entity:**

| Entity | Status | Details |
|--------|--------|---------|
| **Users** | ✅ Complete | Firebase Auth login system working |
| **Staff** | ✅ Complete | Staff management screen with CRUD operations |
| **Staff Profiles** | ⚠️ Needs Clarification | Should be accessible from Staff Management screen, not main menu |
| **Facilities** | ⚠️ Partially Complete | Exists but needs image management |
| **Facility Images** | ❌ Not Implemented | Need to add image square to facility cards |
| **Work Orders/Assignments** | ✅ Complete | Full CRUD with facility selection and images from Firebase |
| **Maintenance Reports** | ✅ Complete | Full CRUD with facility selection and damage images from Firebase |
| **Logs** | ❌ Not Implemented | Missing screen for activity/maintenance logs |

---

## 📋 IMMEDIATE NEXT STEPS

### 1. Clarify Staff Profile Architecture
**Question for User**: How should staff profiles be accessed?

**Option A** (Recommended based on requirements):
```
Staff Management Screen → Select Staff Member → View/Edit Profile
```
- Staff profiles are nested under Staff management
- User clicking a staff member sees their profile + edit dialog
- Profile includes: name, role, email, phone, specialization, photo

**Option B** (Current but wrong):
```
Dashboard sidebar → My Profile (WRONG - removed this)
```

### 2. Add Facility Image Management
**Required Changes**:

In `facilities_screen.dart`:
- Add image square to facility cards showing current image
- Click image to select from Firebase `facility_images/` folder
- Display image in list view
- Add image in edit dialog

**Code Pattern to Add**:
```dart
GestureDetector(
  onTap: () async {
    final imageUrl = await FirebaseImagePicker.pickImageFromFirebase(
      context,
      folderPath: 'facility_images',
      title: 'Select Facility Image',
    );
    if (imageUrl != null) {
      setState(() {
        selectedImageUrl = imageUrl;
      });
    }
  },
  child: Container(
    width: 100,
    height: 100,
    decoration: BoxDecoration(border: Border.all()),
    child: selectedImageUrl != null 
      ? Image.network(selectedImageUrl!, fit: BoxFit.cover)
      : Icon(Icons.image),
  ),
)
```

### 3. Create Logs Screen
**Purpose**: Display activity logs for maintenance tasks, staff actions, etc.

**Data Structure** (proposed Firestore collection: `logs`):
```json
{
  "timestamp": "2026-04-11T10:30:00Z",
  "action": "created|updated|deleted|completed",
  "entityType": "work_order|report|facility|staff",
  "entityId": "doc-id",
  "entityName": "Assignment name / Report title",
  "userId": "user-who-performed-action",
  "details": "What was changed"
}
```

---

## 🏗️ NEW FIREBASE STORAGE STRUCTURE

Now that images come from Firebase Storage (not device uploads):

```
firebase-storage/
├── assignment_images/
│   ├── 1712890202340.jpg (work order documentation)
│   └── 1712890250010.jpg
├── damage_images/
│   ├── 1712890310450.jpg (damage/issue photos)
│   └── 1712890360920.jpg
├── facility_images/
│   ├── lab-a.jpg (facility photos)
│   ├── cafe-building.jpg
│   └── maintenance-room.jpg
└── staff_profiles/
    ├── john-smith.jpg (staff member photos)
    └── jane-doe.jpg
```

**Note**: Upload mechanism needs to be determined - this could be:
1. Admin uploads to Firebase via app (new feature needed)
2. Firebase web console upload
3. Script-based upload
4. Mobile app image capture → upload

---

## 📚 FIRESTORE SCHEMA UPDATE

### Facilities Collection
```json
{
  "name": "Laboratory A",
  "rooms": "5",
  "equipment": "Microscopes, centrifuge",
  "status": "Good",
  "imageUrl": "https://firebasestorage.googleapis.com/...facility_images/lab-a.jpg",
  "createdAt": "2026-01-15T10:00:00Z",
  "updatedAt": "2026-04-11T10:30:00Z"
}
```

### Staff Collection
```json
{
  "name": "John Smith",
  "role": "Maintenance Technician",
  "email": "john@campus.edu",
  "phone": "555-1234",
  "specialization": "HVAC Systems",
  "photoUrl": "https://firebasestorage.googleapis.com/...staff_profiles/john-smith.jpg",
  "createdAt": "2026-02-01T10:00:00Z",
  "updatedAt": "2026-04-11T10:30:00Z"
}
```

### Staff Profiles Collection (Separate from Staff)
```json
{
  "staffId": "staff-doc-id",
  "bio": "Detailed bio",
  "qualifications": ["HVAC certified", "Electrical hazard aware"],
  "experience": "5 years",
  "assignedFacilities": ["facility-id-1", "facility-id-2"],
  "createdAt": "2026-02-01T10:00:00Z",
  "updatedAt": "2026-04-11T10:30:00Z"
}
```

---

## 🔧 CURRENT IMAGE HANDLING

### Images Flow

1. **Intake**: Images stored in Firebase Storage
2. **Display**: Fetched via FirebaseImagePicker and displayed in dialogs
3. **Selection**: User picks from list of available images
4. **Storage**: URL saved to Firestore document
5. **Display in Lists**: Images shown in card views using Image.network()

### Folder Assignments

| Screen | Folder | Entity |
|--------|--------|--------|
| Assignments | `assignment_images/` | Work Order Images |
| Reports | `damage_images/` | Damage/Issue Photos |
| Facilities | `facility_images/` | Facility Photos |
| Staff | `staff_profiles/` | Staff Member Photos |

---

## ✨ SUMMARY

✅ **Completed**:
- Removed incorrect user profile navigation
- Created Firebase image picker utility
- Updated all image handling to use Firebase Storage
- Fixed syntax errors
- Code compiles without errors

⚠️ **Pending Clarification**:
- How to access staff profiles (from staff list vs main menu)
- How images are uploaded to Firebase Storage

❌ **Not Yet Implemented**:
- Facility image management in facility screen
- Logs/activity screen
- Image upload mechanism to Firebase

**Status**: Ready for user input on staffprofile access pattern and image upload strategy
