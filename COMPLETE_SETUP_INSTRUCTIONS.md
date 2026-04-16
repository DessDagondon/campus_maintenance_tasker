# COMPLETE SETUP GUIDE
# Collections + Image Folders + App Configuration

## YOUR FIRESTORE RULES (KEEP AS-IS - DO NOT CHANGE)

```
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    
    match /users/{userId} {
      allow read, write: if request.auth != null
        && (request.auth.uid == userId || request.auth.token.role == "admin");
    }

    // Unified rule for all other collections
    match /{document=**} {
      allow read, write: if request.time < timestamp.date(2026, 5, 2);
    }
  }
}
```

**These rules are LOCKED IN ✅** - the app will work with these rules.

---

## STEP-BY-STEP SETUP

### STEP 1: Create Firestore Collections

Go to **Firebase Console** → **Firestore Database**

Create 4 collections with these exact names:

1. **`users`** - User profiles
2. **`facilities`** - Buildings/equipment
3. **`work_orders`** - Reports & Assignments
4. **`staff`** - Staff members

### STEP 2: Create Storage Folders

Go to **Firebase Console** → **Storage**

Create these 4 folders (OR let app create them):

1. **`facility_images/`** - Facility photos
2. **`damage_images/`** - Damage/issue photos
3. **`assignment_images/`** - Assignment/work photos
4. **`staff_profiles/`** - Staff headshots

---

## COLLECTION FIELD MAPPING

### users Collection

| Field | Type | Required | Example |
|-------|------|----------|---------|
| email | string | ✅ | "admin@campusmaintenance.app" |
| role | string | ✅ | "admin" or "user" |
| name | string | ✅ | "Admin Name" |
| createdAt | timestamp | ✅ | Auto |

```javascript
{
  "email": "admin@campusmaintenance.app",
  "role": "admin",
  "name": "Campus Admin",
  "createdAt": Timestamp
}
```

---

### facilities Collection

| Field | Type | Required | Firebase Field | Example |
|-------|------|----------|----------------|---------|
| name | string | ✅ | name | "Building A - North Wing" |
| equipment | string | ❌ | equipment | "AC, Lights, Projectors" |
| status | string | ❌ | status | "good" |
| imageUrl | string | ❌ | imageUrl | "https://firebasestorage..." |
| createdAt | timestamp | ✅ | createdAt | Auto |
| updatedAt | timestamp | ✅ | updatedAt | Auto |

```javascript
{
  "name": "Building A - North Wing",
  "equipment": "AC, Lights, Projectors",
  "status": "good",
  "imageUrl": "https://firebasestorage.googleapis.com/...",
  "createdAt": Timestamp,
  "updatedAt": Timestamp
}
```

App Screens Using This:
- **Facilities Management** screen → uses all fields
- Creates/edits with photo upload

---

### work_orders Collection (TYPE: "report")

| Field | Type | Required | Firebase Field | Example |
|-------|------|----------|----------------|---------|
| type | string | ✅ | type | "report" |
| problem | string | ✅ | problem | "Broken AC" |
| facilityId | string | ✅ | facilityId | "facility_001" |
| status | string | ❌ | status | "pending" |
| damageImageUrl | string | ❌ | damageImageUrl | "https://..." |
| description | string | ❌ | description | "AC not working" |
| createdAt | timestamp | ✅ | createdAt | Auto |
| updatedAt | timestamp | ✅ | updatedAt | Auto |

```javascript
{
  "type": "report",
  "problem": "Broken AC",
  "facilityId": "facility_001",
  "status": "pending",
  "damageImageUrl": "https://firebasestorage.googleapis.com/...",
  "description": "AC in classroom 101 not working",
  "createdAt": Timestamp,
  "updatedAt": Timestamp
}
```

App Screen Using This:
- **Maintenance Reports** screen
- Filters by `type: "report"`

---

### work_orders Collection (TYPE: "assignment")

| Field | Type | Required | Firebase Field | Example |
|-------|------|----------|----------------|---------|
| type | string | ✅ | type | "assignment" |
| task | string | ✅ | task | "Fix AC in Room 101" |
| staff | string | ✅ | staff | "Mike Johnson" |
| facilityId | string | ✅ | facilityId | "facility_001" |
| priority | string | ❌ | priority | "High" |
| status | string | ❌ | status | "assigned" |
| imageUrl | string | ❌ | imageUrl | "https://..." |
| description | string | ❌ | description | "Replace compressor" |
| zone | string | ❌ | zone | "Building A" |
| location | string | ❌ | location | "Room 101" |
| createdAt | timestamp | ✅ | createdAt | Auto |
| updatedAt | timestamp | ✅ | updatedAt | Auto |

```javascript
{
  "type": "assignment",
  "task": "Fix AC in Room 101",
  "staff": "Mike Johnson",
  "facilityId": "facility_001",
  "priority": "High",
  "status": "assigned",
  "imageUrl": "https://firebasestorage.googleapis.com/...",
  "description": "Replace compressor unit",
  "zone": "Building A",
  "location": "Room 101",
  "createdAt": Timestamp,
  "updatedAt": Timestamp
}
```

App Screen Using This:
- **Work Assignments** screen
- Filters by `type: "assignment"`

---

### staff Collection

| Field | Type | Required | Firebase Field | Example |
|-------|------|----------|----------------|---------|
| name | string | ✅ | name | "Mike Johnson" |
| role | string | ✅ | role | "Technician" |
| email | string | ✅ | email | "mike.johnson@campus.edu" |
| phone | string | ❌ | phone | "555-0101" |
| specialization | string | ❌ | specialization | "HVAC" |
| status | string | ❌ | status | "active" |
| profileImageUrl | string | ❌ | profileImageUrl | "https://..." |
| createdAt | timestamp | ✅ | createdAt | Auto |
| updatedAt | timestamp | ✅ | updatedAt | Auto |

```javascript
{
  "name": "Mike Johnson",
  "role": "Technician",
  "email": "mike.johnson@campus.edu",
  "phone": "555-0101",
  "specialization": "HVAC",
  "status": "active",
  "profileImageUrl": "https://firebasestorage.googleapis.com/...",
  "createdAt": Timestamp,
  "updatedAt": Timestamp
}
```

App Screen Using This:
- **Staff Management** screen
- Shows profile images, filters by status

---

## STORAGE STRUCTURE

### facility_images/
- **Used by**: Facilities Management screen
- **Field in Firestore**: `facilities/{docId}/imageUrl`
- **Image format**: JPEG/PNG
- **Examples**: Building photos, facility exterior

### damage_images/
- **Used by**: Maintenance Reports screen
- **Field in Firestore**: `work_orders/{docId}/damageImageUrl`
- **Image format**: JPEG/PNG
- **Examples**: Broken equipment, water damage, electrical issues

### assignment_images/
- **Used by**: Work Assignments screen
- **Field in Firestore**: `work_orders/{docId}/imageUrl`
- **Image format**: JPEG/PNG
- **Examples**: Work in progress, before/after photos

### staff_profiles/
- **Used by**: Staff Management screen
- **Field in Firestore**: `staff/{docId}/profileImageUrl`
- **Image format**: JPEG/PNG
- **Examples**: Staff headshots, profile photos

---

## QUICK REFERENCE: FIELD NAMES

These field names are CASE-SENSITIVE and must match EXACTLY:

```
FACILITIES:
  name, equipment, status, imageUrl, createdAt, updatedAt

REPORTS (in work_orders):
  type (="report"), problem, facilityId, status, damageImageUrl, description, createdAt, updatedAt

ASSIGNMENTS (in work_orders):
  type (="assignment"), task, staff, facilityId, priority, status, imageUrl, zone, location, createdAt, updatedAt

STAFF:
  name, role, email, phone, specialization, status, profileImageUrl, createdAt, updatedAt

USERS:
  email, role, name, createdAt
```

---

## HOW THE APP WORKS WITH THIS STRUCTURE

### User Flow Example:

**1. Admin creates Facility**
1. Click "Add Facility" button
2. Enter name: "Building A"
3. Enter equipment: "AC, Lights"
4. Select status: "good"
5. Click image area → takes photo
6. Photo auto-uploads to Firebase Storage `facility_images/` folder
7. URL saves to Firestore `facilities/{docId}/imageUrl`
8. Photo appears in list immediately ✅

**2. Staff reports issue**
1. Click "Report Issue" button
2. Select facility: "Building A"
3. Enter problem: "AC not working"
4. Select status: "pending"
5. Click image area → takes/selects damage photo
6. Photo auto-uploads to Firebase Storage `damage_images/` folder
7. URL saves to Firestore `work_orders/{docId}/damageImageUrl`
8. Report appears in list ✅

**3. Admin assigns work**
1. Click "New Assignment" button
2. Enter task: "Fix AC"
3. Select staff: "Mike Johnson" (must exist in staff collection)
4. Select facility: "Building A"
5. Set priority: "High"
6. Click image area → takes/selects photo
7. Photo auto-uploads to Firebase Storage `assignment_images/` folder
8. URL saves to Firestore `work_orders/{docId}/imageUrl`
9. Assignment appears in list ✅

**4. Staff uploads profile**
1. Click "Add Staff Member"
2. Enter name, role, email
3. Click profile image area → takes/selects photo
4. Photo auto-uploads to Firebase Storage `staff_profiles/` folder
5. URL saves to Firestore `staff/{docId}/profileImageUrl`
6. Staff appears with avatar ✅

---

## FIREBASE CONSOLE CHECKLIST

- ✅ Collection `users` created
- ✅ Collection `facilities` created
- ✅ Collection `work_orders` created (for both reports & assignments)
- ✅ Collection `staff` created
- ✅ Storage folder `facility_images/` created
- ✅ Storage folder `damage_images/` created
- ✅ Storage folder `assignment_images/` created
- ✅ Storage folder `staff_profiles/` created
- ✅ Firestore rules applied (your existing rules)
- ✅ Storage rules applied (see STORAGE_SECURITY_RULES.txt)

---

## IMPORTANT REMINDERS

✅ **Field names are CASE-SENSITIVE** - use exact names from this guide
✅ **facilityId must reference real facilities** - must match a document ID in facilities collection
✅ **Staff names must exist** - assignment staff field must match a real staff member name
✅ **Images auto-upload** - app handles all image processing
✅ **Timestamps auto-generated** - use FieldValue.serverTimestamp()
✅ **Firestore rules stay locked** - your existing rules will work fine

❌ **Do NOT**:
- Manually create/delete files in Storage
- Change field names in documents
- Create test/dummy documents
- Use different folder names than specified

---

## TROUBLESHOOTING CHECKLIST

If "Add Facility" not working:
- ✅ Is `facilities` collection created?
- ✅ Are you logged in?
- ✅ Is Firestore time before May 2, 2026? (it is)

If images not uploading:
- ✅ Is Storage folder created?
- ✅ Have you given permissions?
- ✅ Check Storage rules file

If can't see facilities/staff/reports:
- ✅ Are collections created?
- ✅ Do documents have required fields?
- ✅ Is the field name spelled correctly?

---

## SUMMARY

Your app will work perfectly with:
1. ✅ The Firestore rules you provided (locked in)
2. ✅ The 4 collections structure above
3. ✅ The 4 Storage folders above
4. ✅ The field mappings specified

Everything is aligned and ready to go! 🚀

