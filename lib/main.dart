import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:universal_io/io.dart';
import 'package:flutter/foundation.dart'; // Importar kIsWeb
import 'login_screen.dart';
import 'signup_screen.dart';
import 'create_country_screen.dart';
import 'country_list_widget.dart';

final storage = FlutterSecureStorage();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Usar el condicional para verificar si no es web
  if (!kIsWeb) {
    final String? token = await storage.read(key: 'token');
    print('Token JWT: $token');
  }

  final HttpLink httpLink = HttpLink(
    'http://34.125.185.36:9003/graphql/',
  );

  final AuthLink authLink = AuthLink(
    getToken: () async => 'Bearer ${await getToken()}',
  );

  final Link link = authLink.concat(httpLink);

  ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(
      link: link,
      cache: GraphQLCache(),
    ),
  );

  runApp(MyApp(client: client, link: link));
}

Future<String?> getToken() async {
  if (kIsWeb) return null;
  return await storage.read(key: 'token');
}

class MyApp extends StatelessWidget {
  final ValueNotifier<GraphQLClient> client;
  final Link link;

  MyApp({required this.client, required this.link});

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: client,
      child: MaterialApp(
        title: 'Flutter Countries',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(client: client),
        routes: {
          '/home': (context) => MyHomePage(client: client),
          '/login': (context) => LoginScreen(),
          '/signup': (context) => SignupScreen(),
          '/createCountry': (context) => CreateCountryScreen(),
          '/countryList': (context) => CountryListWidget(),
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final ValueNotifier<GraphQLClient> client;

  MyHomePage({required this.client});

  @override
  _MyHomePageState createState() => _MyHomePageState(client: client);
}

class _MyHomePageState extends State<MyHomePage> {
  final ValueNotifier<GraphQLClient> client;
  int _selectedIndex = 0;
  static List<Widget> _widgetOptions = <Widget>[
    CountryListWidget(),
    LoginScreen(),
    SignupScreen(),
    CreateCountryScreen(),
  ];

  _MyHomePageState({required this.client});

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('COUNTRY NEWS'),
      ),
      body: Column(
        children: <Widget>[
          SizedBox(height: 20), // Añadir espacio aquí para bajar los botones
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ElevatedButton(
                onPressed: () => _onItemTapped(0),
                child: Text('Paises Publicados'),
              ),
              ElevatedButton(
                onPressed: () => _onItemTapped(1),
                child: Text('Login'),
              ),
              ElevatedButton(
                onPressed: () => _onItemTapped(2),
                child: Text('Registrate'),
              ),
              ElevatedButton(
                onPressed: () => _onItemTapped(3),
                child: Text('Publica Pais'),
              ),
              if (!kIsWeb)
                ElevatedButton(
                  onPressed: () async {
                    await storage.delete(key: 'token');
                    Navigator.pushReplacementNamed(context, '/login'); // Redirigir a la pantalla de Login después del logout
                  },
                  child: Text('Logout'),
                ),
            ],
          ),
          SizedBox(height: 20), // Añadir espacio aquí si se requiere más separación
          Expanded(
            child: GlassmorphicContainer(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              borderRadius: 0,
              linearGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFffffff),
                  Color(0xFFf2f4f7),
                ],
              ),
              border: 0,
              blur: 20,
              alignment: Alignment.center,
              borderGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFffffff),
                  Color(0xFFf2f4f7),
                ],
              ),
              child: _widgetOptions.elementAt(_selectedIndex),
            ),
          ),
        ],
      ),
    );
  }
}
