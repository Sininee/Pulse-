import 'package:flutter/material.dart';

import 'app_theme.dart';

class TracksTopBar extends StatelessWidget {
  const TracksTopBar({
    super.key,
    required this.onSearchChanged,
    required this.onMenuPressed,
    this.hintText = 'Search tracks or artists...',
  });

  final ValueChanged<String> onSearchChanged;
  final VoidCallback onMenuPressed;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          SquareButton(icon: Icons.menu, onTap: onMenuPressed),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.panelAlt,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                onChanged: onSearchChanged,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                  hintText: hintText,
                  hintStyle: const TextStyle(color: AppColors.textMuted),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}