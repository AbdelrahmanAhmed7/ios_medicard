import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_simple_header.dart';
import '../../../network/data/provider_page_response_model.dart';
import '../../logic/provider_page_cubit.dart';
import '../../logic/provider_page_state.dart';
import 'provider_rebuild_scopes.dart';
import 'provider_shared_widgets.dart';

/// Blue header with provider info. Rebuilds only on provider-data, loading,
/// error, or view changes — never on list/scroll/cart churn.
class ProviderTopHeader extends StatelessWidget {
  final ProviderBranch? selectedBranch;
  final void Function(List<ProviderBranch>?, String?) onBranchTap;

  const ProviderTopHeader({
    super.key,
    required this.selectedBranch,
    required this.onBranchTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProviderPageCubit, ProviderPageState>(
      buildWhen: ProviderRebuildScopes.isHeaderSliceChanged,
      builder: (context, state) {
        final cubit = context.read<ProviderPageCubit>();
        return AppSimpleHeader(
          onBack: () {
            if (state.currentView == ProviderViewType.reviews) {
              cubit.switchView(state.catalogView);
            } else {
              context.pop();
            }
          },
          bottomChild: state.isProviderLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF3872B1)),
                )
              : state.providerData != null
              ? ProviderInfoRow(
                  data: state.providerData!,
                  servicesCount: state.displayServicesCount,
                  selectedBranch: selectedBranch,
                  onBranchTap: () => onBranchTap(
                    state.providerData!.branches,
                    state.providerData!.name,
                  ),
                  onRatingTap: () => context.push(
                    '/provider-reviews',
                    extra: {
                      'cubit': cubit,
                      'providerId': cubit.providerId,
                      'providerName': state.providerData!.name,
                    },
                  ),
                )
              : const SizedBox.shrink(),
        );
      },
    );
  }
}
