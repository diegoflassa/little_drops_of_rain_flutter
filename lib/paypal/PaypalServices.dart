import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert' as convert;
import 'package:http_auth/http_auth.dart';

class PaypalServices {

  String domain = 'https://api.sandbox.paypal.com'; // for sandbox mode
  //String domain = 'https://api.paypal.com'; // for production mode

  // change clientId and secret with your own, provided by paypal
  String clientId = 'Ab4vS4vmfQFgUuQMH49F9Uy3L1FdNHtfGrASCyjNijm_EkHWCFM96ex0la-YFbwavw41R3rTKU3k_Bbm';
  String secret = 'EDjvPfYgTYqdYWR2BfOiBW4dz_jeeuadqH7Z98pZMDvY33PcViiooqYFWVPFSGbfKBfNOb3LnroSI1hv';

  // for getting the access token from Paypal
  Future<String?> getAccessToken() async {
    try {
      var client = BasicAuthClient(clientId, secret);
      var response = await client.post(Uri.parse('$domain/v1/oauth2/token?grant_type=client_credentials'));
      if (response.statusCode == 200) {
        final dynamic body = convert.jsonDecode(response.body);
        return body['access_token'] as String;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // for creating the payment request with Paypal
  Future<Map<String, String>?> createPaypalPayment(
      String transactions, String accessToken) async {
    try {
      var response = await http.post(Uri.parse('$domain/v1/payments/payment'),
          body: convert.jsonEncode(transactions),
          headers: {
            'content-type': 'application/json',
            'Authorization': 'Bearer ' + accessToken
          });

      final dynamic body = convert.jsonDecode(response.body);
      if (response.statusCode == 201) {
        if (body['links'] != null && (body['links'] as String).isNotEmpty) {
          var links = body!['links'] as List;

          var executeUrl = '';
          var approvalUrl = '';
          final dynamic item = links.firstWhere((dynamic o) => o['rel'] == 'approval_url',
              orElse: () => null);
          if (item != null) {
            approvalUrl = item['href'] as String;
          }
          final dynamic item1 = links.firstWhere((dynamic o) => o['rel'] == 'execute',
              orElse: () => null);
          if (item1 != null) {
            executeUrl = item1['href'] as String;
          }
          return {'executeUrl': executeUrl, 'approvalUrl': approvalUrl};
        }
        return null;
      } else {
        throw Exception(body['message']);
      }
    } catch (e) {
      rethrow;
    }
  }

  // for executing the payment transaction
  Future<String?> executePayment(Uri url, String payerId, String accessToken) async {
    try {
      var response = await http.post(url,
          body: convert.jsonEncode({'payer_id': payerId}),
          headers: {
            'content-type': 'application/json',
            'Authorization': 'Bearer ' + accessToken
          });

      final dynamic body = convert.jsonDecode(response.body);
      if (response.statusCode == 200) {
        return body['id'] as String;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}