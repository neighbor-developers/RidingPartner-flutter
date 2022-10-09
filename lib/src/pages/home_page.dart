import 'package:flutter/material.dart';
import 'package:ridingpartner_flutter/src/pages/map_page.dart';
import 'package:ridingpartner_flutter/src/pages/weather_page.dart';

class HomePage extends StatefulWidget {
  HomePage({
    Key? key,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<BottomNavigationBarItem> btmNavItems = [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
    BottomNavigationBarItem(icon: Icon(Icons.map), label: ""),
    BottomNavigationBarItem(icon: Icon(Icons.pedal_bike), label: ""),
    BottomNavigationBarItem(icon: Icon(Icons.flag), label: ""),
    BottomNavigationBarItem(icon: Icon(Icons.settings), label: ""),
  ];

  int _selectedIndex = 0;

  List<Widget> _pages = [
    HomePage(),
    MapSample(),
    WeatherPage(),
    WeatherPage(),
    WeatherPage(),
  ];

  void _onItemTapped(int index){
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: SafeArea(
        child: _pages.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
          label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: '지도',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pedal_bike),
            label: '대여소',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag),
            label: '명소',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '설정',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.lightGreen,
        onTap: _onItemTapped
      ),
    );
  }

  @override
  void initState(){
    super.initState();
  }

  @override
  void dispose(){
    super.dispose();
  }
  }
