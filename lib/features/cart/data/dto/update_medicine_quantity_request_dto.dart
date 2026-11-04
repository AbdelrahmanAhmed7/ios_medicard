class UpdateMedicineQuantityRequestDto {
  final int quantity;
  final String? cardNumber;

  const UpdateMedicineQuantityRequestDto({
    required this.quantity,
    this.cardNumber,
  });

  Map<String, dynamic> toJson() => {
    'quantity': quantity,
    if (cardNumber != null) 'cardNumber': cardNumber,
  };
}
