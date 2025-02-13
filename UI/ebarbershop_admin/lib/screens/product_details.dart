import 'package:ebarbershop_admin/models/product.dart';
import 'package:ebarbershop_admin/models/search_result.dart';
import 'package:ebarbershop_admin/models/vrsta_proizvoda.dart';
import 'package:ebarbershop_admin/providers/product_provider.dart';
import 'package:ebarbershop_admin/providers/vrsta_proizvoda.dart';
import 'package:ebarbershop_admin/widgets/master_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';

class ProductDetailsScreen extends StatefulWidget {
  Product? product;
  ProductDetailsScreen({super.key, this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initalValue = {};
  late VrstaProizvodaProvider _vrstaProizvodaProvider;
  late ProductProvider _productProvider;

  SearchResult<VrstaProizvoda>? vrstaProizvodaResult;
  bool isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("Initial zalihe: ${widget.product?.zalihe}");
    _initalValue = {
      'naziv': widget.product?.naziv,
      'opis': widget.product?.opis,
      'slika': widget.product?.slika,
      'cijena': widget.product?.cijena?.toString(),
      'zalihe': widget.product?.zalihe?.toString(),
      'vrstaProizvodaId':
          widget.product?.vrstaProizvodaId?.toString(), // Convert int to String
    };

    _vrstaProizvodaProvider = context.read<VrstaProizvodaProvider>();
    _productProvider = context.read<ProductProvider>();

    initForm();
  }

  Future initForm() async {
    vrstaProizvodaResult = await _vrstaProizvodaProvider.get();
    print(vrstaProizvodaResult);
    setState(() {
      isLoading = false;
    });
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    // if (widget.product != null) {
    //   setState(() {
    //     _formKey.currentState?.patchValue({
    //       'naziv': widget.product?.naziv ?? "product details",
    //     });
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      // ignore: sort_child_properties_last
      child: Column(
        children: [
          isLoading ? Container() : _buildForm(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: EdgeInsets.all(10),
                child: ElevatedButton(
                    onPressed: () async {
                      _formKey.currentState?.saveAndValidate();
                      print(_formKey.currentState?.value);
                      print(_formKey.currentState?.value['naziv']);

                      try {
                        if (widget.product == null) {
                          await _productProvider
                              .insert(_formKey.currentState?.value);
                        } else {
                          if (widget.product!.proizvodId != null) {
                            await _productProvider.update(
                              widget.product!.proizvodId!,
                              _formKey.currentState!.value,
                            );
                          }
                        }
                      } on Exception catch (e) {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                                  title: Text("Error"),
                                  content: Text(e.toString()),
                                  actions: [
                                    TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text("OK"))
                                  ],
                                ));
                      }
                    },
                    child: Text("Sačuvaj")),
              ),
            ],
          )
        ],
      ),
      title: this.widget.product?.naziv ?? "Product details",
    );
  }

  FormBuilder _buildForm() {
    return FormBuilder(
      key: _formKey,
      initialValue: _initalValue,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: FormBuilderTextField(
                  name: "naziv",
                  decoration: InputDecoration(labelText: "Naziv"),
                ),
              ),
              SizedBox(
                width: 10,
              ), // Dodaje razmak između polja
              Expanded(
                child: FormBuilderTextField(
                  name: "opis",
                  decoration: InputDecoration(labelText: "Opis"),
                ),
              ),
              SizedBox(
                width: 10,
              ), // Dodaje razmak između polja
              Expanded(
                child: FormBuilderTextField(
                  name: "zalihe",
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: "Zalihe"),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: FormBuilderTextField(
                  name: "cijena",
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: "Cijena"),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: FormBuilderTextField(
                  name: "slika",
                  decoration: InputDecoration(labelText: "Slika"),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: FormBuilderDropdown<String>(
                  name: 'vrstaProizvodaId',
                  decoration: InputDecoration(
                    labelText: 'Vrsta proizvoda',
                    suffix: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _formKey.currentState!.fields['vrstaProizvodaId']
                            ?.reset();
                      },
                    ),
                    hintText: 'Select Vrsta proizvoda',
                  ),
                  items: vrstaProizvodaResult?.result
                          .map((item) => DropdownMenuItem(
                                alignment: AlignmentDirectional.center,
                                value: item.vrstaProizvodaId
                                    .toString(), // Ensure it's a string
                                child: Text(item.naziv ?? ""),
                              ))
                          .toList() ??
                      [],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
