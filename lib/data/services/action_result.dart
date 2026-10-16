class ActionResult<T> {
  const ActionResult({
    required this.data,
    this.message,
  });

  final T data;
  final String? message;
}
