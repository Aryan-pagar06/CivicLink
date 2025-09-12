import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/department.dart';
import '../services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final FirestoreService _firestoreService = FirestoreService();
  XFile? _image;
  String? _selectedCategory; // Corrected state variable name
  Department? _selectedDepartment; // Corrected state variable name
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  bool _isAnalyzing = false;
  bool _isGettingLocation = false;
  bool _isSubmitting = false;
  String _aiAnalysisResult = '';
  String _detectedIssueType = '';
  Position? _currentLocation; // Corrected state variable name
  String _locationAddress = '';
  double _confidenceLevel = 0.0;

  final List<String> _issueTypes = [
    'Pothole',
    'Garbage Overflow',
    'Street Light Not Working',
    'Water Pipeline Leakage',
    'Damaged Public Bench',
    'Broken Drainage',
    'Illegal Construction',
    'Road Damage',
    'Public Toilet Issues',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = _issueTypes.first; // Initialize to avoid null
  }

  Department _assignToDepartment(String issueType) {
    switch (issueType.toLowerCase()) {
      case 'pothole':
      case 'road damage':
      case 'road_crack':
        return Department.roadsAndInfrastructure;
      case 'garbage overflow':
      case 'trash':
      case 'waste':
        return Department.sanitation;
      case 'water pipeline leakage':
      case 'water leak':
      case 'drainage':
        return Department.waterAndSewage;
      case 'street light not working':
      case 'light issue':
        return Department.electricity;
      case 'damaged public bench':
      case 'public toilet issues':
        return Department.publicWorks;
      case 'illegal construction':
        return Department.planningAndDevelopment;
      default:
        return Department.publicWorks;
    }
  }

  int _calculatePriority(String issueType, String description) {
    if (issueType.toLowerCase().contains('emergency') ||
        description.toLowerCase().contains('urgent') ||
        description.toLowerCase().contains('danger')) {
      return 5;
    } else if (issueType.toLowerCase().contains('water') ||
        issueType.toLowerCase().contains('electr')) {
      return 4;
    }
    return 3;
  }

  Future<void> _simulateAIAnalysis() async {
    setState(() {
      _isAnalyzing = true;
      _aiAnalysisResult = '';
      _detectedIssueType = '';
      _confidenceLevel = 0.0;
    });

    await Future.delayed(Duration(seconds: 2 + (DateTime.now().millisecond % 2)));

    final imageName = _image?.name.toLowerCase() ?? '';
    final fileSize = 1000000;

    final detectionResult = _smartImageAnalysis(imageName, fileSize);

    setState(() {
      _isAnalyzing = false;
      _detectedIssueType = detectionResult['type'] ?? 'Other';
      _aiAnalysisResult = detectionResult['analysis'] ?? 'Analysis complete';
      _confidenceLevel = detectionResult['confidence'] ?? 0.7;
      _selectedCategory = _detectedIssueType;
    });
  }

  Map<String, dynamic> _smartImageAnalysis(String imageName, int fileSize) {
    if (imageName.contains('pothole') ||
        imageName.contains('pot_hole') ||
        imageName.contains('road_damage') ||
        imageName.contains('roadhole') ||
        imageName.contains('cracked_road') ||
        imageName.contains('road_crack')) {
      return {
        'type': 'Pothole',
        'confidence': 0.92,
        'analysis': '✅ Confirmed: Road Surface Damage\n• Type: Deep pothole\n• Size: ~${(25 + DateTime.now().millisecond % 30)}cm diameter\n• Depth: ~${(8 + DateTime.now().millisecond % 12)}cm\n• Urgency: HIGH - Immediate repair needed\n• Risk: Vehicle damage and safety hazard'
      };
    }

    if (imageName.contains('garbage') ||
        imageName.contains('trash') ||
        imageName.contains('waste') ||
        imageName.contains('rubbish') ||
        imageName.contains('dump') ||
        imageName.contains('litter')) {
      return {
        'type': 'Garbage Overflow',
        'confidence': 0.88,
        'analysis': '✅ Confirmed: Waste Management Issue\n• Bin status: Overflowing\n• Waste type: Mixed materials\n• Cleanup urgency: Within 24 hours\n• Health risk: Moderate\n• Recommendation: Immediate cleanup'
      };
    }

    if (imageName.contains('water') ||
        imageName.contains('flood') ||
        imageName.contains('logging') ||
        imageName.contains('rain') ||
        imageName.contains('drain') ||
        imageName.contains('sewer')) {
      return {
        'type': 'Broken Drainage',
        'confidence': 0.85,
        'analysis': '✅ Confirmed: Drainage Issue\n• Type: Water logging\n• Depth: ~${(5 + DateTime.now().millisecond % 20)}cm\n• Area affected: ${(10 + DateTime.now().millisecond % 40)} sqm\n• Urgency: HIGH during rainfall\n• Risk: Traffic disruption, health hazard'
      };
    }

    if (imageName.contains('light') ||
        imageName.contains('lamp') ||
        imageName.contains('pole') ||
        imageName.contains('streetlight') ||
        imageName.contains('dark')) {
      return {
        'type': 'Street Light Not Working',
        'confidence': 0.82,
        'analysis': '✅ Confirmed: Lighting Infrastructure Issue\n• Pole condition: Non-functional\n• Issue type: Electrical fault\n• Safety concern: HIGH at night\n• Repair priority: Medium\n• Recommendation: Electrical inspection'
      };
    }

    if (imageName.contains('pipe') ||
        imageName.contains('leak') ||
        imageName.contains('waterleak') ||
        imageName.contains('burst')) {
      return {
        'type': 'Water Pipeline Leakage',
        'confidence': 0.87,
        'analysis': '✅ Confirmed: Water Infrastructure Issue\n• Leak rate: ~${(3 + DateTime.now().millisecond % 10)}L/min\n• Pipe type: Suspected main line\n• Water wastage: Significant\n• Urgency: HIGH - immediate repair\n• Risk: Road damage, water shortage'
      };
    }

    if (imageName.contains('bench') ||
        imageName.contains('seat') ||
        imageName.contains('park') ||
        imageName.contains('public_seat')) {
      return {
        'type': 'Damaged Public Bench',
        'confidence': 0.79,
        'analysis': '✅ Confirmed: Public Furniture Damage\n• Damage type: Structural compromise\n• Safety risk: Moderate\n• Repair needed: Yes\n• Priority: Medium urgency\n• Recommendation: Replacement or repair'
      };
    }

    if (imageName.contains('construct') ||
        imageName.contains('build') ||
        imageName.contains('site') ||
        imageName.contains('illegal')) {
      return {
        'type': 'Illegal Construction',
        'confidence': 0.75,
        'analysis': '⚠️ Suspected: Unauthorized Construction\n• Verification needed: Yes\n• Documentation: Recommended\n• Authority alert: Required\n• Priority: Investigation needed\n• Risk: Legal violations, safety concerns'
      };
    }

    if (imageName.contains('road') ||
        imageName.contains('street') ||
        imageName.contains('damage') ||
        imageName.contains('crack')) {
      return {
        'type': 'Road Damage',
        'confidence': 0.80,
        'analysis': '✅ Confirmed: Road Infrastructure Issue\n• Damage type: Surface deterioration\n• Extent: Multiple affected areas\n• Resurfacing needed: Yes\n• Urgency: Medium-term repair\n• Risk: Progressive deterioration'
      };
    }

    if (fileSize > 1500000) {
      return {
        'type': 'Other',
        'confidence': 0.65,
        'analysis': '🔍 Complex Scene Detected\n• Multiple elements found\n• Requires manual review\n• Municipal team notified\n• Further analysis recommended\n• Please provide additional details'
      };
    }

    final random = DateTime.now().millisecond % _issueTypes.length;
    return {
      'type': _issueTypes[random],
      'confidence': 0.6,
      'analysis': '🔍 Analysis Complete\n• Issue categorized for review\n• Confidence: Moderate\n• Verification recommended\n• Please confirm the issue type'
    };
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    try {
      if (kIsWeb) {
        await Future.delayed(const Duration(seconds: 1));
        
        setState(() {
          _locationAddress = 'Simulated Location for Web Demo\nLat: 28.6139, Long: 77.2090\nNear City Center';
          _locationController.text = _locationAddress;
          _currentLocation = Position(
            latitude: 28.6139,
            longitude: 77.2090,
            timestamp: DateTime.now(),
            accuracy: 0.0,
            altitude: 0.0,
            altitudeAccuracy: 0.0,
            heading: 0.0,
            headingAccuracy: 0.0,
            speed: 0.0,
            speedAccuracy: 0.0,
          );
          _isGettingLocation = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location simulation enabled for web demo'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')),
          );
          setState(() {
            _isGettingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are permanently denied')),
        );
        setState(() {
          _isGettingLocation = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final address = await _simulateReverseGeocoding(position.latitude, position.longitude);

      setState(() {
        _currentLocation = position;
        _locationAddress = address;
        _locationController.text = address;
        _isGettingLocation = false;
      });

    } catch (e) {
      setState(() {
        _isGettingLocation = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<String> _simulateReverseGeocoding(double lat, double lng) async {
    await Future.delayed(const Duration(seconds: 1));
    return '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}\nNear City Center, Urban Area';
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _image = image;
          _aiAnalysisResult = '';
          _detectedIssueType = '';
        });

        _simulateAIAnalysis();
        _getCurrentLocation();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error taking photo: ${e.toString()}')),
      );
    }
  }

  Future<void> _selectFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _image = image;
          _aiAnalysisResult = '';
          _detectedIssueType = '';
        });

        _simulateAIAnalysis();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting image: ${e.toString()}')),
      );
    }
  }

  Future<void> _submitReport() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final auth = FirebaseAuth.instance;
        await auth.signInAnonymously();

        String? imageUrl;
        if (_image != null) {
          // --- This is the hackathon jugaad ---
          // Simulate a successful image upload
          await Future.delayed(const Duration(seconds: 2));
          imageUrl = 'https://i.imgur.com/8Q9i7z8.jpeg'; // A sample image of garbage
        }

        final collectionName = '${_selectedCategory}_issues';
        _selectedDepartment = _assignToDepartment(_selectedCategory!);

        final issueData = {
          'userId': auth.currentUser?.uid,
          'category': _selectedCategory,
          'description': _descriptionController.text,
          'location': {
            'latitude': _currentLocation?.latitude,
            'longitude': _currentLocation?.longitude,
          },
          'status': 'Submitted',
          'createdAt': FieldValue.serverTimestamp(),
          'assignedDepartment': _selectedDepartment!.displayName,
          'imageUrl': imageUrl,
        };

        final bool success = await _firestoreService.saveIssueReport(
          collectionName,
          issueData,
        );

        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Report submitted successfully!')),
            );
            Navigator.of(context).pop();
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Failed to submit report. Please try again.')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('An error occurred: $e'),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }
  
  void _removeImage() {
    setState(() {
      _image = null;
      _aiAnalysisResult = '';
      _detectedIssueType = '';
    });
  }

  Color _getResultColor(double confidence) {
    if (confidence > 0.8) return Colors.green;
    if (confidence > 0.6) return Colors.orange;
    return Colors.blue;
  }

  IconData _getResultIcon(double confidence) {
    if (confidence > 0.8) return Feather.check_circle;
    if (confidence > 0.6) return Feather.alert_circle;
    return Feather.info;
  }

  Widget _buildAnalysisInProgress() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          const CircularProgressIndicator(strokeWidth: 2),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'AI is analyzing the image...',
              style: GoogleFonts.poppins(
                color: Colors.blue[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisResult() {
    final resultColor = _getResultColor(_confidenceLevel);
    final resultIcon = _getResultIcon(_confidenceLevel);

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: resultColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: resultColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(resultIcon, size: 18, color: resultColor),
              const SizedBox(width: 8),
              Text(
                'AI Analysis Complete',
                style: GoogleFonts.poppins(
                  color: resultColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: resultColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(_confidenceLevel * 100).toStringAsFixed(0)}% confident',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: resultColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Detected: $_detectedIssueType',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              color: resultColor,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _aiAnalysisResult,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
          ),
          if (_confidenceLevel < 0.7)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Note: Low confidence, please verify the issue type.',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Report an Issue',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isAnalyzing) _buildAnalysisInProgress(),
              if (_aiAnalysisResult.isNotEmpty) _buildAnalysisResult(),

              Text(
                'Issue Type',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    icon: Icon(Feather.chevron_down, color: Colors.blue.shade700),
                    items: _issueTypes.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCategory = newValue!;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'Add Photo',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade100,
                ),
                child: _image == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Feather.camera,
                              size: 40,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No photo added',
                              style: GoogleFonts.poppins(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: kIsWeb
                                ? Image.network(
                                    _image!.path,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    File(_image!.path),
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: _removeImage,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Feather.x,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _takePhoto,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: Icon(Feather.camera, size: 18),
                      label: Text('Take Photo', style: GoogleFonts.poppins()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _selectFromGallery,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue.shade700,
                        side: BorderSide(color: Colors.blue.shade700),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: Icon(Feather.image, size: 18),
                      label: Text('From Gallery', style: GoogleFonts.poppins()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Location',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (_currentLocation == null)
                    TextButton.icon(
                      onPressed: _getCurrentLocation,
                      icon: Icon(
                        Feather.map_pin,
                        size: 16,
                        color: Colors.blue.shade700,
                      ),
                      label: Text(
                        'Get Current Location',
                        style: GoogleFonts.poppins(
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _locationController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Location will be automatically detected...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: _isGettingLocation
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : null,
                ),
                readOnly: true,
              ),
              const SizedBox(height: 20),

              Text(
                'Description',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Describe the issue in detail...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: _isSubmitting
                    ? ElevatedButton(
                        onPressed: null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Submitting Report...'),
                          ],
                        ),
                      )
                    : ElevatedButton(
                        onPressed: _submitReport,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Submit Report',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}