import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static late Box box;

  static Future init() async {
    await Hive.initFlutter();
    box = await Hive.openBox("tailorBox");
  }

  static List getClients() {
    return box.get("clients", defaultValue: []);
  }

  static void saveClients(List clients) {
    box.put("clients", clients);
  }
}