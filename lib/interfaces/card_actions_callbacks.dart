abstract class CardActionsCallbacks<T> {
  void onView(T element);
  void onViewed(T element);
  void onEdit(T element);
  void onDelete(T element);
}
