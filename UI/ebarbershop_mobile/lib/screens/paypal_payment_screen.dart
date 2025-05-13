import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_paypal/flutter_paypal.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class PaypalPaymentScreen extends StatefulWidget {
  final double totalPrice;
  final List<Map<String, dynamic>> listaProizvoda;
  final int korisnikId;
  final Function onPaymentSuccess;

  const PaypalPaymentScreen({
    Key? key,
    required this.totalPrice,
    required this.listaProizvoda,
    required this.korisnikId,
    required this.onPaymentSuccess,
  }) : super(key: key);

  @override
  State<PaypalPaymentScreen> createState() => _PaypalPaymentScreenState();
}

class _PaypalPaymentScreenState extends State<PaypalPaymentScreen> {
  bool _isLoading = true;
  Timer? _loadingTimer;

  // Helper method to safely set state if component is still mounted
  void _setStateIfMounted(VoidCallback fn) {
    if (mounted) setState(fn);
  }

  @override
  void initState() {
    super.initState();
    
    // Initialize platform-specific WebView implementations
    if (WebViewPlatform.instance == null) {
      if (Platform.isAndroid) {
        WebViewPlatform.instance = AndroidWebViewPlatform();
      } else if (Platform.isIOS) {
        WebViewPlatform.instance = WebKitWebViewPlatform();
      }
    }
    
    _loadingTimer = Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      _setStateIfMounted(() => _isLoading = false);
    });
  }

  @override
  void dispose() {
    _loadingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PayPal Plaćanje"),
      ),
      body: Stack(
        children: [
          UsePaypal(
            sandboxMode: true,
            clientId: "ARcssvsRFCLA8PWBWibfbavITBnMbk_fiXMNswC-a_bT35QubNjwpRx_giINqdBzPftk2dMaGyOCwBJb",
            secretKey: "EJFRMr41sTLuBbDWW7qblSh6mZPC5hyTG4GCTrEmJJoWXYKMWD2zmPGyousmmAtAAO9ixZUMFONo7U6v",
            returnURL: "success.snip.tech",
            cancelURL: "cancel.snip.tech",
            transactions: [
              {
                "amount": {
                  "total": widget.totalPrice.toStringAsFixed(2),
                  "currency": "USD",
                  "details": {
                    "subtotal": widget.totalPrice.toStringAsFixed(2),
                    "shipping": '0',
                    "shipping_discount": 0
                  }
                },
                "description": "eBarbershop narudžba",
                "item_list": {
                  "items": widget.listaProizvoda.map((e) {
                    return {
                      "name": e['naziv'] ?? "Proizvod ${e['proizvodID']}",
                      "quantity": e['kolicina'].toString(),
                      "price": (e['cijena'] ?? (widget.totalPrice / widget.listaProizvoda.length)).toStringAsFixed(2),
                      "currency": "USD"
                    };
                  }).toList()
                }
              }
            ],
            note: "Hvala vam na kupnji u eBarbershop!",
            onSuccess: (Map params) async {
              if (!mounted) return;
              widget.onPaymentSuccess();
              Navigator.of(context).pop();
            },
            onError: (error) async {
              if (!mounted) return;
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Greška pri plaćanju: $error")),
              );
            },
            onCancel: (params) async {
              if (!mounted) return;
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Plaćanje otkazano")),
              );
            },
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}