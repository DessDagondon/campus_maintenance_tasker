import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart'; // Required for kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Utility class for picking and managing images from Firebase Storage
class FirebaseImagePicker {
  /// Show dialog to select an image from Firebase Storage or upload a new one
  /// Returns the download URL of the selected/uploaded image
  static Future<String?> pickImageFromFirebase(
    BuildContext context, {
    required String folderPath,
    String title = 'Select Image',
  }) async {
    return showDialog<String?>(
      context: context,
      builder: (context) =>
          _FirebaseImagePickerDialog(folderPath: folderPath, title: title),
    );
  }

  /// Upload an image from device to Firebase Storage and return download URL
  /// Supports: JPG, PNG, GIF, WebP, and other image formats
  /// This version is cross-platform compatible (Web/Mobile)
  static Future<String?> uploadImageToFirebase(
    XFile imageFile, {
    required String folderPath,
  }) async {
    try {
      final fileName =
          'Image_${DateTime.now().millisecondsSinceEpoch}.${imageFile.name.split('.').last}';
      final ref = FirebaseStorage.instance.ref('$folderPath/$fileName');

      // Detect image type from file extension
      final extension = imageFile.name.split('.').last.toLowerCase();
      final contentType = _getContentType(extension);

      SettableMetadata metadata = SettableMetadata(contentType: contentType);

      if (kIsWeb) {
        // Web requires putData using bytes
        final bytes = await imageFile.readAsBytes();
        await ref.putData(bytes, metadata);
      } else {
        // Mobile can still use putData or bytes for consistency
        final bytes = await imageFile.readAsBytes();
        await ref.putData(bytes, metadata);
      }

      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading image to Firebase: $e');
      return null;
    }
  }

  /// Detect content type based on file extension
  static String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'bmp':
        return 'image/bmp';
      case 'svg':
        return 'image/svg+xml';
      case 'tiff':
      case 'tif':
        return 'image/tiff';
      case 'ico':
        return 'image/x-icon';
      default:
        return 'image/jpeg'; // Default fallback
    }
  }
}

class _FirebaseImagePickerDialog extends StatefulWidget {
  final String folderPath;
  final String title;

  const _FirebaseImagePickerDialog({
    required this.folderPath,
    required this.title,
  });

  @override
  State<_FirebaseImagePickerDialog> createState() =>
      _FirebaseImagePickerDialogState();
}

class _FirebaseImagePickerDialogState
    extends State<_FirebaseImagePickerDialog> {
  late Future<List<FirebaseImageItem>> _imagesFuture;
  bool _isUploading = false;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _imagesFuture = _loadImagesFromFirebase();
  }

  Future<void> _uploadImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: source);
      if (pickedFile == null) return;

      setState(() {
        _isUploading = true;
      });

      // Pass the XFile directly to the upload method
      final downloadUrl = await FirebaseImagePicker.uploadImageToFirebase(
        pickedFile,
        folderPath: widget.folderPath,
      );

      if (mounted && downloadUrl != null) {
        Navigator.pop(context, downloadUrl);
      }
    } catch (e) {
      debugPrint('Error uploading image: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error uploading image: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<List<FirebaseImageItem>> _loadImagesFromFirebase() async {
    try {
      final ref = FirebaseStorage.instance.ref(widget.folderPath);
      final result = await ref.listAll();

      final images = <FirebaseImageItem>[];
      for (final item in result.items) {
        try {
          final url = await item.getDownloadURL();
          images.add(
            FirebaseImageItem(name: item.name, path: item.fullPath, url: url),
          );
        } catch (e) {
          debugPrint('Error getting download URL for ${item.name}: $e');
        }
      }

      images.sort((a, b) => b.name.compareTo(a.name));
      return images;
    } catch (e) {
      debugPrint('Error loading images from Firebase: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: _isUploading
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Uploading image...'),
                ],
              ),
            )
          : SizedBox(
              width: 400,
              child: FutureBuilder<List<FirebaseImageItem>>(
                future: _imagesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error loading images: ${snapshot.error}'),
                    );
                  }

                  final images = snapshot.data ?? [];

                  if (images.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.image_not_supported,
                            size: 48,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          const Text('No images found in this folder'),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => _uploadImage(ImageSource.camera),
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Take Photo'),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () => _uploadImage(ImageSource.gallery),
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Choose from Gallery'),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                          itemCount: images.length,
                          itemBuilder: (context, index) {
                            final image = images[index];
                            return _ImageTile(
                              image: image,
                              onSelected: () {
                                Navigator.pop(context, image.url);
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _uploadImage(ImageSource.camera),
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Take Photo'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  _uploadImage(ImageSource.gallery),
                              icon: const Icon(Icons.photo_library),
                              label: const Text('Gallery'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

class FirebaseImageItem {
  final String name;
  final String path;
  final String url;

  FirebaseImageItem({
    required this.name,
    required this.path,
    required this.url,
  });
}

class _ImageTile extends StatelessWidget {
  final FirebaseImageItem image;
  final VoidCallback onSelected;

  const _ImageTile({required this.image, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              image.url,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                );
              },
            ),
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black54,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  image.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
