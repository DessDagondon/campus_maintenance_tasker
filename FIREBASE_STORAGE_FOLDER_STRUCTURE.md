# FIREBASE STORAGE FOLDER STRUCTURE
# Exact Image Folder Organization

## STORAGE FOLDER HIERARCHY

```
firebase-storage-root/
│
├── facility_images/
│   ├── Image_1712858400000.jpg
│   ├── Image_1712858450000.jpg
│   ├── Image_1712858500000.jpg
│   ├── Building_A_Main.jpg
│   └── ... (all facility photos)
│
├── damage_images/
│   ├── Image_1712858550000.jpg
│   ├── Image_1712858600000.jpg
│   ├── BrokenAC_Room101.jpg
│   └── ... (all damage/issue photos)
│
├── assignment_images/
│   ├── Image_1712858650000.jpg
│   ├── Image_1712858700000.jpg
│   ├── WorkInProgress_AC.jpg
│   └── ... (all assignment/work photos)
│
└── staff_profiles/
    ├── Image_1712858750000.jpg
    ├── Image_1712858800000.jpg
    ├── Mike_Johnson.jpg
    └── ... (all staff profile photos)
```

---

## HOW TO CREATE FOLDERS IN FIREBASE STORAGE

### Method 1: Via Firebase Console (Easiest)

1. Go to **Firebase Console** → **Storage**
2. Click the **Create folder** button
3. Name: `facility_images` → Create
4. Repeat for:
   - `damage_images`
   - `assignment_images`
   - `staff_profiles`

### Method 2: Via Uploading Files

1. Go to **Storage**
2. Click **Upload files**
3. Select an image
4. When prompted for path, type: `facility_images/Image_1234567.jpg`
5. Firebase creates the folder automatically
6. Repeat for other folders

---

## IMAGE FILE NAMING CONVENTION

When uploading images, they automatically get named:
```
Image_{timestamp}.jpg
```

Example:
- `Image_1712858400000.jpg` (automatically generated)
- `Image_1712858450000.jpg`

**You can rename them** in Firebase Console if you want more descriptive names:
- `facility_images/Building_A_Main.jpg`
- `damage_images/BrokenAC_Room101.jpg`
- `staff_profiles/Mike_Johnson.jpg`

---

## HOW IMAGES WORK IN THE APP

### When User Uploads Image:

1. **User clicks "Upload Image"** in Facilities/Reports/Assignments/Staff screen
2. **App shows picker dialog** with two options:
   - "Take Photo" (camera)
   - "Choose from Gallery"
3. **User selects/takes photo**
4. **App automatically**:
   - Uploads to Firebase Storage in the correct folder
   - Generates download URL
   - Saves URL to Firestore document

### Example Flow:

```
User clicks "Upload Facility Image"
    ↓
Dialog appears: "Take Photo" / "Choose from Gallery"
    ↓
User taps "Take Photo"
    ↓
Camera opens
    ↓
User takes photo
    ↓
App uploads to: facility_images/Image_1712858400000.jpg
    ↓
Firebase returns: https://firebasestorage.google.com/v0/b/...
    ↓
App saves URL to: facilities/{docId}/imageUrl
    ↓
Image appears in list immediately ✅
```

---

## FOLDER-TO-SCREEN MAPPING

| Folder | Used By Screen | Firestore Field |
|--------|----------------|-----------      |
| facility_images | Facilities Management | imageUrl |
| damage_images | Maintenance Reports | damageImageUrl |
| assignment_images | Work Assignments | imageUrl |
| staff_profiles | Staff Management | profileImageUrl |

---

## IMPORTANT NOTES

✅ **Folders are created automatically** when first image is uploaded to that path
✅ **No pre-upload needed** - users upload on-demand via app
✅ **Download URLs are auto-generated** by Firebase
✅ **File names have timestamps** to prevent overwrites
✅ **Same URL structure** — once saved to Firestore, image displays everywhere

❌ **Do NOT**:
- Manually create folders (Firebase does it)
- Try to delete folders (use console if needed)
- Upload images manually (app handles it)
- Use different folder names (use exact names above)

---

## TEST IMAGE SETUP (OPTIONAL)

If you want to pre-populate with test images:

1. Go to **Firebase Storage**
2. Manually upload a test image to each folder
3. Example test images:
   - facility_images: A photo of a building
   - damage_images: Photo of broken equipment
   - assignment_images: Photo of work in progress
   - staff_profiles: Staff headshots

Then when you click "Select Image" in the app, you'll see these test images!

---

## RETRIEVING IMAGE URLs

When Firebase Storage uploads an image, it auto-generates a download URL like:

```
https://firebasestorage.googleapis.com/v0/b/campusmaintenance-abc123.appspot.com/o/facility_images%2FImage_1712858400000.jpg?alt=media&token=xyz789
```

This URL is:
- ✅ Automatically saved to Firestore
- ✅ Accessible to all authenticated users
- ✅ Persists until you delete it
- ✅ Publicly readable (via Security Rules)

---

## SECURITY CONSIDERATIONS

With your current Storage rules:
- ✅ Authenticated users can READ all images
- ✅ Authenticated users can UPLOAD to any folder
- ✅ Authenticated users can DELETE their own uploads
- ✅ Logs are maintained by Firebase

If you want to restrict uploads:
- Admins only upload → Update Storage rules
- But for now, any logged-in user can upload ✅

---

## STORAGE QUOTA

Firebase Storage gives you:
- **5 GB free storage** per month
- Each image ~1-5 MB depending on quality
- Can store ~1000-5000 images free

If you exceed quota:
- Can increase in Firebase pricing
- Or implement image size limits in app

---

## TROUBLESHOOTING

### Problem: "Upload folder is empty" when clicking "Select Image"
**Solution**: 
- First time? That's normal!
- Click "Take Photo" or "Choose from Gallery" to upload first image
- Next time, you'll see images to select from

### Problem: Image doesn't appear after upload
**Solution**:
- Refresh the screen
- Check Firebase Storage console
- Verify file was uploaded to correct folder
- Check internet connection

### Problem: Wrong image showing for a facility
**Solution**:
- Edit the facility
- Click image area again
- Select the correct image
- Save

### Problem: Can't see Storage folders in console
**Solution**:
- Folders appear after first file upload
- Or create them manually with "Create folder" button
- Don't worry - app creates them automatically

