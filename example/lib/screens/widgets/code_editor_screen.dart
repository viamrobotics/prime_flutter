import 'package:flutter/widgets.dart';
import 'package:prime_flutter/prime_flutter.dart';

import 'showcase.dart';

const String _originalConfig = '''{
  "components": [
    {
      "name": "arm-1",
      "model": "xArm6",
      "attributes": { "host": "10.0.0.2", "speed": 50 }
    }
  ],
  "debug": false
}''';

const String _goSample = '''// Move the arm to a pose.
func (s *Service) Move(ctx context.Context, pose Pose) error {
	if pose == nil {
		return errors.New("pose is required")
	}
	return s.arm.MoveToPosition(ctx, pose, 0.5)
}''';

class CodeEditorScreen extends StatefulWidget {
  const CodeEditorScreen({super.key});

  @override
  State<CodeEditorScreen> createState() => _CodeEditorScreenState();
}

class _CodeEditorScreenState extends State<CodeEditorScreen> {
  String _config = _originalConfig.replaceFirst('"speed": 50', '"speed": 80').replaceFirst('"debug": false', '"debug": true');
  CodeEditorDiff _diff = CodeEditorDiff.unified;

  @override
  Widget build(BuildContext context) {
    return ShowcasePage(
      title: 'Code editor',
      description: 'An editor with syntax highlighting, a line-number gutter, and a diff view.',
      sections: [
        ShowcaseSection(
          title: 'Editable JSON',
          child: CodeEditor(
            semanticLabel: 'Config',
            language: CodeEditorLanguage.json,
            value: _config,
            onChanged: (next) => setState(() => _config = next),
          ),
        ),
        ShowcaseSection(
          title: 'Diff',
          description: 'The same document compared against the original. It stays editable: deleted lines show in place.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              SegmentedButton<CodeEditorDiff>(
                segments: const {CodeEditorDiff.unified: Text('Unified'), CodeEditorDiff.split: Text('Split')},
                selected: {_diff},
                onSelectionChanged: (next) => setState(() => _diff = next.first),
              ),
              CodeEditor(
                language: CodeEditorLanguage.json,
                value: _config,
                original: _originalConfig,
                diff: _diff,
                onChanged: (next) => setState(() => _config = next),
              ),
            ],
          ),
        ),
        const ShowcaseSection(
          title: 'Read only, wrapped',
          child: CodeEditor(language: CodeEditorLanguage.go, value: _goSample, readOnly: true, wrapLines: true),
        ),
        const ShowcaseSection(
          title: 'Invalid and disabled',
          child: Column(
            spacing: 12,
            children: [
              CodeEditor(language: CodeEditorLanguage.json, value: '{ "speed": }', invalid: true, lineNumbers: false),
              CodeEditor(value: 'Disabled', disabled: true),
              CodeEditor(value: '', placeholder: 'SELECT * FROM readings', language: CodeEditorLanguage.sql),
            ],
          ),
        ),
      ],
    );
  }
}
