class UserModel {
  String? uid;
  String? name;
  String? email;
  String? phone;
  DateTime? createdAt;

  UserModel({
    this.uid,
    this.name,
    this.email,
    this.phone,
    this.createdAt,
  });

  // تحويل من Map إلى UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : null,
    );
  }

  // تحويل UserModel إلى Map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'createdAt': createdAt?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch,
    };
  }
}