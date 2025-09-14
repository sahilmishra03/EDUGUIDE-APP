import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// --- Constants ---
const Color primaryBlue = Color(0xFF407BFF);
const Color vibrantPurple = Color(0xFF8A6FF7);
const Color lightBackground = Color(0xFFF7F7FD);
const Color cardBackground = Colors.white;
const Color iconGray = Color(0xFF8A8A8E);
const Color textSubtle = Color(0xFF6E6E73);
const Color textBody = Color(0xFF1D1D1F);

class ProfessorDetailPage extends StatefulWidget {
  final Map<String, dynamic> data;

  const ProfessorDetailPage({required this.data, super.key});

  @override
  State<ProfessorDetailPage> createState() => _ProfessorDetailPageState();
}

class _ProfessorDetailPageState extends State<ProfessorDetailPage> {
  int selectedDay = 0;

  static const List<String> weekDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
  ];

  /// Launches the given URL. Shows a snackbar on failure.
  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $urlString';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Could not open the link.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Safely access availability data
    final availabilityMap =
        widget.data['availability'] as Map<String, dynamic>? ?? {};
    final availableDays = weekDays
        .where((day) => availabilityMap.containsKey(day))
        .toList();

    // Ensure selectedDay is within bounds
    if (selectedDay >= availableDays.length && availableDays.isNotEmpty) {
      selectedDay = 0;
    }

    final selectedDayKey = availableDays.isNotEmpty
        ? availableDays[selectedDay]
        : '';
    final selectedDayValue = selectedDayKey.isNotEmpty
        ? availabilityMap[selectedDayKey]
        : 'Not Available';

    return Scaffold(
      backgroundColor: lightBackground,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: lightBackground),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.data['name'] ?? 'Professor Name',
          style: TextStyle(
            color: lightBackground,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 24),

          // --- Qualifications ---
          _buildInfoCard(
            title: "Qualifications",
            icon: Icons.school_rounded,
            children: (widget.data['qualifications'] as List<dynamic>? ?? [])
                .map((q) => _buildListItem(q.toString()))
                .toList(),
          ),

          // --- Research Areas ---
          _buildInfoCard(
            title: "Research Areas",
            icon: Icons.science_rounded,
            children: (widget.data['research'] as List<dynamic>? ?? [])
                .map((area) => _buildListItem(area.toString()))
                .toList(),
          ),

          // --- Research Papers ---
          _buildInfoCard(
            title: "Research Papers",
            icon: Icons.article_rounded,
            children: (widget.data['research_papers'] as List<dynamic>? ?? [])
                .map((paper) {
                  final String title = paper['title'] ?? 'Untitled Paper';
                  final String? link = paper['link'];
                  return _buildListItem(
                    title,
                    isLink: link != null,
                    onTap: link != null ? () => _launchURL(link) : null,
                  );
                })
                .toList(),
          ),

          // --- Contact Information ---
          _buildInfoCard(
            title: "Contact",
            icon: Icons.contact_mail_rounded,
            children: [
              _contactRow(
                Icons.email_outlined,
                widget.data['contact']?['email'] ?? 'N/A',
              ),
              _contactRow(
                Icons.phone_outlined,
                widget.data['contact']?['phone'] ?? 'N/A',
              ),
              _contactRow(
                Icons.location_on_outlined,
                widget.data['office'] ?? 'N/A',
              ),
            ],
          ),

          // --- Availability ---
          _buildAvailabilitySection(
            availableDays,
            selectedDayKey,
            selectedDayValue,
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// Builds the top card with profile picture, name, and specializations.
  Widget _buildProfileHeader() {
    return Container(
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 38,
            backgroundImage:
                (widget.data['image'] != null &&
                    widget.data['image'].toString().isNotEmpty)
                ? NetworkImage(widget.data['image'])
                : null,
            backgroundColor: primaryBlue.withOpacity(0.1),
            child:
                (widget.data['image'] == null ||
                    widget.data['image'].toString().isEmpty)
                ? Icon(Icons.person, size: 36, color: primaryBlue)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.data['name'] ?? 'Professor Name',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textBody,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 6),
                if (widget.data['specializations'] != null)
                  Text(
                    (widget.data['specializations'] as List).join(', '),
                    style: TextStyle(
                      fontSize: 15,
                      color: textSubtle,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// A generic card for displaying sections of information.
  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    if (children.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: primaryBlue, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textBody,
                ),
              ),
            ],
          ),
          const Divider(height: 24, thickness: 0.5),
          ...children,
        ],
      ),
    );
  }

  /// A styled list item for qualifications, research, etc.
  Widget _buildListItem(
    String text, {
    bool isLink = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Icon(Icons.circle, size: 6, color: iconGray),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: isLink ? primaryBlue : textSubtle,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  decoration: isLink
                      ? TextDecoration.underline
                      : TextDecoration.none,
                  decorationColor: primaryBlue,
                ),
              ),
            ),
            if (isLink) const SizedBox(width: 4),
            if (isLink) Icon(Icons.open_in_new, size: 16, color: primaryBlue),
          ],
        ),
      ),
    );
  }

  /// A styled row for contact information.
  Widget _contactRow(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: iconGray, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: textSubtle,
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the entire availability section.
  Widget _buildAvailabilitySection(
    List<String> days,
    String selectedDayKey,
    String selectedDayValue,
  ) {
    return _buildInfoCard(
      title: "Weekly Availability",
      icon: Icons.calendar_today_rounded,
      children: [
        if (days.isNotEmpty) ...[
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: days.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                final isSelected = idx == selectedDay;
                return GestureDetector(
                  onTap: () => setState(() => selectedDay = idx),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? primaryBlue : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      days[idx],
                      style: TextStyle(
                        color: isSelected ? Colors.white : textBody,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: primaryBlue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primaryBlue.withOpacity(0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.access_time_filled_rounded,
                  color: primaryBlue,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  selectedDayValue,
                  style: TextStyle(
                    color: primaryBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ] else
          _buildListItem("Availability not provided."),
      ],
    );
  }
}
