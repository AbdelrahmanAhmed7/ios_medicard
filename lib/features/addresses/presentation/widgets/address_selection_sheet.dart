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
    final maxHeight = MediaQuery.of(context).size.height * 0.7;

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 12.h),
            Container(
              width: 42.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
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
            SizedBox(height: 8.h),
            Flexible(child: _buildBody()),
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
          initial: () => const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          ),
          loading: () => const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          ),
          failed: (error) => Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.of(
                    fontSize: 14.sp,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                SizedBox(height: 12.h),
                TextButton(
                  onPressed: _cubit.loadAddresses,
                  child: Text('common.retry'.tr()),
                ),
              ],
            ),
          ),
          deleting: () => const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          ),
          deleted: () => const SizedBox.shrink(),
          success: (addresses) => ListView(
            shrinkWrap: true,
            padding: EdgeInsets.only(top: 4.h, bottom: 8.h),
            children: [
              _CurrentLocationTile(onTap: _handleUseCurrentLocation),
              const Divider(height: 1, color: Color(0xFFEEF1F5)),
              if (addresses.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 28.h),
                  child: Center(
                    child: Text(
                      'addresses.no_addresses'.tr(),
                      style: AppTextStyles.of(
                        fontSize: 14.sp,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                )
              else
                ...addresses.map(
                  (address) => _AddressTile(
                    address: address,
                    onTap: () => _handleSelect(address),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            context.push('/addresses');
          },
          icon: Icon(Icons.settings_outlined, size: 18.sp, color: kAuthBlue),
          label: Text(
            'addresses.manage_addresses'.tr(),
            style: AppTextStyles.of(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: kAuthBlue,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: kAuthBorderColor),
            minimumSize: Size.fromHeight(48.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
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
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
        child: Row(
          children: [
            Icon(Icons.my_location_rounded, color: kAuthBlue, size: 22.sp),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(
                'addresses.use_current_location'.tr(),
                style: AppTextStyles.of(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111827),
                ),
              ),
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
    ].where((part) => part.isNotEmpty).join(', ');

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
        child: Row(
          children: [
            Icon(
              address.isWork ? Icons.work_outline_rounded : Icons.home_outlined,
              color: const Color(0xFF475569),
              size: 22.sp,
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        address.isWork
                            ? 'addresses.work'.tr()
                            : 'addresses.home'.tr(),
                        style: AppTextStyles.of(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      if (address.isDefault == true) ...[
                        SizedBox(width: 8.w),
                        Text(
                          '• ${'addresses.default'.tr()}',
                          style: AppTextStyles.of(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: kAuthBlue,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (region.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    Text(
                      region,
                      style: AppTextStyles.of(
                        fontSize: 13.sp,
                        color: const Color(0xFF6B7280),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.black38,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}
