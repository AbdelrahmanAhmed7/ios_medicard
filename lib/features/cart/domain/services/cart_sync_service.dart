import 'dart:async';

class CartSyncEvent {
  final int? serviceId;
  final int? categoryId;
  final bool? isSelected;
  final bool cartCleared;

  const CartSyncEvent({
    this.serviceId,
    this.categoryId,
    this.isSelected,
    this.cartCleared = false,
  });
}

class CartSyncService {
  final _controller = StreamController<CartSyncEvent>.broadcast();

  Stream<CartSyncEvent> get stream => _controller.stream;

  void serviceSelectionChanged({
    required int serviceId,
    int? categoryId,
    required bool isSelected,
  }) {
    _controller.add(
      CartSyncEvent(
        serviceId: serviceId,
        categoryId: categoryId,
        isSelected: isSelected,
      ),
    );
  }

  void cartCleared() {
    _controller.add(const CartSyncEvent(cartCleared: true));
  }

  void dispose() {
    _controller.close();
  }
}
