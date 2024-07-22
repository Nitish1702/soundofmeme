Future<void> sleep(int seconds, [int? maxDeviation]) async {
  await Future.delayed(Duration(seconds: seconds));
}
