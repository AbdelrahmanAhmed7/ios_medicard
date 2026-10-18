import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:medicard/core/theming/app_text_styles.dart';
import 'package:medicard/core/utils/error_state_widget.dart';
import 'package:medicard/core/widgets/auth_shared_widgets.dart';
import '../../data/models/user_address_model.dart';
import '../cubit/addresses_cubit.dart';
import '../cubit/addresses_state.dart';

class AddressesListScreen extends StatefulWidget {
  const AddressesListScreen({super.key});

  @override
  State<AddressesListScreen> createState() => _AddressesListScreenState();
}

class _AddressesListScreenState extends State<AddressesListScreen> {
  // The `initial` branch schedules a load via post-frame; without this flag
  // every rebuild while still `initial` fires another concurrent GET.
  bool _initialLoadScheduled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<AddressesCubit, AddressesState>(
        listener: (context, state) {},
        builder: (context, state) {
          return state.when(
            initial: () {
              if (!_initialLoadScheduled) {
                _initialLoadScheduled = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    context.read<AddressesCubit>().loadAddresses();
                  }
                });
              }
              return const Center(child: CircularProgressIndicator());
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            success: (addresses) => _buildContent(context, addresses),
            failed: (error) => ErrorStateWidget(
              error: error,
              onRetry: () => context.read<AddressesCubit>().loadAddresses(),
            ),
            deleting: () => const Center(child: CircularProgressIndicator()),
            deleted: () => const SizedBox.shrink(),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<UserAddressModel> addresses) {
    return Column(
      children: [
        _buildHeader(context),
        Expanded(
          child: addresses.isEmpty
              ? _buildEmptyState(context)
              : RefreshIndicator(
                  onRefresh: () async {
                    context.read<AddressesCubit>().loadAddresses();
                  },
                  child: ListView.builder(
                    padding: EdgeInsets.only(top: 6.h, bottom: 16.h),
                    itemCount: addresses.length,
                    itemBuilder: (context, index) {
                      return _AddressListItem(address: addresses[index]);
                    },
                  ),
                ),
        ),
        SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: AuthPrimaryButton(
              label: 'addresses.add_address'.tr(),
              isLoading: false,
              onPressed: () => _openForm(context, null),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(8.w, 16.h, 8.w, 6.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: const Color(0xFF111827),
                size: 22.sp,
              ),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
            ),
            Expanded(
              child: Text(
                'addresses.title'.tr(),
                style: AppTextStyles.of(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_outlined, size: 80.sp, color: Colors.grey),
          SizedBox(height: 16.h),
          Text(
            'addresses.no_addresses'.tr(),
            style: AppTextStyles.of(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openForm(
    BuildContext context,
    UserAddressModel? address,
  ) async {
    final saved = await context.push<bool>(
      address == null ? '/addresses/add' : '/addresses/edit',
      extra: address,
    );
    if (saved == true && context.mounted) {
      context.read<AddressesCubit>().loadAddresses();
    }
  }
}

class _AddressListItem extends StatelessWidget {
  final UserAddressModel address;

  const _AddressListItem({required this.address});

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';
    final region = [
      address.localizedGovernorate(isArabic),
      address.localizedCity(isArabic),
    ].where((part) => part.isNotEmpty).join(', ');

    final details = <String>[
      if (address.buildingNumber != null)
        '${'addresses.building_number'.tr()}: ${address.buildingNumber}',
      if (address.floor != null) '${'addresses.floor'.tr()}: ${address.floor}',
      if (address.apartmentNumber != null)
        '${'addresses.apartment_number'.tr()}: ${address.apartmentNumber}',
    ].join('  •  ');

    // Card with side margin like the notification cards, instead of a
    // full-bleed row stuck to the screen edges.
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF1F9),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              address.isWork ? Icons.work_outline_rounded : Icons.home_outlined,
              color: kAuthBlue,
              size: 22.sp,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        address.isWork
                            ? 'addresses.work'.tr()
                            : 'addresses.home'.tr(),
                        style: AppTextStyles.of(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111827),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (address.isDefault == true) ...[
                      SizedBox(width: 8.w),
                      _DefaultBadge(label: 'addresses.default'.tr()),
                    ],
                  ],
                ),
                if (region.isNotEmpty) ...[
                  SizedBox(height: 3.h),
                  Text(
                    region,
                    style: AppTextStyles.of(
                      fontSize: 13.5.sp,
                      color: const Color(0xFF6B7280),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (details.isNotEmpty) ...[
                  SizedBox(height: 3.h),
                  Text(
                    details,
                    style: AppTextStyles.of(
                      fontSize: 12.5.sp,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 8.w),
          _CircleIconButton(
            icon: Icons.edit_outlined,
            foreground: const Color(0xFF475569),
            background: const Color(0xFFF1F5F9),
            onTap: () async {
              final saved = await context.push<bool>(
                '/addresses/edit',
                extra: address,
              );
              if (saved == true && context.mounted) {
                context.read<AddressesCubit>().loadAddresses();
              }
            },
          ),
          SizedBox(width: 10.w),
          _CircleIconButton(
            icon: Icons.delete_outline_rounded,
            foreground: const Color(0xFFDC2626),
            background: const Color(0xFFFDECEC),
            onTap: () => _showDeleteDialog(context),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('addresses.delete_address'.tr()),
          content: Text('addresses.delete_confirmation'.tr()),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF6B7280),
              ),
              onPressed: () => dialogContext.pop(),
              child: Text('common.cancel'.tr()),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFDC2626),
              ),
              onPressed: () {
                dialogContext.pop();
                context.read<AddressesCubit>().deleteAddress(id: address.id!);
              },
              child: Text('common.delete'.tr()),
            ),
          ],
        );
      },
    );
  }
}

class _DefaultBadge extends StatelessWidget {
  final String label;

  const _DefaultBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF1F9),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: AppTextStyles.of(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: kAuthBlue,
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final Color foreground;
  final Color background;
  final VoidCallback onTap;

  const _CircleIconButton({
    required this.icon,
    required this.foreground,
    required this.background,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.r,
        height: 40.r,
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        child: Icon(icon, color: foreground, size: 19.sp),
      ),
    );
  }
}
