class Pagination {
  const Pagination({
    required this.page,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
  });

  final int page;
  final int pageSize;
  final int totalItems;
  final int totalPages;

  bool get isLastPage => page >= totalPages;
  bool get hasNextPage => page < totalPages;

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: json['page'] as int,
      pageSize: json['page_size'] as int,
      totalItems: json['total_items'] as int,
      totalPages: json['total_pages'] as int,
    );
  }

  factory Pagination.empty() => const Pagination(
        page: 1,
        pageSize: 20,
        totalItems: 0,
        totalPages: 0,
      );
}
