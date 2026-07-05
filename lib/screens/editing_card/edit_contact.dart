import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_app/providers/user_provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:card_app/utilities/app_colors.dart';
import 'package:card_app/services/storage/supabase_storage_service.dart';
import 'package:card_app/utilities/constants.dart';
import 'package:card_app/widgets/snackbars.dart';

class LabeledField {
  String label;
  TextEditingController controller;
  LabeledField({required this.label, required this.controller});
}

class EditContactInfo extends ConsumerStatefulWidget {
  const EditContactInfo({super.key});

  @override
  ConsumerState<EditContactInfo> createState() => _EditContactInfoState();
}

class _EditContactInfoState extends ConsumerState<EditContactInfo> {
  File? _selectedCoverImage;
  File? _selectedProfilePicImage;
  late TextEditingController nameController;
  late TextEditingController jobTitleController;
  late TextEditingController organisationController;
  late TextEditingController locationController;
  late TextEditingController addressController;
  late List<LabeledField> phoneFields;
  late List<LabeledField> emailFields;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProvider).value;

    nameController = TextEditingController(text: user?.name ?? '');
    jobTitleController = TextEditingController(text: user?.jobTitle ?? '');
    organisationController = TextEditingController(text: user?.organisation ?? '');
    locationController = TextEditingController(text: user?.location ?? '');
    addressController = TextEditingController(text: user?.address ?? '');

    final phoneList = user?.phoneNumbers;
    final emailList = user?.emails;

    phoneFields = (phoneList != null && phoneList.isNotEmpty)
        ? phoneList.map((p) => LabeledField(label: 'mobile', controller: TextEditingController(text: p))).toList()
        : [LabeledField(label: 'mobile', controller: TextEditingController())];

    emailFields = (emailList != null && emailList.isNotEmpty)
        ? emailList.map((e) => LabeledField(label: 'home', controller: TextEditingController(text: e))).toList()
        : [LabeledField(label: 'home', controller: TextEditingController())];
  }

  @override
  void dispose() {
    nameController.dispose();
    jobTitleController.dispose();
    organisationController.dispose();
    locationController.dispose();
    addressController.dispose();
    for (var field in phoneFields) {
      field.controller.dispose();
    }
    for (var field in emailFields) {
      field.controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage(bool isCover) async {
    final pickedfile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedfile != null) {
      final imageFile = File(pickedfile.path);
      setState(() {
        if (isCover) {
          _selectedCoverImage = imageFile;
        } else {
          _selectedProfilePicImage = imageFile;
        }
      });
    }
  }

  void _showCupertinoLabelPicker(
    BuildContext context,
    List<String> options,
    String currentLabel,
    Function(String) onSelected,
  ) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: options
            .map((label) => CupertinoActionSheetAction(
                  onPressed: () {
                    onSelected(label);
                    Navigator.pop(context);
                  },
                  child: Text(label),
                ))
            .toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final user = ref.read(userProvider).value;
    if (user == null || _isSaving) return;

    if (nameController.text.trim().isEmpty) {
      context.showErrorSnackBar(message: 'Please add your name.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      String profilePicUrl = user.profilePicUrl ?? '';
      String coverPicUrl = user.coverPicUrl ?? '';

      if (_selectedProfilePicImage != null) {
        profilePicUrl = await SupabaseStorageService()
            .uploadProfilePic(_selectedProfilePicImage!, user.uid);
      }
      if (_selectedCoverImage != null) {
        coverPicUrl = await SupabaseStorageService()
            .uploadCoverPic(_selectedCoverImage!, user.uid);
      }

      final phones = phoneFields.map((f) => f.controller.text.trim()).where((e) => e.isNotEmpty).toList();
      final emails = emailFields.map((f) => f.controller.text.trim()).where((e) => e.isNotEmpty).toList();

      await ref.read(userProvider.notifier).updateContactInfo(
            name: nameController.text.trim(),
            profilePicUrl: profilePicUrl,
            coverPicUrl: coverPicUrl,
            jobTitle: jobTitleController.text.trim(),
            organisation: organisationController.text.trim(),
            location: locationController.text.trim(),
            address: addressController.text.trim(),
            phoneNumbers: phones,
            emails: emails,
          );

      if (!mounted) return;
      context.showSuccessSnackBar(message: 'Profile updated successfully!');
      Navigator.pop(context);
    } catch (e) {
      if (mounted) context.showErrorSnackBar(message: 'Failed to save: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider).value;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Contact Info')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            SizedBox(
              height: 180,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  GestureDetector(
                    onTap: () => _pickImage(true),
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        image: DecorationImage(
                          image: _selectedCoverImage != null
                              ? FileImage(_selectedCoverImage!)
                              : (user?.coverPicUrl?.isNotEmpty == true)
                                  ? NetworkImage(user!.coverPicUrl!)
                                  : const AssetImage(defaultCover) as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: const Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.camera_alt, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -25,
                    left: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => _pickImage(false),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: theme.scaffoldBackgroundColor,
                        child: CircleAvatar(
                          radius: 56,
                          backgroundImage: _selectedProfilePicImage != null
                              ? FileImage(_selectedProfilePicImage!)
                              : (user?.profilePicUrl?.isNotEmpty == true)
                                  ? NetworkImage(user!.profilePicUrl!)
                                  : const AssetImage(defaultAvatar) as ImageProvider,
                          child: const Align(
                            alignment: Alignment.bottomRight,
                            child: Icon(Icons.camera_alt, size: 20),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 16),
            TextField(controller: jobTitleController, decoration: const InputDecoration(labelText: 'Job title')),
            const SizedBox(height: 16),
            TextField(
              controller: organisationController,
              decoration: const InputDecoration(labelText: 'Organisation / Company'),
            ),
            const SizedBox(height: 16),
            TextField(controller: locationController, decoration: const InputDecoration(labelText: 'Location')),
            const SizedBox(height: 16),
            TextField(controller: addressController, decoration: const InputDecoration(labelText: 'Address')),
            const SizedBox(height: 20),
            _FieldGroup(
              title: 'Phone numbers',
              fields: phoneFields,
              labelOptions: const ['mobile', 'home', 'work'],
              keyboardType: TextInputType.phone,
              placeholder: 'Phone',
              addLabel: 'Add phone',
              onAdd: () => setState(() => phoneFields.add(LabeledField(label: 'mobile', controller: TextEditingController()))),
              onRemove: (field) => setState(() => phoneFields.remove(field)),
              onLabelPick: _showCupertinoLabelPicker,
              onChanged: () => setState(() {}),
            ),
            const SizedBox(height: 16),
            _FieldGroup(
              title: 'Emails',
              fields: emailFields,
              labelOptions: const ['home', 'work'],
              keyboardType: TextInputType.emailAddress,
              placeholder: 'Email',
              addLabel: 'Add email',
              onAdd: () => setState(() => emailFields.add(LabeledField(label: 'home', controller: TextEditingController()))),
              onRemove: (field) => setState(() => emailFields.remove(field)),
              onLabelPick: _showCupertinoLabelPicker,
              onChanged: () => setState(() {}),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: ElevatedButton.icon(
            onPressed: _isSaving ? null : _save,
            icon: _isSaving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.save_outlined),
            label: Text(_isSaving ? 'Saving...' : 'Save changes'),
          ),
        ),
      ),
    );
  }
}

class _FieldGroup extends StatelessWidget {
  final String title;
  final List<LabeledField> fields;
  final List<String> labelOptions;
  final TextInputType keyboardType;
  final String placeholder;
  final String addLabel;
  final VoidCallback onAdd;
  final void Function(LabeledField) onRemove;
  final void Function(BuildContext, List<String>, String, Function(String)) onLabelPick;
  final VoidCallback onChanged;

  const _FieldGroup({
    required this.title,
    required this.fields,
    required this.labelOptions,
    required this.keyboardType,
    required this.placeholder,
    required this.addLabel,
    required this.onAdd,
    required this.onRemove,
    required this.onLabelPick,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Align(alignment: Alignment.centerLeft, child: Text(title, style: theme.textTheme.titleSmall)),
          ...fields.map(
            (field) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    color: CupertinoColors.systemGrey5,
                    minimumSize: const Size(30, 30),
                    onPressed: () => onLabelPick(context, labelOptions, field.label, (val) {
                      field.label = val;
                      onChanged();
                    }),
                    child: Text(field.label, style: const TextStyle(fontSize: 14)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CupertinoTextField(
                      controller: field.controller,
                      placeholder: placeholder,
                      keyboardType: keyboardType,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle, color: errorColor),
                    onPressed: () => onRemove(field),
                  ),
                ],
              ),
            ),
          ),
          TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_circle, color: successColor),
            label: Text(addLabel, style: const TextStyle(color: successColor)),
          ),
        ],
      ),
    );
  }
}
