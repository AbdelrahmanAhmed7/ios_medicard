import 'package:medicard/core/widgets/app_header_back_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theming/app_text_styles.dart';
import '../../../network/data/provider_page_response_model.dart';
import '../../logic/provider_page_cubit.dart';
import '../../logic/provider_page_state.dart';
import 'provider_rebuild_scopes.dart';
import 'provider_shared_widgets.dart';

/// Navigation stays separate from the scrollable provider details.
class ProviderTopHeader extends StatelessWidget {
  const ProviderTopHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEF1F5))),
      ),
      padding: AppHeaderSpacing.padding(top: 4, bottom: 4),
      child: Row(
        children: [
          AppHeaderBackButton(
            onPressed: () {
              final cubit = context.read<ProviderPageCubit>();
              if (cubit.state.currentView == ProviderViewType.reviews) {
                cubit.switchView(cubit.state.catalogView);
              } else if (context.canPop()) {
                context.pop();
              } else {
                context.go('/medicard-home');
              }
            },
          ),
          Expanded(
            child: Text(
              'provider_page.title'.tr(),
              style: AppTextStyles.of(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111827),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProviderDetailsSection extends StatelessWidget {
  final ProviderBranch? selectedBranch;
  final void Function(List<ProviderBranch>?, String?) onBranchTap;

  const ProviderDetailsSection({
    super.key,
    required this.selectedBranch,
    required this.onBranchTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProviderPageCubit, ProviderPageState>(
      buildWhen: ProviderRebuildScopes.isHeaderSliceChanged,
      builder: (context, state) {
        if (state.isProviderLoading) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Color(0xFF3872B1),
                ),
              ),
            ),
          );
        }
        final data = state.providerData;
        if (data == null) return const SizedBox.shrink();
        final cubit = context.read<ProviderPageCubit>();
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF3872B1).withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF3872B1).withValues(alpha: 0.10),
            ),
          ),
          child: ProviderInfoRow(
            data: data,
            servicesCount: state.displayServicesCount,
            selectedBranch: selectedBranch,
            onBranchTap: () => onBranchTap(data.branches, data.name),
            onRatingTap: () => context.push(
              '/provider-reviews',
              extra: {
                'cubit': cubit,
                'providerId': cubit.providerId,
                'providerName': data.name,
              },
            ),
          ),
        );
      },
    );
  }
}
