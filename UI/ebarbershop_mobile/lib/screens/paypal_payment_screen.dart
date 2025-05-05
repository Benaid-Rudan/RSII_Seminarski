import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_paypal/flutter_paypal.dart';

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

  @override
  void initState() {
    super.initState();
  }
  Timer? _timer;
  @override
  void dispose() {
      _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PayPal Plaćanje"),
      ),
      body: UsePaypal(
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
        onSuccess: (Map params) {
          if (mounted) {
            widget.onPaymentSuccess();
            Navigator.of(context).pop();
          }
        },
        onError: (error) {
          if (mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Greška pri plaćanju: $error")),
            );
          }
        },
        onCancel: (params) {
          if (mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Plaćanje otkazano")),
            );
          }
        },
      ),
    );
  }
}
  
