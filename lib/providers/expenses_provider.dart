import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/category.dart';
import '../models/expense.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';
import 'auth_state.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(
    tokenStorage: ref.watch(tokenStorageProvider),
    authService: ref.watch(authServiceProvider),
    onAuthExpired: () => ref.read(authProvider.notifier).forceLogout(),
  );
});

final expensesProvider = FutureProvider.autoDispose<List<Expense>>((ref) async {
  final authState = ref.watch(authProvider);
  if (authState is! AuthAuthenticated) return const <Expense>[];
  final api = ref.watch(apiServiceProvider);
  return api.fetchExpenses();
});

// transactionTypeId: 1=gastos, 2=ingresos, null=todos
final categoriesProvider =
    FutureProvider.autoDispose.family<List<Category>, int?>((ref, transactionTypeId) async {
  final authState = ref.watch(authProvider);
  if (authState is! AuthAuthenticated) return const <Category>[];
  final api = ref.watch(apiServiceProvider);
  return api.fetchCategories(transactionTypeId: transactionTypeId);
});
