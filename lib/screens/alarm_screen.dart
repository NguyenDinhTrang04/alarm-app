import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AlarmScreen extends StatefulWidget {
  @override
  _AlarmScreenState createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final CollectionReference alarmsCollection =
      FirebaseFirestore.instance.collection('alarms');

  // Hàm thêm báo thức
  void _addAlarm() async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (selectedTime != null) {
      String time = selectedTime.format(context);
      var docRef = await alarmsCollection.add({'time': time, 'isActive': true});
      _scheduleAlarm(selectedTime, docRef.id);
    }
  }

  // Hàm chỉnh sửa báo thức
  void _editAlarm(String id, String currentTime) async {
    print("Editing alarm with id: $id and currentTime: $currentTime");
    List<String> timeParts = currentTime.split(" ");
    List<String> hourMinute = timeParts[0].split(":");
    int hour = int.parse(hourMinute[0]);
    int minute = int.parse(hourMinute[1]);
    if (timeParts[1] == "PM" && hour != 12) {
      hour += 12;
    } else if (timeParts[1] == "AM" && hour == 12) {
      hour = 0;
    }
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: minute),
    );
    if (selectedTime != null) {
      String newTime = selectedTime.format(context);
      await alarmsCollection.doc(id).update({'time': newTime});
      _scheduleAlarm(selectedTime, id);
    }
  }

  // Hàm xóa báo thức
  void _deleteAlarm(String id) async {
    await alarmsCollection.doc(id).delete();
    await flutterLocalNotificationsPlugin.cancel(id.hashCode);
  }

  // Hàm hiển thị hộp thoại xác nhận xóa
  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: const Text('Bạn có chắc chắn muốn xóa báo thức này không?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng hộp thoại
              },
              child: const Text('Không'),
            ),
            TextButton(
              onPressed: () {
                _deleteAlarm(id); // Xóa báo thức
                Navigator.of(context).pop(); // Đóng hộp thoại
              },
              child: const Text('Có'),
            ),
          ],
        );
      },
    );
  }

  // Hàm lên lịch thông báo báo thức
  void _scheduleAlarm(TimeOfDay time, String id) async {
    var now = DateTime.now();
    var scheduledTime =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }
    var androidDetails = const AndroidNotificationDetails(
      'alarm_channel',
      'Alarm Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    var notificationDetails = NotificationDetails(android: androidDetails);
    // ignore: deprecated_member_use
    await flutterLocalNotificationsPlugin.schedule(
      id.hashCode,
      'Báo thức',
      'Đã đến giờ báo thức!',
      scheduledTime,
      notificationDetails,
    );
  }

// Dùng firebase notifications
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Báo thức')),
      body: StreamBuilder(
        stream: alarmsCollection.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            children: snapshot.data!.docs.map((doc) {
              return Card(
                margin:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  side: BorderSide(color: Colors.grey.shade300, width: 0.5),
                ),
                child: ListTile(
                  title: Text(doc['time']),
                  onTap: () => _editAlarm(doc.id, doc['time']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editAlarm(doc.id, doc['time']),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () =>
                            _confirmDelete(doc.id), // Gọi hàm xác nhận
                      ),
                      Switch(
                        value: doc['isActive'],
                        onChanged: (value) {
                          alarmsCollection
                              .doc(doc.id)
                              .update({'isActive': value});
                        },
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAlarm,
        child: const Icon(Icons.add),
      ),
    );
  }
}
// Cấu trúc phân lớp đơn giản với các lớp giao diện, logic, lưu trữ dữ liệu, thông báo