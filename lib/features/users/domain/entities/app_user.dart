class AppUser {
  const AppUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.image,
    required this.company,
  });

  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String image;
  final String company;

  String get fullName => '$firstName $lastName'.trim();

  factory AppUser.fromMap(Map<String, dynamic> map) {
    final companyData = map['company'];
    return AppUser(
      id: map['id'] as int? ?? 0,
      firstName: map['firstName'] as String? ?? '',
      lastName: map['lastName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      image: map['image'] as String? ?? '',
      company: companyData is Map ? companyData['name'] as String? ?? '' : '',
    );
  }
}