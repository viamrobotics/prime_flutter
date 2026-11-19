import 'package:flutter/widgets.dart';
import 'package:prime_flutter/prime_flutter.dart';

import 'showcase.dart';

class MenusScreen extends StatefulWidget {
  const MenusScreen({super.key});

  @override
  State<MenusScreen> createState() => _MenusScreenState();
}

class _MenusScreenState extends State<MenusScreen> {
  bool _menuOpen = false;
  String _page = '/overview';
  bool _showHidden = false;
  String _density = 'comfortable';

  void _openTakeover() {
    Takeover.show<void>(
      context: context,
      builder: (context) => const Takeover(
        header: TakeoverHeader(
          children: [
            Expanded(child: TakeoverTitle(child: Text('Setup wizard'))),
            TakeoverClose(),
          ],
        ),
        child: Center(child: Text('Your content here')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);
    return ShowcasePage(
      title: 'Actions and navigation',
      description: 'Icon buttons, menus, breadcrumbs, disclosures and the full-screen takeover.',
      sections: [
        ShowcaseSection(
          title: 'Icon button',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final variant in IconButtonVariant.values)
                IconButton(icon: const Icon(PrimeIcons.trashCanOutline), label: variant.name, variant: variant, onPressed: () {}),
              const IconButton(icon: Icon(PrimeIcons.plus), label: 'Large', size: IconButtonSize.large, variant: IconButtonVariant.secondary),
              const IconButton(icon: Icon(PrimeIcons.plus), label: 'Disabled', disabled: true, variant: IconButtonVariant.secondary),
              const IconButton(icon: Icon(PrimeIcons.plus), label: 'Loading', loading: true, variant: IconButtonVariant.secondary),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'Floating menu',
          child: Align(
            alignment: Alignment.centerLeft,
            child: FloatingMenu(
              isOpen: _menuOpen,
              onChange: (open) => setState(() => _menuOpen = open),
              label: 'More actions',
              control: const Padding(padding: EdgeInsets.all(8), child: Icon(PrimeIcons.dotsHorizontal)),
              items: [
                ContextMenuItem(icon: PrimeIcons.pencilOutline, onTap: () => setState(() => _menuOpen = false), child: const Text('Rename')),
                ContextMenuItem(icon: PrimeIcons.contentDuplicate, onTap: () => setState(() => _menuOpen = false), child: const Text('Duplicate')),
                const ContextMenuSeparator(),
                ContextMenuItem(
                  icon: PrimeIcons.trashCanOutline,
                  variant: ContextMenuItemVariant.danger,
                  onTap: () => setState(() => _menuOpen = false),
                  child: const Text('Delete'),
                ),
              ],
            ),
          ),
        ),
        ShowcaseSection(
          title: 'Menu',
          description: 'Closes itself after an item runs. Supports checks, radio groups and submenus.',
          child: Align(
            alignment: Alignment.centerLeft,
            child: Menu(
              label: 'View options',
              trigger: const Button(label: Text('View'), icon: Icon(PrimeIcons.filterSliders)),
              items: [
                MenuItem(icon: PrimeIcons.refresh, shortcut: '⌘R', onTap: () {}, child: const Text('Refresh')),
                MenuCheckboxItem(checked: _showHidden, onChanged: (v) => setState(() => _showHidden = v), child: const Text('Show hidden')),
                const MenuSeparator(),
                MenuRadioGroup<String>(
                  value: _density,
                  onChanged: (v) => setState(() => _density = v),
                  heading: const Text('Density'),
                  children: const [
                    MenuRadioItem(value: 'comfortable', child: Text('Comfortable')),
                    MenuRadioItem(value: 'compact', child: Text('Compact')),
                  ],
                ),
                const MenuSeparator(),
                MenuSub(
                  icon: PrimeIcons.exportIcon,
                  items: [
                    MenuItem(onTap: () {}, child: const Text('CSV')),
                    MenuItem(onTap: () {}, child: const Text('JSON')),
                  ],
                  child: const Text('Export as'),
                ),
                MenuItem(icon: PrimeIcons.trashCanOutline, variant: MenuItemVariant.danger, onTap: () {}, child: const Text('Delete')),
              ],
            ),
          ),
        ),
        ShowcaseSection(
          title: 'Menubar',
          child: Align(
            alignment: Alignment.centerLeft,
            child: Menubar(
              menus: [
                MenubarMenu(
                  label: const Text('File'),
                  items: [
                    MenuItem(shortcut: '⌘N', onTap: () {}, child: const Text('New')),
                    MenuItem(shortcut: '⌘O', onTap: () {}, child: const Text('Open')),
                  ],
                ),
                MenubarMenu(
                  label: const Text('Edit'),
                  items: [
                    MenuItem(shortcut: '⌘Z', onTap: () {}, child: const Text('Undo')),
                    MenuItem(disabled: true, onTap: () {}, child: const Text('Redo')),
                  ],
                ),
                MenubarMenu(label: const Text('View'), items: [MenuItem(onTap: () {}, child: const Text('Zoom in'))]),
              ],
            ),
          ),
        ),
        ShowcaseSection(
          title: 'Context menu region',
          child: ContextMenuRegion(
            items: [
              MenuItem(icon: PrimeIcons.contentCopy, onTap: () {}, child: const Text('Copy')),
              MenuItem(icon: PrimeIcons.contentPaste, onTap: () {}, child: const Text('Paste')),
            ],
            child: Container(
              height: 72,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceOffset,
                borderRadius: BorderRadius.circular(theme.cornerRadius),
                border: Border.all(color: theme.colorScheme.borderSubtle),
              ),
              child: Text('Right-click or long-press here', style: theme.textTheme.bodySmall),
            ),
          ),
        ),
        ShowcaseSection(
          title: 'Popover',
          child: Align(
            alignment: Alignment.centerLeft,
            child: Popover(
              placement: FloatingPlacement.bottomStart,
              trigger: const Button(label: Text('Share')),
              contentBuilder: (context, close) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 12,
                children: [
                  const Text('Anyone with the link can view this machine.'),
                  Button(label: const Text('Copy link'), variant: ButtonVariant.primary, onPressed: close),
                ],
              ),
            ),
          ),
        ),
        ShowcaseSection(
          title: 'Nav dropdown',
          child: NavDropdown<String>(
            selected: _page,
            onSelected: (value) => setState(() => _page = value),
            options: const [
              NavOption(label: 'Overview', value: '/overview'),
              NavOption(label: 'Logs', value: '/logs', description: 'Live and historical'),
              NavOption(label: 'Config', value: '/config', detail: 'JSON'),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'Breadcrumbs',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              const Breadcrumbs(crumbs: ['Dessert', 'Cookie', 'Chocolate chip']),
              NavigationBreadcrumb(
                children: [
                  NavigationBreadcrumbLink(onTap: () {}, child: const Text('Fleet')),
                  const NavigationBreadcrumbSeparator(),
                  const NavigationBreadcrumbEllipsis(),
                  const NavigationBreadcrumbSeparator(),
                  NavigationBreadcrumbLink(onTap: () {}, child: const Text('Lab')),
                  const NavigationBreadcrumbSeparator(),
                  const NavigationBreadcrumbPage(child: Text('arm-1')),
                ],
              ),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'Expandable',
          description: 'An unstyled disclosure; you supply the trigger.',
          child: Expandable(
            triggerBuilder: (context, isOpen) => Row(
              children: [
                AnimatedRotation(
                  turns: isOpen ? 0.25 : 0,
                  duration: const Duration(milliseconds: 150),
                  child: const Icon(PrimeIcons.chevronRight, size: 20),
                ),
                const SizedBox(width: 8),
                Text(isOpen ? 'Hide advanced options' : 'Show advanced options', style: theme.textTheme.bodyDefault),
              ],
            ),
            content: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text('Advanced options go here.', style: theme.textTheme.bodySmall),
            ),
          ),
        ),
        const ShowcaseSection(
          title: 'Collapsible',
          description: 'A styled disclosure with a chevron.',
          child: Collapsible(title: Text('Advanced'), initiallyOpen: true, child: Text('More settings live here.')),
        ),
        ShowcaseSection(
          title: 'Modal',
          child: Align(
            alignment: Alignment.centerLeft,
            child: Button(
              label: const Text('Open modal'),
              onPressed: () => Modal.show<void>(
                context: context,
                title: const Text('Print a statement?'),
                message: const Text('This writes a line to the console.'),
                actionsBuilder: (context) => [
                  Button(label: const Text('Cancel'), onPressed: () => Navigator.of(context).pop()),
                  Button(label: const Text('Print'), variant: ButtonVariant.primary, onPressed: () => Navigator.of(context).pop()),
                ],
              ),
            ),
          ),
        ),
        ShowcaseSection(
          title: 'Takeover',
          child: Align(
            alignment: Alignment.centerLeft,
            child: Button(label: const Text('Open takeover'), onPressed: _openTakeover),
          ),
        ),
        const ShowcaseSection(
          title: 'Kbd',
          child: Row(
            spacing: 16,
            children: [
              KbdGroup(
                children: [
                  Kbd(child: Icon(PrimeIcons.appleKeyboardCommand)),
                  Kbd(child: Text('S')),
                ],
              ),
              KbdGroup(children: [Kbd(child: Text('Ctrl')), Kbd(child: Text('K'))]),
            ],
          ),
        ),
      ],
    );
  }
}
