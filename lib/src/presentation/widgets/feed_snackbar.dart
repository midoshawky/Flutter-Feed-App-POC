import 'package:flutter/material.dart';

void showFeedSnackBar(BuildContext context, String message) {
  final windowWidth = MediaQuery.of(context).size.width;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: windowWidth > 600  ? SnackBarBehavior.floating : SnackBarBehavior.fixed,
      padding: EdgeInsets.zero,
      
      content: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
        Container(
          width: windowWidth > 600 ? 300 : windowWidth,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        
        decoration: BoxDecoration(
          color: const Color(0xFFF2FAF6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: Color(0xFF47B881),
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Color(0xFF47B881),
                  fontSize: 14,
                  fontFamily: 'Product Sans',
                  height: 1.43,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
              child: const Icon(
                Icons.close,
                color: Color(0xFF47B881),
                size: 16,
              ),
            ),
          ],
        ),
      )
      ],),
    ),
  );
}
