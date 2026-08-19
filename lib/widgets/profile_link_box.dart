import 'package:card_app/widgets/snackbars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfileLinkBox extends StatelessWidget {
  final String profileLink;

  const ProfileLinkBox({super.key, required this.profileLink});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        color: theme.colorScheme.surfaceContainerHighest,
        elevation: 1,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Clipboard.setData(ClipboardData(text: profileLink));
            context.showNeutralSnackBar(
              message: 'Copied to clipboard!',
              icon: Icons.copy,
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    profileLink,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: 0.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.copy_rounded, size: 20, color: theme.colorScheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
