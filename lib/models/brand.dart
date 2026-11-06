class Brand {
  const Brand({
    required this.id,
    required this.name,
    required this.country,
    required this.foundedYear,
    required this.specialization,
    this.deletedAt,
  });

  final int id;
  final String name;
  final String country;
  final int foundedYear;
  final String specialization;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;

  Brand copyWith({
    String? name,
    String? country,
    int? foundedYear,
    String? specialization,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Brand(
      id: id,
      name: name ?? this.name,
      country: country ?? this.country,
      foundedYear: foundedYear ?? this.foundedYear,
      specialization: specialization ?? this.specialization,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }
}
