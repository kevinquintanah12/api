import 'package:flutter/cupertino.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();

class CreateCountryScreen extends StatefulWidget {
  @override
  _CreateCountryScreenState createState() => _CreateCountryScreenState();
}

class _CreateCountryScreenState extends State<CreateCountryScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _capitalController = TextEditingController();
  final TextEditingController _populationController = TextEditingController();
  final TextEditingController _languageController = TextEditingController();

  void _createCountry() async {
    final HttpLink httpLink = HttpLink(
      'http://34.125.185.36:9003/graphql/',
    );

    final AuthLink authLink = AuthLink(
      getToken: () async => 'JWT ${await storage.read(key: 'token')}',
    );

    final Link link = authLink.concat(httpLink);

    final GraphQLClient client = GraphQLClient(
      link: link,
      cache: GraphQLCache(),
    );

    final MutationOptions options = MutationOptions(
      document: gql('''
        mutation CreateCountry(\$name: String!, \$capital: String!, \$population: Int!, \$language: String!) {
          createCountry(name: \$name, capital: \$capital, population: \$population, language: \$language) {
            name
            capital
            population
            language 
            postedBy {
              username
            } 
          }
        }
      '''),
      variables: <String, dynamic>{
        'name': _nameController.text,
        'capital': _capitalController.text,
        'population': int.parse(_populationController.text),
        'language': _languageController.text,
      },
    );

    final QueryResult result = await client.mutate(options);

    if (!result.hasException && result.data != null) {
      final country = result.data?['createCountry'];
      if (country != null) {
        final postedBy = country['postedBy']?['username'];
        print('País creado exitosamente por $postedBy');
        // Puedes mostrar un mensaje de éxito aquí si lo deseas
      } else {
        _showErrorDialog('No se pudo crear el país. Intente de nuevo. Debe tener su sesión iniciada!');
      }
    } else {
      // Mostrar mensaje de error
      _showErrorDialog('No se pudo crear el país. Intente de nuevo. Debe tener su sesión iniciada!');
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
        middle: Text('Crear país'),
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
                  controller: _nameController,
                  placeholder: 'Nombre del país',
                ),
                SizedBox(height: 16),
                CupertinoTextField(
                  controller: _capitalController,
                  placeholder: 'Capital',
                ),
                SizedBox(height: 16),
                CupertinoTextField(
                  controller: _populationController,
                  placeholder: 'Población',
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16),
                CupertinoTextField(
                  controller: _languageController,
                  placeholder: 'Idioma',
                ),
                SizedBox(height: 16),
                CupertinoButton.filled(
                  child: Text('Crear país'),
                  onPressed: _createCountry,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
