import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'screens/alarm_screen.dart';
import 'screens/clock_screen.dart';
import 'screens/stopwatch_screen.dart';
import 'screens/timer_screen.dart';
import 'screens/task_screen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBV2_5z0LYwodWkj5_kkhdUstIPwAKWgjs",
      authDomain: "app-node-27037.firebaseapp.com",
      projectId: "app-node-27037",
      storageBucket: "app-node-27037.firebasestorage.app",
      messagingSenderId: "23677665657",
      appId: "1:23677665657:web:5154266e2ad8b323a6efa8",
    ),
  );
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Thêm dòng này để bỏ debug banner
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    AlarmScreen(),
    ClockScreen(),
    StopwatchScreen(),
    TimerScreen(),
    TaskScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.alarm), label: 'Báo thức'),
          BottomNavigationBarItem(
              icon: Icon(Icons.access_time), label: 'Đồng hồ'),
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'Bấm giờ'),
          BottomNavigationBarItem(
              icon: Icon(Icons.hourglass_empty), label: 'Hẹn giờ'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Nhiệm vụ'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black, // Màu icon và text khi được chọn
        unselectedItemColor:
            Colors.black, // Màu icon và text khi không được chọn
        onTap: _onItemTapped,
      ),
    );
  }
}
