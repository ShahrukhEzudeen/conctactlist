class Contact {
  int? id;
  String? name;
  String? email;
  int? isFavorite;

  Contact({
     this.id,
     this.name,
     this.email,
     this.isFavorite,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      isFavorite: json['isFavorite'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'isFavorite': isFavorite,
  };
}