import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/auth_tokens.dart';
import '../models/category.dart';
import '../models/expense.dart';
import 'api_config.dart';
import 'auth_service.dart';
import 'token_storage.dart';

class ApiService {
  final TokenStorage _tokenStorage;
  final AuthService _authService;
  final http.Client _client;
  final Future<void> Function() _onAuthExpired;

  Future<AuthTokens>? _refreshInFlight;

  ApiService({
    required TokenStorage tokenStorage,
    required AuthService authService,
    required Future<void> Function() onAuthExpired,
    http.Client? client,
  })  : _tokenStorage = tokenStorage,
        _authService = authService,
        _onAuthExpired = onAuthExpired,
        _client = client ?? http.Client();

  Future<List<Expense>> fetchExpenses() async {
    final response = await _authorizedRequest(
      (headers) => _client.get(
          Uri.parse('${ApiConfig.baseUrl}/api/transactions'),
          headers: headers),
    );
    if (response.statusCode == 404) return const [];
    if (response.statusCode != 200) {
      throw Exception('Error al obtener movimientos: ${response.statusCode}');
    }
    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((e) => Expense.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Expense> createExpense(ExpenseDraft draft) async {
    final response = await _authorizedRequest(
      (headers) => _client.post(
        Uri.parse('${ApiConfig.baseUrl}/api/transactions'),
        headers: {...headers, 'Content-Type': 'application/json'},
        body: jsonEncode(draft.toJson()),
      ),
    );
    if (response.statusCode != 201) {
      throw Exception(
        'Error al crear movimiento: ${response.statusCode} ${response.body}',
      );
    }
    return Expense.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<List<Category>> fetchCategories({int? transactionTypeId}) async {
    final uri = transactionTypeId != null
        ? Uri.parse('${ApiConfig.baseUrl}/api/categories?transaction_type_id=$transactionTypeId')
        : Uri.parse('${ApiConfig.baseUrl}/api/categories');
    final response = await _authorizedRequest(
      (headers) => _client.get(uri, headers: headers),
    );
    if (response.statusCode == 404) return const [];
    if (response.statusCode != 200) {
      throw Exception('Error al obtener categorías: ${response.statusCode}');
    }
    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((e) => Category.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteExpense(int id) async {
    final response = await _authorizedRequest(
      (headers) => _client.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/transactions/$id'),
        headers: headers,
      ),
    );
    if (response.statusCode != 204) {
      throw Exception('Error al eliminar gasto: ${response.statusCode}');
    }
  }

  Future<http.Response> _authorizedRequest(
    Future<http.Response> Function(Map<String, String> headers) send,
  ) async {
    final access = await _tokenStorage.readAccessToken();
    if (access == null) {
      await _onAuthExpired();
      throw AuthExpiredException('No hay sesión activa');
    }

    var response = await send({'Authorization': 'Bearer $access'});
    if (response.statusCode != 401) {
      return response;
    }

    final AuthTokens newTokens;
    try {
      newTokens = await _refreshTokensSingleFlight();
    } on AuthException {
      await _onAuthExpired();
      rethrow;
    }

    response = await send({'Authorization': 'Bearer ${newTokens.accessToken}'});
    if (response.statusCode == 401) {
      await _onAuthExpired();
      throw AuthExpiredException('Sesión inválida tras refrescar');
    }
    return response;
  }

  Future<AuthTokens> _refreshTokensSingleFlight() {
    final inFlight = _refreshInFlight;
    if (inFlight != null) return inFlight;

    final future = _doRefresh();
    _refreshInFlight = future;
    future.whenComplete(() => _refreshInFlight = null);
    return future;
  }

  Future<AuthTokens> _doRefresh() async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken == null) {
      throw AuthExpiredException('Sin refresh token');
    }
    final tokens = await _authService.refresh(refreshToken);
    await _tokenStorage.saveTokens(tokens);
    return tokens;
  }
}
