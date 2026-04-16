# Firebase Firestore Schema Documentation
## Campus Maintenance Tasker Application

---

## Collections Overview

| Collection | Purpose | Documents |
|-----------|---------|-----------|
| `assignments` | Legacy - Work orders with type: 'assignment' | assignments |
| `facilities` | Campus buildings and rooms | facility_001, facility_002, etc. |
| `logs` | System logs and audit trail | Auto-generated |
| `reports` | Legacy - Work orders with type: 'report' | reports |
| `staff` | Maintenance staff members | staff_001, staff_002, etc. |
| `users` | User accounts and roles | {uid} |
| `work_orders` | Central collection for assignments and reports | work_order_001, etc. |

---

## Detailed Collection Schemas

### 1. **users** Collection

Stores user authentication and role information.

```json
{
  "docId": "user_uid_1",
  "email": "admin@campusmaintenance.app",
  "role": "admin",
  "disabled": false,
  "createdAt": "Timestamp(2026, 1, 1, 0, 0, 0)"
}
```

**Fields:**
- `docId` (String): Firebase UID - **Document ID should be the user's UID**
- `email` (String): User email address
- `role` (String): Authorization role - `"admin"` or `"user"`
- `disabled` (Boolean): Account status
- `createdAt` (Timestamp): Account creation date

---

### 2. **staff** Collection

Stores maintenance staff member information with profiles.

```json
{
  "docId": "staff_001",
  "name": "Mike Johnson",
  "role": "Technician",
  "email": "mike.johnson@campus.edu",
  "phone": "555-0101",
  "specialization": "HVAC",
  "status": "active",
  "profileImageUrl": "https://firebasestorage.googleapis.com/.../staff_profiles/...",
  "createdAt": "Timestamp(2026, 1, 1, 0, 0, 0)",
  "updatedAt": "Timestamp(2026, 1, 1, 0, 0, 0)"
}
```

**Fields:**
- `name` (String, Required): Full name of staff member
- `role` (String, Required): Job title (e.g., "Technician", "Electrician")
- `email` (String, Required): Email address
- `phone` (String, Optional): Contact phone number
- `specialization` (String, Optional): Area of expertise (e.g., "HVAC", "Electrical")
- `status` (String): Status - `"active"` or `"inactive"`
- `profileImageUrl` (String, Optional): URL to uploaded profile image
- `createdAt` (Timestamp): Record creation date
- `updatedAt` (Timestamp): Last modification date

---

### 3. **facilities** Collection

Stores campus facility/building information.

```json
{
  "docId": "facility_001",
  "name": "Building A - North Wing",
  "title": "Building A - North Wing",
  "rooms": "15 classrooms",
  "numRooms": 15,
  "equipment": "AC, Lights, Projectors",
  "description": "AC, Lights, Projectors, Doors",
  "status": "good",
  "capacity": "150 students",
  "location": "Campus Center",
  "createdAt": "Timestamp(2026, 1, 1, 0, 0, 0)"
}
```

**Fields:**
- `name` (String, Required): Facility name
- `title` (String, Required): Display title
- `rooms` (String): Description of rooms
- `numRooms` (Number): Number of rooms
- `equipment` (String): Equipment list
- `description` (String): Detailed description
- `status` (String): Status - `"good"`, `"maintenance_required"`, or `"closed"`
- `capacity` (String): Capacity information
- `location` (String): Building/area location
- `createdAt` (Timestamp): Creation date

---

### 4. **work_orders** Collection

Central collection for all work orders (assignments and reports).

#### 4.1 Assignment Type

```json
{
  "docId": "assign_001",
  "type": "assignment",
  "staff": "Mike Johnson",
  "task": "Fix AC in Room 101",
  "facility": "Building A - North Wing",
  "facilityId": "facility_001",
  "priority": "High",
  "status": "assigned",
  "imageUrl": "https://firebasestorage.googleapis.com/.../assignment_images/...",
  "createdAt": "Timestamp(2026, 4, 7, 11, 0, 0)",
  "updatedAt": "Timestamp(2026, 4, 7, 11, 0, 0)"
}
```

**Assignment-Specific Fields:**
- `type` (String): `"assignment"` - Required
- `staff` (String, Required): Assigned staff member name
- `task` (String, Required): Task description
- `facility` (String, Required): Facility name for dropdown reference
- `facilityId` (String, Required): Reference to facilities collection
- `priority` (String): `"Low"`, `"Medium"`, or `"High"`
- `status` (String): `"assigned"`, `"in_progress"`, `"completed"`
- `imageUrl` (String, Optional): URL to damage/area image
- `createdAt` (Timestamp): Assignment date
- `updatedAt` (Timestamp): Last update

#### 4.2 Report Type

```json
{
  "docId": "report_001",
  "type": "report",
  "facility": "Building A",
  "facilityId": "facility_001",
  "problem": "Broken AC",
  "status": "pending",
  "damageImageUrl": "https://firebasestorage.googleapis.com/.../damage_images/...",
  "createdAt": "Timestamp(2026, 4, 7, 10, 30, 0)",
  "updatedAt": "Timestamp(2026, 4, 7, 10, 30, 0)"
}
```

**Report-Specific Fields:**
- `type` (String): `"report"` - Required
- `facility` (String, Required): Facility name for dropdown reference
- `facilityId` (String, Required): Reference to facilities collection
- `problem` (String, Required): Problem description
- `status` (String): `"pending"`, `"in_progress"`, or `"fixed"`
- `damageImageUrl` (String, Optional): URL to damage photo
- `createdAt` (Timestamp): Report creation date
- `updatedAt` (Timestamp): Last update

---

## Firebase Storage Structure

Images are stored in Firebase Storage with the following paths:

```
gs://your-bucket/
├── staff_profiles/
│   ├── 1704067200000.jpg      // Staff profile photos
│   └── 1704067261234.jpg
├── assignment_images/
│   ├── 1704067300000.jpg      // Work area/damage photos for assignments
│   └── 1704067361234.jpg
└── damage_images/
    ├── 1704067400000.jpg      // Damage photos for reports
    └── 1704067461234.jpg
```

**Image Storage Rules:**
- **Staff Profiles**: `staff_profiles/{timestamp}.jpg` - Circular display
- **Assignment Images**: `assignment_images/{timestamp}.jpg` - Work area documentation
- **Damage Images**: `damage_images/{timestamp}.jpg` - Problem documentation

---

## Security Rules (Firestore)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users can only read/write their own user document
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Staff collection - admins can manage, users can read
    match /staff/{document=**} {
      allow read: if request.auth != null;
      allow create, update, delete: if get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Facilities - anyone authenticated can read
    match /facilities/{document=**} {
      allow read: if request.auth != null;
      allow write: if get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Work Orders - authenticated users can create/read, admins can manage
    match /work_orders/{document=**} {
      allow read: if request.auth != null;
      allow create, update: if request.auth != null;
      allow delete: if get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

---

## Firebase Storage Rules

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

## How to Add This Data to Firebase

### Step 1: Create Collections

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project → Firestore Database
3. Create the following collections (if not exists):
   - `users`
   - `staff`
   - `facilities`
   - `work_orders`
   - `logs`

### Step 2: Add Initial Users

1. Go to Firestore → Collection: `users`
2. Click **+ Add document**
3. Set Document ID: `{user_uid}` (actual Firebase UID from Authentication)
4. Add fields:
   ```
   email: string
   role: string (admin/user)
   disabled: boolean
   createdAt: timestamp
   ```

### Step 3: Add Facilities

1. Go to Firestore → Collection: `facilities`
2. Click **+ Add document**
3. Set Document ID: `facility_001`
4. Add fields from **Facilities Collection** schema above

### Step 4: Add Staff Members

1. Go to Firestore → Collection: `staff`
2. Click **+ Add document**
3. Set Document ID: `staff_001`
4. Add fields from **Staff Collection** schema above
5. **Note**: `profileImageUrl` will be auto-populated when staff upload images through the app

### Step 5: Authentication Setup

1. Go to Firebase Console → Authentication
2. Add users with your preferred sign-in methods
3. After user creates account, ensure an entry exists in `users` collection with matching UID
4. Set appropriate `role` field (`admin` or `user`)

---

## Key Points on New Features

### ✅ Staff Management Screen
- Displays all staff members with profile pictures
- Allows admin to add/edit staff with image uploads
- Images stored in `staff_profiles/` folder in Firebase Storage
- Each staff gets their own "My Profile" where they can view their details

### ✅ Facility Dropdown in Reports & Assignments
- Instead of manually typing facility names, users select from dropdown
- Dropdown populated from `facilities` collection
- Both `facility` (name) and `facilityId` stored with each work order
- Links assignments/reports to specific facilities for better tracking

### ✅ Image Upload for Damage Documentation
- Assignments can include images of work areas
- Reports can include damage photos
- Images stored in appropriate folders:
  - `assignment_images/` for work documentation
  - `damage_images/` for problem documentation
- Download URLs stored in work order documents for display

### ✅ Profile Screen for Staff
- Simple view of staff member details
- Shows name, role, email, phone, specialization
- Displays profile photo if uploaded
- Shows current status (active/inactive)

---

## Testing the Implementation

### Test Data

Add these test records to Firebase:

**Test Staff Member:**
```json
{
  "name": "John Doe",
  "role": "Technician",
  "email": "john.doe@campus.edu",
  "phone": "555-1234",
  "specialization": "General Maintenance",
  "status": "active"
}
```

**Test Facility:**
```json
{
  "name": "Student Center",
  "title": "Student Center Building",
  "numRooms": 10,
  "equipment": "AC, Lights, Water Fountains",
  "status": "good",
  "location": "Campus Main"
}
```

**Test Assignment with Images:**
```json
{
  "type": "assignment",
  "staff": "John Doe",
  "task": "Replace broken AC unit",
  "facility": "Student Center",
  "facilityId": "{facility_id}",
  "priority": "High",
  "status": "assigned"
  // imageUrl will be populated when image is uploaded
}
```

---

## Notes

- All timestamps should be Firestore `Timestamp` type, not strings
- Document IDs can be auto-generated or custom (current setup uses custom)
- Images are required to be < 5MB in size
- Proper indexing should be set up for queries filtering by status, priority, facility
- Backup your Firestore data regularly, especially before production launch
