import 'package:flutter/material.dart';
import 'package:mytutor/views/favouritescreen.dart';
import 'package:mytutor/views/subjectscreen.dart';
import 'package:mytutor/views/subscribescreen.dart';
import 'package:mytutor/views/tutorscreen.dart';
import 'package:mytutor/views/profilescreen.dart';

import '../models/user.dart';

class MainScreen extends StatefulWidget {
  final User user;
  const MainScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  /*static const List<Widget> _widgetOptions = <Widget>[
    //SubjectScreen(user: widget.user),
    TutorScreen(),
    SubscribeScreen(),
    FavouriteScreen(),
    ProfileScreen(),
  ];*/

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: <Widget>[
        getCurrentPage(_selectedIndex),
      ]),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Subjects',
            backgroundColor: Colors.black,
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.co_present_rounded),
              label: 'Tutors',
              backgroundColor: Colors.black),
          BottomNavigationBarItem(
              icon: Icon(Icons.collections_bookmark),
              label: 'Subscribe',
              backgroundColor: Colors.black),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Favourite',
              backgroundColor: Colors.black),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle_rounded),
              label: 'Profile',
              backgroundColor: Colors.black),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange,
        onTap: _onItemTapped,
      ),
    );
  }

  getCurrentPage(int index) {
    if (index == 0) {
      return SubjectScreen(
        user: widget.user,
      );
    } else if (index == 1) {
      return const TutorScreen();
    } else if (index == 2) {
      return SubscribeScreen();
    } else if (index == 3) {
      return FavouriteScreen();
    } else if (index == 4) {
      return ProfileScreen(
        user: widget.user,
      );
    }
  }
}
