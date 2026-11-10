import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/theming/app_toast.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../data/models/medicine_response_model.dart';
import '../cubit/search_cubit.dart';
import '../cubit/search_state.dart';

import 'package:medicard/core/theming/app_colors.dart';

class SearchMedicinesTab extends StatefulWidget {
  final bool enableCartFeatures;
  final bool embedded;

  const SearchMedicinesTab({
    super.key,
    required this.enableCartFeatures,
    this.embedded = false,
  });

  @override
  State<SearchMedicinesTab> createState() => _SearchMedicinesTabState();
}

class _SearchMedicinesTabState extends State<SearchMedicinesTab> {
  final ScrollController _scrollController = ScrollController();
  final Map<int, int> _quantities = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_loadMoreIfNeeded);
  }

  void _loadMoreIfNeeded() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<SearchCubit>().loadMoreMedicines();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchCubit, SearchState>(
      buildWhen: (previous, current) =>
          previous.medicines != current.medicines ||
          previous.isLoadingMedicines != current.isLoadingMedicines ||
          previous.isLoadingMoreMedicines != current.isLoadingMoreMedicines ||
          previous.medicinesError != current.medicinesError ||
          previous.selectedMedicineIds != current.selectedMedicineIds ||
          previous.pendingServiceIds != current.pendingServiceIds ||
          previous.categorySelectedCounts != current.categorySelectedCounts,
      builder: (context, state) {
        final selectedCount =
            state.categorySelectedCounts[1] ?? state.selectedMedicineIds.length;
        return Stack(
          children: [
            _buildBody(context, state, selectedCount),
            if (widget.enableCartFeatures && selectedCount > 0)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _ReviewMedicinesBar(count: selectedCount),
              ),
          ],
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    SearchState state,
    int selectedCount,
  ) {
    if (state.isLoadingMedicines && state.medicines.isEmpty) {
      return _MedicinesShimmer(embedded: widget.embedded);
    }

    if (state.medicinesError != null && state.medicines.isEmpty) {
      return _MedicineMessageView(
        icon: Icons.error_outline_rounded,
        message: state.medicinesError!,
        actionLabel: 'common.retry'.tr(),
        onAction: () => context.read<SearchCubit>().searchMedicines(
          search: context.read<SearchCubit>().state.keyword,
        ),
      );
    }

    if (state.medicines.isEmpty) {
      return _MedicineMessageView(
        icon: Icons.medication_outlined,
        message: 'home.no_medicines_found'.tr(),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.fromLTRB(
        widget.embedded ? 0 : 16.w,
        12.h,
        widget.embedded ? 0 : 16.w,
        selectedCount > 0 ? MediaQuery.of(context).padding.bottom + 92.h : 16.h,
      ),
      itemCount:
          state.medicines.length + (state.isLoadingMoreMedicines ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.medicines.length) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: const Center(
              child: CircularProgressIndicator(
                color: AppColors.brandBlueClr,
                strokeWidth: 2.5,
              ),
            ),
          );
        }
        final medicine = state.medicines[index];
        return _MedicineCard(
          key: ValueKey('medicine_${medicine.id}'),
          medicine: medicine,
          isSelected: state.selectedMedicineIds.contains(medicine.id),
          isPending: state.pendingServiceIds.contains(medicine.id),
          quantity: _quantities[medicine.id] ?? 1,
          onIncrement: () => _changeQuantity(medicine.id, state, 1),
          onDecrement: () => _changeQuantity(medicine.id, state, -1),
          onToggle: () => _toggleMedicine(
            context,
            medicine.id,
            state,
            _quantities[medicine.id] ?? 1,
          ),
        );
      },
    );
  }

  void _toggleMedicine(
    BuildContext context,
    int medicineId,
    SearchState state,
    int quantity,
  ) {
    if (!widget.enableCartFeatures) {
      showLoginRequiredMessage(context);
      return;
    }
    final cubit = context.read<SearchCubit>();
    if (state.selectedMedicineIds.contains(medicineId)) {
      cubit.removeServiceFromCart(serviceId: medicineId, categoryId: 1);
    } else {
      cubit.addServiceToCart(
        serviceId: medicineId,
        categoryId: 1,
        quantity: quantity,
      );
    }
  }

  void _changeQuantity(int medicineId, SearchState state, int change) {
    final current = _quantities[medicineId] ?? 1;
    if (change < 0 &&
        current <= 1 &&
        state.selectedMedicineIds.contains(medicineId)) {
      context.read<SearchCubit>().removeServiceFromCart(
        serviceId: medicineId,
        categoryId: 1,
      );
      return;
    }
    final next = current + change;
    if (next < 1 || state.pendingServiceIds.contains(medicineId)) return;
    setState(() => _quantities[medicineId] = next);
    if (state.selectedMedicineIds.contains(medicineId)) {
      context.read<SearchCubit>().updateMedicineQuantity(
        serviceId: medicineId,
        quantity: next,
      );
    }
  }
}

class _MedicineCard extends StatelessWidget {
  final MedicineModel medicine;
  final bool isSelected;
  final bool isPending;
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onToggle;

  const _MedicineCard({
    super.key,
    required this.medicine,
    required this.isSelected,
    required this.isPending,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';
    final primaryName =
        (isArabic ? medicine.arName : medicine.enName)?.trim() ?? '';
    final secondaryName =
        (isArabic ? medicine.enName : medicine.arName)?.trim() ?? '';
    final title = primaryName.isNotEmpty ? primaryName : secondaryName;
    final imageUrl = medicine.medicineImageUrl?.trim() ?? '';
    final details = [
      medicine.medicineForm?.trim(),
      medicine.unit?.trim(),
    ].whereType<String>().where((value) => value.isNotEmpty).join(' • ');
    final currentPrice = medicine.priceAfter ?? medicine.medicinePrice;
    final oldPrice = medicine.priceBefore;
    final hasDiscount =
        (medicine.discountPercentage ?? 0) > 0 &&
        oldPrice != null &&
        currentPrice != null &&
        oldPrice > currentPrice;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.exactFFF8FAFC : AppColors.whiteClr,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isSelected
              ? AppColors.brandBlueClr.withValues(alpha: 0.35)
              : AppColors.exactFFE5E7EB,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.exactFF0F172A.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: SizedBox(
              width: 82.r,
              height: 82.r,
              child: imageUrl.isEmpty
                  ? const _MedicineImageFallback()
                  : CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      memCacheWidth: 220,
                      memCacheHeight: 220,
                      placeholder: (_, _) => const _MedicineImageFallback(),
                      errorWidget: (_, _, _) => const _MedicineImageFallback(),
                    ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.of(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.inkClr,
                  ),
                ),
                if (secondaryName.isNotEmpty && secondaryName != title) ...[
                  SizedBox(height: 2.h),
                  Text(
                    secondaryName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.of(
                      fontSize: 12.sp,
                      color: AppColors.exactFF6B7280,
                    ),
                  ),
                ],
                if (details.isNotEmpty) ...[
                  SizedBox(height: 5.h),
                  Text(
                    details,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.of(
                      fontSize: 11.5.sp,
                      color: AppColors.exactFF8A94A6,
                    ),
                  ),
                ],
                SizedBox(height: 7.h),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (hasDiscount) ...[
                      Text(
                        formatPrice(oldPrice),
                        style: AppTextStyles.of(
                          fontSize: 11.sp,
                          color: AppColors.exactFF9CA3AF,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      SizedBox(width: 6.w),
                    ],
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.exactFFEFF6FF,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        formatPrice(currentPrice),
                        style: AppTextStyles.of(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.brandBlueClr,
                        ),
                      ),
                    ),
                    if (hasDiscount) ...[
                      SizedBox(width: 6.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.exactFFF0FDF4,
                          borderRadius: BorderRadius.circular(7.r),
                        ),
                        child: Text(
                          '${medicine.discountPercentage!.toStringAsFixed(0)}%',
                          style: AppTextStyles.of(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.exactFF15803D,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          if (isPending)
            SizedBox(
              width: 34.r,
              height: 34.r,
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.brandBlueClr,
                ),
              ),
            )
          else if (isSelected)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _QuantityButton(
                  icon: quantity <= 1
                      ? Icons.delete_outline_rounded
                      : Icons.remove,
                  onTap: onDecrement,
                ),
                SizedBox(
                  width: 26.w,
                  child: Text(
                    '$quantity',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.of(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.inkClr,
                    ),
                  ),
                ),
                _QuantityButton(icon: Icons.add, onTap: onIncrement),
              ],
            )
          else
            _AddToCartButton(onTap: onToggle),
        ],
      ),
    );
  }
}

class _MedicinesShimmer extends StatelessWidget {
  final bool embedded;

  const _MedicinesShimmer({required this.embedded});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.exactFFE5E7EB,
      highlightColor: AppColors.exactFFF8FAFC,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(
          embedded ? 0 : 16.w,
          12.h,
          embedded ? 0 : 16.w,
          16.h,
        ),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        itemBuilder: (_, _) => const _MedicineShimmerCard(),
      ),
    );
  }
}

class _MedicineShimmerCard extends StatelessWidget {
  const _MedicineShimmerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 116.h,
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.whiteClr,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          Container(
            width: 82.r,
            height: 82.r,
            decoration: BoxDecoration(
              color: AppColors.whiteClr,
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 15.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.whiteClr,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                ),
                SizedBox(height: 9.h),
                Container(
                  height: 11.h,
                  width: 105.w,
                  decoration: BoxDecoration(
                    color: AppColors.whiteClr,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                ),
                SizedBox(height: 10.h),
                Container(
                  height: 22.h,
                  width: 76.w,
                  decoration: BoxDecoration(
                    color: AppColors.whiteClr,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: AppColors.whiteClr,
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        ],
      ),
    );
  }
}

class _MedicineImageFallback extends StatelessWidget {
  const _MedicineImageFallback();

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: AppColors.exactFFEEF3FB,
    child: Icon(
      Icons.medication_outlined,
      color: AppColors.exactFF7A9EC7,
      size: 30.sp,
    ),
  );
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 28.r,
      height: 28.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.exactFFEFF6FF,
        border: Border.all(color: AppColors.brandBlueClr),
      ),
      child: Icon(icon, size: 15.sp, color: AppColors.brandBlueClr),
    ),
  );
}

class _AddToCartButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddToCartButton({required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.brandBlueClr,
    borderRadius: BorderRadius.circular(10.r),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 9.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add_shopping_cart_rounded,
              size: 16.sp,
              color: AppColors.whiteClr,
            ),
            SizedBox(width: 4.w),
            Text(
              'cart.add_to_cart'.tr(),
              style: AppTextStyles.of(
                fontSize: 9.5.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.whiteClr,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _MedicineMessageView extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _MedicineMessageView({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 52.sp, color: AppColors.exactFFD1D5DB),
          SizedBox(height: 12.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.of(
              fontSize: 15.sp,
              color: AppColors.exactFF6B7280,
            ),
          ),
          if (onAction != null && actionLabel != null) ...[
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandBlueClr,
                foregroundColor: AppColors.whiteClr,
              ),
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    ),
  );
}

class _ReviewMedicinesBar extends StatelessWidget {
  final int count;

  const _ReviewMedicinesBar({required this.count});

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      16.w,
      0,
      16.w,
      MediaQuery.of(context).padding.bottom + 14.h,
    ),
    child: GestureDetector(
      onTap: () => context.push('/cart'),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.brandBlueClr,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.brandBlueClr.withValues(alpha: 0.30),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 28.r,
              height: 28.r,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$count',
                  style: AppTextStyles.of(
                    color: AppColors.whiteClr,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Text(
              'cart.review_medicines'.tr(),
              style: AppTextStyles.of(
                color: AppColors.whiteClr,
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
