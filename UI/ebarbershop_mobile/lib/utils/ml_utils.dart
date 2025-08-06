import 'package:flutter/material.dart';

class MLUtils {
  
  /// Vraća boju na osnovu confidence score-a
  static Color getConfidenceColor(double confidence) {
    if (confidence >= 0.8) {
      return Colors.green;
    } else if (confidence >= 0.6) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  /// Vraća tekstualni opis confidence score-a
  static String getConfidenceDescription(double confidence) {
    if (confidence >= 0.9) {
      return 'Visoko preporučeno';
    } else if (confidence >= 0.8) {
      return 'Preporučeno';
    } else if (confidence >= 0.6) {
      return 'Umjereno preporučeno';
    } else if (confidence >= 0.4) {
      return 'Slabo preporučeno';
    } else {
      return 'Nije preporučeno';
    }
  }

  /// Vraća boju na osnovu postotak zauzetosti
  static Color getBusynessColor(double busynessPercentage) {
    if (busynessPercentage < 0.3) {
      return Colors.green;
    } else if (busynessPercentage < 0.7) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  /// Vraća tekstualni opis zauzetosti
  static String getBusynessDescription(double busynessPercentage) {
    if (busynessPercentage < 0.3) {
      return 'Slobodno';
    } else if (busynessPercentage < 0.5) {
      return 'Umjereno zauzeto';
    } else if (busynessPercentage < 0.7) {
      return 'Zauzeto';
    } else if (busynessPercentage < 0.9) {
      return 'Veoma zauzeto';
    } else {
      return 'Potpuno zauzeto';
    }
  }

  /// Formatira confidence score kao postotak
  static String formatConfidenceAsPercentage(double confidence) {
    return '${(confidence * 100).round()}%';
  }

  /// Formatira zauzetost kao postotak
  static String formatBusynessAsPercentage(double busyness) {
    return '${(busyness * 100).round()}%';
  }

  /// Provjerava da li je termin u radnom vremenu
  static bool isWorkingHour(int hour) {
    return hour >= 9 && hour <= 17;
  }

  /// Generiše radne sate kao listu stringova
  static List<String> getWorkingHours() {
    return List.generate(9, (index) => '${9 + index}:00');
  }

  /// Vraća ikonu na osnovu confidence score-a
  static IconData getConfidenceIcon(double confidence) {
    if (confidence >= 0.8) {
      return Icons.star;
    } else if (confidence >= 0.6) {
      return Icons.star_half;
    } else {
      return Icons.star_border;
    }
  }

  /// Vraća broj zvjezdica na osnovu confidence score-a
  static int getStarRating(double confidence) {
    if (confidence >= 0.9) return 5;
    if (confidence >= 0.8) return 4;
    if (confidence >= 0.6) return 3;
    if (confidence >= 0.4) return 2;
    return 1;
  }

  /// Kreira widget za prikaz confidence score-a
  static Widget buildConfidenceIndicator(double confidence, {double size = 16}) {
    final color = getConfidenceColor(confidence);
    final percentage = formatConfidenceAsPercentage(confidence);
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            getConfidenceIcon(confidence),
            color: color,
            size: size,
          ),
          SizedBox(width: 4),
          Text(
            percentage,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: size - 2,
            ),
          ),
        ],
      ),
    );
  }

  /// Kreira widget za prikaz zauzetosti
  static Widget buildBusynessIndicator(double busyness, {double size = 16}) {
    final color = getBusynessColor(busyness);
    final percentage = formatBusynessAsPercentage(busyness);
    final description = getBusynessDescription(busyness);
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule,
            color: color,
            size: size,
          ),
          SizedBox(width: 4),
          Text(
            '$percentage - $description',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: size - 2,
            ),
          ),
        ],
      ),
    );
  }

  /// Sortira preporuke po confidence score-u
  static List<T> sortByConfidence<T>(List<T> items, double Function(T) getConfidence) {
    final sortedItems = List<T>.from(items);
    sortedItems.sort((a, b) => getConfidence(b).compareTo(getConfidence(a)));
    return sortedItems;
  }

  /// Filtrira preporuke na osnovu minimalne confidence vrijednosti
  static List<T> filterByMinConfidence<T>(
    List<T> items, 
    double Function(T) getConfidence, 
    double minConfidence
  ) {
    return items.where((item) => getConfidence(item) >= minConfidence).toList();
  }

  /// Provjerava da li je termin u budućnosti
  static bool isFutureAppointment(DateTime appointmentTime) {
    return appointmentTime.isAfter(DateTime.now());
  }

  /// Formatira datum za prikaz
  static String formatDateForDisplay(DateTime date) {
    final weekdays = [
      'Ponedjeljak', 'Utorak', 'Srijeda', 'Četvrtak', 
      'Petak', 'Subota', 'Nedjelja'
    ];
    
    final months = [
      'Januar', 'Februar', 'Mart', 'April', 'Maj', 'Juni',
      'Juli', 'August', 'Septembar', 'Oktobar', 'Novembar', 'Decembar'
    ];
    
    final weekday = weekdays[date.weekday - 1];
    final month = months[date.month - 1];
    
    return '$weekday, ${date.day}. $month ${date.year}.';
  }

  /// Formatira vrijeme za prikaz
  static String formatTimeForDisplay(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// Kreira objašnjenje za preporuku
  static String generateRecommendationExplanation(
    double confidence, 
    String barberName, 
    DateTime appointmentTime
  ) {
    final timeOfDay = appointmentTime.hour < 12 ? 'ujutro' : 
                     appointmentTime.hour < 17 ? 'popodne' : 'navečer';
    
    if (confidence >= 0.9) {
      return 'Odličan izbor! Ovaj termin $timeOfDay kod $barberName je idealan na osnovu vaših prethodnih rezervacija.';
    } else if (confidence >= 0.8) {
      return 'Dobar izbor! Termin $timeOfDay kod $barberName odgovara vašim navikama rezerviranja.';
    } else if (confidence >= 0.6) {
      return 'Umjereno dobra opcija. Termin $timeOfDay kod $barberName može biti prikladan.';
    } else {
      return 'Alternativna opcija za termin $timeOfDay kod $barberName.';
    }
  }
}