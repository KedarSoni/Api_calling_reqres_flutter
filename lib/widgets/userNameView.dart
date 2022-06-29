import 'package:flutter/material.dart';

import '../models/UsersResponse.dart';
import '../utility/appColors.dart';

class UserNameView extends StatelessWidget {
  UserDetails userDetails;
  bool isDetailScreen;
  UserNameView({
    @required this.userDetails,
    @required this.isDetailScreen,
  });

  @override
  Widget build(BuildContext context) {
    String name = userDetails?.firstName == null
        ? ""
        : userDetails.firstName + " " + userDetails.lastName;
    return Text(
      name,
      style: TextStyle(
        fontSize: isDetailScreen ? 20 : 18,
        color: AppColors.blackColor,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
