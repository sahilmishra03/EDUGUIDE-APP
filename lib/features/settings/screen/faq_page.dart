import 'package:flutter/material.dart';

// --- Constants (Synced with other pages) ---
const Color primaryBlue = Color(0xFF407BFF);
const Color lightBackground = Color(0xFFF7F7FD);
const Color cardBackground = Colors.white;
const Color textSubtle = Color(0xFF6E6E73);
const Color textBody = Color(0xFF1D1D1F);

class FaqPage extends StatelessWidget {
  final List<Map<String, String>> faqData = [
    {
      "question": "What is EduGuide?",
      "answer":
          "EduGuide is a platform that helps students easily find the right teachers, check their availability, and access study resources.",
    },
    {
      "question": "How can I search for a teacher?",
      "answer":
          "Go to the Teacher Directory or use the Search option. You can search by name, department, or specialization.",
    },
    {
      "question": "How do I check a teacher’s availability?",
      "answer":
          "Open the teacher’s profile and tap on the Availability section. You’ll see their timetable and free slots clearly highlighted.",
    },
    {
      "question": "Can I view or download documents?",
      "answer":
          "Yes! Navigate to the Documents section in a teacher’s profile to view or download research papers, notes, or timetables.",
    },
    {
      "question": "Can I save teachers for quick access?",
      "answer":
          "Absolutely! You can mark teachers as favorites, and they will appear in your favorites list on the home screen.",
    },
    {
      "question": "Will I get notified about updates?",
      "answer":
          "Yes, EduGuide sends notifications whenever a teacher updates their timetable or uploads new documents.",
    },
    {
      "question": "How do I sign up as a student?",
      "answer":
          "Just go to the Signup screen, fill in your details, and you’ll be redirected to your Student Dashboard after successful registration.",
    },
    {
      "question": "What can admins do?",
      "answer":
          "Admins can add, edit, or delete teacher profiles and upload important documents like timetables or research papers.",
    },
    {
      "question": "Is my data safe on EduGuide?",
      "answer":
          "Yes, EduGuide uses Firebase Authentication and secure storage to keep your data and documents safe.",
    },
  ];

  FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackground,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: lightBackground,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'FAQs',
          style: TextStyle(
            color: lightBackground,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        itemCount: faqData.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: cardBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                iconColor: primaryBlue,
                collapsedIconColor: textSubtle,
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                title: Text(
                  faqData[index]['question']!,
                  style: const TextStyle(
                    color: textBody,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Text(
                      faqData[index]['answer']!,
                      style: const TextStyle(
                        color: textSubtle,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
