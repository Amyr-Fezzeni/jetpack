import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jetpack/models/user.dart';
import 'package:jetpack/services/util/ext.dart';

class DeliveryTrackingMap extends StatefulWidget {
  final UserModel delivery;
  const DeliveryTrackingMap({super.key, required this.delivery});

  @override
  State<DeliveryTrackingMap> createState() => _DeliveryTrackingMapState();
}

class _DeliveryTrackingMapState extends State<DeliveryTrackingMap> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.h * .7,
      width: context.w * .8,
      child: GoogleMap(
        markers: {
          Marker(
              markerId: const MarkerId('Delivery'),
              position: widget.delivery.location!),
        },

        // scrollGesturesEnabled: false,
        zoomGesturesEnabled: true,
        zoomControlsEnabled: true,
        myLocationButtonEnabled: false,
        onMapCreated: (controller) {},
        initialCameraPosition:
            CameraPosition(zoom: 10, target: widget.delivery.location!),
      ),
    );
  }
}
