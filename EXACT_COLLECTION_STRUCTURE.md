# EXACT FIRESTORE COLLECTION STRUCTURE
# DO NOT CHANGE - USE THIS EXACT STRUCTURE

## 1. USERS COLLECTION
Path: `/users`

Document ID: `{user_uid}` (Firebase UID)
Fields:
```
{
  "email": "admin@campusmaintenance.app" (string)
  "role": "admin" (string) - values: "admin" or "user"
  "name": "Admin Name" (string)
  "createdAt": Timestamp
}
```

Example:
```
users/
├── abc123xyz789... (user UID)
│   ├── email: "admin@campusmaintenance.app"
│   ├── role: "admin"
│   ├── name: "Campus Admin"
│   └── createdAt: 2026-04-11
├── def456uvw012... (another user UID)
│   ├── email: "staff@campusmaintenance.app"
│   ├── role: "user"
│   ├── name: "John Technician"
│   └── createdAt: 2026-04-11
```

---

## 2. FACILITIES COLLECTION
Path: `/facilities`

Document ID: Any (auto-generated OR custom like "facility_001")
Fields:
```
{
  "name": "Building A - North Wing" (string) ⭐ REQUIRED
  "title": "Building A - North Wing" (string)
  "equipment": "AC, Lights, Projectors" (string)
  "description": "AC, Lights, Projectors, Doors" (string)
  "status": "good" (string) - values: "good", "maintenance_required", "needs_attention"
  "location": "Campus Center" (string)
  "capacity": "150 students" (string)
  "imageUrl": "https://firebasestorage.googleapis.com/..." (string)
  "createdAt": Timestamp
  "updatedAt": Timestamp
}
```

Example Collection Structure:
```
facilities/
├── auto_id_abc123 (or facility_001)
│   ├── name: "Building A - North Wing"
│   ├── equipment: "AC, Lights, Projectors"
│   ├── status: "good"
│   ├── imageUrl: "https://..."
│   ├── createdAt: Timestamp
│   └── updatedAt: Timestamp
├── auto_id_def456 (or facility_002)
│   ├── name: "Building B - South Wing"
│   ├── equipment: "Heating, Windows, Doors"
│   ├── status: "maintenance_required"
│   └── ...
```

---

## 3. WORK_ORDERS COLLECTION
Path: `/work_orders`

This collection contains BOTH Reports AND Assignments.
The `type` field determines which one it is.

### REPORT DOCUMENT
Document ID: Any (auto-generated)
Fields:
```
{
  "type": "report" (string) ⭐ MUST BE "report"
  "problem": "Broken AC" (string) ⭐ REQUIRED
  "issue": "AC not working" (string)
  "description": "AC in classroom 101 not working" (string)
  "facilityId": "facility_001" (string) ⭐ REQUIRED - link to facilities collection
  "status": "pending" (string) - values: "pending", "in_progress", "completed"
  "damageImageUrl": "https://firebasestorage.googleapis.com/..." (string)
  "room": "101" (string)
  "location": "Building A" (string)
  "createdAt": Timestamp
  "updatedAt": Timestamp
}
```

### ASSIGNMENT DOCUMENT
Document ID: Any (auto-generated)
Fields:
```
{
  "type": "assignment" (string) ⭐ MUST BE "assignment"
  "task": "Fix AC in Room 101" (string) ⭐ REQUIRED
  "description": "Replace compressor unit" (string)
  "problem": "AC not working" (string)
  "staff": "Mike Johnson" (string) ⭐ REQUIRED
  "assignedTo": "Mike Johnson" (string)
  "facilityId": "facility_001" (string) ⭐ REQUIRED - link to facilities collection
  "zone": "Building A" (string)
  "location": "Room 101" (string)
  "priority": "High" (string) - values: "Low", "Medium", "High"
  "status": "assigned" (string) - values: "assigned", "in_progress", "completed"
  "imageUrl": "https://firebasestorage.googleapis.com/..." (string)
  "createdAt": Timestamp
  "updatedAt": Timestamp
}
```

Example Collection Structure:
```
work_orders/
├── auto_id_report_001
│   ├── type: "report"
│   ├── problem: "Broken AC"
│   ├── facilityId: "facility_001"
│   ├── status: "pending"
│   ├── damageImageUrl: "https://..."
│   ├── createdAt: Timestamp
│   └── updatedAt: Timestamp
├── auto_id_assign_001
│   ├── type: "assignment"
│   ├── task: "Fix AC in Room 101"
│   ├── staff: "Mike Johnson"
│   ├── facilityId: "facility_001"
│   ├── priority: "High"
│   ├── status: "assigned"
│   ├── imageUrl: "https://..."
│   ├── createdAt: Timestamp
│   └── updatedAt: Timestamp
```

---

## 4. STAFF COLLECTION
Path: `/staff`

Document ID: Any (auto-generated OR custom like "staff_001")
Fields:
```
{
  "name": "Mike Johnson" (string) ⭐ REQUIRED
  "role": "Technician" (string) ⭐ REQUIRED
  "email": "mike.johnson@campus.edu" (string) ⭐ REQUIRED
  "phone": "555-0101" (string)
  "specialization": "HVAC" (string)
  "status": "active" (string) - values: "active", "inactive"
  "profileImageUrl": "https://firebasestorage.googleapis.com/..." (string)
  "createdAt": Timestamp
  "updatedAt": Timestamp
}
```

Example Collection Structure:
```
staff/
├── auto_id_staff_001 (or staff_001)
│   ├── name: "Mike Johnson"
│   ├── role: "Technician"
│   ├── email: "mike.johnson@campus.edu"
│   ├── phone: "555-0101"
│   ├── specialization: "HVAC"
│   ├── status: "active"
│   ├── profileImageUrl: "https://..."
│   ├── createdAt: Timestamp
│   └── updatedAt: Timestamp
├── auto_id_staff_002 (or staff_002)
│   ├── name: "Sarah Lee"
│   ├── role: "Electrician"
│   └── ...
```

---

## IMPORTANT RULES

✅ **facilityId**: MUST match a document ID in the `facilities` collection
✅ **Staff name fields**: Use exact same names (`staff` and `assignedTo` can be the same)
✅ **Status values**: Use exact lowercase values
✅ **Image URLs**: Must be Firebase Storage URLs (auto-generated by app)
✅ **Timestamps**: Use Firestore FieldValue.serverTimestamp()

❌ **DO NOT use**:
- Multiple spelling variations (use consistent field names)
- Random/test documents (use real data only)
- Missing required fields

---

## HOW TO SET UP IN FIREBASE CONSOLE

### Step 1: Create Collections
1. Go to Firestore Database
2. Click "Create collection"
3. Name: `users`
4. Add at least one test document
5. Repeat for: `facilities`, `work_orders`, `staff`

### Step 2: Add Sample Data
- Go to each collection
- Click "Add document"
- Use the exact field names and structure above
- Copy the field names EXACTLY (case-sensitive)

### Step 3: Link Collections
- When creating a report/assignment, the `facilityId` MUST match a real documents ID in `facilities`
- When creating an assignment, the `staff` name MUST be a real person from `staff` collection

---

## REFERENCE TABLE

| Collection | Doc ID | Required Fields | Image Field |
|-----------|--------|-----------------|-------------|
| users | User UID | email, role | - |
| facilities | Auto/Custom | name, status | imageUrl |
| work_orders (report) | Auto | type, problem, facilityId | damageImageUrl |
| work_orders (assignment) | Auto | type, task, staff, facilityId | imageUrl |
| staff | Auto/Custom | name, role, email | profileImageUrl |

