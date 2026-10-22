import 'package:medicard/core/widgets/app_header_back_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:medicard/core/di/service_locator.dart';
import 'package:medicard/core/services/location_repository.dart';
import 'package:medicard/core/services/location_service.dart';
import 'package:medicard/core/theming/app_text_styles.dart';
import 'package:medicard/core/widgets/app_dropdown_menu_item.dart';
import 'package:medicard/core/widgets/auth_shared_widgets.dart';
import '../../data/models/user_address_model.dart';
import '../cubit/address_form_cubit.dart';
import '../cubit/address_form_state.dart';

class AddEditAddressScreen extends StatefulWidget {
  final UserAddressModel? address;

  const AddEditAddressScreen({super.key, this.address});

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _floorController = TextEditingController();
  final _buildingController = TextEditingController();
  final _apartmentController = TextEditingController();

  int? _selectedGovernorateId;
  int? _selectedCityId;
  bool _isWork = false;
  bool _isDefault = false;

  double? _latitude;
  double? _longitude;
  bool _resolvingLocation = true;
  Future<void>? _locationFuture;
  // The save button disables on `isSaving`, but that flag only engages
  // inside the cubit — rapid taps during the location wait above used to
  // fire duplicate POSTs.
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final address = widget.address;
    if (address != null) {
      _selectedGovernorateId = address.governorateId;
      _selectedCityId = address.cityId;
      _isWork = address.isWork;
      _isDefault = address.isDefault ?? false;
      _floorController.text = address.floor?.toString() ?? '';
      _buildingController.text = address.buildingNumber?.toString() ?? '';
      _apartmentController.text = address.apartmentNumber?.toString() ?? '';
      _latitude = address.lat;
      _longitude = address.long;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  Future<void> _initialize() async {
    final cubit = context.read<AddressFormCubit>();
    await cubit.loadGovernorates();
    if (!mounted) return;
    if (widget.address?.governorateId != null) {
      await cubit.selectGovernorate(widget.address!.governorateId);
    }
    // New addresses have no coordinates yet, so resolve the device
    // location. When editing, only re-resolve if the stored address
    // has none (previously `widget.address?.... == false` skipped new
    // addresses entirely, sending lat/long as null).
    if (widget.address == null || widget.address?.hasCoordinates == false) {
      _locationFuture = _resolveLocation();
      await _locationFuture;
    } else {
      setState(() => _resolvingLocation = false);
    }
  }

  Future<void> _resolveLocation() async {
    final repository = sl<LocationRepository>();
    final service = sl<LocationService>();
    var result = repository.cached;
    if (result?.hasCoordinates != true) {
      result = await repository.resolve(service);
    }
    if (!mounted) return;
    setState(() {
      _latitude = result?.latitude;
      _longitude = result?.longitude;
      _resolvingLocation = false;
    });
  }

  @override
  void dispose() {
    _floorController.dispose();
    _buildingController.dispose();
    _apartmentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    // Don't send the request with null coordinates just because the user
    // tapped save before the GPS resolution finished.
    if (_resolvingLocation) {
      await (_locationFuture ?? _resolveLocation());
      if (!mounted) return;
    }
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      await context.read<AddressFormCubit>().save(
        governorateId: _selectedGovernorateId!,
        cityId: _selectedCityId!,
        floor: _parseInt(_floorController.text),
        buildingNumber: _parseInt(_buildingController.text),
        apartmentNumber: _parseInt(_apartmentController.text),
        mainAddress: _isWork ? 1 : 0,
        isDefault: _isDefault,
        latitude: _latitude,
        longitude: _longitude,
        addressId: widget.address?.id,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  int? _parseInt(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return int.tryParse(trimmed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: BlocConsumer<AddressFormCubit, AddressFormState>(
          listener: (context, state) {
            if (state.saved && context.mounted) {
              context.pop(true);
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  SizedBox(height: 24.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FieldLabel('addresses.address_type'.tr()),
                          _buildTypeSelector(),
                          SizedBox(height: 14.h),
                          _FieldLabel('addresses.governorate'.tr()),
                          _buildGovernorateDropdown(state),
                          SizedBox(height: 14.h),
                          _FieldLabel('addresses.city'.tr()),
                          _buildCityDropdown(state),
                          SizedBox(height: 14.h),
                          _FieldLabel('addresses.building_number'.tr()),
                          _buildNumberField(
                            controller: _buildingController,
                            hint: 'addresses.building_number'.tr(),
                            required: true,
                          ),
                          SizedBox(height: 14.h),
                          _FieldLabel('addresses.floor'.tr()),
                          _buildNumberField(
                            controller: _floorController,
                            hint: 'addresses.floor'.tr(),
                          ),
                          SizedBox(height: 14.h),
                          _FieldLabel('addresses.apartment_number'.tr()),
                          _buildNumberField(
                            controller: _apartmentController,
                            hint: 'addresses.apartment_number'.tr(),
                          ),
                          SizedBox(height: 8.h),
                          _buildDefaultSwitch(),
                          SizedBox(height: 8.h),
                          _buildLocationStatus(),
                          SizedBox(height: 28.h),
                          AuthPrimaryButton(
                            label: widget.address == null
                                ? 'common.save'.tr()
                                : 'common.update'.tr(),
                            isLoading: state.isSaving || _isSubmitting,
                            onPressed: (state.isSaving || _isSubmitting)
                                ? () {}
                                : _submit,
                          ),
                          SizedBox(height: 24.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: AppHeaderSpacing.padding(top: 16.h, bottom: 6.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppHeaderBackButton(
              color: const Color(0xFF111827),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
            ),
            Expanded(
              child: Text(
                widget.address == null
                    ? 'addresses.add_address'.tr()
                    : 'addresses.edit_address'.tr(),
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

  Widget _buildTypeSelector() {
    return Row(
      children: [
        Expanded(
          child: _TypeOption(
            icon: Icons.home_outlined,
            label: 'addresses.home'.tr(),
            selected: !_isWork,
            onTap: () => setState(() => _isWork = false),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _TypeOption(
            icon: Icons.work_outline_rounded,
            label: 'addresses.work'.tr(),
            selected: _isWork,
            onTap: () => setState(() => _isWork = true),
          ),
        ),
      ],
    );
  }

  Widget _buildGovernorateDropdown(AddressFormState state) {
    if (state.isLoadingGovernorates && state.governorates.isEmpty) {
      return _LoadingBox();
    }
    return AppDropdownTheme(
      child: DropdownButtonFormField<int>(
        initialValue:
            state.governorates.any((g) => g.id == _selectedGovernorateId)
            ? _selectedGovernorateId
            : null,
        isExpanded: true,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) => value == null ? 'common.required'.tr() : null,
        style: AppTextStyles.of(
          fontSize: 15.sp,
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Colors.grey.shade500,
          size: 20.sp,
        ),
        decoration: authInputDecoration(
          hintText: 'addresses.select_governorate'.tr(),
        ),
        items: state.governorates.map((governorate) {
          return AppDropdownMenuItem<int>(
            value: governorate.id,
            label: governorate.name ?? '',
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedGovernorateId = value;
            _selectedCityId = null;
          });
          context.read<AddressFormCubit>().selectGovernorate(value);
        },
      ),
    );
  }

  Widget _buildCityDropdown(AddressFormState state) {
    final hasGovernorate = _selectedGovernorateId != null;
    if (!hasGovernorate) {
      return _DisabledBox(hint: 'addresses.select_governorate_first'.tr());
    }
    if (state.isLoadingCities) {
      return _LoadingBox();
    }
    return AppDropdownTheme(
      child: DropdownButtonFormField<int>(
        key: ValueKey('city-$_selectedGovernorateId'),
        initialValue: state.cities.any((c) => c.id == _selectedCityId)
            ? _selectedCityId
            : null,
        isExpanded: true,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) => value == null ? 'common.required'.tr() : null,
        style: AppTextStyles.of(
          fontSize: 15.sp,
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Colors.grey.shade500,
          size: 20.sp,
        ),
        decoration: authInputDecoration(hintText: 'addresses.select_city'.tr()),
        items: state.cities.map((city) {
          return AppDropdownMenuItem<int>(
            value: city.id,
            label: city.name ?? '',
          );
        }).toList(),
        onChanged: (value) {
          setState(() => _selectedCityId = value);
        },
      ),
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String hint,
    bool required = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (value) {
        final text = value?.trim() ?? '';
        if (text.isEmpty) {
          return required ? 'common.required'.tr() : null;
        }
        return null;
      },
      style: AppTextStyles.of(
        fontSize: 15.sp,
        color: Colors.black,
        fontWeight: FontWeight.w500,
      ),
      decoration: authInputDecoration(hintText: hint),
    );
  }

  Widget _buildDefaultSwitch() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'addresses.set_as_default'.tr(),
              style: AppTextStyles.of(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Switch(
            value: _isDefault,
            activeThumbColor: kAuthBlue,
            onChanged: (value) => setState(() => _isDefault = value),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationStatus() {
    final hasLocation = _latitude != null && _longitude != null;
    return Row(
      children: [
        Icon(
          hasLocation ? Icons.location_on_rounded : Icons.location_off_outlined,
          size: 18.sp,
          color: hasLocation ? kAuthBlue : const Color(0xFF9CA3AF),
        ),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            _resolvingLocation
                ? 'addresses.getting_location'.tr()
                : hasLocation
                ? 'addresses.location_captured'.tr()
                : 'addresses.location_unavailable'.tr(),
            style: AppTextStyles.of(
              fontSize: 12.5.sp,
              color: const Color(0xFF6B7280),
            ),
          ),
        ),
      ],
    );
  }
}

class _TypeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TypeOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52.h,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEAF1F9) : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: selected ? kAuthBlue : kAuthBorderColor,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20.sp,
              color: selected ? kAuthBlue : const Color(0xFF6B7280),
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: AppTextStyles.of(
                fontSize: 15.sp,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? kAuthBlue : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: kAuthBorderColor),
      ),
      child: SizedBox(
        width: 20.r,
        height: 20.r,
        child: const CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}

class _DisabledBox extends StatelessWidget {
  final String hint;

  const _DisabledBox({required this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.h,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: kAuthBorderColor),
      ),
      child: Text(
        hint,
        style: AppTextStyles.of(
          fontSize: 14.sp,
          color: const Color(0xFFB0B8C1),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;

  const _FieldLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h, top: 4.h),
      child: Text(
        label,
        style: AppTextStyles.of(
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }
}
