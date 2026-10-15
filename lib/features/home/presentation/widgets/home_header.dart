import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theming/app_spacing.dart';
import '../../../../core/theming/app_toast.dart';
import '../../../../core/widgets/app_blue_header.dart';
import '../../../addresses/presentation/widgets/address_selection_sheet.dart';

import '../cubit/location_cubit.dart';
import '../cubit/location_state.dart';
import 'location_display.dart';
import 'search_bar_widget.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF3872B1),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      width: double.infinity,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: kMainTabHeaderContentHeight,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.pageHorizontal,
              10,
              AppSpacing.pageHorizontal,
              10,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                _HeaderTopRow(),
                SizedBox(height: 12),
                Expanded(child: _HeaderSearchBar()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderTopRow extends StatelessWidget {
  const _HeaderTopRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: BlocBuilder<LocationCubit, LocationState>(
            builder: (context, state) {
              return LocationDisplay(
                text: _locationText(state, context),
                onTap: () => _openAddressSheet(context),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: GestureDetector(
            onTap: () => context.push('/notifications'),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFF3872B1),
              size: 22,
            ),
          ),
        ),
      ],
    );
  }

  String _locationText(LocationState state, BuildContext context) {
    return switch (state) {
      LocationInitial() || LocationLoading() => 'home.getting_location'.tr(),
      LocationLoaded(:final name) => name,
      LocationError(:final message) => message,
    };
  }

  void _openAddressSheet(BuildContext context) {
    final locationCubit = context.read<LocationCubit>();
    AddressSelectionSheet.show(
      context,
      onSelect: (address) {
        if (!address.hasCoordinates) {
          showWarningToast('addresses.location_unavailable'.tr());
          return;
        }
        final label = address.isWork
            ? 'addresses.work'.tr()
            : 'addresses.home'.tr();
        locationCubit.selectAddress(
          id: address.id,
          name: label,
          latitude: address.lat!,
          longitude: address.long!,
        );
      },
      onUseCurrentLocation: () async {
        await locationCubit.clearSelectedAddress();
        await locationCubit.retryLocation();
      },
    );
  }
}

class _HeaderSearchBar extends StatelessWidget {
  const _HeaderSearchBar();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<LocationCubit>().state;
    // Rebuild when locale changes so the hint text updates.
    final _ = context.locale;
    return SearchBarWidget(
      latitude: state is LocationLoaded ? state.latitude : null,
      longitude: state is LocationLoaded ? state.longitude : null,
    );
  }
}
