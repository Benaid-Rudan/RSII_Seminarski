
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
  bool _isLoading = true;
  bool _showPaypal = true;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      if (!_isDisposed && mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _safeSetState(VoidCallback fn) {
    if (!_isDisposed && mounted) {
      setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PayPal Plaćanje"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          if (_showPaypal)
            UsePaypal(
              sandboxMode: true,
              clientId: "Adv3cKi9QFe_LSGXHPSmKUJXI68XVcrZzK2fkIJ4TngVHQp6tBzOF7cumhwhmIPAfyCpSdyfCgY2Xcs0",
               secretKey: "EOzSKNmduSHrwii_D-_9Cp9n-tN0_e1G4IWfEk7mNdKhBZ0RBWcoSZKPZWP3xCuD6iKPOou8iHChd1xY",
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
              _safeSetState(() => _showPaypal = false);
              try {
                await widget.onPaymentSuccess();
                if (!_isDisposed && mounted) {
                  Navigator.of(context).pop(true); 
                }
              } catch (e) {
                if (!_isDisposed && mounted) {
                  Navigator.of(context).pop(false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Greška pri obradi narudžbe: $e")),
                  );
                }
              }
            },
              onError: (error) {
                _safeSetState(() => _showPaypal = false);
                if (!_isDisposed && mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Greška pri plaćanju: $error")),
                  );
                }
              },
              onCancel: (params) {
                _safeSetState(() => _showPaypal = false);
                if (!_isDisposed && mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Plaćanje otkazano")),
                  );
                }
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