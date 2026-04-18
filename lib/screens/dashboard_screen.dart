import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  final List clients;

  DashboardScreen({required this.clients});

  double totalRevenue() {
    double total = 0;
    for (var c in clients) {
      for (var o in c["orders"]) {
        total += o["price"] * o["quantity"];
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("📊 Dashboard")),
      body: Center(
        child: Text(
          "💰 Total: ${totalRevenue()} DT",
          style: TextStyle(fontSize: 28),
        ),
      ),
    );
  }
}