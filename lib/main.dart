import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const LosCompadresApp());
}

// PALETA DE COLORES CIAN (Identidad Visual)
const Color customPrimaryTeal = Color(0xFF14BDD1);

class LosCompadresApp extends StatefulWidget {
  const LosCompadresApp({super.key});

  @override
  State<LosCompadresApp> createState() => _LosCompadresAppState();
}

class _LosCompadresAppState extends State<LosCompadresApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ladrillera Los Compadres',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: customPrimaryTeal, brightness: Brightness.light),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: customPrimaryTeal, brightness: Brightness.dark),
      ),
      themeMode: _themeMode,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) return MainNavigationPage(onThemeToggle: _toggleTheme);
          return LoginPage(onThemeToggle: _toggleTheme);
        },
      ),
    );
  }
}

// --- CONTENEDOR DE NAVEGACIÓN ---
class MainNavigationPage extends StatefulWidget {
  final VoidCallback onThemeToggle;
  const MainNavigationPage({super.key, required this.onThemeToggle});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const InicioPage(),
      const StockPage(),
      const RegistrarVentaPage(),
      const FinanzasPage(),
      const AjustesPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Los Compadres', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.brightness_6), onPressed: widget.onThemeToggle),
          IconButton(icon: const Icon(Icons.logout), onPressed: () => FirebaseAuth.instance.signOut()),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: customPrimaryTeal,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'Stock'),
          BottomNavigationBarItem(icon: Icon(Icons.add_shopping_cart), label: 'Ventas'),
          BottomNavigationBarItem(icon: Icon(Icons.monetization_on), label: 'Finanzas'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ajustes'),
        ],
      ),
    );
  }
}

// --- PÁGINA 0: INICIO ---
class InicioPage extends StatelessWidget {
  const InicioPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.home_work, size: 100, color: customPrimaryTeal),
          const SizedBox(height: 20),
          const Text('¡Hola, Gerardo!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Text('Ladrillera Los Compadres', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

// --- PÁGINA 1: STOCK ---
class StockPage extends StatelessWidget {
  const StockPage({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('inventario').doc('global').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        var data = snapshot.data!.data() as Map<String, dynamic>;
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Stock Actual', style: TextStyle(fontSize: 20)),
              Text('${data['piezas_disponibles']}', 
                style: const TextStyle(fontSize: 90, fontWeight: FontWeight.bold, color: customPrimaryTeal)),
            ],
          ),
        );
      },
    );
  }
}

class RegistrarVentaPage extends StatefulWidget {
  const RegistrarVentaPage({super.key});
  @override
  State<RegistrarVentaPage> createState() => _RegistrarVentaPageState();
}

class _RegistrarVentaPageState extends State<RegistrarVentaPage> {
  final _clienteController = TextEditingController();
  final _cantidadController = TextEditingController();
  
  // 1. Definimos el precio inicial y la lista de opciones (6.0 a 7.0)
  double _precioSeleccionado = 6.0;
  final List<double> _preciosDisponibles = [6.0, 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 6.7, 6.8, 6.9, 7.0];
  
  bool _cargando = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('NUEVA VENTA', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 25),
          
          // Campo Cliente
          TextField(controller: _clienteController, decoration: const InputDecoration(labelText: 'Cliente', border: OutlineInputBorder())),
          const SizedBox(height: 15),
          
          // Campo Cantidad
          TextField(controller: _cantidadController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Cantidad de Ladrillos', border: OutlineInputBorder())),
          const SizedBox(height: 15),
          
          // 2. LA CAJA DE PRECIOS FIJOS (Dropdown)
          const Text('Precio por Unidad (\$)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          DropdownButtonFormField<double>(
            value: _precioSeleccionado,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: _preciosDisponibles.map((double precio) {
              return DropdownMenuItem<double>(
                value: precio,
                child: Text('\$ $precio'),
              );
            }).toList(),
            onChanged: (double? nuevoPrecio) {
              setState(() {
                _precioSeleccionado = nuevoPrecio!;
              });
            },
          ),
          
          const SizedBox(height: 40),
          
          // Botón de Confirmar
          SizedBox(width: double.infinity, height: 55, child: ElevatedButton(
            onPressed: _cargando ? null : () async {
              setState(() => _cargando = true);
              
              int cant = int.tryParse(_cantidadController.text) ?? 0;
              // 3. Calculamos el total usando el precio de la caja
              double total = cant * _precioSeleccionado;

              DocumentReference stockRef = FirebaseFirestore.instance.collection('inventario').doc('global');
              CollectionReference ventasRef = FirebaseFirestore.instance.collection('ventas');

              try {
                await FirebaseFirestore.instance.runTransaction((tx) async {
                  DocumentSnapshot snap = await tx.get(stockRef);
                  // Restar del stock (CU-04)
                  tx.update(stockRef, {'piezas_disponibles': snap['piezas_disponibles'] - cant});
                  // Guardar venta (CU-03)
                  tx.set(ventasRef.doc(), {
                    'cliente': _clienteController.text.trim(),
                    'cantidad': cant,
                    'total': total,
                    'fecha': FieldValue.serverTimestamp(),
                  });
                });
                
                setState(() => _cargando = false);
                _clienteController.clear(); 
                _cantidadController.clear();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Venta registrada correctamente')));
              } catch (e) {
                setState(() => _cargando = false);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Error: $e')));
              }
            },
            child: _cargando ? const CircularProgressIndicator(color: Colors.white) : const Text('CONFIRMAR VENTA'),
          )),
        ],
      ),
    );
  }
}

// --- PÁGINA 3: FINANZAS (Visualización simplificada) ---
class FinanzasPage extends StatelessWidget {
  const FinanzasPage({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('ventas').orderBy('fecha', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        double capitalTotal = 0;
        for (var doc in snapshot.data!.docs) {
          capitalTotal += (doc['total'] as num).toDouble();
        }

        return Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('CAPITAL TOTAL', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              Text('\$${capitalTotal.toStringAsFixed(2)}', 
                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: customPrimaryTeal)),
              const Divider(height: 40),
              const Text('HISTORIAL', style: TextStyle(fontWeight: FontWeight.bold)),
              Expanded(
                child: ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var v = snapshot.data!.docs[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(v['cliente']),
                      subtitle: Text('${v['cantidad']} piezas'),
                      trailing: Text('\$${v['total']}', style: const TextStyle(fontWeight: FontWeight.bold, color: customPrimaryTeal)),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AjustesPage extends StatelessWidget {
  const AjustesPage({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Configuración del Perfil'));
}

// --- LOGIN PAGE ---
class LoginPage extends StatelessWidget {
  final VoidCallback onThemeToggle;
  LoginPage({super.key, required this.onThemeToggle});
  final _e = TextEditingController(); final _p = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.lock, size: 80, color: customPrimaryTeal),
          const Text('Los Compadres', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 40),
          TextField(controller: _e, decoration: const InputDecoration(labelText: 'Correo', border: OutlineInputBorder())),
          const SizedBox(height: 15),
          TextField(controller: _p, obscureText: true, decoration: const InputDecoration(labelText: 'Contraseña', border: OutlineInputBorder())),
          const SizedBox(height: 30),
          SizedBox(width: double.infinity, height: 55, child: ElevatedButton(
            onPressed: () => FirebaseAuth.instance.signInWithEmailAndPassword(email: _e.text.trim(), password: _p.text.trim()),
            child: const Text('ENTRAR'),
          )),
        ]),
      ),
    );
  }
}