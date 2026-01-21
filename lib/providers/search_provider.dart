// lib/providers/search_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';

// Search Query Provider
final searchQueryProvider = StateProvider<String>((ref) => '');

// Search State
class SearchState {
  final List<Product> results;
  final bool isLoading;
  final bool hasMore;
  final int currentPage;
  final String? error;
  final String lastQuery;

  const SearchState({
    this.results = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.error,
    this.lastQuery = '',
  });

  SearchState copyWith({
    List<Product>? results,
    bool? isLoading,
    bool? hasMore,
    int? currentPage,
    String? error,
    String? lastQuery,
  }) {
    return SearchState(
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      error: error,
      lastQuery: lastQuery ?? this.lastQuery,
    );
  }
}

// Search Notifier
class SearchNotifier extends StateNotifier<SearchState> {
  final ApiService _apiService;

  SearchNotifier(this._apiService) : super(const SearchState());

  Future<void> search(String query) async {
    if (query.isEmpty) {
      state = const SearchState();
      return;
    }

    // Reset for new search
    state = SearchState(isLoading: true, lastQuery: query);

    try {
      final results = await _apiService.searchProducts(query, page: 1);
      state = state.copyWith(
        results: results,
        isLoading: false,
        currentPage: 1,
        hasMore: results.length >= 20,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore || state.lastQuery.isEmpty) return;

    state = state.copyWith(isLoading: true);

    try {
      final nextPage = state.currentPage + 1;
      final results =
          await _apiService.searchProducts(state.lastQuery, page: nextPage);

      state = state.copyWith(
        results: [...state.results, ...results],
        isLoading: false,
        currentPage: nextPage,
        hasMore: results.length >= 20,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  void clear() {
    state = const SearchState();
  }
}

// Search Provider
final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>(
  (ref) => SearchNotifier(ApiService()),
);

// Search Results Provider (convenience)
final searchResultsProvider = Provider<List<Product>>((ref) {
  return ref.watch(searchProvider).results;
});

// Is Searching Provider
final isSearchingProvider = Provider<bool>((ref) {
  return ref.watch(searchProvider).isLoading;
});
