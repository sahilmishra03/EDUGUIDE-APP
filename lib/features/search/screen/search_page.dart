import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eduguide/features/professors/screens/professors_profile.dart'; // Make sure this import is correct
import 'package:eduguide/features/professors/services/professor_service.dart'; // Make sure this import is correct
import 'package:flutter/material.dart';

// --- Constants (Copied for consistency, consider moving to a shared file) ---
const Color primaryBlue = Color(0xFF407BFF);
const Color lightBackground = Color(0xFFF7F7FD);
const Color cardBackground = Colors.white;
const Color textSubtle = Color(0xFF6E6E73);
const Color textBody = Color(0xFF1D1D1F);

class SearchPage extends StatefulWidget {
  final ProfessorsService professorsService;

  const SearchPage({required this.professorsService, super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // State variables for search and filtering
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedSpecialization;

  // Lists to hold professor data
  List<DocumentSnapshot> _allProfessors = [];
  List<DocumentSnapshot> _filteredProfessors = [];

  // Set to hold unique specializations for the dropdown filter
  final Set<String> _specializations = {'All'}; // Start with 'All'

  @override
  void initState() {
    super.initState();
    // Listen to changes in the search bar text
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
        _applyFilters();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Applies search and filter logic to the list of professors
  void _applyFilters() {
    List<DocumentSnapshot> tempList = List.from(_allProfessors);

    // 1. Apply search query
    if (_searchQuery.isNotEmpty) {
      tempList = tempList.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final name = (data['name'] as String? ?? '').toLowerCase();
        return name.contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // 2. Apply specialization filter
    if (_selectedSpecialization != null && _selectedSpecialization != 'All') {
      tempList = tempList.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final specializations =
            (data['specializations'] as List<dynamic>? ?? []);
        return specializations.contains(_selectedSpecialization);
      }).toList();
    }

    setState(() {
      _filteredProfessors = tempList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackground,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 1,
        centerTitle: true,
        automaticallyImplyLeading: false, // Hides the back button
        title: const Text(
          'Find a Professor',
          style: TextStyle(
            color: lightBackground,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search and Filter UI
          _buildControls(),

          // Professor List
          Expanded(
            child: FutureBuilder<QuerySnapshot>(
              // Fetch the data once
              future: widget.professorsService.getProfessorsStream().first,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: primaryBlue),
                  );
                }
                if (snapshot.hasError) {
                  return const Center(child: Text("Failed to load data."));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No professors available."));
                }

                // If this is the first time loading data, populate our lists
                if (_allProfessors.isEmpty) {
                  _allProfessors = snapshot.data!.docs;
                  _filteredProfessors = List.from(_allProfessors);

                  // Extract unique specializations for the filter dropdown
                  for (var doc in _allProfessors) {
                    final data = doc.data() as Map<String, dynamic>;
                    final specs =
                        (data['specializations'] as List<dynamic>? ?? []);
                    for (var spec in specs) {
                      _specializations.add(spec.toString());
                    }
                  }
                }

                if (_filteredProfessors.isEmpty) {
                  return const Center(
                    child: Text(
                      "No professors match your criteria.",
                      style: TextStyle(color: textSubtle, fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: _filteredProfessors.length,
                  itemBuilder: (context, idx) {
                    final doc = _filteredProfessors[idx];
                    final data = doc.data() as Map<String, dynamic>;
                    data['id'] = doc.id; // Pass the document ID
                    return _buildProfessorCard(context, data);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the search bar and filter dropdown
  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: cardBackground,
      child: Row(
        children: [
          // Search Bar
          Expanded(
            flex: 3, // Give search bar more space
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name...',
                prefixIcon: Icon(Icons.search, color: textSubtle),
                filled: true,
                fillColor: lightBackground,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Filter Dropdown
          Expanded(
            flex: 2, // Give dropdown flexible space
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: lightBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                // Clean way to remove the underline
                child: DropdownButton<String>(
                  value: _selectedSpecialization ?? 'All',
                  isExpanded:
                      true, // FIX: Allows the dropdown to expand and prevents overflow
                  icon: Icon(Icons.filter_list_rounded, color: primaryBlue),
                  items: _specializations.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        overflow: TextOverflow
                            .ellipsis, // FIX: Prevents long text from overflowing the menu
                        style: TextStyle(color: textBody),
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedSpecialization = newValue;
                      _applyFilters();
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a styled card for a single professor. (No changes needed here)
  Widget _buildProfessorCard(BuildContext context, Map<String, dynamic> data) {
    final name = data['name'] ?? 'N/A';
    final specializations = (data['specializations'] as List<dynamic>? ?? [])
        .join(', ');
    final imageUrl = data['image'] as String?;

    return GestureDetector(
      onTap: () {
        // Ensure ProfessorDetailPage is imported correctly
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProfessorDetailPage(data: data)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13), // ~5% opacity
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: primaryBlue.withAlpha(26), // 10% opacity
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
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: textBody,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (specializations.isNotEmpty)
                    Text(
                      specializations,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: textSubtle,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
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
