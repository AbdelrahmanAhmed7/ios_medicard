import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:medicard/core/di/service_locator.dart';
import 'package:medicard/core/theming/app_text_styles.dart';
import 'package:medicard/core/widgets/auth_shared_widgets.dart';

import '../../data/models/user_address_model.dart';
import '../cubit/addresses_cubit.dart';
import '../cubit/addresses_state.dart';

class AddressSelectionSheet extends StatefulWidget {
  final void Function(UserAddressModel address) onSelect;
  final VoidCallback onUseCurrentLocation;

  const AddressSelectionSheet({
    super.key,
    required this.onSelect,
    required this.onUseCurrentLocation,
  });

  static Future<void> show(
    BuildContext context, {
    required void Function(UserAddressModel address) onSelect,
    required VoidCallback onUseCurrentLocation,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      clipBehavior: Clip.antiAlias,
      builder: (_) => AddressSelectionSheet(
        onSelect: onSelect,
        onUseCurrentLocation: onUseCurrentLocation,
      ),
    );
  }

  @override
  State<AddressSelectionSheet> createState() => _AddressSelectionSheetState();
}

class _AddressSelectionSheetState extends State<AddressSelectionSheet> {
  late final AddressesCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = sl<AddressesCubit>()..loadAddresses();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.68,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 10.h),
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 12.h),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  'addresses.select_address'.tr(),
                  style: AppTextStyles.of(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            Flexible(child: _buildBody()),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<AddressesCubit, AddressesState>(
      bloc: _cubit,
      builder: (context, state) {
        return state.when(
          initial: _buildLoading,
          loading: _buildLoading,
          deleting: _buildLoading,
          deleted: () => const SizedBox.shrink(),
          failed: (error) =>
              _ErrorState(error: error, onRetry: _cubit.loadAddresses),
          success: (addresses) => ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: addresses.isEmpty ? 2 : addresses.length + 1,
            separatorBuilder: (_, _) => Divider(
              height: 1,
              indent: 20.w,
              endIndent: 20.w,
              color: const Color(0xFFEEF1F5),
            ),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _CurrentLocationTile(onTap: _handleUseCurrentLocation);
              }

              if (addresses.isEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.h),
                  child: Text(
                    'addresses.no_addresses'.tr(),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.of(
                      fontSize: 13.sp,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                );
              }

              final address = addresses[index - 1];
              return _AddressTile(
                address: address,
                onTap: () => _handleSelect(address),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLoading() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 36.h),
      child: const Center(child: CircularProgressIndicator(color: kAuthBlue)),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 14.h),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () {
            Navigator.of(context).pop();
            context.push('/addresses');
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: kAuthBlue,
            side: const BorderSide(color: kAuthBlue),
            minimumSize: Size.fromHeight(46.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: Text(
            'addresses.manage_addresses'.tr(),
            style: AppTextStyles.of(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: kAuthBlue,
            ),
          ),
        ),
      ),
    );
  }

  void _handleSelect(UserAddressModel address) {
    widget.onSelect(address);
    Navigator.of(context).pop();
  }

  void _handleUseCurrentLocation() {
    widget.onUseCurrentLocation();
    Navigator.of(context).pop();
  }
}

class _CurrentLocationTile extends StatelessWidget {
  final VoidCallback onTap;

  const _CurrentLocationTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
        child: Row(
          children: [
            Icon(Icons.my_location_rounded, color: kAuthBlue, size: 21.sp),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(
                'addresses.use_current_location'.tr(),
                style: AppTextStyles.of(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: kAuthBlue,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: const Color(0xFF9CA3AF),
              size: 15.sp,
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressTile extends StatelessWidget {
  final UserAddressModel address;
  final VoidCallback onTap;

  const _AddressTile({required this.address, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';
    final region = [
      address.localizedGovernorate(isArabic),
      address.localizedCity(isArabic),
    ].where((part) => part.isNotEmpty).join(isArabic ? '، ' : ', ');

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
        child: Row(
          children: [
            Icon(
              address.isWork ? Icons.work_outline_rounded : Icons.home_outlined,
              color: const Color(0xFF4B5563),
              size: 21.sp,
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          address.isWork
                              ? 'addresses.work'.tr()
                              : 'addresses.home'.tr(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.of(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF111827),
                          ),
                        ),
                      ),
                      if (address.isDefault == true) ...[
                        SizedBox(width: 6.w),
                        Text(
                          '• ${'addresses.default'.tr()}',
                          style: AppTextStyles.of(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: kAuthBlue,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (region.isNotEmpty) ...[
                    SizedBox(height: 3.h),
                    Text(
                      region,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.of(
                        fontSize: 12.5.sp,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: const Color(0xFF9CA3AF),
              size: 15.sp,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorState({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            error,
            textAlign: TextAlign.center,
            style: AppTextStyles.of(
              fontSize: 13.sp,
              color: const Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: 8.h),
          TextButton(onPressed: onRetry, child: Text('common.retry'.tr())),
        ],
      ),
    );
  }
}
