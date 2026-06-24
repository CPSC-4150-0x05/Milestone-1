class AppUser {
  final int? id;
  final String name;
  final String email;
  final String password;
  final String role;
  final String classCode;

  AppUser({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    required this.classCode,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'email': email.toLowerCase(),
    'password': password,
    'role': role,
    'classCode': classCode,
  };

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
      role: map['role'],
      classCode: map['classCode'],
    );
  }
}

class Student extends AppUser {
  final String currentList;
  final int currentListId;

  Student({
    super.id,
    required super.classCode,
    required super.email,
    required super.name,
    required super.password,
    required super.role,
    required this.currentList,
    required this.currentListId,
  });
}
