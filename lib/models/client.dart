import 'order.dart';

class Client {
  String name;
  String phone;
  String date;
  List<Order> orders;
  List<String> images;

  Client({
    required this.name,
    required this.phone,
    required this.date,
    this.orders = const [],
    this.images = const [],
  });
}