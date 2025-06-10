import 'package:ebarbershop_mobile/providers/korisnik_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ebarbershop_mobile/models/review.dart';
import 'package:ebarbershop_mobile/providers/reviews_provider.dart';
import 'package:ebarbershop_mobile/utils/util.dart';
import 'package:intl/intl.dart';

class ReviewsScreen extends StatefulWidget {
  static const String routeName = '/reviews';

  @override
  _ReviewsScreenState createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  late ReviewsProvider _reviewsProvider;
  List<Review> _reviews = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _reviewsProvider = context.read<ReviewsProvider>();
    _loadReviews();
  }

 Future<void> _loadReviews() async {
  try {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _reviewsProvider.get();
    final validReviews = result.result.where((r) => r != null).toList();
    
    final usersProvider = Provider.of<KorisnikProvider>(context, listen: false);
    
    for (var review in validReviews) {
      if (review != null && review.korisnik == null && review.korisnikId != null) {
        try {
          final userData = await usersProvider.getById(review.korisnikId);
          review.korisnik = userData;
        } catch (e) {
          print("Couldn't fetch user data for korisnikId: ${review.korisnikId}");
        }
      }
    }
    
    if (mounted) {
      setState(() {
        _reviews = validReviews.cast<Review>();
        _isLoading = false;
      });
    }
  } catch (e, stackTrace) {
    debugPrint("Puna greška: $e");
    debugPrint("Stack trace: $stackTrace");
    
    if (mounted) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Došlo je do greške pri učitavanju podataka";
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška: ${e.toString()}")),
      );
    }
  }
}

  Future<void> _addReview(String komentar, int ocjena) async {
    try {
      if (Authorization.userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Morate biti prijavljeni da biste dodali recenziju")),
        );
        return;
      }
      
      await _reviewsProvider.insert({
        "komentar": komentar,
        "ocjena": ocjena,
        "datum": DateFormat("yyyy-MM-ddTHH:mm:ss").format(DateTime.now()),
        "korisnikId": Authorization.userId 
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Recenzija uspješno dodana"),
        backgroundColor: Colors.green,),
      );
      
      _loadReviews();
    } catch (e) {
      print("Greška pri dodavanju recenzije: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška pri dodavanju recenzije: ${e.toString()}")),
      );
    }
  }

  void _showAddReviewDialog() {
    if (Authorization.userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Morate biti prijavljeni da biste dodali recenziju")),
      );
      return;
    }
    
    final _komentarController = TextEditingController();
    double _selectedOcjena = 10.0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Dodaj recenziju"),
              content: SingleChildScrollView(
                child: Container(
                  width: 300,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Recenziju dodajete kao: ${Authorization.ime} ${Authorization.prezime}",
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 12),
                      TextField(
                        controller: _komentarController,
                        decoration: InputDecoration(
                          labelText: "Komentar",
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        ),
                        maxLines: 3,
                        maxLength: 200,
                        keyboardType: TextInputType.multiline,
                      ),
                      SizedBox(height: 10),
                      GestureDetector(
                        onHorizontalDragUpdate: (details) {
                          final box = context.findRenderObject() as RenderBox;
                          final localPosition = box.globalToLocal(details.globalPosition);
                          final starWidth = box.size.width / 5;
                          final starIndex = (localPosition.dx / starWidth).clamp(0.0, 4.999);
                          final newRating = (starIndex + 0.5) * 2;
                          setState(() {
                            _selectedOcjena = newRating.clamp(1.0, 10.0);
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedOcjena = (index + 1) * 2.0;
                                });
                              },
                              child: _buildStar(index, _selectedOcjena, size: 40),
                            );
                          }),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Ocjena: ${_selectedOcjena.toInt()}",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Odustani"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_komentarController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Molimo unesite komentar")),
                      );
                      return;
                    }
                    _addReview(_komentarController.text, _selectedOcjena.toInt());
                    Navigator.pop(context);
                  },
                  child: Text("Dodaj"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStar(int index, double rating, {double size = 20}) {
    IconData icon;
    double starValue = (index + 1) * 2.0;
    
    if (rating >= starValue) {
      icon = Icons.star;
    } else if (rating >= starValue - 1.0) {
      icon = Icons.star_half;
    } else {
      icon = Icons.star_border;
    }

    return Icon(
      icon,
      size: size,
      color: Colors.amber,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recenzije'),
      ),
      body: _isLoading 
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _reviews.isEmpty
                  ? Center(child: Text('Nema dostupnih recenzija'))
                  : RefreshIndicator(
                      onRefresh: _loadReviews,
                      child: ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: _reviews.length,
                        itemBuilder: (context, index) {
                          var review = _reviews[index];
                          return _buildReviewItem(review);
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddReviewDialog,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildReviewItem(Review review) {
    String formatDate(String dateString) {
      try {
        final date = DateTime.parse(dateString);
        return DateFormat('dd.MM.yyyy. HH:mm').format(date);
      } catch (e) {
        return dateString;
      }
    }
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    review.korisnik != null 
                      ? '${review.korisnik!.ime} ${review.korisnik!.prezime}'
                      : 'Korisnik ID: ${review.korisnikId}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  formatDate(review.datum),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: List.generate(
                5,
                (index) => _buildStar(index, review.ocjena.toDouble()),
              ),
            ),
            SizedBox(height: 12),
            Text(review.komentar, style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text(
              "Ocjena: ${review.ocjena}",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}