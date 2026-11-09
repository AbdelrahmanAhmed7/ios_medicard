import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/services/url_launcher_service.dart';
import '../../../../network/data/provider_page_response_model.dart';

import 'package:medicard/core/theming/app_colors.dart';
class CheckoutMapPreview extends StatefulWidget {
  final ProviderBranch branch;

  const CheckoutMapPreview({super.key, required this.branch});

  @override
  State<CheckoutMapPreview> createState() => CheckoutMapPreviewState();
}

class CheckoutMapPreviewState extends State<CheckoutMapPreview> {
  final _mapController = MapController();

  LatLng? get _point {
    final latitude = widget.branch.latitude;
    final longitude = widget.branch.longitude;
    if (latitude == null || longitude == null) return null;
    return LatLng(latitude, longitude);
  }

  @override
  void didUpdateWidget(covariant CheckoutMapPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    final point = _point;
    if (point == null) return;
    if (oldWidget.branch.branchId != widget.branch.branchId ||
        oldWidget.branch.latitude != widget.branch.latitude ||
        oldWidget.branch.longitude != widget.branch.longitude) {
      _mapController.move(point, 14);
    }
  }

  @override
  Widget build(BuildContext context) {
    final point = _point;
    final hasLocation = point != null;

    return GestureDetector(
      onTap: () {
        final url = widget.branch.mapUrl;
        if (url != null && url.isNotEmpty) {
          UrlLauncherService().launchURL(url);
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16.r)),
        child: Container(
          width: double.infinity,
          height: 146.h,
          color: AppColors.exactFFE5E7EB,
          child: !hasLocation
              ? const Center(child: Icon(Icons.map_outlined))
              : FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: point,
                    initialZoom: 14,
                    interactionOptions: const InteractionOptions(
                      flags:
                          InteractiveFlag.drag |
                          InteractiveFlag.pinchZoom |
                          InteractiveFlag.doubleTapZoom,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.medicard',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: point,
                          width: 42.r,
                          height: 42.r,
                          child: Icon(
                            Icons.location_on,
                            color: AppColors.brandBlueClr,
                            size: 38.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

