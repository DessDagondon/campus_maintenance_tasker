# How to Apply Security Rules to Firebase

## PART 1: FIRESTORE SECURITY RULES

### Step 1: Open Firebase Console
1. Go to https://console.firebase.google.com/
2. Select your project: **Campus Maintenance Tasker**

### Step 2: Navigate to Firestore Rules
1. From the left sidebar, click **Firestore Database**
2. Click on the **Rules** tab at the top

### Step 3: Replace the Rules
1. Delete ALL existing rules in the editor
2. Copy and paste the complete rules from `FIRESTORE_SECURITY_RULES.txt`
3. Click **Publish** button (top right)

### Step 4: Verify Rules
- You should see a green checkmark
- Rules are now LIVE on your database

---

## PART 2: STORAGE SECURITY RULES

### Step 1: Navigate to Storage Rules
1. From the left sidebar, click **Storage**
2. Click on the **Rules** tab at the top

### Step 2: Replace the Rules
1. Delete ALL existing rules in the editor
2. Copy and paste the complete rules from `STORAGE_SECURITY_RULES.txt`
3. Click **Publish** button

### Step 3: Verify Rules
- You should see a green checkmark
- Rules are now LIVE on your storage

---

## WHAT THESE RULES DO

### Firestore Rules Summary:
✅ **All authenticated users** can READ facilities, work_orders, staff
✅ **Only admins** can CREATE, UPDATE, DELETE facilities, work_orders, staff
✅ **Users** can READ/WRITE their own document
✅ **Admins** can READ all user documents
✅ **Only admins** can DELETE user documents

### Storage Rules Summary:
✅ **All authenticated users** can READ all images
✅ **All authenticated users** can UPLOAD images to any folder
✅ **All authenticated users** can DELETE their own images

---

## HOW TO MAKE SOMEONE AN ADMIN

### To grant admin privileges to a user:

1. **Option A: Via Firebase Console**
   - Go to **Authentication** tab
   - Find the user by email
   - Click on their user ID
   - In the **Custom claims** section, click **Edit**
   - Add: `{"role": "admin"}`
   - Click **Save**

2. **Option B: Via Firestore users collection**
   - Go to **Firestore Database**
   - Click **users** collection
   - Find/create document with user's UID as ID
   - Add field: `role: "admin"` (string type)
   - Save

### Example Admin User:
```
UID: xyz123abc...
Document: users/{uid}
Fields:
  - role: "admin" (string)
  - email: "admin@campusmaintenance.app" (string)
```

---

## TEST THE RULES

### Check if rules are working:

1. **Test as Regular User**
   - Log in with normal user account
   - Try to CREATE a facility → Should FAIL ❌
   - Try to READ facilities → Should SUCCEED ✅
   - Try to EDIT a facility → Should FAIL ❌

2. **Test as Admin**
   - Log in with admin account
   - Try to CREATE a facility → Should SUCCEED ✅
   - Try to READ facilities → Should SUCCEED ✅
   - Try to EDIT a facility → Should SUCCEED ✅
   - Try to DELETE a facility → Should SUCCEED ✅

3. **Test without Login**
   - Try to access anything → Should FAIL ❌

---

## IMPORTANT NOTES

⚠️ **Do NOT use the "Anyone" rules in production!**
- The old rules allowed everyone (even without authentication) to access data
- Our new rules require authentication first

✅ **These rules are production-ready**
- Secure by default
- Only authorized users can modify data
- Admin panel protected

⏰ **No expiration date**
- Unlike the old rules (expired May 2, 2026), these rules never expire
- Safe to publish and leave as-is

🔐 **Three-tier security**
- Authentication (must be logged in)
- Authorization (admin vs regular user)
- Document-level security (own documents)

---

## TROUBLESHOOTING

### Rule Issues?

**Problem**: "Permission denied" when trying to add/edit facilities
- **Solution**: Check if your user account is an admin. Add `role: "admin"` to their Firestore user document.

**Problem**: "Permission denied" when trying to upload images
- **Solution**: User must be authenticated first. Make sure they're logged in.

**Problem**: Can't see any data
- **Solution**: Verify rules are PUBLISHED (green checkmark). Try logging out and back in.

**Problem**: Rules show errors in the editor
- **Solution**: Make sure you copied the ENTIRE rules file and didn't delete any brackets `{}`.

---

## RULE STRUCTURE EXPLAINED

```
match /facilities/{facility} {
  allow read: if isUser();        // Anyone logged in can READ
  allow create, update: if isAdmin();  // Only admins can CREATE/UPDATE
  allow delete: if isAdmin();     // Only admins can DELETE
}
```

- `match`: Specifies which documents this applies to
- `allow`: What actions are allowed
- `if`: Under what conditions (must be logged in, must be admin, etc.)
- `isUser()`: Function that checks if authenticated
- `isAdmin()`: Function that checks if admin role set

---

## QUICK REFERENCE

| Action | Facilities | Work Orders | Staff | Users (Own) | Users (All) |
|--------|-----------|------------|-------|------------|------------|
| READ | ✅ Users | ✅ Users | ✅ Users | ✅ Owner | ✅ Admin |
| CREATE | ✅ Admin | ✅ Admin | ✅ Admin | ✅ Anyone | ✅ Admin |
| UPDATE | ✅ Admin | ✅ Admin | ✅ Admin | ✅ Owner | ✅ Admin |
| DELETE | ✅ Admin | ✅ Admin | ✅ Admin | ✅ Owner | ✅ Admin |

---

## FILES YOU NEED

1. **FIRESTORE_SECURITY_RULES.txt** - Copy to Firestore Rules tab
2. **STORAGE_SECURITY_RULES.txt** - Copy to Storage Rules tab

Both files are in your project folder.
