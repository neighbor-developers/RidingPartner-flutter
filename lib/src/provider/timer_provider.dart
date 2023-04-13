import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/timer.dart';

class TimerNotifier extends StateNotifier<TimerModel> {
  TimerNotifier() : super(_initialState);

  static final _initialState = TimerModel(
    _durationString(0),
    0,
    TimerState.initial,
  );

  @override
  set state(TimerModel value) {
    // TODO: implement state
    super.state = value;
  }

  final Ticker _ticker = Ticker();
  StreamSubscription<int>? _tickerSubscription;

  static String _durationString(int duration) {
    final minutes = ((duration / 60) % 60).floor().toString().padLeft(2, '0');
    final seconds = (duration % 60).floor().toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _tickerSubscription?.cancel();
    super.dispose();
  }

  void start() {
    if (state.timerState == TimerState.paused) {
      _restartTimer();
    } else {
      _startTimer();
    }
  }

  void pause() {
    _tickerSubscription?.pause();
    state =
        TimerModel(_durationString(state.time), state.time, TimerState.paused);
  }

  void reset() {
    _tickerSubscription?.cancel();
    state = _initialState;
  }

  void _restartTimer() {
    _tickerSubscription?.resume();
    state =
        TimerModel(_durationString(state.time), state.time, TimerState.started);
  }

  void _startTimer() {
    _tickerSubscription?.cancel();

    _tickerSubscription = _ticker.tick(ticks: 10).listen((duration) {
      state =
          TimerModel(_durationString(duration), duration, TimerState.started);
    });

    _tickerSubscription?.onDone(() {
      state = TimerModel(
          _durationString(state.time), state.time, TimerState.finished);
    });

    state = TimerModel(_durationString(0), 0, TimerState.started);
  }
}

class Ticker {
  Stream<int> tick({required int ticks}) {
    return Stream.periodic(
      const Duration(seconds: 1),
      (x) => ticks + x,
    ).take(ticks);
  }
}
