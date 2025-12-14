import 'package:flutter/material.dart';
import '../../models/user.dart';

class UserTile extends StatelessWidget {
  const UserTile({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(fontWeight: FontWeight.w600);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          ClipOval(
            child: Image.asset(
              'images/profile.png',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.name, style: textStyle),
              Text(user.company, style: textStyle),
            ],
          ),
        ],
      ),
    );
  }
}
