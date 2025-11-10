import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/profile_summary.dart';
import '../utils/constants.dart';
import 'auth_service.dart';

class ProfileService with ChangeNotifier {
  final http.Client _client = http.Client();

  AuthService? _auth;
  ProfileSummary? _summary;
  bool _isLoading = false;
  String? _tokenFp; // huella del token

  ProfileSummary? get summary => _summary;
  bool get isLoading => _isLoading;

  void attachAuth(AuthService auth) {
    _auth = auth;
    final newFp = auth.token == null ? null : auth.token!.substring(0, 16);
    if (_tokenFp != newFp) {
      _tokenFp = newFp;
      _summary = null;       // limpia datos del usuario anterior
      _isLoading = false;
      notifyListeners();
    }
  }

  Map<String, String> _headers(String token) => {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Cache-Control': 'no-cache',
      };

  Future<void> fetch() async {
    if (_isLoading) return;
    final tokenSnap = _auth?.token;
    if (tokenSnap == null || tokenSnap.isEmpty) return;

    _isLoading = true;
    notifyListeners();
    try {
      final uri = Uri.parse('${Constants.baseUrl}${Constants.apiV1}/evaluations/me');
      final res = await _client.get(uri, headers: _headers(tokenSnap));

      // Si cambió el token mientras llegaba la respuesta, descártala
      if (_auth?.token != tokenSnap) return;

      if (res.statusCode == 200 && res.body.isNotEmpty) {
        final data = json.decode(res.body) as Map<String, dynamic>;
        _summary = ProfileSummary.fromJson(data);
      } else {
        _summary = null;
      }
    } catch (_) {
      if (_auth?.token == tokenSnap) _summary = null;
    } finally {
      if (_auth?.token == tokenSnap) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void clear() {
    _summary = null;
    _isLoading = false;
    notifyListeners();
  }
}