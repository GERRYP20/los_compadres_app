import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Asegúrate de tener 'intl' en tu pubspec.yaml

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const LosCompadresApp());
}

const Color customPrimaryTeal = Color.fromARGB(255, 120, 120, 120);

class LosCompadresApp extends StatefulWidget {
  const LosCompadresApp({super.key});
  @override
  State<LosCompadresApp> createState() => _LosCompadresAppState();
}

class _LosCompadresAppState extends State<LosCompadresApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ladrillera Los Compadres',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: customPrimaryTeal,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: customPrimaryTeal,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: _themeMode,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData)
            return MainNavigationPage(onThemeToggle: _toggleTheme);
          return LoginPage(onThemeToggle: _toggleTheme);
        },
      ),
    );
  }
}

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
        title: const Text(
          'Los Compadres',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: widget.onThemeToggle,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
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
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2),
            label: 'Stock',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_shopping_cart),
            label: 'Ventas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on),
            label: 'Finanzas',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ajustes'),
        ],
      ),
    );
  }
}

class InicioPage extends StatelessWidget {
  const InicioPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home_work, size: 100, color: customPrimaryTeal),
          SizedBox(height: 20),
          Text(
            '¡Hola, Gerardo!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            'Ladrillera Los Compadres',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class StockPage extends StatelessWidget {
  const StockPage({super.key});

  void _mostrarDialogoAgregar(BuildContext context, int stockActual) {
    final TextEditingController cantidadController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('ENTRADA DE BLOCKS'),
          content: TextField(
            controller: cantidadController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '¿Cuántos ingresan?',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCELAR'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: customPrimaryTeal,
              ),
              onPressed: () async {
                int cant = int.tryParse(cantidadController.text) ?? 0;
                if (cant > 0) {
                  try {
                    await FirebaseFirestore.instance.runTransaction((tx) async {
                      DocumentSnapshot snap = await tx.get(
                        FirebaseFirestore.instance
                            .collection('inventario')
                            .doc('global'),
                      );
                      tx.update(snap.reference, {
                        'piezas_disponibles': snap['piezas_disponibles'] + cant,
                      });
                    });

                    // SOLUCIÓN AL ERROR: Verificar si el context sigue activo
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✅ Stock actualizado')),
                    );
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('❌ Error: $e')));
                  }
                }
              },
              child: const Text(
                'AÑADIR',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('inventario')
          .doc('global')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        var data = snapshot.data!.data() as Map<String, dynamic>;
        int current = data['piezas_disponibles'] ?? 0;
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Blocks en Almacén',
                style: TextStyle(fontSize: 20, color: Colors.grey),
              ),
              Text(
                '$current',
                style: const TextStyle(
                  fontSize: 100,
                  fontWeight: FontWeight.bold,
                  color: customPrimaryTeal,
                ),
              ),
              const SizedBox(height: 50),
              ElevatedButton.icon(
                onPressed: () => _mostrarDialogoAgregar(context, current),
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('AÑADIR BLOCKS'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: customPrimaryTeal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(20),
                ),
              ),
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
  double _precio = 6.0;
  bool _cargando = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'NUEVA VENTA',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 25),
          TextField(
            controller: _clienteController,
            decoration: const InputDecoration(
              labelText: 'Cliente',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _cantidadController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Cantidad',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 15),
          DropdownButtonFormField<double>(
            value: _precio,
            decoration: const InputDecoration(
              labelText: 'Precio por Unidad',
              border: OutlineInputBorder(),
            ),
            items: [6.0, 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 6.7, 6.8, 6.9, 7.0]
                .map((p) => DropdownMenuItem(value: p, child: Text('\$ $p')))
                .toList(),
            onChanged: (v) => setState(() => _precio = v!),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: _cargando
                  ? null
                  : () async {
                      setState(() => _cargando = true);
                      int cant = int.tryParse(_cantidadController.text) ?? 0;
                      try {
                        await FirebaseFirestore.instance.runTransaction((
                          tx,
                        ) async {
                          DocumentReference stockRef = FirebaseFirestore
                              .instance
                              .collection('inventario')
                              .doc('global');
                          DocumentSnapshot snap = await tx.get(stockRef);
                          tx.update(stockRef, {
                            'piezas_disponibles':
                                snap['piezas_disponibles'] - cant,
                          });
                          tx.set(
                            FirebaseFirestore.instance
                                .collection('ventas')
                                .doc(),
                            {
                              'cliente': _clienteController.text.trim(),
                              'cantidad': cant,
                              'total': cant * _precio,
                              'fecha': FieldValue.serverTimestamp(),
                            },
                          );
                        });

                        // SOLUCIÓN AL ERROR: Verificar si el State sigue montado
                        if (!mounted) return;
                        setState(() => _cargando = false);
                        _clienteController.clear();
                        _cantidadController.clear();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('✅ Venta Exitosa')),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        setState(() => _cargando = false);
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('❌ Error: $e')));
                      }
                    },
              child: _cargando
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('CONFIRMAR VENTA'),
            ),
          ),
        ],
      ),
    );
  }
}

class FinanzasPage extends StatelessWidget {
  const FinanzasPage({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('ventas')
          .orderBy('fecha', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        double total = snapshot.data!.docs.fold(
          0,
          (prev, doc) => prev + (doc['total'] as num).toDouble(),
        );

        return Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CAPITAL TOTAL',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: customPrimaryTeal,
                ),
              ),
              const Divider(height: 40),
              const Text(
                'HISTORIAL',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var v = snapshot.data!.docs[index];
                    String fecha = "S/F";
                    if (v['fecha'] != null) {
                      fecha = DateFormat(
                        'dd/MM/yyyy',
                      ).format((v['fecha'] as Timestamp).toDate());
                    }
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      leading: const CircleAvatar(
                        backgroundColor: Colors.grey,
                        child: Icon(
                          Icons.receipt_long,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        v['cliente'] ?? 'Sin nombre',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text('${v['cantidad']} piezas • $fecha'),

                      // AQUÍ ESTÁ EL CAMBIO PARA EL PRECIO
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: customPrimaryTeal.withOpacity(
                            0.1,
                          ), // Un fondo suave cian
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '\$${v['total']}',
                          style: const TextStyle(
                            fontSize: 20, // ¡Mucho más grande!
                            fontWeight: FontWeight.bold, // Más grueso
                            color: customPrimaryTeal,
                          ),
                        ),
                      ),
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
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Configuración del Perfil',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            'Estudiante: Gerardo Pérez Sánchez',
            style: TextStyle(color: Colors.grey),
          ),
          Text('ID: 186000', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  final VoidCallback onThemeToggle;
  LoginPage({super.key, required this.onThemeToggle});
  final _e = TextEditingController();
  final _p = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, size: 80, color: customPrimaryTeal),
            const Text(
              'Los Compadres',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _e,
              decoration: const InputDecoration(
                labelText: 'Correo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _p,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: _e.text.trim(),
                      password: _p.text.trim(),
                    );
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error de acceso: $e')),
                    );
                  }
                },
                child: const Text('ENTRAR'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
