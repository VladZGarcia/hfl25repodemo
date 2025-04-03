import 'package:flutter/material.dart';
import 'package:parkingapp/views/repositories/parking_space_repository.dart';

class ParkingView extends StatelessWidget {
  const ParkingView({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ParkingSpaceRepository().getAll(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Avaible Parkings',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
              children:
                  snapshot.data!.map((parkingSpace) {
                    return Column(
                      children: [
                        ListTile(
                      title: Text(parkingSpace.adress),
                      subtitle: Text(parkingSpace.spaceId),
                      leading: const Icon(Icons.local_parking),
                    ),
                    
                        const Divider(),
                      ],
                    );
                  }).toList(),
                )
              ]
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error loading parkings: ${snapshot.error}'),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
