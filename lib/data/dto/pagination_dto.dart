class PaginationDto {
  const PaginationDto({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  final int page;
  final int limit;
  final int total;
  final int totalPages;

  factory PaginationDto.fromJson(Map<String, dynamic> json) {
    return PaginationDto(
      page: (json['page'] as num? ?? 1).toInt(),
      limit: (json['limit'] as num? ?? 20).toInt(),
      total: (json['total'] as num? ?? 0).toInt(),
      totalPages: (json['totalPages'] as num? ?? 0).toInt(),
    );
  }
}
