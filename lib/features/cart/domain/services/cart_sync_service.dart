import 'dart:async';

class CartSyncEvent {
  final int? serviceId;
  final int? categoryId;
  final bool? isSelected;
  final bool cartCleared;
  final Set<int>? selectedServiceIds;
  final Set<int>? selectedMedicineIds;
  final Map<int, int>? categorySelectedCounts;
  final bool refreshCart;

  const CartSyncEvent({
    this.serviceId,
    this.categoryId,
    this.isSelected,
    this.cartCleared = false,
    this.selectedServiceIds,
    this.selectedMedicineIds,
    this.categorySelectedCounts,
    this.refreshCart = true,
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

  void selectionSnapshotChanged({
    required Iterable<int> selectedServiceIds,
    Iterable<int>? selectedMedicineIds,
    Map<int, int>? categorySelectedCounts,
    bool refreshCart = true,
  }) {
    _controller.add(
      CartSyncEvent(
        selectedServiceIds: Set<int>.unmodifiable(selectedServiceIds),
        selectedMedicineIds: selectedMedicineIds == null
            ? null
            : Set<int>.unmodifiable(selectedMedicineIds),
        categorySelectedCounts: categorySelectedCounts == null
            ? null
            : Map<int, int>.unmodifiable(categorySelectedCounts),
        refreshCart: refreshCart,
      ),
    );
  }

  void dispose() {
    _controller.close();
  }
}
