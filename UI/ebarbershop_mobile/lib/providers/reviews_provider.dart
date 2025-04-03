import 'dart:convert';
import 'package:ebarbershop_mobile/models/review.dart';
import 'package:ebarbershop_mobile/providers/base_provider.dart';
import 'package:flutter/material.dart';

class ReviewsProvider extends BaseProvider<Review> {
  ReviewsProvider() : super("Recenzija");

  @override
  Review fromJson(data) {
      return Review.fromJson(data);
  }
}
