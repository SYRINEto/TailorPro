class Order {
  String type;
  double price;
  int quantity;

  Order({
    required this.type,
    required this.price,
    required this.quantity,
  });

  double get total => price * quantity;
}