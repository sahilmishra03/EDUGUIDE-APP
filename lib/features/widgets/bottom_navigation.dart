import 'package:eduguide/features/home/screens/home_page.dart';
import 'package:eduguide/features/professors/services/professor_service.dart';
import 'package:eduguide/features/settings/screen/setting_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../professors/screens/professors_list.dart';
import '../search/screen/search_page.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  Color primaryBlue = Color(0xFF407BFF);
  Color lightBackground = Color(0xFFF7F7FD);
  Color cardBackground = Colors.white;
  Color textSubtle = Color(0xFF6E6E73);
  Color textBody = Color(0xFF1D1D1F);
  late final List<Widget> _widgetOptions;
  final ProfessorsService _professorsService = ProfessorsService();

  int myIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      myIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      HomePage(onNavigate: _onItemTapped),
      ProfessorsListPage(professorsService: _professorsService),
      SearchPage(professorsService: _professorsService),
      SettingsPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _widgetOptions.elementAt(myIndex)),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: primaryBlue,
        unselectedItemColor: textSubtle,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.house),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.graduationCap),
            label: 'Teachers',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.magnifyingGlass),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.gear),
            label: 'Settings',
          ),
        ],
        currentIndex: myIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
