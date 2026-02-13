class Hayd {
  final DateTime start;
  final DateTime? end;

  Hayd({required this.start, this.end});

  Hayd copyWith({DateTime? start, DateTime? end}) {
    return Hayd(start: start ?? this.start, end: end ?? this.end);
  }

  bool get isActive => end == null;
}
