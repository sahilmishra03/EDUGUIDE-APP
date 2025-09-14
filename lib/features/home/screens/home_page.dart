import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eduguide/features/professors/services/professor_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../professors/screens/professors_profile.dart';

// --- Constants (Synced with ProfessorDetailPage) ---
Color primaryBlue = Color(0xFF407BFF);
Color lightBackground = Color(0xFFF7F7FD);
Color cardBackground = Colors.white;
Color textSubtle = Color(0xFF6E6E73);
Color textBody = Color(0xFF1D1D1F);

class HomePage extends StatefulWidget {
  final Function(int) onNavigate;
  const HomePage({super.key, required this.onNavigate});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ProfessorsService _professorsService = ProfessorsService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackground,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        title: const Text(
          "EduGuide",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _professorsService.getProfessorsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong."));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No professors found."));
          }

          // --- Process and categorize the data ---
          final professors = snapshot.data!.docs;
          final Map<String, List<Map<String, dynamic>>>
          allCategorizedProfessors = {};

          for (var profDoc in professors) {
            final data = profDoc.data() as Map<String, dynamic>;
            data['id'] = profDoc.id; // Keep the document ID
            final specializations =
                data['specializations'] as List<dynamic>? ?? [];

            // MODIFICATION: Assign professor to their FIRST specialization only
            if (specializations.isNotEmpty) {
              final primaryCategory = specializations.first.toString();
              if (allCategorizedProfessors.containsKey(primaryCategory)) {
                allCategorizedProfessors[primaryCategory]!.add(data);
              } else {
                allCategorizedProfessors[primaryCategory] = [data];
              }
            }
          }

          // MODIFICATION: Limit to the top 5 categories by professor count
          var sortedCategories = allCategorizedProfessors.entries.toList()
            ..sort((a, b) => b.value.length.compareTo(a.value.length));

          final top5Categories = sortedCategories.take(5);
          final categorizedProfessors = {
            for (var e in top5Categories) e.key: e.value,
          };

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // --- Quick Actions Section ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _quickAction(
                      context,
                      icon: FontAwesomeIcons.graduationCap,
                      label: "Teachers",
                      onTap: () => widget.onNavigate(1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _quickAction(
                      context,
                      icon: FontAwesomeIcons.magnifyingGlass,
                      label: "Search",
                      onTap: () => widget.onNavigate(2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // --- Dynamically Generated Professor Sections ---
              ...categorizedProfessors.entries.map((entry) {
                final category = entry.key;
                final profList = entry.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle("Top Teachers in $category"),
                    ...profList.map((profData) {
                      return _teacherCard(context: context, data: profData);
                    }),
                    const SizedBox(height: 20),
                  ],
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _quickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: primaryBlue, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textBody,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8, left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textBody,
        ),
      ),
    );
  }

  Widget _teacherCard({
    required BuildContext context,
    required Map<String, dynamic> data,
  }) {
    final name = data['name'] ?? 'N/A';
    final specializations = (data['specializations'] as List<dynamic>? ?? [])
        .join(', ');
    final imageUrl = data['image'] as String?;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfessorDetailPage(data: data),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: primaryBlue.withOpacity(0.1),
              backgroundImage: (imageUrl != null && imageUrl.isNotEmpty)
                  ? NetworkImage(imageUrl)
                  : null,
              child: (imageUrl == null || imageUrl.isEmpty)
                  ? Icon(Icons.person, color: primaryBlue, size: 30)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: textBody,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    specializations,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textSubtle,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.grey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
