import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('clients');
  runApp(TailorProApp());
}

class TailorProApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TailorPro',
      theme: ThemeData.dark(),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Box box = Hive.box('clients');

  List clients = [];

  @override
  void initState() {
    super.initState();
    clients = box.get('data', defaultValue: []);
  }

  void save() {
    box.put('data', clients);
  }

  void addClient() {
    String name = "";
    String phone = "";
    String dateLimit = "";

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Nouveau client"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(onChanged: (v) => name = v, decoration: InputDecoration(labelText: "Nom")),
            TextField(onChanged: (v) => phone = v, decoration: InputDecoration(labelText: "Téléphone")),
            TextField(onChanged: (v) => dateLimit = v, decoration: InputDecoration(labelText: "Date limite")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Annuler")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                clients.add({
                  "name": name,
                  "phone": phone,
                  "date": dateLimit,
                  "orders": [],
                  "images": [],
                });
                save();
              });
              Navigator.pop(context);
            },
            child: Text("Ajouter"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("🧵 TailorPro")),
      body: ListView.builder(
        itemCount: clients.length,
        itemBuilder: (context, i) {
          return ListTile(
            title: Text(clients[i]["name"]),
            subtitle: Text(clients[i]["phone"]),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ClientPage(
                    client: clients[i],
                    onUpdate: () {
                      setState(() {});
                      save();
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addClient,
        child: Icon(Icons.add),
      ),
    );
  }
}

class ClientPage extends StatefulWidget {
  Map client;
  final Function onUpdate;

  ClientPage({required this.client, required this.onUpdate});

  @override
  State<ClientPage> createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  File? image;

  void addOrder() {
    String type = "";
    String price = "";
    String qty = "";

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Commande"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(onChanged: (v) => type = v, decoration: InputDecoration(labelText: "Type")),
            TextField(onChanged: (v) => price = v, decoration: InputDecoration(labelText: "Prix")),
            TextField(onChanged: (v) => qty = v, decoration: InputDecoration(labelText: "Quantité")),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                widget.client["orders"].add({
                  "type": type,
                  "price": double.parse(price),
                  "qty": int.parse(qty),
                });
              });
              widget.onUpdate();
              Navigator.pop(context);
            },
            child: Text("Ajouter"),
          )
        ],
      ),
    );
  }

  double total() {
    double t = 0;
    for (var o in widget.client["orders"]) {
      t += o["price"] * o["qty"];
    }
    return t;
  }

  Future pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        widget.client["images"].add(picked.path);
      });
      widget.onUpdate();
    }
  }

  double aiPriceSuggestion(String type) {
    if (type.contains("robe")) return 120;
    if (type.contains("pantalon")) return 60;
    return 80;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.client["name"])),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text("📞 ${widget.client["phone"]}"),
            Text("📅 ${widget.client["date"]}"),

            SizedBox(height: 20),

            ElevatedButton(onPressed: addOrder, child: Text("📦 Ajouter commande")),
            ElevatedButton(onPressed: pickImage, child: Text("📸 Ajouter photo")),

            SizedBox(height: 20),

            Text("📦 Commandes"),
            ...widget.client["orders"].map<Widget>((o) {
              return ListTile(
                title: Text(o["type"]),
                subtitle: Text("${o["qty"]} x ${o["price"]}"),
              );
            }).toList(),

            SizedBox(height: 10),

            Text("💰 Total: ${total()}"),

            SizedBox(height: 20),

            Text("🤖 IA suggestion prix: ${aiPriceSuggestion("robe")} DT"),

            SizedBox(height: 20),

            Text("📸 Photos"),
            Wrap(
              children: widget.client["images"].map<Widget>((p) {
                return Image.file(File(p), width: 80, height: 80);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}