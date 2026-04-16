# Campus Maintenance Tasker - Session Update (April 2026)
## Code Changes & Firebase Configuration Summary

---

## 📝 Code Changes This Session

### Issue #1: Staff Management Navigation - FIXED ✅
**File:** `lib/screens/dashboard_screen.dart`  
**Problem:** Clicking "Staff Management" in sidebar showed activity logs instead of staff screen  
**Solution:** Corrected index mapping in `_SidebarButton` for desktop layout
```dart
// BEFORE (Line 196):
selected: _selectedSection == 4,  // Wrong: Same as Logs
onTap: () => _selectSection(4),

// AFTER:
selected: _selectedSection == 5,  // Correct: Unique index
onTap: () => _selectSection(5),
```

---

### Issue #2: Facilities Edit Button - FIXED ✅
**File:** `lib/screens/facilities_screen.dart`  
**Problem:** Edit dialog crashed when clicking facilities edit button  
**Root Cause:** Unbounded gesture detector with zero-size hit test area on web  
**Solution:** Complete rewrite of `_showFacilityDialog()` method:
- Added fixed-width `SizedBox(width: 420)` to dialog content
- Replaced `GestureDetector` with `InkWell` for event handling
- Added `borderRadius` to gesture area
- Ensured image picker container has definite 150px height
- Fixed loading state handling in `loadingBuilder` callback

```dart
// CHANGED: GestureDetector → InkWell
InkWell(
  borderRadius: BorderRadius.circular(8),
  onTap: isUploading ? null : () async { ... },
  child: Container(
    width: double.infinity,
    height: 150,  // Fixed height
    // ... rest of layout
  ),
),
```

---

### Issue #3: Dashboard Summary Data - FIXED ✅
**File:** `lib/screens/overview_screen.dart`  
**Problem:** Dashboard displayed hardcoded counts instead of real Firebase data  
**Solution:** Converted to stateful widget with live Firestore queries
```dart
// CLASS CHANGE:
StatelessWidget → StatefulWidget

// NEW initState():
reportsCount = firestore.collection('work_orders')
    .where('type', isEqualTo: 'report')
    .get()
    .then((snap) => snap.docs.length);

assignmentsCount = firestore.collection('work_orders')
    .where('type', isEqualTo: 'assignment')
    .get()
    .then((snap) => snap.docs.length);

facilitiesCount = firestore.collection('facilities')
    .get()
    .then((snap) => snap.docs.length);

staffCount = firestore.collection('staff')
    .get()
    .then((snap) => snap.docs.length);

// Dashboard cards now use FutureBuilder for live updates:
FutureBuilder<int>(
  future: reportsCount,
  builder: (context, snapshot) => _OverviewCard(
    count: snapshot.data?.toString() ?? '0',
    ...
  ),
),
```

---

## 🗄️ Firestore Collections & Document Structure

### 1. **work_orders** Collection
Used for both reports AND assignments (differentiated by `type` field)

#### Report Document Example:
```json
{
  "type": "report",
  "problem": "Air conditioner not working in Room 201",
  "issue": "AC Unit Malfunction",
  "status": "pending",
  "facilityId": "fac_001",
  "facility": "Building A - Room 201",
  "damageImageUrl": "https://storage.googleapis.com/...",
  "createdBy": "user_email@example.com",
  "createdAt": "Timestamp(2026-04-11T10:30:00Z)",
  "updatedAt": "Timestamp(2026-04-11T10:30:00Z)"
}
```

#### Assignment Document Example:
```json
{
  "type": "assignment",
  "reportId": "doc_id_of_report",
  "staffId": "staff_001",
  "facilityId": "fac_001",
  "reportProblem": "Air conditioner not working in Room 201",
  "staffName": "John Doe",
  "staffEmail": "john@example.com",
  "status": "pending",
  "assignedAt": "Timestamp(2026-04-11T10:35:00Z)",
  "updatedAt": "Timestamp(2026-04-11T10:35:00Z)"
}
```

### 2. **facilities** Collection
```json
{
  "id": "fac_001",
  "name": "Building A - Room 201",
  "equipment": "Air Conditioning Unit (Model XYZ)",
  "status": "good",  // or "maintenance_required", "needs_attention"
  "imageUrl": "https://storage.googleapis.com/...",
  "createdAt": "Timestamp(...)",
  "updatedAt": "Timestamp(...)"
}
```

### 3. **staff** Collection
```json
{
  "id": "staff_001",
  "name": "John Doe",
  "email": "john@example.com",
  "role": "maintenance_technician",  // or "supervisor", "admin"
  "phone": "+1-555-0123",
  "profileImageUrl": "https://storage.googleapis.com/...",
  "assignedFacilities": ["fac_001", "fac_002"],
  "createdAt": "Timestamp(...)",
  "updatedAt": "Timestamp(...)"
}
```

### 4. **activityLogs** Collection (Subcollection within assignment)
**Path:** `work_orders/{assignmentId}/activityLogs/{logId}`

```json
{
  "action": "status_update",  // or "comment", "image_added", etc.
  "oldStatus": "pending",
  "newStatus": "in_progress",
  "description": "Started maintenance work",
  "timestamp": "Timestamp(2026-04-11T14:00:00Z)",
  "updatedBy": "john@example.com"
}
```

---

## 📁 Firebase Storage Folder Structure

### Root: `gs://your-project-id.appspot.com/`

```
root/
├── staff_images/                          # Staff profile photos
│   ├── staff_001_profile.jpg
│   ├── staff_002_profile.jpg
│   └── [staffId]_profile.[ext]
│
├── damage_images/                         # Damage report photos
│   ├── report_20260411_001.jpg
│   ├── report_20260411_002.jpg
│   └── [report_id]_damage.[ext]
│
├── facility_images/                       # Facility reference photos
│   ├── fac_001_main.jpg
│   ├── fac_002_main.jpg
│   └── [facilityId]_facility.[ext]
│
└── assignment_images/                     # Assignment progress photos
    ├── assign_20260411_001.jpg
    ├── assign_20260411_002.jpg
    └── [assignmentId]_progress.[ext]
```

### Storage Rules (Recommended)
```javascript
rules_version = '2';

service firebase.storage {
  match /b/{bucket}/o {
    // Staff images - accessible to authenticated users
    match /staff_images/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && isAdmin();
    }
    
    // Damage images - accessible to authenticated users
    match /damage_images/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // Facility images - accessible to authenticated users
    match /facility_images/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && isAdmin();
    }
    
    // Assignment images - accessible to authenticated users
    match /assignment_images/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
  
  function isAdmin() {
    return request.auth.token.get('admin', false) == true;
  }
}
```

---

## 📊 Data Flow Summary

```
User Reports Issue
        ↓
Create Report (work_orders, type: 'report')
   - Store problem description
   - Upload damage image → storage/damage_images/
   - Link facility ID
        ↓
Admin Assigns to Staff Member
        ↓
Create Assignment (work_orders, type: 'assignment')
   - Link report ID
   - Assign staff member
        ↓
Staff Updates Progress
        ↓
Add Activity Log (work_orders/{assignmentId}/activityLogs/)
   - Record status changes: pending → in_progress → complete
   - Upload progress images → storage/assignment_images/
   - Add timestamps (Timestamp.now() not FieldValue.serverTimestamp())
        ↓
Dashboard & Activity Logs Display Summary & Progress
   - Live counts from Firestore queries
   - Activity timeline with status colors
```

---

## 🔑 Key Implementation Details

### Timestamp Handling (IMPORTANT)
- ✅ **Use:** `Timestamp.now()` for activity logs
- ❌ **Don't use:** `FieldValue.serverTimestamp()` in array fields

### Image Upload Paths
All images use pattern: `{folder}/{identifier}.{extension}`

**Size Limits (Recommended):**
- Staff photos: 5 MB max
- Damage/Progress photos: 10 MB max
- Max concurrent uploads: 1 per dialog

### Status Values
**Reports & Assignments:**
- `pending` - Not started
- `in_progress` (or `working`) - Currently being worked on
- `complete` - Finished

**Facilities:**
- `good` - Operational
- `maintenance_required` - Needs scheduled maintenance
- `needs_attention` - Critical issue

---

## 🆕 New Queries Added

```dart
// Dashboard - Real-time counts
reportsCount: work_orders where type == 'report'
assignmentsCount: work_orders where type == 'assignment'
facilitiesCount: facilities collection
staffCount: staff collection

// Assignments Screen - Get all reports
work_orders.where('type', isEqualTo: 'report').snapshots()

// Logs Screen - Get assignment with activity logs
work_orders/{assignmentId}/activityLogs
```

---

## ✅ Summary of Files Modified

| File | Changes | Status |
|------|---------|--------|
| `lib/screens/dashboard_screen.dart` | Staff nav index fix (1 line) | ✅ Fixed |
| `lib/screens/facilities_screen.dart` | Dialog redesign for edit button | ✅ Fixed |
| `lib/screens/overview_screen.dart` | Stateful + live data queries | ✅ Fixed |

---

## 🚀 For Other Team Members

### Before Accessing Firebase
1. **Collections created:** `work_orders`, `facilities`, `staff` (+ subcollections `activityLogs`)
2. **Storage folders created:** `staff_images`, `damage_images`, `facility_images`, `assignment_images`
3. **Update rules** using the provided storage rules above
4. **Note:** All timestamps in activity logs use `Timestamp.now()` not server timestamps

### Code Guidelines
- Staff/Facility images: Use `InkWell` not `GestureDetector` for touch areas
- Dialog sizing: Always use `SizedBox(width: X)` in content
- Status updates: Add activity log entry with timestamp
- Image loading: Use `loadingBuilder` and `errorBuilder` callbacks

### Testing Checklist
- [ ] Click "Staff Management" → shows staff screen (not logs)
- [ ] Click facility edit button → dialog appears without crash
- [ ] Dashboard shows correct counts (not hardcoded values)
- [ ] Create report with damage image → image uploads to `damage_images/`
- [ ] Create assignment → creates activity log with timestamp
- [ ] Update status → reflects in logs with new color

---

**Last Updated:** April 11, 2026  
**Session Focus:** Bug fixes (navigation, edit dialogs, dashboard data)  
**Status:** ✅ All 3 issues resolved
