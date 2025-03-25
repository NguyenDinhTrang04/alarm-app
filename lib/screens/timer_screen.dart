import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';

class TimerScreen extends StatefulWidget {
  @override
  _TimerScreenState createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  int _seconds = 0;
  Timer? _timer;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void _startTimer() {
    if (_timer != null) _timer!.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_seconds > 0) {
          _seconds--;
        } else {
          _timer!.cancel();
          _showNotification();
        }
      });
    });
  }

  void _showNotification() async {
    var androidDetails = AndroidNotificationDetails(
      'timer_channel',
      'Timer Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    var notificationDetails = NotificationDetails(android: androidDetails);
    await _notificationsPlugin.show(
      0,
      'Hẹn giờ',
      'Hết giờ!',
      notificationDetails,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hẹn giờ'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${(_seconds ~/ 60).toString().padLeft(2, '0')}:${(_seconds % 60).toString().padLeft(2, '0')}',
            style: TextStyle(fontSize: 48),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _seconds += 60; // Thêm 1 phút
                  });
                },
                child: Text('+1 phút'),
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: _startTimer,
                child: Text('Bắt đầu'),
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _timer?.cancel();
                    _seconds = 0;
                  });
                },
                child: Text('Đặt lại'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
