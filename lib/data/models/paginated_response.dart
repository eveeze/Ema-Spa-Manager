// lib/data/models/paginated_response.dart

class Meta {
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  Meta({
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      total: json['total'] ?? 0,
      page: json['page'] ?? 0,
      pageSize: json['pageSize'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
    );
  }
}

class PaginatedResponse<T> {
  final List<T> data;
  final Meta meta;

  PaginatedResponse({required this.data, required this.meta});
}
