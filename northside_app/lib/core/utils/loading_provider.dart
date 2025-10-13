import 'package:flutter_riverpod/flutter_riverpod.dart';

final loadingProvider =
    StateNotifierProvider<LoadingNotifier, bool>((ref) => LoadingNotifier());

class LoadingNotifier extends StateNotifier<bool> {
  LoadingNotifier() : super(false);

  void startLoading() {
    if (!state) {
      state = true;
    }
  }

  void stopLoading() {
    if (state) {
      state = false;
    }
  }
}
