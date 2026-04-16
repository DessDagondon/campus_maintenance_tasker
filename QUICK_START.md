# 🚀 Quick Start Guide - Campus Maintenance Tasker Updates

## Immediate Next Steps (Do This First!)

### Step 1: Install Dependencies (5 minutes)
```bash
cd c:\2Flutter Projects\flutter activities\campus_maintenance_tasker
flutter pub get
```

**For iOS (if developing on Mac):**
```bash
cd ios
pod install
cd ..
```

### Step 2: Firebase Setup (10 minutes)

#### Enable Cloud Storage:
1. Open [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Go to **Storage** in left menu
4. Click **Get Started**
5. Accept default rules (we'll update them next)

#### Update Storage Security Rules:
1. In Firebase Console → Storage → **Rules** tab
2. Replace with this:
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
3. Click **Publish**

### Step 3: Create Staff Collection (5 minutes)

1. Firebase Console → **Firestore Database**
2. Click **Create Collection**
3. Name: `staff`
4. Click **Create**

### Step 4: Add Test Data (10 minutes)

**Add a test staff member:**

1. Go to Firestore → `staff` collection
2. Click **Add document**
3. Set Document ID: `test_staff_001`
4. Add these fields:
   - `name` (string): John Doe
   - `role` (string): Technician
   - `email` (string): john@campus.edu
   - `phone` (string): 555-1234
   - `specialization` (string): HVAC
   - `status` (string): active
   - `createdAt` (timestamp): Today's date

5. Click **Save**

**Add a test facility (if not already present):**

1. Go to Firestore → `facilities` collection (or create it)
2. Click **Add document**
3. Set Document ID: `facility_test_001`
4. Add these fields:
   - `name` (string): Test Building
   - `title` (string): Test Building
   - `numRooms` (number): 10
   - `equipment` (string): AC, Lights
   - `status` (string): good
   - `location` (string): Campus

5. Click **Save**

---

## 🧪 Testing the New Features

### Test 1: Create a Report with Facility Dropdown
1. Run the app: `flutter run`
2. Login as admin
3. Click **Reports** → **Report Issue**
4. ✅ Verify facility dropdown shows your test facility
5. Select the facility
6. Add problem description: "Test issue"
7. Click tap image area (optional)
8. Click **Submit**

### Test 2: Create an Assignment with Image
1. Click **Assignments** → **New Assignment**
2. Fill in:
   - Staff Name: John Doe
   - Task: Test assignment
   - Facility: Select from dropdown ✅
   - Priority: High
3. Tap image area to upload a photo
4. Click **Create**

### Test 3: View Staff Management (Admin only)
1. Click **Staff Management** (in sidebar)
2. ✅ See your test staff member
3. Click **Edit** to modify
4. Click camera to upload profile photo
5. Click **Update**

### Test 4: View Your Profile
1. Click **My Profile**
2. ✅ Should show staff information

---

## 🔍 Debugging Tips

### If image upload fails:
- Check Firebase Storage rules are published
- Verify device has camera/gallery permissions
- Check console for error messages

### If facility dropdown is empty:
- Ensure `facilities` collection exists in Firestore
- Add at least one facility document
- Refresh the page

### If staff doesn't appear:
- Ensure `staff` collection exists
- Check document has all required fields
- Verify Firestore rules allow reading

---

## 📱 Platform-Specific Setup

### Android
No additional setup needed with image_picker

### iOS
Need to add permissions in `ios/Runner/Info.plist`:
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs access to your photo library to upload images</string>
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to take photos</string>
```

### Web (if developing for web)
Image picker works but may need additional configuration. See [image_picker docs](https://pub.dev/packages/image_picker#web).

---

## 📊 What You Can Now Do

✅ **Staff Management**
- Create staff with profile photos
- Edit staff details
- View staff directory with photos

✅ **Better Reports**
- Select facilities from dropdown (no typing)
- Upload damage photos
- Link reports to specific facilities

✅ **Better Assignments**
- Select facilities from dropdown
- Upload work area photos
- Track which facility each assignment is for

✅ **Personal Profile**
- All staff/users see their profile
- Name, role, contact info
- Profile photo if uploaded

---

## 🎯 Sample Test Credentials

If you need to create test users:

**Admin Account:**
```
Email: admin@campusmaintenance.app
Password: firebaseadmin
```

**Staff Account:**
```
Email: staff@campus.edu
Password: 123456
```

---

## 📚 Full Documentation

For details beyond this quick start:

1. **FIREBASE_SCHEMA.md**
   - Complete data structures
   - All field definitions
   - Security rules
   - Storage organization

2. **IMPLEMENTATION_GUIDE.md**
   - Feature explanations
   - Usage instructions
   - Troubleshooting guide
   - Testing checklist

3. **CHANGES_SUMMARY.md**
   - Summary of what changed
   - Files modified
   - Dependencies added

---

## ✅ Completion Checklist

- [ ] Run `flutter pub get`
- [ ] Enable Firebase Storage
- [ ] Update Storage Security Rules
- [ ] Create `staff` collection in Firestore
- [ ] Add test staff member
- [ ] Add test facility
- [ ] Test facility dropdown in reports
- [ ] Test facility dropdown in assignments
- [ ] Test image upload
- [ ] View staff management screen
- [ ] View profile screen
- [ ] Review documentation files

---

## 🆘 Need Help?

### Common Issues:

**"Target of URI doesn't exist" errors**
→ Run `flutter pub get` to install missing packages

**Images won't upload**
→ Check Firebase Storage rules are published

**Facility dropdown empty**
→ Add documents to `facilities` collection

**Staff not showing**
→ Create `staff` collection and add documents

### Getting Support:
- Check console for error messages
- Review Firebase Console for storage issues
- See IMPLEMENTATION_GUIDE.md troubleshooting section

---

## 📞 File Locations (for Reference)

```
Project Root
├── lib/screens/
│   ├── staff_screen.dart              (NEW)
│   ├── staff_profile_screen.dart       (NEW)
│   ├── assignments_screen.dart        (UPDATED)
│   ├── reports_screen.dart            (UPDATED)
│   └── dashboard_screen.dart          (UPDATED)
├── FIREBASE_SCHEMA.md                 (NEW)
├── IMPLEMENTATION_GUIDE.md            (NEW)
├── CHANGES_SUMMARY.md                 (NEW)
└── pubspec.yaml                       (UPDATED)
```

---

## 🎉 You're All Set!

Everything is ready to go. Follow the steps above and you'll have:
- Staff management with photos
- Facility selection dropdowns
- Image upload for documentation
- Professional staff profiles

**Enjoy the enhanced Campus Maintenance Tasker!**

---

**Created**: April 11, 2026  
**Status**: Ready to Deploy  
**Version**: 1.1.0
