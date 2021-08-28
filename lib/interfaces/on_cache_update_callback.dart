abstract class OnCacheUpdateCallback {
  void updateStart(int quantity);
  void updateProgress(int current, int quantity);
  void updateEnd();
}
