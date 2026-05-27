Future<void> initNative() async {}

Future<void> cancelAll() async {}

Future<void> cancelById(int id) async {}

Future<void> scheduleDailyNotification({
  required int id,
  required String title,
  required String body,
  required int hour,
  required int minute,
}) async {}
