import 'package:flutter/material.dart';
import '../theme/win95_theme.dart';
import '../widgets/win95_widgets.dart';
import 'tasks_screen.dart';
import 'habits_screen.dart';
import 'calendar_screen.dart';
import 'tags_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const TasksScreen(),
    const HabitsScreen(),
    const CalendarScreen(),
    const TagsScreen(),
  ];

  final List<String> _titles = [
    'Tasks',
    'Habits',
    'Calendar',
    'Tags',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Win95Theme.desktop,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Win95Window(
            title: _titles[_selectedIndex],
            child: Column(
              children: [
                // Menu bar
                Container(
                  color: Win95Theme.buttonFace,
                  child: Row(
                    children: [
                      _buildMenuButton('Tasks', 0),
                      _buildMenuButton('Habits', 1),
                      _buildMenuButton('Calendar', 2),
                      _buildMenuButton('Tags', 3),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Win95Theme.buttonShadow),
                // Screen content
                Expanded(
                  child: Container(
                    color: Win95Theme.windowBackground,
                    child: _screens[_selectedIndex],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color:
              isSelected ? Win95Theme.buttonHighlight : Win95Theme.buttonFace,
          border: isSelected
              ? const Border(
                  top: BorderSide(color: Win95Theme.buttonDarkShadow, width: 1),
                  left:
                      BorderSide(color: Win95Theme.buttonDarkShadow, width: 1),
                  right:
                      BorderSide(color: Win95Theme.buttonHighlight, width: 1),
                )
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Win95Theme.buttonText,
            decoration: isSelected ? TextDecoration.underline : null,
          ),
        ),
      ),
    );
  }
}
