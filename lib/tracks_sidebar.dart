import 'package:flutter/material.dart';

import 'app_language.dart';
import 'app_theme.dart';
import 'app_version.dart';

enum LibrarySection {
  tracks,
  albums,
  playlists,
}

class TracksOnlySidebar extends StatelessWidget {
  const TracksOnlySidebar({
    super.key,
    required this.onClose,
    required this.onLogout,
    required this.selectedSection,
    required this.onSelectSection,
  });

  final VoidCallback onClose;
  final VoidCallback onLogout;
  final LibrarySection selectedSection;
  final ValueChanged<LibrarySection> onSelectSection;

  @override
  Widget build(BuildContext context) {
    final text = t(context);
    final controller = AppLanguageScope.controllerOf(context);

    return Positioned.fill(
      child: Material(
        color: Colors.black.withAlpha(102),
        child: Row(
          children: [
            Container(
              width: 240,
              decoration: const BoxDecoration(
                color: AppColors.sidebar,
                border: Border(right: BorderSide(color: AppColors.border)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          text.get('myLibrary'),
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: onClose,
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _SidebarItem(
                      icon: Icons.music_note_outlined,
                      label: text.get('tracks'),
                      selected: selectedSection == LibrarySection.tracks,
                      onTap: () => onSelectSection(LibrarySection.tracks),
                    ),

                    const SizedBox(height: 10),

                    _SidebarItem(
                      icon: Icons.album_rounded,
                      label: text.get('albums'),
                      selected: selectedSection == LibrarySection.albums,
                      onTap: () => onSelectSection(LibrarySection.albums),
                    ),

                    const SizedBox(height: 10),

                    _SidebarItem(
                      icon: Icons.queue_music_rounded,
                      label: text.get('playlists'),
                      selected: selectedSection == LibrarySection.playlists,
                      onTap: () => onSelectSection(LibrarySection.playlists),
                    ),

                    const Spacer(),

                    Text(
                      text.get('language'),
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.panel,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: controller.code,
                          isExpanded: true,
                          dropdownColor: AppColors.panel,
                          items: appLanguages.map((language) {
                            return DropdownMenuItem(
                              value: language.code,
                              child: Text(language.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              controller.setLanguage(value);
                            }
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Pulse ${AppVersion.version}',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 10),
                    const Divider(),

                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.logout),
                      title: Text(text.get('logout')),
                      onTap: onLogout,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: onClose,
                child: Container(color: Colors.transparent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0E234F) : AppColors.panel,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? AppColors.accent : Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}