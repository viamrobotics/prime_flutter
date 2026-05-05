import 'package:flutter/widgets.dart';
import 'package:prime_flutter/prime_flutter.dart';

class ListItemGroupScreen extends StatelessWidget {
  const ListItemGroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);
    return PrimeScaffold(
      appBar: const PrimeAppBar(title: Text('List Item Group')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Two-Row Group', style: theme.textTheme.title),
            const SizedBox(height: 16),
            ListItemGroup(
              children: [
                ListItem(
                  leading: const Icon(PrimeIcons.cameraOutline),
                  title: const Text('Take and upload image'),
                  onPressed: () {
                    print('Take photo');
                  },
                ),
                ListItem(
                  leading: const Icon(PrimeIcons.upload),
                  title: const Text('Upload images from camera roll'),
                  onPressed: () {
                    print('Pick from camera roll');
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),
            Text('Three-Row Group', style: theme.textTheme.title),
            const SizedBox(height: 16),
            ListItemGroup(
              children: [
                ListItem(
                  leading: const Icon(PrimeIcons.cog),
                  title: const Text('Settings'),
                  onPressed: () {
                    print('Settings');
                  },
                ),
                ListItem(
                  leading: const Icon(PrimeIcons.accountGroupOutline),
                  title: const Text('Team'),
                  onPressed: () {
                    print('Team');
                  },
                ),
                ListItem(
                  leading: const Icon(PrimeIcons.article),
                  title: const Text('Documents'),
                  onPressed: () {
                    print('Documents');
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),
            Text('With Trailing', style: theme.textTheme.title),
            const SizedBox(height: 16),
            ListItemGroup(
              children: [
                ListItem(
                  leading: const Icon(PrimeIcons.alert),
                  title: const Text('Account'),
                  trailing: const Icon(PrimeIcons.chevronRight),
                  onPressed: () {
                    print('Account');
                  },
                ),
                ListItem(
                  leading: const Icon(PrimeIcons.send),
                  title: const Text('Privacy'),
                  trailing: const Icon(PrimeIcons.chevronRight),
                  onPressed: () {
                    print('Privacy');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
