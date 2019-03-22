class Records {
  static void save(Profiler p) {
    print('${p.name} : ${p.dts.last - p.dts.first} ms');
  }
}

class Profiler {
  final String name;
  List<double> dts = [];

  Profiler(this.name) {
    tick();
  }

  void tick() {
    dts.add(currentTime());
  }

  void end() {
    tick();
    Records.save(this);
  }

  static double currentTime() =>
      DateTime.now().microsecondsSinceEpoch.toDouble() /
      Duration.microsecondsPerMillisecond;
}
