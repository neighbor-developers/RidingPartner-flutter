class TimerModel {
  const TimerModel(this.timeText, this.time, this.timerState);
  final String timeText;
  final int time;
  final TimerState timerState;
}

enum TimerState {
  initial,
  started,
  paused,
  finished,
}
