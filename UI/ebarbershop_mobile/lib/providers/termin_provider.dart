import 'dart:convert';
import 'package:ebarbershop_mobile/models/search_result.dart';
import 'package:ebarbershop_mobile/models/termin.dart';
import 'package:ebarbershop_mobile/providers/base_provider.dart';
import 'package:ebarbershop_mobile/utils/util.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class TerminProvider extends BaseProvider<Termin> {
  TerminProvider() : super("Termin");

  @override
  Termin fromJson(data) {
    // TODO: implement fromJson
    return Termin.fromJson(data);
  }
  Future<List<Termin>> getByDateAndEmployee(DateTime date, int employeeId) async {
    // Replace this with your actual API call logic
    // Example: Fetch appointments for the given date and employeeId
    final response = await fetchAppointmentsFromApi(date, employeeId);
    return response.map((json) => Termin.fromJson(json)).toList();
  }

  Future<List<dynamic>> fetchAppointmentsFromApi(DateTime date, int employeeId) async {
    // Simulate API call
    // Replace this with actual API call logic
    return [];
  }
}
