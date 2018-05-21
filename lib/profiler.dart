class Records {
  static void save(Profiler p) {
    print('${p.name} : ${p.dts.last - p.dts.first} ms');
  }
}

class Profiler {
  final String name;
  List<double> dts = [];

  Profiler(this.name) {
    this.tick();
  }

  void tick() {
    this.dts.add(currentTime());
  }

  void end() {
    this.tick();
    Records.save(this);
  }

  static double currentTime() =>
      new DateTime.now().microsecondsSinceEpoch.toDouble() /
      Duration.microsecondsPerMillisecond;
}
