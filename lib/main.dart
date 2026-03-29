import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const LosCompadresApp());
}

// 1. DEFINICIÓN DE LA NUEVA PALETA DE COLORES (Inspirada en image_d2b026.png)
const Color customPrimaryTeal = Color(0xFF14BDD1); // El cian vibrante de la imagen
const Color customOnPrimary = Colors.white;
const Color customSurfaceLight = Colors.white;
const Color customOnSurfaceDark = Color(0xFF1C1C1E); // Un gris muy oscuro para texto

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
      
      // 2. APLICACIÓN DEL NUEVO TEMA CLARO (Basado en la imagen)
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: customPrimaryTeal,
          onPrimary: customOnPrimary,
          surface: customSurfaceLight,
          onSurface: customOnSurfaceDark,
          secondary: customPrimaryTeal, // Usamos el mismo cian para acentos
        ),
        scaffoldBackgroundColor: customSurfaceLight,
        appBarTheme: const AppBarTheme(
          backgroundColor: customSurfaceLight,
          foregroundColor: customOnSurfaceDark,
          elevation: 0,
        ),
        // Estilo global para botones para usar el nuevo cian
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: customPrimaryTeal,
            foregroundColor: customOnPrimary,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      
      // 3. APLICACIÓN DEL TEMA OSCURO (Adaptado para que el cian resalte)
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: customPrimaryTeal, // El cian resalta muy bien en oscuro
          onPrimary: Colors.black, // Texto negro sobre botones cian
          surface: Color(0xFF121212),
          onSurface: Colors.white70,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: customPrimaryTeal,
            foregroundColor: Colors.black,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      
      themeMode: _themeMode,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return MainNavigationPage(onThemeToggle: _toggleTheme);
          }
          return LoginPage(onThemeToggle: _toggleTheme);
        },
      ),
    );
  }
}

// --- CONTENEDOR DE NAVEGACIÓN PRINCIPAL (Actualizado con colores) ---
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
        // NUEVO: Usamos el cian para el ítem seleccionado
        selectedItemColor: customPrimaryTeal, 
        unselectedItemColor: Colors.grey,
        backgroundColor: Theme.of(context).colorScheme.surface,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'Stock'),
          BottomNavigationBarItem(icon: Icon(Icons.add_shopping_cart), label: 'Ventas'),
          BottomNavigationBarItem(icon: Icon(Icons.monetization_on), label: 'Finanzas'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Más'),
        ],
      ),
    );
  }
}

// --- 1. PÁGINA DE STOCK (Actualizado color de texto) ---
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
              const Text('Ladrillos en Almacén', style: TextStyle(fontSize: 20)),
              Text('${data['piezas_disponibles']}', 
                // NUEVO: Texto grande en el nuevo cian
                style: const TextStyle(fontSize: 90, fontWeight: FontWeight.bold, color: customPrimaryTeal)),
            ],
          ),
        );
      },
    );
  }
}

// --- 2. PÁGINA DE VENTAS (Mismo código, toma color de botones global) ---
class RegistrarVentaPage extends StatefulWidget {
  const RegistrarVentaPage({super.key});

  @override
  State<RegistrarVentaPage> createState() => _RegistrarVentaPageState();
}

class _RegistrarVentaPageState extends State<RegistrarVentaPage> {
  final _formKey = GlobalKey<FormState>();
  final _cantidadController = TextEditingController();
  bool _cargando = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('NUEVA VENTA', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            TextFormField(
              controller: _cantidadController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Cantidad de Ladrillos', border: OutlineInputBorder()),
              validator: (v) => (int.tryParse(v ?? '') ?? 0) <= 0 ? 'Ingrese una cantidad válida' : null,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                // NUEVO: El botón toma el color global (cian)
                onPressed: _cargando ? null : () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() => _cargando = true);
                    int cant = int.parse(_cantidadController.text);
                    DocumentReference ref = FirebaseFirestore.instance.collection('inventario').doc('global');
                    await FirebaseFirestore.instance.runTransaction((tx) async {
                      DocumentSnapshot snap = await tx.get(ref);
                      tx.update(ref, {'piezas_disponibles': snap['piezas_disponibles'] - cant});
                    });
                    setState(() => _cargando = false);
                    _cantidadController.clear();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Venta Exitosa')));
                  }
                },
                child: _cargando ? const CircularProgressIndicator(color: Colors.white) : const Text('CONFIRMAR VENTA'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 3. PÁGINA DE FINANZAS (Actualizado color de icono) ---
class FinanzasPage extends StatelessWidget {
  const FinanzasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // NUEVO: Icono en el nuevo cian
          Icon(Icons.account_balance_wallet, size: 80, color: customPrimaryTeal),
          Text('Resumen Financiero', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text('Próximamente: Gastos y Utilidades', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

// --- 4. OTRAS COSAS ---
class AjustesPage extends StatelessWidget {
  const AjustesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Configuración y Perfil de Usuario'));
  }
}

// --- LOGIN PAGE (Actualizado con nuevos colores) ---
class LoginPage extends StatelessWidget {
  final VoidCallback onThemeToggle;
  LoginPage({super.key, required this.onThemeToggle});
  final _email = TextEditingController();
  final _pass = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, actions: [
        IconButton(icon: const Icon(Icons.brightness_6), onPressed: onThemeToggle),
      ]),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // NUEVO: Icono de candado en el nuevo cian
            const Icon(Icons.lock_person, size: 100, color: customPrimaryTeal),
            const Text('Acceso Los Compadres', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 50),
            TextField(controller: _email, decoration: const InputDecoration(labelText: 'Correo', border: OutlineInputBorder())),
            const SizedBox(height: 15),
            TextField(controller: _pass, obscureText: true, decoration: const InputDecoration(labelText: 'Contraseña', border: OutlineInputBorder())),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                // NUEVO: Botón de entrar en el nuevo cian
                onPressed: () => FirebaseAuth.instance.signInWithEmailAndPassword(email: _email.text.trim(), password: _pass.text.trim()),
                child: const Text('ENTRAR', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}