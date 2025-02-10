import 'package:flutter/material.dart';

Widget buildStatCard(
    String title, Color cardcolor, int count, Color iconcolor, IconData icon) {
  return Expanded(
    child: Card(
      color: cardcolor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconcolor, size: 30),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              '$count',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: iconcolor),
            ),
          ],
        ),
      ),
    ),
  );
}
