import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lcc_web_app/services/menu_api.dart';

void main() {
  test('loads public flavors and hours from the menu API', () async {
    final api = MenuApi(
      client: MockClient((request) async {
        expect(request.url.path, '/api/menu');
        return http.Response(
          jsonEncode({
            'flavors': ['Vanilla', 'Chocolate'],
            'hours': ['Monday: 2pm - 8pm'],
          }),
          200,
        );
      }),
    );

    final menu = await api.getMenu();

    expect(menu.flavors, ['Vanilla', 'Chocolate']);
    expect(menu.hours, ['Monday: 2pm - 8pm']);
  });

  test('sends login credentials and returns the admin token', () async {
    final api = MenuApi(
      client: MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/api/admin/login');
        expect(jsonDecode(request.body), {
          'username': 'admin',
          'password': 'test-password',
        });
        return http.Response(jsonEncode({'token': 'signed-token'}), 200);
      }),
    );

    expect(await api.login('admin', 'test-password'), 'signed-token');
  });

  test('sends flavor edits with the admin bearer token', () async {
    final api = MenuApi(
      client: MockClient((request) async {
        expect(request.method, 'PUT');
        expect(request.url.path, '/api/admin/flavors');
        expect(request.headers['authorization'], 'Bearer signed-token');
        expect(jsonDecode(request.body), {
          'flavors': ['Vanilla'],
        });
        return http.Response(jsonEncode({'ok': true}), 200);
      }),
    );

    await api.updateFlavors('signed-token', ['Vanilla']);
  });
}
