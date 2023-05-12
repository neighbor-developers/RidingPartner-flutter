import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class TimerNotifier extends StateNotifier<int> {
  TimerNotifier() : super(0);

  StreamSubscription<int>? _stream;

  @override
  void dispose() {
    _stream?.cancel();
    super.dispose();
  }

  @override
  set state(int value) {
    super.state = value;
  }

  void start() {
    _stream = Stream.periodic(const Duration(seconds: 1), (x) => x).listen((x) {
      if (mounted) {
        state = x;
      }
    });
  }

  void pause() {
    _stream?.pause();
  }

  void cancel() {
    _stream?.cancel();
    state = 0;
  }

  void restart() {
    _stream?.resume();
  }
}
