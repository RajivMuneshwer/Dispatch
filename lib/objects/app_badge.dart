import 'package:queue/queue.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';

class AppBadge {
  SharedPreferences prefs;

  AppBadge({
    required this.prefs,
  });

  static Future<AppBadge> getInstance() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    return AppBadge(
      prefs: prefs,
    );
  }

  Future<void> increaseBadgeCountBy(int inc) async {
    print("increase");
    var currentUnread = prefs.getInt("currentUnread");
    if (currentUnread == null) {
      throw Exception("no currentUnread. Value was not initialized");
    }
    print(currentUnread);
    currentUnread += inc;
    final displayValue = (currentUnread <= 0) ? 0 : currentUnread;
    await FlutterAppBadger.updateBadgeCount(displayValue);
    await prefs.setInt("currentUnread", currentUnread);
  }

  Future<void> decreaseBadgeCountBy(int dec) async {
    print("decrease");
    final currentUnread = prefs.getInt("currentUnread");
    if (currentUnread == null) {
      throw Exception("no currentUnread. Value was not initialized");
    }
    print(currentUnread);
    final newUnread = currentUnread - dec;
    final displayValue = (newUnread <= 0) ? 0 : newUnread;
    await FlutterAppBadger.updateBadgeCount(displayValue);
    await prefs.setInt("currentUnread", newUnread);
  }

  Future<void> initializeBadgeCount() async {
    await prefs.setInt("currentUnread", 0);
    FlutterAppBadger.removeBadge();
  }
}

final appBadgeQueue = Queue();
