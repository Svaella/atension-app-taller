import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/app_rating.dart';
import 'auth_service.dart';
import '../utils/constants.dart';

class RatingService extends ChangeNotifier {
  AuthService? _auth;
  AppRating? _rating;

  final String _ratingsUrl = '${Constants.baseUrl}${Constants.apiV1}/ratings/'; // <-- Añadir slash al final
  final String _myRatingUrl = '${Constants.baseUrl}${Constants.apiV1}/ratings/me';

  RatingService();

  RatingService attachAuth(AuthService auth) {
    _auth = auth;
    if (auth.isAuthenticated && _rating == null) {
      fetchMyRating();
    }
    return this;
  }

  AppRating? get rating => _rating;
  bool get hasRated => _rating != null;
  
  // ✅ CORRECCIÓN: La única condición es si el usuario ya ha valorado o no.
  bool get shouldShowRatingModal => !hasRated;

  Future<void> fetchMyRating() async {
    if (_auth?.token == null) return;

    try {
      final response = await http.get(
        Uri.parse(_myRatingUrl),
        headers: Constants.authHeaders(_auth!.token!),
      );

      if (response.statusCode == 200 && response.body.isNotEmpty && response.body != 'null') {
        final data = json.decode(response.body);
        if (data != null) {
          _rating = AppRating.fromJson(data);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('❌ Error fetching rating: $e');
    }
  }

  Future<bool> submitRating(int rating, String? comment) async {
    if (_auth?.token == null) return false;

    try {
      final response = await http.post(
        Uri.parse(_ratingsUrl),
        headers: Constants.authHeaders(_auth!.token!),
        body: json.encode({
          'rating': rating,
          'comment': comment?.trim().isNotEmpty == true ? comment : null,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        _rating = AppRating.fromJson(data);
        notifyListeners();
        return true;
      } else {
        debugPrint('❌ Failed to submit rating: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error submitting rating: $e');
      return false;
    }
  }

  void reset() {
    _rating = null;
    notifyListeners();
  }
}