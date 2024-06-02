import 'package:flutter/cupertino.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:flutter/material.dart';

final storage = new FlutterSecureStorage();

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _signupUser() async {
    final HttpLink httpLink = HttpLink(
      'http://34.125.185.36:9003/graphql/',
    );

    final GraphQLClient client = GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(),
    );

    final MutationOptions options = MutationOptions(
      document: gql('''
        mutation CreateUser(\$username: String!, \$email: String!, \$password: String!) {
          createUser(username: \$username, email: \$email, password: \$password) {
            user {
              username
              email
            }
          }
        }
      '''),
      variables: <String, dynamic>{
        'username': _usernameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
      },
    );

    final QueryResult result = await client.mutate(options);

    if (!result.hasException) {
      // Usuario creado exitosamente
      // Puedes redirigir a la pantalla de inicio de sesión o realizar alguna acción adicional
      print('Usuario creado exitosamente');
    } else {
      // Mostrar mensaje de error
      _showErrorDialog('No se pudo crear la cuenta. Intente de nuevo.');
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
        middle: Text('Crear cuenta'),
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
                  controller: _emailController,
                  placeholder: 'Email',
                ),
                SizedBox(height: 16),
                CupertinoTextField(
                  controller: _passwordController,
                  placeholder: 'Password',
                  obscureText: true,
                ),
                SizedBox(height: 16),
                CupertinoButton.filled(
                  child: Text('Crear cuenta'),
                  onPressed: _signupUser,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
