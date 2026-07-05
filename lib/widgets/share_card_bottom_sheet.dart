// libraries imports
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

// scripts imports
import 'package:card_app/models/user_data.dart';
import 'package:card_app/utilities/app_colors.dart';
import 'package:card_app/utilities/vcard_utils.dart';
import 'package:card_app/utilities/branch_share_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'qr_code_with_image.dart';
import 'package:card_app/utilities/constants.dart';
import 'profile_link_box.dart';
import 'list_item.dart';

class ShareCardBottomSheet extends StatefulWidget {
  final UserData userData;
  const ShareCardBottomSheet({super.key, required this.userData});

  @override
  State<ShareCardBottomSheet> createState() => _ShareCardBottomSheetState();
}

class _ShareCardBottomSheetState extends State<ShareCardBottomSheet> {
  bool showVcard = false;
  late Future<String> branchLinkFuture;
  final GlobalKey _qrGlobalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    branchLinkFuture = createBranchShareLink(
      widget.userData.uid,
      widget.userData.username,
      widget.userData.name ?? widget.userData.username
    );
  }

  /// Capture the RepaintBoundary as PNG bytes
  Future<Uint8List?> _capturePngBytes() async {
    try {
      final boundary = _qrGlobalKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;
      return byteData.buffer.asUint8List();
    } catch (e) {
      debugPrint("Error capturing QR image: $e");
      return null;
    }
  }

  /// Write the PNG bytes to a temp file and open the share sheet
  Future<void> _shareQrImage() async {
    final pngBytes = await _capturePngBytes();
    if (pngBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to capture QR code.')),
      );
      return;
    }

    // 1. Save to a temporary file
    final tempDir = await getTemporaryDirectory();
    final filePath =
        '${tempDir.path}/connecta_qr_${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File(filePath);
    await file.writeAsBytes(pngBytes);

    // 2. Launch the native share sheet with that PNG
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(filePath, mimeType: 'image/png')],
        text: "Here's my Connecta QR code!",
        subject: 'Connecta QR',
      ),
    );

    // (Optional) Delete the temp file after a short delay
    // Future.delayed(const Duration(seconds: 5), () => file.delete());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: branchLinkFuture,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const Center(child: CircularProgressIndicator());
          default:
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Failed to generate share link.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: Text('No link available'));
            }
            final branchLink = snapshot.data!;
            return SizedBox(
              width: MediaQuery.of(context).size.width,
              child: DraggableScrollableSheet(
                expand: false,
                initialChildSize: 0.75,
                minChildSize: 0.7,
                maxChildSize: 0.9,
                builder: (context, scrollController) {
                  return StatefulBuilder(
                    builder: (context, setState) {
                      final qrData = showVcard
                          ? generateMinimalVCardFromUserData(widget.userData)
                          : branchLink;

                      return SingleChildScrollView(
                        controller: scrollController,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Container(
                                height: 5,
                                width: 40,
                                decoration: BoxDecoration(
                                  color: Colors.grey[400],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              const SizedBox(height: 20),
                              RepaintBoundary(
                                key: _qrGlobalKey,
                                child: QRCodeWithImage(
                                  data: qrData,
                                  imageProvider: const AssetImage(appLogo),
                                  width: 200,
                                  qrColor: qrColor,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                showVcard
                                    ? 'Scan to save contact offline'
                                    : 'Scan this to view my business card',
                                style: const TextStyle(fontSize: 16),
                              ),
                              ProfileLinkBox(profileLink: branchLink),
                              SwitchListTile(
                                value: showVcard,
                                activeColor: primaryColor,
                                onChanged: (val) {
                                  setState(() => showVcard = val);
                                },
                                title: const Text('Offline QR (vCard)'),
                              ),
                              const SizedBox(height: 20),
                              Material(
                                color: Colors.white,
                                elevation: 4,
                                borderRadius: BorderRadius.circular(16),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Column(
                                    children: [
                                      // Share profile link (URL)…
                                      ShareOptionTile(
                                        icon: Icons.link,
                                        title: 'Share profile link',
                                        onTap: () async {
                                          final shareText = StringBuffer()
                                            ..writeln(
                                                'Check out my profile on Connecta:')
                                            ..writeln(branchLink);
                                          await SharePlus.instance.share(
                                            ShareParams(
                                              text: shareText.toString(),
                                              subject:
                                                  'Connecta Profile: ${widget.userData.username}',
                                            ),
                                          );
                                        },
                                        iconColor: primaryColor,
                                      ),
                                      const Divider(height: 1, color: Colors.grey),
                                      // Share via SMS (body + URL)…
                                      ShareOptionTile(
                                        icon: Icons.sms,
                                        title: 'Share via text',
                                        onTap: () async {
                                          final shareText = StringBuffer()
                                            ..writeln(
                                                'Check out my profile on Connecta:')
                                            ..writeln(branchLink);
                                          final encodedText =
                                              Uri.encodeComponent(shareText.toString());
                                          final uri =
                                              Uri.parse('sms:?body=$encodedText');
                                          if (await canLaunchUrl(uri)) {
                                            await launchUrl(uri);
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Could not open SMS app.'),
                                              ),
                                            );
                                          }
                                        },
                                        iconColor: primaryColor,
                                      ),
                                      const Divider(height: 1, color: Colors.grey),
                                      // “Save QR to phone” now just opens a share sheet for the PNG…
                                      ShareOptionTile(
                                        icon: Icons.download,
                                        title: 'Share QR image',
                                        onTap: _shareQrImage,
                                        iconColor: primaryColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            );
        }
      },
    );
  }
}