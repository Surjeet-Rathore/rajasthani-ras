import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rajasthani_ras/features/favorites/domain/favorites_repository.dart';
import 'package:rajasthani_ras/features/idioms/domain/idiom.dart';
import 'package:rajasthani_ras/features/idioms/domain/idiom_repository.dart';

class IdiomState extends Equatable {
  const IdiomState({
    this.idioms = const [],
    this.favoriteIds = const {},
    this.isLoading = true,
    this.categoryId,
    this.searchQuery = '',
    this.errorMessage,
    this.favoriteError,
  });

  final List<Idiom> idioms;
  final Set<String> favoriteIds;
  final bool isLoading;
  final String? categoryId;
  final String searchQuery;
  final String? errorMessage;
  final String? favoriteError;

  List<Idiom> visibleIdioms({bool favoritesOnly = false}) {
    final normalizedQuery = searchQuery.trim().toLowerCase();
    return idioms
        .where((idiom) {
          if (categoryId != null && idiom.categoryId != categoryId) {
            return false;
          }
          if (favoritesOnly && !favoriteIds.contains(idiom.id)) {
            return false;
          }
          if (normalizedQuery.isEmpty) {
            return true;
          }
          return idiom.rajasthaniText.toLowerCase().contains(normalizedQuery) ||
              idiom.hindiMeaning.toLowerCase().contains(normalizedQuery) ||
              idiom.englishMeaning.toLowerCase().contains(normalizedQuery);
        })
        .toList(growable: false);
  }

  IdiomState copyWith({
    List<Idiom>? idioms,
    Set<String>? favoriteIds,
    bool? isLoading,
    String? categoryId,
    bool clearCategoryId = false,
    String? searchQuery,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? favoriteError,
    bool clearFavoriteError = false,
  }) {
    return IdiomState(
      idioms: idioms ?? this.idioms,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      isLoading: isLoading ?? this.isLoading,
      categoryId: clearCategoryId ? null : categoryId ?? this.categoryId,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      favoriteError: clearFavoriteError
          ? null
          : favoriteError ?? this.favoriteError,
    );
  }

  @override
  List<Object?> get props => [
    idioms,
    favoriteIds,
    isLoading,
    categoryId,
    searchQuery,
    errorMessage,
    favoriteError,
  ];
}

class IdiomCubit extends Cubit<IdiomState> {
  IdiomCubit({required this.idiomRepository, required this.favoritesRepository})
    : super(const IdiomState());

  final IdiomRepository idiomRepository;
  final FavoritesRepository favoritesRepository;
  StreamSubscription<List<Idiom>>? _idiomsSubscription;
  StreamSubscription<Set<String>>? _favoritesSubscription;

  void start() {
    _idiomsSubscription = idiomRepository.watchIdioms().listen(
      (idioms) {
        emit(
          state.copyWith(
            idioms: idioms,
            isLoading: false,
            clearErrorMessage: true,
          ),
        );
      },
      onError: (Object error, StackTrace stackTrace) {
        emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
      },
    );
    _favoritesSubscription = favoritesRepository.watchFavoriteIds().listen(
      (favoriteIds) => emit(state.copyWith(favoriteIds: favoriteIds)),
      onError: (Object error, StackTrace stackTrace) {
        emit(
          state.copyWith(favoriteError: 'Could not load saved idioms: $error'),
        );
      },
    );
  }

  void selectCategory(String? categoryId) {
    emit(
      categoryId == null
          ? state.copyWith(clearCategoryId: true)
          : state.copyWith(categoryId: categoryId),
    );
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void clearFavoriteError() {
    emit(state.copyWith(clearFavoriteError: true));
  }

  Future<void> toggleFavorite(Idiom idiom) async {
    final isFavorite = state.favoriteIds.contains(idiom.id);
    try {
      await favoritesRepository.setFavorite(idiom.id, !isFavorite);
      emit(state.copyWith(clearFavoriteError: true));
    } on FavoritesPersistenceException catch (error) {
      emit(state.copyWith(favoriteError: error.message));
    }
  }

  @override
  Future<void> close() async {
    await _idiomsSubscription?.cancel();
    await _favoritesSubscription?.cancel();
    await super.close();
  }
}
