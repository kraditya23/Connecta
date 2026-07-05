import 'package:card_app/utilities/constants.dart';
import 'package:flutter/material.dart';
import 'package:card_app/models/user_data.dart';
import 'package:card_app/utilities/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

class UserCard extends StatelessWidget {
  final UserData data;
  final Widget? editIcon;

  const UserCard({super.key, required this.data, this.editIcon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final validSocialLinks = (data.socialNames != null && data.socialUrl != null)
        ? List.generate(data.socialNames!.length, (index) {
            return {
              'url': index < data.socialUrl!.length ? data.socialUrl![index] : '',
              'name': data.socialNames![index],
            };
          }).where((item) => (item['url'] ?? '').isNotEmpty).toList()
        : <Map<String, String>>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
                          image: DecorationImage(
                            image: (data.coverPicUrl?.isNotEmpty ?? false)
                                ? CachedNetworkImageProvider(data.coverPicUrl!)
                                : const AssetImage(defaultCover) as ImageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -50,
                        left: 0,
                        right: 0,
                        child: Align(
                          alignment: Alignment.center,
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: theme.cardColor,
                            child: CircleAvatar(
                              radius: 56,
                              backgroundImage: (data.profilePicUrl?.isNotEmpty ?? false)
                                  ? CachedNetworkImageProvider(data.profilePicUrl!)
                                  : const AssetImage(defaultAvatar) as ImageProvider,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 17),
                  editIcon ?? const SizedBox(height: 50),
                  Text(
                    data.name ?? data.username,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 2),
                  if ((data.jobTitle?.isNotEmpty ?? false) && (data.organisation?.isNotEmpty ?? false))
                    Text('${data.jobTitle}, ${data.organisation}', style: theme.textTheme.bodyMedium)
                  else if (data.jobTitle?.isNotEmpty ?? false)
                    Text(data.jobTitle!, style: theme.textTheme.bodyMedium)
                  else if (data.organisation?.isNotEmpty ?? false)
                    Text(data.organisation!, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (validSocialLinks.isNotEmpty) ...[
                _SectionLabel('Connect with me'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: validSocialLinks
                      .map((item) => _SocialChip(
                            iconAsset: 'assets/icons/social_icons/${item['name']!.toLowerCase()}.png',
                            url: item['url']!,
                            name: item['name']!,
                          ))
                      .toList(),
                ),
                const SizedBox(height: 20),
              ],
              if (data.aboutMe?.isNotEmpty ?? false) ...[
                _SectionLabel('About me'),
                const SizedBox(height: 8),
                Text(data.aboutMe!, style: theme.textTheme.bodyMedium?.copyWith(height: 1.6)),
                const SizedBox(height: 20),
              ],
              if ((data.linksText?.isNotEmpty ?? false) && (data.linkUrl?.isNotEmpty ?? false)) ...[
                _SectionLabel(data.linkSectionHeader?.isNotEmpty == true ? data.linkSectionHeader! : 'My links'),
                const SizedBox(height: 12),
                ...List.generate(data.linksText!.length, (index) {
                  if (index >= data.linkUrl!.length || data.linkUrl![index].isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _LinkTile(title: data.linksText![index], url: data.linkUrl![index]),
                  );
                }),
                const SizedBox(height: 16),
              ],
              if (data.scheduling?.isNotEmpty ?? false) ...[
                _SectionLabel('Schedule time'),
                const SizedBox(height: 12),
                _ScheduleButton(url: data.scheduling!),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;
  const _SectionLabel(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleSmall);
  }
}

class _SocialChip extends StatelessWidget {
  final String iconAsset;
  final String url;
  final String name;
  const _SocialChip({required this.iconAsset, required this.url, required this.name});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _launchURL(context, url),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
          border: Border.all(color: theme.colorScheme.outline),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(iconAsset, width: 16, height: 16, errorBuilder: (_, __, ___) => const Icon(Icons.link, size: 16)),
            const SizedBox(width: 8),
            Text(name, style: theme.textTheme.labelMedium),
          ],
        ),
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  final String title;
  final String url;
  const _LinkTile({required this.title, required this.url});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _launchURL(context, url),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
          border: Border.all(color: theme.colorScheme.outline),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.link_rounded, size: 18, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                  Text(url, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _ScheduleButton extends StatelessWidget {
  final String url;
  const _ScheduleButton({required this.url});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _launchURL(context, url),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [primaryColor, primaryColorDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Row(
          children: [
            Icon(Icons.calendar_today_rounded, size: 20, color: Colors.white),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Book an appointment', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                  SizedBox(height: 2),
                  Text('Schedule time with me', style: TextStyle(fontSize: 13, color: Colors.white70)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_rounded, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

Future<void> _launchURL(BuildContext context, String url) async {
  final uri = Uri.tryParse(url);
  if (uri != null && await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open the link')));
  }
}