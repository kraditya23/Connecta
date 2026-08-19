import 'package:card_app/utilities/constants.dart';
import 'package:flutter/material.dart';
import 'package:card_app/models/user_data.dart';
import 'package:card_app/utilities/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

/// The shared visual for a Connecta business card. Rendered identically for the
/// signed-in user's own card and for other people's cards — only the actions
/// that wrap it (Share / Edit / Exchange Contacts) differ, and those live on
/// the surrounding screens, not here.
class UserCard extends StatelessWidget {
  final UserData data;

  const UserCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final socialLinks = (data.socialNames != null && data.socialUrl != null)
        ? List.generate(data.socialNames!.length, (index) {
            return {
              'url': index < data.socialUrl!.length ? data.socialUrl![index] : '',
              'name': data.socialNames![index],
            };
          }).where((item) => (item['url'] ?? '').isNotEmpty).toList()
        : <Map<String, String>>[];

    final links = (data.linksText != null && data.linkUrl != null)
        ? List.generate(data.linksText!.length, (index) {
            return {
              'title': data.linksText![index],
              'url': index < data.linkUrl!.length ? data.linkUrl![index] : '',
            };
          }).where((item) => (item['url'] ?? '').isNotEmpty).toList()
        : <Map<String, String>>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
          child: _HeroHeader(data: data),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (socialLinks.isNotEmpty) ...[
                const _SectionLabel('Connect with me'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: socialLinks
                      .map((item) => _SocialChip(
                            iconAsset: 'assets/icons/social_icons/${item['name']!.toLowerCase()}.png',
                            url: item['url']!,
                            name: item['name']!,
                          ))
                      .toList(),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              if (data.aboutMe?.isNotEmpty ?? false) ...[
                const _SectionLabel('About'),
                const SizedBox(height: 10),
                Text(
                  data.aboutMe!,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              if (links.isNotEmpty) ...[
                _SectionLabel(
                  data.linkSectionHeader?.isNotEmpty == true ? data.linkSectionHeader! : 'My links',
                ),
                const SizedBox(height: 12),
                ...links.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _LinkTile(title: item['title']!, url: item['url']!),
                    )),
                const SizedBox(height: AppSpacing.sm),
              ],
              if (data.scheduling?.isNotEmpty ?? false) ...[
                const _SectionLabel('Schedule time'),
                const SizedBox(height: 12),
                _ScheduleButton(url: data.scheduling!),
                const SizedBox(height: AppSpacing.lg),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

/// Cover banner + overlapping avatar + identity (name, role, location).
class _HeroHeader extends StatelessWidget {
  final UserData data;
  const _HeroHeader({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const double avatarRadius = 50;
    const double ringWidth = 4;
    // How far the avatar overflows below the cover.
    const double overhang = avatarRadius + ringWidth;

    final roleText = _joinRole(data.jobTitle, data.organisation);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
                child: SizedBox(
                  height: 148,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image(
                        image: (data.coverPicUrl?.isNotEmpty ?? false)
                            ? CachedNetworkImageProvider(data.coverPicUrl!) as ImageProvider
                            : const AssetImage(defaultCover),
                        fit: BoxFit.cover,
                      ),
                      // Subtle bottom scrim for depth behind the avatar.
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.28),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: -overhang,
                child: Container(
                  padding: const EdgeInsets.all(ringWidth),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.cardColor,
                  ),
                  child: CircleAvatar(
                    radius: avatarRadius,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    backgroundImage: (data.profilePicUrl?.isNotEmpty ?? false)
                        ? CachedNetworkImageProvider(data.profilePicUrl!)
                        : const AssetImage(defaultAvatar) as ImageProvider,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: overhang + 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(
              data.name?.isNotEmpty == true ? data.name! : data.username,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall,
            ),
          ),
          if (roleText != null) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                roleText,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
          if (data.location?.isNotEmpty ?? false) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on_outlined, size: 15, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  data.location!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  static String? _joinRole(String? jobTitle, String? organisation) {
    final hasJob = jobTitle?.isNotEmpty ?? false;
    final hasOrg = organisation?.isNotEmpty ?? false;
    if (hasJob && hasOrg) return '$jobTitle · $organisation';
    if (hasJob) return jobTitle;
    if (hasOrg) return organisation;
    return null;
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;
  const _SectionLabel(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            fontSize: 12,
          ),
    );
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
    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        onTap: () => _launchURL(context, url),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: theme.colorScheme.outline),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                iconAsset,
                width: 18,
                height: 18,
                errorBuilder: (_, __, ___) =>
                    Icon(Icons.link_rounded, size: 18, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 8),
              Text(name, style: theme.textTheme.labelMedium),
            ],
          ),
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
    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: () => _launchURL(context, url),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: theme.colorScheme.outline),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(Icons.link_rounded, size: 20, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      url,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_outward_rounded, size: 18, color: theme.colorScheme.onSurfaceVariant),
            ],
          ),
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
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: () => _launchURL(context, url),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
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
                    Text('Book an appointment',
                        style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                    SizedBox(height: 2),
                    Text('Schedule time with me',
                        style: TextStyle(fontSize: 13, color: Colors.white70)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_rounded, color: Colors.white),
            ],
          ),
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
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Could not open the link')));
  }
}
