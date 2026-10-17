import '../dto/pagination_dto.dart';

class PagedResult<T> {
  const PagedResult({required this.items, required this.pagination});

  final List<T> items;
  final PaginationDto pagination;
}
