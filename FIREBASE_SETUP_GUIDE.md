# Firebase Setup Guide for Campus Maintenance Tasker

## 1. FIRESTORE COLLECTION STRUCTURE

### Collection: `facilities`
```
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
  "imageUrl": "https://firebase-storage-url...",
  "createdAt": Timestamp
}
```

### Collection: `work_orders` (for Reports & Assignments)

**Report Documents:**
```
{
  "docId": "report_001",
  "type": "report",
  "problem": "Broken AC",
  "facilityId": "facility_001",
  "status": "pending",
  "description": "AC in classroom 101 not working",
  "damageImageUrl": "https://firebase-storage-url...",
  "createdAt": Timestamp,
  "updatedAt": Timestamp
}
```

**Assignment Documents:**
```
{
  "docId": "assign_001",
  "type": "assignment",
  "task": "Fix AC in Room 101",
  "description": "Replace compressor unit",
  "staff": "Mike Johnson",
  "assignedTo": "Mike Johnson",
  "facilityId": "facility_001",
  "zone": "Building A",
  "location": "Room 101",
  "priority": "High",
  "status": "in_progress",
  "imageUrl": "https://firebase-storage-url...",
  "createdAt": Timestamp,
  "updatedAt": Timestamp
}
```

### Collection: `staff`
```
{
  "docId": "staff_001",
  "name": "Mike Johnson",
  "role": "Technician",
  "email": "mike.johnson@campus.edu",
  "phone": "555-0101",
  "specialization": "HVAC",
  "status": "active",
  "profileImageUrl": "https://firebase-storage-url...",
  "createdAt": Timestamp
}
```

---

## 2. FIREBASE STORAGE STRUCTURE

Create these folders in Firebase Storage:

```
/facility_images/
  ├── Image_1712858400000.jpg
  ├── Image_1712858450000.jpg
  └── ...

/damage_images/
  ├── Image_1712858500000.jpg
  └── ...

/assignment_images/
  ├── Image_1712858550000.jpg
  └── ...

/staff_profiles/
  ├── Image_1712858600000.jpg
  └── ...
```

---

## 3. HOW TO UPLOAD IMAGES TO FIREBASE STORAGE

### Option A: Using Firebase Console (Manual)
1. Go to **Firebase Console** → Your Project
2. Click **Storage** tab
3. Click **Create folders** → Create these folders:
   - `facility_images`
   - `damage_images`
   - `assignment_images`
   - `staff_profiles`
4. Click on each folder and click **Upload files**
5. Select your images from your computer
6. Firebase will generate download URLs automatically

### Option B: During App Usage (Automatic)
When you click "Upload Image" or "Take Photo" in the app:
1. The app uses your device camera or gallery
2. Image is automatically uploaded to Firebase Storage
3. Download URL is saved to Firestore document
4. Image displays immediately in the app

---

## 4. FIREBASE SECURITY RULES

Add these rules to **Firestore** (Rules tab):

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow authenticated users to read all collections
    match /{document=**} {
      allow read: if request.auth != null;
    }
    
    // Facilities: Only admins can create/update/delete
    match /facilities/{facility} {
      allow create, update, delete: if request.auth != null && request.auth.token.admin == true;
    }
    
    // Work Orders (Reports & Assignments)
    match /work_orders/{order} {
      allow create, update, delete: if request.auth != null && request.auth.token.admin == true;
    }
    
    // Staff
    match /staff/{staff} {
      allow create, update, delete: if request.auth != null && request.auth.token.admin == true;
    }
  }
}
```

Add these rules to **Firebase Storage** (Rules tab):

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Allow authenticated users to read images
    match /{allPaths=**} {
      allow read: if request.auth != null;
    }
    
    // Allow authenticated users to upload to their respective folders
    match /{folder}/{allPaths=**} {
      allow write: if request.auth != null;
    }
  }
}
```

---

## 5. FIREBASE AUTHENTICATION SETUP

1. Go to **Firebase Console** → **Authentication**
2. Click **Email/Password** and enable it
3. Test users are created when they sign up in the app
4. To make someone an admin:
   - Go to **Firestore** → Create collection `users`
   - Create document with user's UID
   - Add field: `role: "admin"` (or `role: "user"`)

---

## 6. REMOVING UNWANTED DATA

To remove random/test posts from staff collection:

1. Go to **Firebase Console**
2. Click **Firestore Database**
3. Click **staff** collection
4. Select the documents you want to delete
5. Click **Delete** button
6. OR use the code below in your app (one-time)

**Code to clean staff collection (run once, then remove):**
```dart
Future<void> cleanStaffCollection() async {
  final staffDocs = await FirebaseFirestore.instance.collection('staff').get();
  for (final doc in staffDocs.docs) {
    // Keep only documents with required fields
    final data = doc.data();
    if (data['name'] == null || data['email'] == null) {
      await doc.reference.delete();
    }
  }
}
```

---

## 7. STEP-BY-STEP SETUP INSTRUCTIONS

### Step 1: Create Firestore Collections
1. Firebase Console → Firestore Database
2. Create collection `facilities`
3. Create collection `work_orders`
4. Create collection `staff`
5. Create collection `users` (for admin/user roles)

### Step 2: Create Storage Folders
1. Firebase Console → Storage
2. Click "Upload folder" or create folders:
   - facility_images
   - damage_images
   - assignment_images
   - staff_profiles

### Step 3: Upload Test Images (Optional)
1. Pick some facility/staff photos
2. Upload to each folder in Storage
3. These will appear when you click "Add Image" in the app

### Step 4: Set Security Rules
1. Copy rules from Section 4 above
2. Paste into Firestore Rules tab → Publish
3. Paste into Storage Rules tab → Publish

### Step 5: Test Everything
1. Run the app
2. Create a facility - should work
3. Click "Upload Image" - should show folders in Firebase Storage
4. Take a photo - should upload automatically
5. Create a staff member
6. Create a report/assignment

---

## 8. IMPORTANT NOTES

✅ **Images Auto-Upload**: When you click "Take Photo" or "Choose from Gallery" in the app, the image automatically uploads to Firebase Storage and the URL saves to Firestore.

✅ **No Pre-Upload Needed**: You don't need to pre-upload images. The app handles it.

❌ **Images Must Exist for Selection**: When clicking "Select Image", you need at least ONE image already in that Firebase Storage folder. Then you can see it and choose it, OR take a new photo.

⚠️ **First Time Setup**: 
- First time using "Select Image"? It might be empty. Just click "Take Photo" or "Choose from Gallery" to upload one.
- After that, you'll see all uploaded images when you click "Select Image".

