import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final _picker = ImagePicker();
  final _supabase = Supabase.instance.client;
  final _issueTypes = ['Pothole', 'Garbage', 'Streetlight', 'Other'];

  String? _selectedIssue;
  File? _image;
  bool _isSubmitting = false;
  LocationData? _locationData;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source, imageQuality: 70);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint('Image pick error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  Future<void> _getLocation() async {
    try {
      Location location = Location();

      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) return;
      }

      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) return;
      }

      _locationData = await location.getLocation();
    } catch (e) {
      debugPrint('Location error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get location: $e')),
      );
    }
  }

  Future<String?> _uploadImage(File image) async {
  try {
    final fileName = 'reports/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final bytes = await image.readAsBytes();

    final storageResponse = await _supabase.storage
        .from('civic-issue')
        .uploadBinary(fileName, bytes);

    // If no exception thrown, upload succeeded
    final publicUrl = _supabase.storage
        .from('civic-issue')
        .getPublicUrl(fileName);

    debugPrint('✅ Uploaded to: $publicUrl');
    return publicUrl;
  } on StorageException catch (e) {
    debugPrint('❌ Upload failed: ${e.message}');
    return null;
  } catch (e) {
    debugPrint('Upload error: $e');
    return null;
  }
}

Future<void> _submitReport() async {
  if (_selectedIssue == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select an issue type')),
    );
    return;
  }

  setState(() => _isSubmitting = true);

  await _getLocation();

  String? imageUrl;
  if (_image != null) {
    imageUrl = await _uploadImage(_image!);
    if (imageUrl == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image upload failed, please try again')),
      );
      setState(() => _isSubmitting = false);
      return;
    }
  }

  try {
    // Insert without expecting a PostgrestResponse
    final insertedRows = await _supabase.from('reports').insert({
      'issue_type': _selectedIssue,
      'image_url': imageUrl ?? '',
      'latitude': _locationData?.latitude,
      'longitude': _locationData?.longitude,
      'created_at': DateTime.now().toIso8601String(),
    });

    debugPrint('✅ Supabase insert success: $insertedRows');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report submitted successfully!')),
    );

    setState(() {
      _image = null;
      _selectedIssue = null;
    });
  } catch (e) {
    debugPrint('❌ Supabase insert exception: $e');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to submit report')),
    );
  } finally {
    setState(() => _isSubmitting = false);
  }
}


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Report an Issue')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Issue details', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Select Issue Type',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedIssue,
                      items: _issueTypes
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedIssue = val),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _issueTypes.map((type) {
                        final bool selected = _selectedIssue == type;
                        return ChoiceChip(
                          label: Text(type),
                          selected: selected,
                          onSelected: _isSubmitting
                              ? null
                              : (v) => setState(() => _selectedIssue = type),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Photo', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isSubmitting ? null : () => _pickImage(ImageSource.camera),
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Camera'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isSubmitting ? null : () => _pickImage(ImageSource.gallery),
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Gallery'),
                          ),
                        ),
                      ],
                    ),
                    if (_image != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_image!, height: 220, fit: BoxFit.cover),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: color.primaryContainer,
                  foregroundColor: color.onPrimaryContainer,
                  child: const Icon(Icons.location_on_outlined),
                ),
                title: const Text('Use current location'),
                subtitle: Text(
                  _locationData == null
                      ? 'We will capture your location on submit'
                      : 'Lat: ${_locationData!.latitude?.toStringAsFixed(5)}, Lng: ${_locationData!.longitude?.toStringAsFixed(5)}',
                ),
                trailing: TextButton(
                  onPressed: _isSubmitting ? null : _getLocation,
                  child: const Text('Refresh'),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReport,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                        ),
                      )
                    : const Text('Submit Report'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
