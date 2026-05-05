import 'package:flutter/material.dart';
import 'package:prime_flutter/prime_flutter.dart';

enum ListItemGroupPageStyle { basic, withTrailing }

class ListItemGroupPage extends StatelessWidget {
  final ListItemGroupPageStyle style;

  const ListItemGroupPage({super.key, required this.style});

  @override
  Widget build(BuildContext context) {
    return PrimeScaffold(
      body: Center(
        child: SizedBox(
          width: 350,
          child: switch (style) {
            ListItemGroupPageStyle.basic => ListItemGroup(
              children: [
                ListItem(
                  leading: const Icon(PrimeIcons.cameraOutline),
                  title: const Text('Take and upload image'),
                  onPressed: () {},
                ),
                ListItem(
                  leading: const Icon(PrimeIcons.upload),
                  title: const Text('Upload images from camera roll'),
                  onPressed: () {},
                ),
              ],
            ),
            ListItemGroupPageStyle.withTrailing => ListItemGroup(
              children: [
                ListItem(
                  leading: const Icon(PrimeIcons.cog),
                  title: const Text('Settings'),
                  trailing: const Icon(PrimeIcons.chevronRight),
                  onPressed: () {},
                ),
                ListItem(
                  leading: const Icon(PrimeIcons.accountGroupOutline),
                  title: const Text('Team'),
                  trailing: const Icon(PrimeIcons.chevronRight),
                  onPressed: () {},
                ),
                ListItem(
                  leading: const Icon(PrimeIcons.article),
                  title: const Text('Documents'),
                  trailing: const Icon(PrimeIcons.chevronRight),
                  onPressed: () {},
                ),
              ],
            ),
          },
        ),
      ),
    );
  }
}
