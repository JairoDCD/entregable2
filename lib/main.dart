import 'package:flutter/material.dart';

void main() => runApp(EcoMarketApp());

class EcoMarketApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoMarket (beta)',
      theme: ThemeData(primarySwatch: Colors.green),
      home: Splash(),
    );
  }
}

class Splash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(milliseconds: 700), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
    });
    return Scaffold(body: Center(child: Text('EcoMarket', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold))));
  }
}

// Simple in-memory models
class Product {
  String id, name, desc, category, image;
  double price;
  Product({required this.id, required this.name, this.desc = '', this.category = 'General', this.image = '', this.price = 0});
}

class FakeDB {
  static List<Product> products = [
    Product(id: '1', name: 'Miel orgánica', desc: 'Miel local, sin pesticidas', price: 18.5, category: 'Alimentos'),
    Product(id: '2', name: 'Cepillo biodegradable', desc: 'Cepillo de bambú', price: 6.0, category: 'Hogar'),
  ];
}

// Login - minimal (no auth)
class LoginPage extends StatelessWidget {
  final _email = TextEditingController();
  final _name = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('EcoMarket (beta)')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: _name, decoration: InputDecoration(labelText: 'Nombre')),
          SizedBox(height: 8),
          TextField(controller: _email, decoration: InputDecoration(labelText: 'Correo')),
          SizedBox(height: 16),
          ElevatedButton(onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage(userName: _name.text.isEmpty ? 'Invitado' : _name.text))), child: Text('Entrar'))
        ]),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final String userName;
  HomePage({required this.userName});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tab = 0;
  List<Product> products = List.from(FakeDB.products);
  Set<String> favIds = {};

  void _addProduct(Product p) {
    setState(() => products.add(p));
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _catalogView(),
      _favoritesView(),
      _profileView(),
    ];
    return Scaffold(
      appBar: AppBar(title: Text('EcoMarket - Hola ${widget.userName}')),
      drawer: Drawer(child: _drawerContent()),
      body: pages[_tab],
      floatingActionButton: _tab == 0
          ? FloatingActionButton(child: Icon(Icons.add), onPressed: () async {
        final p = await Navigator.push<Product?>(context, MaterialPageRoute(builder: (_) => AddProductPage()));
        if (p != null) _addProduct(p);
      })
          : null,
      bottomNavigationBar: BottomNavigationBar(currentIndex: _tab, onTap: (i) => setState(() => _tab = i), items: [
        BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Catálogo'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favoritos'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
      ]),
    );
  }

  Widget _catalogView() {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (c, i) {
        final p = products[i];
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            leading: CircleAvatar(child: Text(p.name[0])),
            title: Text(p.name),
            subtitle: Text(p.category + ' • \$' + p.price.toStringAsFixed(2)),
            trailing: IconButton(icon: Icon(favIds.contains(p.id) ? Icons.favorite : Icons.favorite_border, color: favIds.contains(p.id) ? Colors.red : null), onPressed: () => setState(() => favIds.contains(p.id) ? favIds.remove(p.id) : favIds.add(p.id))),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailPage(product: p, onToggleFav: () => setState(() => favIds.contains(p.id) ? favIds.remove(p.id) : favIds.add(p.id)), isFav: favIds.contains(p.id)))),
          ),
        );
      },
    );
  }

  Widget _favoritesView() {
    final favs = products.where((p) => favIds.contains(p.id)).toList();
    if (favs.isEmpty) return Center(child: Text('No hay favoritos aún'));
    return ListView(children: favs.map((p) => ListTile(title: Text(p.name), subtitle: Text('\$${p.price.toStringAsFixed(2)}'))).toList());
  }

  Widget _profileView() {
    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text('Usuario: ${widget.userName}'), SizedBox(height: 8), ElevatedButton(onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage())), child: Text('Cerrar sesión'))]));
  }

  Widget _drawerContent() {
    return ListView(padding: EdgeInsets.zero, children: [DrawerHeader(child: Text('EcoMarket', style: TextStyle(fontSize: 24, color: Colors.white)), decoration: BoxDecoration(color: Colors.green),), ListTile(leading: Icon(Icons.add), title: Text('Publicar producto'), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => AddProductPage())).then((p){ if (p!=null) _addProduct(p as Product);}); }), ListTile(leading: Icon(Icons.info), title: Text('Acerca de'), onTap: () => showAboutDialog(context: context, applicationName: 'EcoMarket (beta)', children: [Text('Aplicación demo para el entregable de Flutter.')])),]);
  }
}

class ProductDetailPage extends StatelessWidget {
  final Product product;
  final VoidCallback onToggleFav;
  final bool isFav;
  ProductDetailPage({required this.product, required this.onToggleFav, required this.isFav});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.name), actions: [IconButton(icon: Icon(isFav ? Icons.favorite : Icons.favorite_border), onPressed: onToggleFav)]),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(product.name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), SizedBox(height: 8), Text('\$${product.price.toStringAsFixed(2)}', style: TextStyle(fontSize: 18)), SizedBox(height: 12), Text(product.desc)]),
      ),
    );
  }
}

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _name = TextEditingController();
  final _desc = TextEditingController();
  final _price = TextEditingController();
  final _category = TextEditingController(text: 'General');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Publicar producto')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: _name, decoration: InputDecoration(labelText: 'Nombre')),
          TextField(controller: _desc, decoration: InputDecoration(labelText: 'Descripción')),
          TextField(controller: _price, decoration: InputDecoration(labelText: 'Precio'), keyboardType: TextInputType.number),
          TextField(controller: _category, decoration: InputDecoration(labelText: 'Categoría')),
          SizedBox(height: 12),
          ElevatedButton(onPressed: () {
            final p = Product(id: DateTime.now().millisecondsSinceEpoch.toString(), name: _name.text, desc: _desc.text, category: _category.text, price: double.tryParse(_price.text) ?? 0);
            Navigator.pop(context, p);
          }, child: Text('Publicar'))
        ]),
      ),
    );
  }
}
