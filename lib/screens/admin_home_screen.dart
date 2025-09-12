import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/department.dart';
import '../services/firestore_service.dart';

class AdminHomeScreen extends StatefulWidget {
  final Department? selectedDepartment; 

  const AdminHomeScreen({super.key, this.selectedDepartment});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _currentTab = 0;
  final FirestoreService _firestoreService = FirestoreService();

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

  Widget _buildIssueCard(DocumentSnapshot doc) {
    final issueData = doc.data() as Map<String, dynamic>;
    final imageUrl = issueData['imageUrl'] as String?;
    final issueType = issueData['category'] as String? ?? 'Unknown';
    final description = issueData['description'] as String? ?? 'No description';
    final location = issueData['location'] as Map<String, dynamic>?;
    final createdAt = issueData['createdAt'] as Timestamp? ?? Timestamp.now();
    final department = _assignToDepartment(issueType);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: department.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${department.emoji} ${department.displayName}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: department.color,
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              issueType,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Feather.map_pin, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    location != null ? 'Lat: ${location['latitude']}, Lon: ${location['longitude']}' : 'Location not available',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Feather.clock, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  '${DateTime.now().difference(createdAt.toDate()).inMinutes} min ago',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.selectedDepartment != null
              ? '${widget.selectedDepartment!.emoji} ${widget.selectedDepartment!.displayName} Dashboard'
              : 'Admin Dashboard',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Feather.bell),
            onPressed: () {},
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.getAllIssues(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No issues found',
                style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey.shade600),
              ),
            );
          }

          final issues = snapshot.data!.docs;
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: issues.length,
            itemBuilder: (context, index) {
              return _buildIssueCard(issues[index]);
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        onTap: (index) => setState(() => _currentTab = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Feather.home),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Feather.alert_circle),
            label: 'Pending',
          ),
          BottomNavigationBarItem(
            icon: Icon(Feather.user_check),
            label: 'Assigned',
          ),
        ],
      ),
    );
  }
}