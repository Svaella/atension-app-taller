import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/bp_entry.dart';
import 'auth_service.dart';
import '../utils/constants.dart'; // <- ADD

class BPService extends ChangeNotifier {
  BPService({String? baseUrl})
      : baseUrl = baseUrl ?? '${Constants.baseUrl}${Constants.apiV1}'; // <- usa Constants

  final String baseUrl; // p.ej. http://192.168.1.38:8000/api/v1
  AuthService? _auth;
  void attachAuth(AuthService auth) {
    final tokenChanged = _auth?.token != auth.token;
    _auth = auth;
    if (tokenChanged) {
      _items.clear();
      _last = null;
      notifyListeners();
    }
  }

  final List<BPEntry> _items = [];
  BPEntry? _last;
  bool _loading = false;

  List<BPEntry> get items => List.unmodifiable(_items);
  BPEntry? get last => _last;
  bool get loading => _loading;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if ((_auth?.token ?? '').isNotEmpty) 'Authorization': 'Bearer ${_auth!.token}',
      };

  Future<void> fetch({int limit = 7}) async {
    final tokenSnapshot = _auth?.token;
    _loading = true;
    notifyListeners();
    try {
      final listRes = await http.get(Uri.parse('$baseUrl/pressures?skip=0&limit=$limit'), headers: _headers);
      debugPrint('GET /pressures -> ${listRes.statusCode} ${listRes.body}');
      if (_auth?.token != tokenSnapshot) return;

      if (listRes.statusCode == 200) {
        final body = json.decode(listRes.body) as Map<String, dynamic>;
        final list = (body['items'] as List).cast<Map<String, dynamic>>();
        _items
          ..clear()
          ..addAll(list.map(BPEntry.fromJson));
      } else {
        _items.clear();
      }

      final lastRes = await http.get(Uri.parse('$baseUrl/pressures/last'), headers: _headers);
      debugPrint('GET /pressures/last -> ${lastRes.statusCode} ${lastRes.body}');
      if (_auth?.token != tokenSnapshot) return;

      if (lastRes.statusCode == 200 && lastRes.body.isNotEmpty && lastRes.body != 'null') {
        _last = BPEntry.fromJson(json.decode(lastRes.body) as Map<String, dynamic>);
      } else {
        _last = null;
      }
    } catch (e) {
      debugPrint('BPService.fetch error: $e');
      if (_auth?.token == tokenSnapshot) {
        _items.clear();
        _last = null;
      }
    } finally {
      if (_auth?.token == tokenSnapshot) {
        _loading = false;
        notifyListeners();
      }
    }
  }

  Future<bool> add({required int sys, required int dia, required DateTime takenAt}) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/pressures'),
        headers: _headers,
        body: json.encode({
          'systolic': sys,
          'diastolic': dia,
          // Enviar siempre en UTC
          'taken_at': takenAt.toUtc().toIso8601String(),
        }),
      );
      debugPrint('POST /pressures -> ${res.statusCode} ${res.body}');
      if (res.statusCode == 200 || res.statusCode == 201) {
        await fetch();
        return true;
      }
    } catch (e) {
      debugPrint('BPService.add error: $e');
    }
    return false;
  }

  Future<bool> delete(int id) async {
    try {
      final res = await http.delete(Uri.parse('$baseUrl/pressures/$id'), headers: _headers);
      debugPrint('DELETE /pressures/$id -> ${res.statusCode}');
      if (res.statusCode == 204) {
        await fetch();
        return true;
      }
    } catch (e) {
      debugPrint('BPService.delete error: $e');
    }
    return false;
  }
}