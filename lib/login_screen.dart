import 'package:flutter/cupertino.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:flutter/material.dart';

final storage = new FlutterSecureStorage();

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _loginUser() async {
    final HttpLink httpLink = HttpLink(
      'http://34.125.185.36:9003/graphql/',
    );

    final GraphQLClient client = GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(),
    );

    final MutationOptions options = MutationOptions(
      document: gql('''
        mutation TokenAuth(\$username: String!, \$password: String!) {
          tokenAuth(username: \$username, password: \$password) {
            token
          }
        }
      '''),
      variables: <String, dynamic>{
        'username': _usernameController.text,
        'password': _passwordController.text,
      },
    );

    final QueryResult result = await client.mutate(options);

    if (!result.hasException) {
      final token = result.data?['tokenAuth']?['token'];
      if (token != null) {
        await storage.write(key: 'token', value: token);
        _checkToken(); // Verificar el token guardado en el almacenamiento local
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _showErrorDialog('No se pudo obtener el token. Intente de nuevo.');
      }
    } else {
      _showErrorDialog('Usuario o contraseña incorrectos.');
    }
  }

  void _checkToken() async {
    final String? token = await storage.read(key: 'token');
    if (token != null) {
      print('Token JWT: $token');
    } else {
      print('Token JWT no encontrado en el almacenamiento local.');
    }
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Login'),
      ),
      child: Center(
        child: GlassmorphicContainer(
          width: 300,
          height: 400,
          borderRadius: 20,
          blur: 20,
          alignment: Alignment.center,
          border: 2,
          linearGradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.1)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderGradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.5),
              Colors.white.withOpacity(0.5),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CupertinoTextField(
                  controller: _usernameController,
                  placeholder: 'Username',
                ),
                SizedBox(height: 16),
                CupertinoTextField(
                  controller: _passwordController,
                  placeholder: 'Password',
                  obscureText: true,
                ),
                SizedBox(height: 16),
                CupertinoButton.filled(
                  child: Text('Login'),
                  onPressed: _loginUser,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
