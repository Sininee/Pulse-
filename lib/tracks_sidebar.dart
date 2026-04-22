import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'app_theme.dart';

enum LibrarySection {
  tracks,
  playlists,
}

class TracksOnlySidebar extends StatefulWidget {
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
  State<TracksOnlySidebar> createState() => _TracksOnlySidebarState();
}

class _TracksOnlySidebarState extends State<TracksOnlySidebar> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();

    if (!mounted) return;

    setState(() {
      _appVersion = info.version;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                          'My Library',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: widget.onClose,
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _SidebarItem(
                      icon: Icons.music_note_outlined,
                      label: 'Tracks',
                      selected: widget.selectedSection == LibrarySection.tracks,
                      onTap: () => widget.onSelectSection(LibrarySection.tracks),
                    ),
                    const SizedBox(height: 10),
                    _SidebarItem(
                      icon: Icons.queue_music_rounded,
                      label: 'Playlists',
                      selected: widget.selectedSection == LibrarySection.playlists,
                      onTap: () => widget.onSelectSection(LibrarySection.playlists),
                    ),
                    const Spacer(),
                    if (_appVersion.isNotEmpty)
                      Text(
                        'Pulse $_appVersion',
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
                      title: const Text('Logout'),
                      onTap: widget.onLogout,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: widget.onClose,
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