class Proche {
  const Proche({
    required this.id,
    required this.name,
    required this.relation,
    this.phone,
  });

  final String id;
  final String name;
  final String relation;
  final String? phone;

  factory Proche.fromMap(String id, Map<String, dynamic> map) {
    return Proche(
      id: id,
      name: map["name"] as String? ?? "",
      relation: map["relation"] as String? ?? "",
      phone: map["phone"] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    "name": name,
    "relation": relation,
    if (phone != null) "phone": phone,
  };
}
