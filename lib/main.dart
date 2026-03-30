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
      title: 'Blockera Los Compadres',
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

class InicioPage extends StatefulWidget {
  const InicioPage({super.key});
  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  @override
  Widget build(BuildContext context) {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;

    final DateTime ahora = DateTime.now();
    final DateTime comienzoHoy = DateTime(ahora.year, ahora.month, ahora.day);
    final DateTime finHoy = DateTime(ahora.year, ahora.month, ahora.day, 23, 59, 59);

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('usuarios').doc(uid).get(),
      builder: (context, userSnapshot) {
        String nombreUsuario = "Usuario";
        if (userSnapshot.hasData && userSnapshot.data!.exists) {
          var data = userSnapshot.data!.data() as Map<String, dynamic>;
          nombreUsuario = data['nombre'] ?? "Usuario";
        }

        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('inventario')
              .doc('global')
              .snapshots(),
          builder: (context, stockSnapshot) {
            int stockActual = 0;
            if (stockSnapshot.hasData && stockSnapshot.data!.exists) {
              stockActual = (stockSnapshot.data!['piezas_disponibles'] as num?)?.toInt() ?? 0;
            }

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('ventas')
                  .where('fecha', isGreaterThanOrEqualTo: comienzoHoy)
                  .where('fecha', isLessThanOrEqualTo: finHoy)
                  .snapshots(),
              builder: (context, ventasSnapshot) {
                double ventasHoy = 0;
                int numVentas = 0;
                if (ventasSnapshot.hasData) {
                  numVentas = ventasSnapshot.data!.docs.length;
                  ventasHoy = ventasSnapshot.data!.docs.fold<double>(0.0, (prev, doc) {
                    final value = (doc['total'] as num?)?.toDouble() ?? 0;
                    return prev + value;
                  });
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 30),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Revisar Inventario',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'BIENVENIDO',
                                    style: TextStyle(
                                      fontSize: 42,
                                      fontWeight: FontWeight.w900,
                                      color: Theme.of(context).colorScheme.onSurface,
                                      height: 1.0,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    '¡Hola, $nombreUsuario!',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Blockera Los Compadres',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Image.asset(
                                  'assets/logo.png',
                                  width: 150,
                                  height: 150,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      const SizedBox(height: 20),
                      Text(
                        'RESUMEN DEL DÍA',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDashboardCard(
                              context,
                              title: 'Inventario Global',
                              icon: Icons.inventory_2_outlined,
                              dataValue: '$stockActual',
                              unitValue: 'Blocks',
                              cardColor: customPrimaryTeal.withOpacity(0.1),
                              textColor: Theme.of(context).colorScheme.onSurface,
                              subtitle: 'Stock en tiempo real',
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildDashboardCard(
                              context,
                              title: 'Ventas de hoy',
                              icon: Icons.add_shopping_cart,
                              dataValue: '+\$${ventasHoy.toStringAsFixed(0)}',
                              unitValue: numVentas > 0 ? '$numVentas venta${numVentas > 1 ? 's' : ''}' : 'Sin ventas',
                              cardColor: Colors.green.withOpacity(0.1),
                              textColor: Colors.green,
                              subtitle: 'Total recaudado hoy',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EstadisticasPage(),
                          ),
                        ),
                        child: _buildDashboardCard(
                          context,
                          title: 'Estadísticas y Capital',
                          icon: Icons.bar_chart_rounded,
                          dataValue: 'Ver Todo',
                          unitValue: 'Finanzas',
                          cardColor: Theme.of(context).colorScheme.surfaceVariant,
                          textColor: Theme.of(context).colorScheme.onSurface,
                          subtitle: 'Análisis semanal y capital total',
                        ),
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
                        subtitle: 'Últimas 10 transacciones',
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

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

  // FUNCIÓN PARA EL DIÁLOGO (Actualizada para guardar en el historial)
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
              prefixIcon: Icon(Icons.inventory),
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
                if (cant <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('❌ Ingrese una cantidad válida mayor a 0'),
                    ),
                  );
                  return;
                }
                if (cant > 999999) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('❌ La cantidad máxima es 999,999'),
                    ),
                  );
                  return;
                }
                try {
                  String nombreUsuario = 'Usuario';
                  try {
                    var userDoc = await FirebaseFirestore.instance
                        .collection('usuarios')
                        .doc(FirebaseAuth.instance.currentUser?.uid)
                        .get();
                    if (userDoc.exists) {
                      nombreUsuario = userDoc['nombre'] ?? 'Usuario';
                    }
                  } catch (_) {
                    // Keep default 'Usuario'
                  }

                  await FirebaseFirestore.instance.runTransaction((tx) async {
                    DocumentReference stockRef = FirebaseFirestore.instance
                        .collection('inventario')
                        .doc('global');

                    DocumentSnapshot snap = await tx.get(stockRef);

                    int stockActual =
                        (snap['piezas_disponibles'] as num?)?.toInt() ?? 0;
                    tx.update(stockRef, {
                      'piezas_disponibles': stockActual + cant,
                    });

                    tx.set(
                      FirebaseFirestore.instance
                          .collection('historial_stock')
                          .doc(),
                      {
                        'cantidad': cant,
                        'fecha': FieldValue.serverTimestamp(),
                        'id_usuario': FirebaseAuth.instance.currentUser?.uid,
                        'usuario_nombre': nombreUsuario,
                      },
                    );
                  });

                  if (!context.mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Stock e Historial actualizados'),
                    ),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('❌ Error: $e')));
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
    return Column(
      children: [
        // --- PARTE SUPERIOR: VISUALIZACIÓN DEL STOCK ---
        StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('inventario')
              .doc('global')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 50,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Sin datos de inventario',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }
            var data = snapshot.data!.data() as Map<String, dynamic>;
            int current = (data['piezas_disponibles'] as num?)?.toInt() ?? 0;

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(
                color: customPrimaryTeal.withOpacity(0.1),
                border: Border(
                  bottom: BorderSide(color: Colors.grey.withOpacity(0.2)),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Blocks en Almacén',
                    style: TextStyle(
                      fontSize: 18,
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
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => _mostrarDialogoAgregar(context, current),
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('AÑADIR BLOCKS'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: customPrimaryTeal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        // --- PARTE INFERIOR: HISTORIAL DE ENTRADAS ---
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              const Icon(Icons.history, size: 20, color: Colors.grey),
              const SizedBox(width: 10),
              const Text(
                'HISTORIAL DE ENTRADAS',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('historial_stock')
                .orderBy('fecha', descending: true)
                .limit(15) // Mostramos las últimas 15 entradas
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return const Center(child: CircularProgressIndicator());
              if (snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text('No hay registros de entradas todavía.'),
                );
              }

              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                itemBuilder: (context, index) {
                  var v = snapshot.data!.docs[index];
                  String fecha = "Pendiente...";
                  if (v['fecha'] != null && v['fecha'] is Timestamp) {
                    fecha = DateFormat(
                      'dd/MM/yyyy • HH:mm',
                    ).format((v['fecha'] as Timestamp).toDate());
                  }

                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Icon(Icons.arrow_upward, color: Colors.white),
                      ),
                      title: Text(
                        '+ ${v['cantidad']} piezas',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Text(
                        'Fecha: $fecha\nRegistró: ${v['usuario_nombre']}',
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
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
              labelText: 'Nombre del Cliente',
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
                      int cant = int.tryParse(_cantidadController.text) ?? 0;
                      if (cant <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('❌ La cantidad debe ser mayor a 0'),
                          ),
                        );
                        return;
                      }
                      if (cant > 999999) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('❌ La cantidad máxima es 999,999'),
                          ),
                        );
                        return;
                      }
                      String cliente = _clienteController.text.trim();
                      if (cliente.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('❌ Ingrese el nombre del cliente'),
                          ),
                        );
                        return;
                      }
                      if (cliente.length > 100) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              '❌ El nombre del cliente es muy largo (máx. 100 caracteres)',
                            ),
                          ),
                        );
                        return;
                      }
                      setState(() => _cargando = true);
                      try {
                        await FirebaseFirestore.instance.runTransaction((
                          tx,
                        ) async {
                          DocumentReference stockRef = FirebaseFirestore
                              .instance
                              .collection('inventario')
                              .doc('global');
                          DocumentSnapshot snap = await tx.get(stockRef);

                          int stockActual =
                              (snap['piezas_disponibles'] as num?)?.toInt() ??
                              0;
                          if (stockActual < cant) {
                            throw Exception('STOCK_INSUFFICIENT');
                          }

                          tx.update(stockRef, {
                            'piezas_disponibles': stockActual - cant,
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
                        String mensaje =
                            e.toString().contains('STOCK_INSUFFICIENT')
                            ? '❌ Stock insuficiente. No hay suficientes blocks disponibles.'
                            : '❌ Error al registrar la venta';
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(mensaje)));
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
  late DateTime _selectedDate;
  late DateTime _visibleMonth;
  bool _isCalendarExpanded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedDate = DateTime.now();
    _visibleMonth = DateTime.now();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  DateTime get _startOfSelectedDay => DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
  DateTime get _endOfSelectedDay => DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 23, 59, 59);

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('ventas')
          .where('fecha', isGreaterThanOrEqualTo: _startOfSelectedDay)
          .where('fecha', isLessThanOrEqualTo: _endOfSelectedDay)
          .orderBy('fecha', descending: true)
          .snapshots(),
      builder: (context, ventasSnapshot) {
          return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('gastos')
              .where('fecha', isGreaterThanOrEqualTo: _startOfSelectedDay)
              .where('fecha', isLessThanOrEqualTo: _endOfSelectedDay)
              .orderBy('fecha', descending: true)
              .snapshots(),
          builder: (context, gastosSnapshot) {
            if (!ventasSnapshot.hasData || !gastosSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            double totalVentas = ventasSnapshot.data!.docs.fold<double>(0.0, (prev, doc) {
              final value = (doc['total'] as num?)?.toDouble();
              return prev + (value ?? 0.0);
            });
            double totalGastos = gastosSnapshot.data!.docs.fold<double>(0.0, (prev, doc) {
              final value = (doc['monto'] as num?)?.toDouble();
              return prev + (value ?? 0.0);
            });
            double balanceNeto = totalVentas - totalGastos;

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'RESUMEN FINANCIERO',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedDate = DateTime.now();
                            _visibleMonth = DateTime.now();
                            _isCalendarExpanded = false;
                          });
                        },
                        icon: const Icon(Icons.today, size: 16),
                        label: const Text('HOY'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => setState(() => _isCalendarExpanded = !_isCalendarExpanded),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.calendar_today, size: 18, color: Theme.of(context).colorScheme.primary),
                              const SizedBox(width: 8),
                              Text(
                                DateFormat('d MMMM yyyy').format(_selectedDate).toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            _isCalendarExpanded ? Icons.expand_less : Icons.expand_more,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: Column(
                      children: [
                        const SizedBox(height: 10),
                        _buildMiniCalendar(context),
                      ],
                    ),
                    crossFadeState: _isCalendarExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 200),
                  ),
                  const SizedBox(height: 15),
                  _buildCardBalance(context, balanceNeto),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _buildSmallStat(context, 'Ingresos', totalVentas, Colors.green, Icons.arrow_upward),
                      const SizedBox(width: 15),
                      _buildSmallStat(context, 'Egresos', totalGastos, Colors.red, Icons.arrow_downward),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TabBar(
                    controller: _tabController,
                    labelColor: Theme.of(context).colorScheme.primary,
                    unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
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

  // --- MÉTODOS HELPER (Se mantienen con tu diseño) ---

  Widget _buildVentasList(List<QueryDocumentSnapshot> ventas) {
    if (ventas.isEmpty) {
      return Center(
        child: Text('No hay ventas hoy', style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      itemCount: ventas.length,
      itemBuilder: (context, index) {
        var v = ventas[index];
        // Cambiamos a formato de hora porque la fecha ya sabemos que es hoy
        String hora = "S/F";
        if (v['fecha'] != null) {
          hora = DateFormat('HH:mm').format((v['fecha'] as Timestamp).toDate());
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
          subtitle: Text('${v['cantidad']} piezas • $hora'),
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
        child: Text('No hay gastos hoy', style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      itemCount: gastos.length,
      itemBuilder: (context, index) {
        var g = gastos[index];
        String hora = "S/F";
        if (g['fecha'] != null) {
          hora = DateFormat('HH:mm').format((g['fecha'] as Timestamp).toDate());
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
          subtitle: Text('Hora: $hora'),
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
        color: customPrimaryTeal, // Usando tu color Teal
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: customPrimaryTeal.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BALANCE NETO DE HOY',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '\$${monto.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
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

  Widget _buildMiniCalendar(BuildContext context) {
    final List<String> weekDays = ['Do', 'Lu', 'Ma', 'Mi', 'Ju', 'Vi', 'Sa'];
    final DateTime now = DateTime.now();
    final DateTime firstDayOfMonth = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final int daysInMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    final int startWeekday = firstDayOfMonth.weekday % 7;
    final bool isCurrentMonth = _visibleMonth.year == now.year && _visibleMonth.month == now.month;
    final bool canGoNext = !isCurrentMonth;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 24),
                onPressed: () {
                  setState(() {
                    _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1, 1);
                  });
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              Text(
                DateFormat('MMMM yyyy').format(_visibleMonth).toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right, size: 24, color: canGoNext ? null : Colors.grey),
                onPressed: canGoNext
                    ? () {
                        setState(() {
                          _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 1);
                        });
                      }
                    : null,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDays
                .map((day) => SizedBox(
                      width: 36,
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 4),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: startWeekday + daysInMonth,
            itemBuilder: (context, index) {
              if (index < startWeekday) {
                return const SizedBox.shrink();
              }
              final int day = index - startWeekday + 1;
              final DateTime date = DateTime(_visibleMonth.year, _visibleMonth.month, day);
              final bool isToday = date.year == now.year && date.month == now.month && date.day == now.day;
              final bool isSelected = date.year == _selectedDate.year &&
                  date.month == _selectedDate.month &&
                  date.day == _selectedDate.day;
              final bool isFuture = date.isAfter(DateTime(now.year, now.month, now.day));

              return GestureDetector(
                onTap: isFuture
                    ? null
                    : () {
                        setState(() {
                          _selectedDate = date;
                          _visibleMonth = DateTime(date.year, date.month, 1);
                        });
                      },
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected ? customPrimaryTeal : (isToday ? customPrimaryTeal.withOpacity(0.1) : null),
                    borderRadius: BorderRadius.circular(8),
                    border: isToday && !isSelected
                        ? Border.all(color: customPrimaryTeal, width: 1.5)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '$day',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isFuture
                            ? Colors.grey.withOpacity(0.4)
                            : (isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  final VoidCallback onThemeToggle;
  const LoginPage({super.key, required this.onThemeToggle});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _e = TextEditingController(); // Usuario/Alias
  final _p = TextEditingController(); // Contraseña
  bool _isObscured = true; // Controla la visibilidad

  @override
  void dispose() {
    _e.dispose();
    _p.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(35),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // LOGO DE LA LADRILLERA
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Image.asset(
                    'assets/logo2.png',
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.business,
                      size: 100,
                      color: Colors.grey,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  'LOS COMPADRES',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const Text(
                  'Acceso Administrativo',
                  style: TextStyle(color: Colors.grey, letterSpacing: 1.5),
                ),

                const SizedBox(height: 40),

                // CAMPO DE USUARIO
                TextField(
                  controller: _e,
                  decoration: InputDecoration(
                    labelText: 'Usuario / Alias',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // CAMPO DE CONTRASEÑA CON BOTÓN DE VISIBILIDAD
                TextField(
                  controller: _p,
                  obscureText: _isObscured, // Usa el estado de la variable
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    // AQUÍ ESTÁ EL BOTÓN DEL OJO
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isObscured ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscured = !_isObscured; // Cambia el estado
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),

                const SizedBox(height: 35),

                // BOTÓN DE ACCESO
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: customPrimaryTeal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () async {
                      String rawInput = _e.text.trim();
                      String password = _p.text.trim();

                      if (rawInput.isEmpty || password.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Ingresa tus credenciales'),
                          ),
                        );
                        return;
                      }

                      String correoFinal = rawInput.contains('@')
                          ? rawInput
                          : '$rawInput@compadres.com';

                      try {
                        await FirebaseAuth.instance.signInWithEmailAndPassword(
                          email: correoFinal,
                          password: password,
                        );
                      } on FirebaseAuthException catch (e) {
                        if (!context.mounted) return;
                        String mensaje;
                        switch (e.code) {
                          case 'user-not-found':
                            mensaje = 'Usuario no encontrado';
                            break;
                          case 'wrong-password':
                            mensaje = 'Contraseña incorrecta';
                            break;
                          case 'user-disabled':
                            mensaje = 'Cuenta deshabilitada';
                            break;
                          case 'invalid-email':
                            mensaje = 'Correo electrónico inválido';
                            break;
                          case 'too-many-requests':
                            mensaje = 'Demasiados intentos. Intenta más tarde';
                            break;
                          case 'network-request-failed':
                            mensaje = 'Error de conexión. Verifica tu internet';
                            break;
                          default:
                            mensaje =
                                'Error de acceso. Verifica tus credenciales';
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('❌ $mensaje'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('❌ Error inesperado'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'ENTRAR AL SISTEMA',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                IconButton(
                  onPressed: widget.onThemeToggle,
                  icon: const Icon(
                    Icons.brightness_6_outlined,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
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
            keyboardType: TextInputType.number,
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
              labelText: 'Descripción (ej. Pago de cemento, tepojal, etc.)',
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
                      if (monto > 9999999) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('❌ El monto máximo es 9,999,999'),
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
                      if (desc.length > 200) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              '❌ La descripción es muy larga (máx. 200 caracteres)',
                            ),
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

class EstadisticasPage extends StatelessWidget {
  const EstadisticasPage({super.key});

  @override
  Widget build(BuildContext context) {
    // LÓGICA DE SEMANA ACTUAL (Lunes a Domingo)
    final ahora = DateTime.now();
    final inicioSemana = ahora.subtract(Duration(days: ahora.weekday - 1));
    final comienzoSemana = DateTime(
      inicioSemana.year,
      inicioSemana.month,
      inicioSemana.day,
    );
    final finSemana = comienzoSemana.add(
      const Duration(days: 6, hours: 23, minutes: 59),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Análisis de Negocio')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('ventas').snapshots(),
        builder: (context, ventasSnap) {
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('gastos').snapshots(),
            builder: (context, gastosSnap) {
              if (!ventasSnap.hasData || !gastosSnap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              // --- CÁLCULO DE CAPITAL TOTAL (Toda la historia) ---
              double ingresosHistoricos = ventasSnap.data!.docs.fold(
                0,
                (p, d) => p + (d['total'] ?? 0),
              );
              double gastosHistoricos = gastosSnap.data!.docs.fold(
                0,
                (p, d) => p + (d['monto'] ?? 0),
              );
              double capitalTotal = ingresosHistoricos - gastosHistoricos;

              // --- CÁLCULO SEMANAL ---
              double ingresosSemana = 0;
              for (var doc in ventasSnap.data!.docs) {
                if (doc['fecha'] != null && doc['fecha'] is Timestamp) {
                  DateTime fecha = (doc['fecha'] as Timestamp).toDate();
                  if (fecha.isAfter(comienzoSemana) &&
                      fecha.isBefore(finSemana)) {
                    final value = (doc['total'] as num?)?.toDouble() ?? 0;
                    ingresosSemana += value;
                  }
                }
              }

              double gastosSemana = 0;
              for (var doc in gastosSnap.data!.docs) {
                if (doc['fecha'] != null && doc['fecha'] is Timestamp) {
                  DateTime fecha = (doc['fecha'] as Timestamp).toDate();
                  if (fecha.isAfter(comienzoSemana) &&
                      fecha.isBefore(finSemana)) {
                    final value = (doc['monto'] as num?)?.toDouble() ?? 0;
                    gastosSemana += value;
                  }
                }
              }

              double totalSemanal = ingresosSemana - gastosSemana;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(context, 'BALANCE GLOBAL'),
                    const SizedBox(height: 15),
                    _buildMainCard(
                      context,
                      'Capital Total Actual',
                      capitalTotal,
                      Icons.account_balance_wallet,
                    ),

                    const SizedBox(height: 30),
                    _buildSectionTitle(context, 'RENDIMIENTO SEMANAL'),
                    Text(
                      '${DateFormat('d MMM').format(comienzoSemana)} - ${DateFormat('d MMM').format(finSemana)}',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),

                    const SizedBox(height: 15),
                    _buildStatRow(
                      context,
                      'Ingresos Semanales',
                      ingresosSemana,
                      Colors.green,
                      Icons.trending_up,
                    ),
                    const SizedBox(height: 10),
                    _buildStatRow(
                      context,
                      'Gastos Semanales',
                      gastosSemana,
                      Colors.red,
                      Icons.trending_down,
                    ),
                    const SizedBox(height: 10),
                    _buildStatRow(
                      context,
                      'Total Semanal',
                      totalSemanal,
                      totalSemanal >= 0 ? Colors.green : Colors.red,
                      Icons.pie_chart_outline,
                    ),

                    const SizedBox(height: 30),
                    _buildInfoCard(context),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // --- WIDGETS DE APOYO (UI) ---

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildMainCard(
    BuildContext context,
    String label,
    double monto,
    IconData icon,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [customPrimaryTeal, customPrimaryTeal.withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: customPrimaryTeal.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 40),
          const SizedBox(height: 15),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          Text(
            '\$${monto.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    String label,
    double monto,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 15),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
          Text(
            '\$${monto.toStringAsFixed(2)}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Estas estadísticas se calculan en tiempo real basándose en todos los registros de la base de datos.',
              style: TextStyle(fontSize: 12, color: Colors.blueGrey),
            ),
          ),
        ],
      ),
    );
  }
}
