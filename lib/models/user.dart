class User {
  final String id;
  final String name;
  final String email;
  final int xpPoints;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.xpPoints = 0,
  });
}
