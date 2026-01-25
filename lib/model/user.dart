
class LoginModel {
  final String id;
  final String username;
  final String password;
  final bool isadmin;
  final bool ison;
  final bool isuploaddata;

  LoginModel({
    required this.id,
    required this.username,
    required this.password,
    this.isadmin = false,
    this.ison = true,
    this.isuploaddata = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'isadmin': isadmin,
      'ison': ison,
      'isuploaddata': isuploaddata,
    };
  }

  factory LoginModel.fromMap(Map<String, dynamic> map) {
    return LoginModel(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      isadmin: map['isadmin'] ?? false,
      ison: map['ison'] ?? true,
      isuploaddata: map['isuploaddata'] ?? false,
    );
  }
}
