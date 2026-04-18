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
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.deepPurple,
        scaffoldBackgroundColor: Color(0xFF121212),
      ),
      home: HomePage(),
    );
  }
}

// 📦 LISTE PRODUITS
List<String> products = [
  "Parure lit 1 place (3 pièces)",
  "Parure lit 2 places (6 pièces)",
  "Chemise",
  "Pantalon",
  "Robe",
  "Jebba",
  "Koftan",
  "Cache couette",
];

// 📸 IMAGES MODELES
Map<String, String> productImages = {
  "Robe": "assets/robe.png",
  "Pantalon": "assets/pantalon.png",
  "Chemise": "assets/chemise.png",
  "Jebba": "assets/jebba.png",
};

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
          return Card(
            child: ListTile(
              title: Text(clients[i]["name"]),
              subtitle: Text(clients[i]["phone"]),
              trailing: Icon(Icons.arrow_forward_ios),
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
            ),
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
  String selectedProduct = products[0];

  void addOrder() {
    String price = "";
    String qty = "";

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Nouvelle commande"),
        content: SingleChildScrollView(
          child: Column(
            children: [

              // 🎯 DROPDOWN PRODUIT
              DropdownButtonFormField(
                value: selectedProduct,
                items: products.map((p) {
                  return DropdownMenuItem(value: p, child: Text(p));
                }).toList(),
                onChanged: (v) {
                  setState(() {
                    selectedProduct = v!;
                  });
                },
              ),

              SizedBox(height: 10),

              // 📸 IMAGE MODELE
              if (productImages.containsKey(selectedProduct))
                Image.asset(productImages[selectedProduct]!, height: 100),

              TextField(
                decoration: InputDecoration(labelText: "Prix"),
                keyboardType: TextInputType.number,
                onChanged: (v) => price = v,
              ),

              TextField(
                decoration: InputDecoration(labelText: "Quantité"),
                keyboardType: TextInputType.number,
                onChanged: (v) => qty = v,
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                widget.client["orders"].add({
                  "type": selectedProduct,
                  "price": double.tryParse(price) ?? 0,
                  "qty": int.tryParse(qty) ?? 1,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.client["name"])),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text("📞 ${widget.client["phone"]}", style: TextStyle(fontSize: 16)),
            Text("📅 ${widget.client["date"]}", style: TextStyle(fontSize: 16)),

            SizedBox(height: 20),

            ElevatedButton(onPressed: addOrder, child: Text("📦 Ajouter commande")),
            ElevatedButton(onPressed: pickImage, child: Text("📸 Ajouter photo")),

            SizedBox(height: 20),

            Text("📦 Commandes", style: TextStyle(fontSize: 18)),
            ...widget.client["orders"].map<Widget>((o) {
              return Card(
                child: ListTile(
                  title: Text(o["type"]),
                  subtitle: Text("${o["qty"]} x ${o["price"]}"),
                ),
              );
            }).toList(),

            SizedBox(height: 10),

            Text("💰 Total: ${total()} DT",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

            SizedBox(height: 20),

            Text("📸 Photos"),
            Wrap(
              spacing: 10,
              children: widget.client["images"].map<Widget>((p) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(File(p), width: 80, height: 80, fit: BoxFit.cover),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}