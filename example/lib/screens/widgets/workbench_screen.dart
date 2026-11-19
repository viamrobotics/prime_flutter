import 'package:flutter/widgets.dart';
import 'package:prime_flutter/prime_flutter.dart';

class _FileNode {
  final String path;
  final String name;
  final List<_FileNode>? children;
  final String? source;
  final CodeEditorLanguage? language;

  const _FileNode(this.path, this.name, {this.children, this.source, this.language});
}

const List<_FileNode> _files = [
  _FileNode(
    'src',
    'src',
    children: [
      _FileNode(
        'src/main.go',
        'main.go',
        language: CodeEditorLanguage.go,
        source: 'package main\n\nimport "fmt"\n\n// Entry point.\nfunc main() {\n\tfmt.Println("hello, arm")\n}',
      ),
      _FileNode(
        'src/teleop.py',
        'teleop.py',
        language: CodeEditorLanguage.python,
        source: '# Mirror the leader onto the follower.\ndef mirror(leader, follower):\n    pose = leader.get_pose()\n    follower.move(pose, speed=0.5)\n    return True',
      ),
      _FileNode('src/empty', 'empty', children: []),
    ],
  ),
  _FileNode(
    'config.json',
    'config.json',
    language: CodeEditorLanguage.json,
    source: '{\n  "name": "arm-1",\n  "speed": 50,\n  "debug": false,\n  "tags": null\n}',
  ),
  _FileNode(
    'query.sql',
    'query.sql',
    language: CodeEditorLanguage.sql,
    source: "-- Recent readings\nSELECT time, value FROM readings\nWHERE machine = 'arm-1' AND value > 0.5\nORDER BY time DESC LIMIT 100",
  ),
];

/// A small IDE-style layout: a file tree beside an editor, with a stack of
/// tabbed panes underneath.
class WorkbenchScreen extends StatefulWidget {
  const WorkbenchScreen({super.key});

  @override
  State<WorkbenchScreen> createState() => _WorkbenchScreenState();
}

class _WorkbenchScreenState extends State<WorkbenchScreen> {
  LayoutNode<String>? _layout = const SplitNode<String>(
    id: 'root',
    direction: SplitDirection.row,
    ratio: 0.32,
    first: PaneNode(id: 'files', data: 'Files'),
    second: SplitNode<String>(
      id: 'right',
      direction: SplitDirection.column,
      ratio: 0.65,
      first: PaneNode(id: 'editor', data: 'Editor'),
      second: StackNode<String>(
        id: 'bottom',
        activeId: 'logs',
        panes: [
          PaneNode(id: 'logs', data: 'Logs'),
          PaneNode(id: 'problems', data: 'Problems'),
        ],
      ),
    ),
  );

  Set<String> _expanded = {'src'};
  Set<String> _selected = {'src/main.go'};
  final Map<String, String> _sources = {};

  _FileNode? _find(List<_FileNode> nodes, String path) {
    for (final node in nodes) {
      if (node.path == path) return node;
      final found = _find(node.children ?? const [], path);
      if (found != null) return found;
    }
    return null;
  }

  /// A header that drags the pane, with buttons to move it from the keyboard and to float or dock it.
  Widget _buildPane(BuildContext context, PaneNode<String> pane, PaneState state) {
    final theme = PrimeTheme.of(context);
    final c = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 32,
          padding: const EdgeInsets.only(left: 12, right: 4),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.borderSubtle))),
          child: Row(
            children: [
              Expanded(
                child: PaneDragTrigger(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(pane.data, style: theme.textTheme.bodySmall.copyWith(fontSize: 12, fontWeight: FontWeight.w600, color: c.textSecondary)),
                  ),
                ),
              ),
              PaneMoveTrigger(
                label: 'Move ${pane.data}',
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(PrimeIcons.cursorMove, size: 16, color: state.isMoving ? c.inputFocus : c.iconSecondary),
                ),
              ),
              if (!state.isFloating)
                IconButton(
                  icon: const Icon(PrimeIcons.pictureInPictureTopRight, size: 16),
                  label: 'Float ${pane.data}',
                  variant: IconButtonVariant.ghost,
                  onPressed: () => setState(() {
                    _layout = floatPane(_layout, pane.id, const FloatRect(x: 120, y: 80, width: 360, height: 240), 'window-${pane.id}', 'floats');
                  }),
                ),
            ],
          ),
        ),
        Expanded(child: _buildBody(context, pane)),
      ],
    );
  }

  Widget _buildBody(BuildContext context, PaneNode<String> pane) {
    final theme = PrimeTheme.of(context);
    final file = _selected.isEmpty ? null : _find(_files, _selected.first);

    switch (pane.id) {
      case 'files':
        return SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: TreeView<_FileNode>(
            semanticLabel: 'Files',
            nodes: _files,
            nodeToValue: (node) => node.path,
            nodeToString: (node) => node.name,
            nodeToChildren: (node) => node.children,
            nodeToChildrenCount: (node) => node.children?.length,
            branchClick: TreeBranchClick.toggle,
            showIndentGuides: true,
            expanded: _expanded,
            onExpandedChanged: (next) => setState(() => _expanded = next),
            selected: _selected,
            onSelectedChanged: (next) => setState(() => _selected = next),
          ),
        );
      case 'editor':
        if (file?.source == null) {
          return Center(child: Text('Select a file', style: theme.textTheme.bodySmall.copyWith(color: theme.colorScheme.textTertiary)));
        }
        return Padding(
          padding: const EdgeInsets.all(8),
          child: CodeEditor(
            key: ValueKey(file!.path),
            semanticLabel: file.name,
            language: file.language,
            value: _sources[file.path] ?? file.source!,
            onChanged: (next) => _sources[file.path] = next,
          ),
        );
      case 'logs':
        return const Padding(
          padding: EdgeInsets.all(8),
          child: CodeEditor(
            value: '12:00:01 info  connected to arm-1\n12:00:02 info  teleop started\n12:00:09 warn  pose jump rejected',
            readOnly: true,
            lineNumbers: false,
          ),
        );
      default:
        return Center(child: Text('No problems detected', style: theme.textTheme.bodySmall.copyWith(color: theme.colorScheme.textTertiary)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PrimeScaffold(
      appBar: PrimeAppBar(
        title: const Text('Workbench'),
        actions: [
          IconButton(
            icon: const Icon(PrimeIcons.arrowCollapse),
            label: 'Swap files and editor',
            variant: IconButtonVariant.ghost,
            onPressed: () => setState(() => _layout = swapPanes(_layout, 'files', 'editor')),
          ),
        ],
      ),
      body: Panes<String>(
        layout: _layout,
        onLayoutChanged: (next) => setState(() => _layout = next),
        paneLabel: (pane) => pane.data,
        paneBuilder: _buildPane,
      ),
    );
  }
}
