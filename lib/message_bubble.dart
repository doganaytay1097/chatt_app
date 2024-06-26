import 'package:chatt_app/constants/styles.dart';
import 'package:flutter/material.dart';
import 'constants/colors.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;

  MessageBubble(this.message, this.isMe);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isMe)
          CircleAvatar(
            child: Text(message[0]), // Placeholder for avatar
          ),
        Container(
          decoration: BoxDecoration(
            color: isMe ? ColorsManager.gray400 : ColorsManager.greenPrimary,
            borderRadius: BorderRadius.circular(12),
          ),
          width: 200,
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: isMe ? TextStyles.font14DarkBlue500Weight : TextStyles.font16White600Weight,
              ),
            ],
          ),
        ),
        if (isMe)
          CircleAvatar(
            child: Text(message[0]), // Placeholder for avatar
          ),
      ],
    );
  }
}
