import 'dart:core';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'PaypalServices.dart';

class PaypalPayment extends StatefulWidget {
  final Function? onFinish;

  PaypalPayment({Key? key, this.onFinish}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return PaypalPaymentState();
  }
}

class PaypalPaymentState extends State<PaypalPayment> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? checkoutUrl;
  String? executeUrl;
  String? accessToken;
  PaypalServices services = PaypalServices();

  // you can change default currency according to your need
  Map<String, dynamic> defaultCurrency =<String, dynamic>{'symbol': 'USD ', 'decimalDigits': 2, 'symbolBeforeTheNumber': true, 'currency': 'USD'};

  bool isEnableShipping = false;
  bool isEnableAddress = false;

  String returnURL = 'return.example.com';
  String cancelURL= 'cancel.example.com';


  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      try {
        accessToken = await services.getAccessToken();

        final transactions = getOrderParams();
        final res =
            await services.createPaypalPayment(transactions.toString(), accessToken!);
        if (res != null) {
          setState(() {
            checkoutUrl = res['approvalUrl'];
            executeUrl = res['executeUrl'];
          });
        }
      } catch (e) {
        print('exception: '+e.toString());
        final snackBar = SnackBar(
          content: Text(e.toString()),
          duration: Duration(seconds: 10),
          action: SnackBarAction(
            label: 'Close',
            onPressed: () {
              // Some code to undo the change.
            },
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    });
  }

  // item name, price and quantity
  String itemName = 'iPhone X';
  String itemPrice = '1.99';
  int quantity = 1;

  Map<String, dynamic> getOrderParams() {
    var items = [
      <String, dynamic>{
        'name': itemName,
        'quantity': quantity,
        'price': itemPrice,
        'currency': defaultCurrency['currency']
      }
    ];


    // checkout invoice details
    var totalAmount = '1.99';
    var subTotalAmount = '1.99';
    var shippingCost = '0';
    var shippingDiscountCost = 0;
    var userFirstName = 'Gulshan';
    var userLastName = 'Yadav';
    var addressCity = 'Delhi';
    var addressStreet = 'Mathura Road';
    var addressZipCode = '110014';
    var addressCountry = 'India';
    var addressState = 'Delhi';
    var addressPhoneNumber = '+919990119091';

    var temp = <String, dynamic>{
      'intent': 'sale',
      'payer': {'payment_method': 'paypal'},
      'transactions': [
        {
          'amount': <String, dynamic>{
            'total': totalAmount,
            'currency': defaultCurrency['currency'],
            'details': {
              'subtotal': subTotalAmount,
              'shipping': shippingCost,
              'shipping_discount':
                  ((-1.0) * shippingDiscountCost).toString()
            }
          },
          'description': 'The payment transaction description.',
          'payment_options': {
            'allowed_payment_method': 'INSTANT_FUNDING_SOURCE'
          },
          'item_list': {
            'items': items,
            if (isEnableShipping &&
                isEnableAddress)
              'shipping_address': {
                'recipient_name': userFirstName +
                    ' ' +
                    userLastName,
                'line1': addressStreet,
                'line2': '',
                'city': addressCity,
                'country_code': addressCountry,
                'postal_code': addressZipCode,
                'phone': addressPhoneNumber,
                'state': addressState
              },
          }
        }
      ],
      'note_to_payer': 'Contact us for any questions on your order.',
      'redirect_urls': {
        'return_url': returnURL,
        'cancel_url': cancelURL
      }
    };
    return temp;
  }

  @override
  Widget build(BuildContext context) {
    print(checkoutUrl);

    if (checkoutUrl != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).backgroundColor,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.arrow_back_ios),
          ),
        ),
        body: WebView(
          initialUrl: checkoutUrl,
          javascriptMode: JavascriptMode.unrestricted,
          navigationDelegate: (NavigationRequest request) {
            if (request.url.contains(returnURL)) {
              final uri = Uri.parse(request.url);
              final payerID = uri.queryParameters['PayerID'];
              if (payerID != null) {
                services
                    .executePayment(Uri.parse(executeUrl!), payerID, accessToken!)
                    .then((id) {
                      if(widget.onFinish!=null) {
                        widget.onFinish!(id);
                      }
                  Navigator.of(context).pop();
                });
              } else {
                Navigator.of(context).pop();
              }
              Navigator.of(context).pop();
            }
            if (request.url.contains(cancelURL)) {
              Navigator.of(context).pop();
            }
            return NavigationDecision.navigate;
          },
        ),
      );
    } else {
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              }),
          backgroundColor: Colors.black12,
          elevation: 0.0,
        ),
        body: Center(child: Container(child: CircularProgressIndicator())),
      );
    }
  }
}