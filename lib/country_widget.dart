import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();

class CountryWidget extends StatelessWidget {
  final int id;
  final String name;
  final String capital;
  final String postedBy;
  final int votes;

  CountryWidget({
    required this.id,
    required this.name,
    required this.capital,
    required this.postedBy,
    required this.votes,
  });

  @override
  Widget build(BuildContext context) {
    final HttpLink httpLink = HttpLink('http://34.125.185.36:9003/graphql/');

    final AuthLink authLink = AuthLink(
      getToken: () async => 'JWT ${await storage.read(key: 'token')}',
    );

    final Link link = authLink.concat(httpLink);

    final ValueNotifier<GraphQLClient> client = ValueNotifier(
      GraphQLClient(
        link: link,
        cache: GraphQLCache(),
      ),
    );

    return GraphQLProvider(
      client: client,
      child: Mutation(
        options: MutationOptions(
          document: gql('''
            mutation CreateVote(\$countryId: Int!) {
              createVote(countryId: \$countryId) {
                user {
                  id
                  username
                }
                country {
                  id
                  name
                  votes {
                    id
                  }
                  postedBy {
                    username
                  }
                }
              }
            }
          '''),
          onCompleted: (dynamic resultData) {
            print('Voto creado exitosamente');
          },
        ),
        builder: (
          RunMutation runMutation,
          QueryResult? result,
        ) {
          return ListTile(
            title: Text(name),
            subtitle: Text('$capital\n$votes votes | by $postedBy'),
            trailing: InkWell(
              onTap: () {
                runMutation({'countryId': id}, optimisticResult: {'countryId': id});
              },
              child: Text('Like'),
            ),
          );
        },
      ),
    );
  }
}
