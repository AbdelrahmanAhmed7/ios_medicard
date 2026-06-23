import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
        color: Color(0xFF2D5FA6),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      width: double.infinity,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              _HeaderTopRow(),
              SizedBox(height: 16),
              _HeaderSearchBar(),
            ],
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
                text: _locationText(state),
                onTap: context.read<LocationCubit>().refreshLocation,
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
              color: Color(0xFF2D5FA6),
              size: 22,
            ),
          ),
        ),
      ],
    );
  }

  String _locationText(LocationState state) {
    return switch (state) {
      LocationInitial() || LocationLoading() => 'Getting location...',
      LocationLoaded(:final name) => name,
      LocationError(:final message) => message,
    };
  }
}

class _HeaderSearchBar extends StatelessWidget {
  const _HeaderSearchBar();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationCubit, LocationState>(
      builder: (context, state) {
        return SearchBarWidget(
          latitude: state is LocationLoaded ? state.latitude : null,
          longitude: state is LocationLoaded ? state.longitude : null,
        );
      },
    );
  }
}
