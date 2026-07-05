import 'package:flutter/material.dart';
import 'edit_contact.dart';
import 'card_button.dart';
import 'edit_content.dart';

class EditScreenNavigator extends StatelessWidget {
  const EditScreenNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose what to edit')),
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            buildCardButton(
              iconAdress: 'assets/icons/editing_card/edit-contact-info.png',
              title: 'Edit Contact Info',
              subtitle: 'This is what people save to their contacts when you choose to share offline!',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const EditContactInfo()));
              },
              height: 150,
            ),
            buildCardButton(
              iconAdress: 'assets/icons/editing_card/add-contents.png',
              title: 'Add Contents to Card',
              subtitle:
                  'Choose the content you would like to show on your page. You can edit, reorder, or remove it later!',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const EditContentsScreen()));
              },
              height: 150,
            ),
          ],
        ),
      ),
    );
  }
}