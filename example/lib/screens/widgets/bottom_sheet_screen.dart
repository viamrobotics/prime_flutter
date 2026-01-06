import 'package:flutter/widgets.dart';
import 'package:prime_flutter/prime_flutter.dart';

class BottomSheetScreen extends StatelessWidget {
  const BottomSheetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PrimeScaffold(
      appBar: const PrimeAppBar(title: Text('Bottom Sheet')),
      body: Center(
        child: Column(
          spacing: 16.0,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Button(
              label: const Text('Simple Sheet'),
              onPressed: () {
                BottomSheet.show(
                  context: context,
                  child: const Padding(padding: EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 24.0), child: Text('This is a simple bottom sheet.')),
                );
              },
            ),

            Button(
              label: const Text('Sheet with Title'),
              onPressed: () {
                BottomSheet.show(
                  context: context,
                  title: const Text('Sheet Title'),
                  child: Padding(padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 24.0), child: Text('This sheet has a title.')),
                );
              },
            ),

            Button(
              label: const Text('Scrolling List Sheet'),
              onPressed: () {
                BottomSheet.show(
                  context: context,
                  title: const Text('Sheet Title'),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListItem(title: const Text('Option 1'), leading: const Icon(PrimeIcons.robotOutline), onPressed: () {}),
                      const Divider(),
                      ListItem(title: const Text('Option 2'), leading: const Icon(PrimeIcons.cog), onPressed: () {}),
                      const Divider(),
                      ListItem(title: const Text('Option 3'), leading: const Icon(PrimeIcons.logout), onPressed: () {}),
                      const Divider(),
                      ListItem(title: const Text('Option 4'), leading: const Icon(PrimeIcons.robotOutline), onPressed: () {}),
                      const Divider(),
                      ListItem(title: const Text('Option 5'), leading: const Icon(PrimeIcons.cog), onPressed: () {}),
                      const Divider(),
                      ListItem(title: const Text('Option 6'), leading: const Icon(PrimeIcons.logout), onPressed: () {}),
                      const Divider(),
                      ListItem(title: const Text('Option 7'), leading: const Icon(PrimeIcons.robotOutline), onPressed: () {}),
                      const Divider(),
                      ListItem(title: const Text('Option 8'), leading: const Icon(PrimeIcons.cog), onPressed: () {}),
                      const Divider(),
                      ListItem(title: const Text('Option 9'), leading: const Icon(PrimeIcons.logout), onPressed: () {}),
                      const Divider(),
                      ListItem(title: const Text('Option 10'), leading: const Icon(PrimeIcons.robotOutline), onPressed: () {}),
                      const Divider(),
                      ListItem(title: const Text('Option 11'), leading: const Icon(PrimeIcons.cog), onPressed: () {}),
                      const Divider(),
                      ListItem(title: const Text('Option 12'), leading: const Icon(PrimeIcons.logout), onPressed: () {}),
                      const Divider(),
                      ListItem(title: const Text('Option 13'), leading: const Icon(PrimeIcons.robotOutline), onPressed: () {}),
                      const Divider(),
                      ListItem(title: const Text('Option 14'), leading: const Icon(PrimeIcons.cog), onPressed: () {}),
                      const Divider(),
                      ListItem(title: const Text('Option 15'), leading: const Icon(PrimeIcons.logout), onPressed: () {}),
                      const Divider(),
                      ListItem(title: const Text('Option 16'), leading: const Icon(PrimeIcons.robotOutline), onPressed: () {}),
                      const Divider(),
                      ListItem(title: const Text('Option 17'), leading: const Icon(PrimeIcons.cog), onPressed: () {}),
                      const Divider(),
                      ListItem(title: const Text('Option 18'), leading: const Icon(PrimeIcons.logout), onPressed: () {}),
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              },
            ),

            Button(
              label: const Text('Alternate Color'),
              onPressed: () {
                BottomSheet.show(
                  context: context,
                  title: const Text('Sheet Title'),
                  backgroundColor: PrimeTheme.of(context).colorScheme.surfaceBase,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 24.0),
                    child: Text('This sheet has `bg-light` as its background color.'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
