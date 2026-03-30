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
      const GastosPage(),
      const FinanzasPage(),
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
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
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
          BottomNavigationBarItem(icon: Icon(Icons.money_off), label: 'Gastos'),
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on),
            label: 'Finanzas',
          ),
        ],
      ),
    );
  }
}

class InicioPage extends StatelessWidget {
  const InicioPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Definimos un esquema de color personalizado para las tarjetas para que resalten
    final cardColorVentas = Colors.green.withOpacity(0.1);
    final cardColorGastos = Colors.red.withOpacity(0.1);
    final textOnCardVentas = Colors.green;
    final textOnCardGastos = Colors.red;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SECCIÓN SUPERIOR: TEXTO Y LOGO INTEGRADOS AL ESTILO CAR APP
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: Row(
              children: [
                // Columna de texto (izquierda)
                Expanded(
                  flex: 2, // Toma más espacio
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Revisar Inventario',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'BIENVENIDO', // Texto principal muy grande y bold
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w900, // Equivale a Black
                          color: Theme.of(context).colorScheme.onSurface,
                          height: 1.0, // Ajuste de altura de línea
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '¡Hola, Gerardo Pérez!', // Saludo personalizado
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Ladrillera Los Compadres',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      // Botón/Contenedor del ID de estudiante
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: customPrimaryTeal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'ID: 186000',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Contenedor de la imagen (derecha) - integrado al diseño
                Expanded(
                  flex: 1, // Toma menos espacio
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Image.asset(
                      'assets/logo.png', // Tu logo exacto
                      width: 150, // Tamaño adecuado
                      height: 150,
                      fit: BoxFit.contain, // Muestra la imagen completa
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(),
          const SizedBox(height: 20),

          // SECCIÓN DE PANALES DE RESUMEN (DASHBOARD)
          Text(
            'RESUMEN DEL DÍA',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 15),

          // Fila de Paneles de estadísticas
          Row(
            children: [
              // Panel 1: Inventario
              Expanded(
                child: _buildDashboardCard(
                  context,
                  title: 'Inventario Global',
                  icon: Icons.inventory_2_outlined,
                  dataValue: '5,000',
                  unitValue: 'Blocks',
                  cardColor: customPrimaryTeal.withOpacity(0.1),
                  textColor: Theme.of(context).colorScheme.onSurface,
                  subtitle: 'Última actualización: Hace 5m',
                ),
              ),
              const SizedBox(width: 15), // Espacio entre paneles
              // Panel 2: Ventas
              Expanded(
                child: _buildDashboardCard(
                  context,
                  title: 'Ventas de hoy',
                  icon: Icons.add_shopping_cart,
                  dataValue: '+ \$12,500', // Marcador de posición
                  unitValue: 'Recaudado',
                  cardColor: cardColorVentas,
                  textColor: textOnCardVentas,
                  subtitle: 'Venta más reciente: \$2,500',
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // Paneles inferiores
          _buildDashboardCard(
            context,
            title: 'Ver Stock Completo',
            icon: Icons.warehouse_outlined,
            dataValue: 'Ver Todo',
            unitValue: 'Inventario',
            cardColor: Theme.of(context).colorScheme.surfaceVariant,
            textColor: Theme.of(context).colorScheme.onSurface,
            subtitle: 'Ubicación: Ladrillera Principal - Bodega 1',
          ),
          const SizedBox(height: 15),
          _buildDashboardCard(
            context,
            title: 'Ver Ventas Recientes',
            icon: Icons.monetization_on_outlined,
            dataValue: 'Ver Historial',
            unitValue: 'Finanzas',
            cardColor: Theme.of(context).colorScheme.surfaceVariant,
            textColor: Theme.of(context).colorScheme.onSurface,
            subtitle: 'Vea las últimas 10 ventas registradas',
          ),
        ],
      ),
    );
  }

  // WIDGET HELPER: Crea una tarjeta de Dashboard reutilizable
  Widget _buildDashboardCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String dataValue,
    required String unitValue,
    required Color cardColor,
    required Color textColor,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: textColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                unitValue,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Icon(icon, size: 16, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            dataValue,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.normal,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          Text(subtitle, style: TextStyle(color: Colors.grey, fontSize: 11)),
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
              Text(
                'Blocks en Almacén',
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '$current',
                style: TextStyle(
                  fontSize: 100,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
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

  bool get _esFormularioValido {
    final cantidad = int.tryParse(_cantidadController.text) ?? 0;
    final cliente = _clienteController.text.trim();
    return cantidad > 0 && cliente.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _clienteController.addListener(_onFormChanged);
    _cantidadController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _clienteController.removeListener(_onFormChanged);
    _cantidadController.removeListener(_onFormChanged);
    _clienteController.dispose();
    _cantidadController.dispose();
    super.dispose();
  }

  void _onFormChanged() {
    setState(() {});
  }

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
              onPressed: _cargando || !_esFormularioValido
                  ? null
                  : () async {
                      if (!_esFormularioValido) return;
                      setState(() => _cargando = true);
                      int cant = int.tryParse(_cantidadController.text) ?? 0;
                      if (cant <= 0) {
                        setState(() => _cargando = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('❌ La cantidad debe ser mayor a 0'),
                          ),
                        );
                        return;
                      }
                      String cliente = _clienteController.text.trim();
                      if (cliente.isEmpty) {
                        setState(() => _cargando = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('❌ Ingrese el nombre del cliente'),
                          ),
                        );
                        return;
                      }
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
                              'cliente': cliente,
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

class FinanzasPage extends StatefulWidget {
  const FinanzasPage({super.key});
  @override
  State<FinanzasPage> createState() => _FinanzasPageState();
}

class _FinanzasPageState extends State<FinanzasPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('ventas').snapshots(),
      builder: (context, ventasSnapshot) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('gastos').snapshots(),
          builder: (context, gastosSnapshot) {
            if (!ventasSnapshot.hasData || !gastosSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            double totalVentas = ventasSnapshot.data!.docs.fold(
              0,
              (prev, doc) => prev + (doc['total'] as num).toDouble(),
            );
            double totalGastos = gastosSnapshot.data!.docs.fold(
              0,
              (prev, doc) => prev + (doc['monto'] as num).toDouble(),
            );
            double balanceNeto = totalVentas - totalGastos;

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RESUMEN FINANCIERO',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildCardBalance(context, balanceNeto),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _buildSmallStat(
                        context,
                        'Ingresos',
                        totalVentas,
                        Colors.green,
                        Icons.arrow_upward,
                      ),
                      const SizedBox(width: 15),
                      _buildSmallStat(
                        context,
                        'Egresos',
                        totalGastos,
                        Colors.red,
                        Icons.arrow_downward,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TabBar(
                    controller: _tabController,
                    labelColor: Theme.of(context).colorScheme.primary,
                    unselectedLabelColor: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant,
                    tabs: const [
                      Tab(text: 'Ventas'),
                      Tab(text: 'Gastos'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildVentasList(ventasSnapshot.data!.docs),
                        _buildGastosList(gastosSnapshot.data!.docs),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildVentasList(List<QueryDocumentSnapshot> ventas) {
    if (ventas.isEmpty) {
      return Center(
        child: Text(
          'No hay ventas registradas',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: ventas.length,
      itemBuilder: (context, index) {
        var v = ventas[index];
        String fecha = "S/F";
        if (v['fecha'] != null) {
          fecha = DateFormat(
            'dd/MM/yyyy',
          ).format((v['fecha'] as Timestamp).toDate());
        }

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 5),
          leading: CircleAvatar(
            backgroundColor: Colors.green.withOpacity(0.1),
            child: const Icon(
              Icons.add_shopping_cart,
              color: Colors.green,
              size: 20,
            ),
          ),
          title: Text(
            v['cliente'] ?? 'Sin nombre',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text('${v['cantidad']} piezas • $fecha'),
          trailing: Text(
            '\$${v['total']}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        );
      },
    );
  }

  Widget _buildGastosList(List<QueryDocumentSnapshot> gastos) {
    if (gastos.isEmpty) {
      return Center(
        child: Text(
          'No hay gastos registrados',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: gastos.length,
      itemBuilder: (context, index) {
        var g = gastos[index];
        String fecha = "S/F";
        if (g['fecha'] != null) {
          fecha = DateFormat(
            'dd/MM/yyyy',
          ).format((g['fecha'] as Timestamp).toDate());
        }

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 5),
          leading: CircleAvatar(
            backgroundColor: Colors.red.withOpacity(0.1),
            child: const Icon(Icons.money_off, color: Colors.red, size: 20),
          ),
          title: Text(
            g['descripcion'] ?? 'Sin descripción',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(fecha),
          trailing: Text(
            '-\$${g['monto'].toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardBalance(BuildContext context, double monto) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BALANCE NETO',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '\$${monto.toStringAsFixed(2)}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 35,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallStat(
    BuildContext context,
    String label,
    double monto,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              '\$${monto.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
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
            Text(
              'Ladrillera Los Compadres',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
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

class GastosPage extends StatefulWidget {
  const GastosPage({super.key});
  @override
  State<GastosPage> createState() => _GastosPageState();
}

class _GastosPageState extends State<GastosPage> {
  final _montoController = TextEditingController();
  final _descController = TextEditingController();
  bool _cargando = false;

  bool get _esFormularioValido {
    final monto = double.tryParse(_montoController.text) ?? 0;
    final desc = _descController.text.trim();
    return monto > 0 && desc.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _montoController.addListener(_onFormChanged);
    _descController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _montoController.removeListener(_onFormChanged);
    _descController.removeListener(_onFormChanged);
    _montoController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _onFormChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'REGISTRAR GASTO',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 25),
          TextField(
            controller: _montoController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Monto (\$)',
              border: const OutlineInputBorder(),
              prefixIcon: Icon(
                Icons.remove_circle,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _descController,
            decoration: const InputDecoration(
              labelText: 'Descripción (ej. Diesel, Leña)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              onPressed: _cargando || !_esFormularioValido
                  ? null
                  : () async {
                      if (!_esFormularioValido) return;
                      double monto =
                          double.tryParse(_montoController.text) ?? 0;
                      if (monto <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('❌ El monto debe ser mayor a 0'),
                          ),
                        );
                        return;
                      }
                      String desc = _descController.text.trim();
                      if (desc.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('❌ Ingrese la descripción del gasto'),
                          ),
                        );
                        return;
                      }
                      setState(() => _cargando = true);
                      try {
                        await FirebaseFirestore.instance
                            .collection('gastos')
                            .add({
                              'monto': monto,
                              'descripcion': desc,
                              'fecha': FieldValue.serverTimestamp(),
                              'id_usuario':
                                  FirebaseAuth.instance.currentUser?.uid,
                            });

                        if (!mounted) return;
                        setState(() => _cargando = false);
                        _montoController.clear();
                        _descController.clear();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Gasto registrado correctamente'),
                          ),
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
                  : const Text('GUARDAR GASTO'),
            ),
          ),
        ],
      ),
    );
  }
}
