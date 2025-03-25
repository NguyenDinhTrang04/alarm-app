import 'package:flutter/material.dart';
import 'dart:async';

class StopwatchScreen extends StatefulWidget {
  @override
  _StopwatchScreenState createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen> {
  Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  String _timeDisplay = '00:00:00:00';

  void _updateTime(Timer timer) {
    if (_stopwatch.isRunning) {
      setState(() {
        _timeDisplay = _formatTime(_stopwatch.elapsedMilliseconds);
      });
    }
  }

  String _formatTime(int milliseconds) {
    int hundreds = (milliseconds / 10).floor() % 100;
    int seconds = (milliseconds / 1000).floor();
    int minutes = (seconds / 60).floor();
    int hours = (minutes / 60).floor();
    seconds = seconds % 60;
    minutes = minutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${hundreds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bấm giờ'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_timeDisplay,
              style: TextStyle(
                  fontSize: 48,
                  fontFamily: 'Monospace',
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (_stopwatch.isRunning) {
                      _stopwatch.stop();
                      _timer?.cancel();
                    } else {
                      _stopwatch.start();
                      _timer = Timer.periodic(
                          Duration(milliseconds: 100), _updateTime);
                    }
                  });
                },
                child: Text(_stopwatch.isRunning ? 'Dừng' : 'Bắt đầu'),
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _stopwatch.reset();
                    _timeDisplay = '00:00:00:00';
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
