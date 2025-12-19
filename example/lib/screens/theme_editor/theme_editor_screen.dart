import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:prime_flutter/prime_flutter.dart';
import 'theme_manager.dart';

class GlobalThemeEditor extends StatefulWidget {
  const GlobalThemeEditor({super.key});

  @override
  State<GlobalThemeEditor> createState() => _GlobalThemeEditorState();
}

class _GlobalThemeEditorState extends State<GlobalThemeEditor> {
  final ThemeManager _manager = ThemeManager();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _manager,
      builder: (context, child) {
        final scheme = _manager.currentScheme;
        return PrimeTheme(
          // Ensure we are previewing what we are editing
          data: PrimeThemeData(colorScheme: scheme, textTheme: PrimeTextTheme.base(), cornerRadius: 8.0),
          child: PrimeScaffold(
            appBar: PrimeAppBar(
              title: const Text('Theme Editor'),
              actions: [
                GestureDetector(
                  onTap: _export,
                  child: Container(padding: const EdgeInsets.all(8), child: const Icon(PrimeIcons.codeJson, size: 24)),
                ),
              ],
            ),
            body: Column(
              children: [
                _buildThemeControls(),
                Divider(),
                Expanded(child: _buildEditList(scheme)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeControls() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Text('Theme: ', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: PrimeColors.borderSubtle),
              borderRadius: BorderRadius.circular(8),
            ),
            child: material.Material(
              child: material.DropdownButton<String>(
                value: _manager.currentThemeName,
                underline: const SizedBox(),
                items: _manager.availableThemes.map((t) => material.DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (val) {
                  if (val != null) _manager.switchTheme(val);
                },
              ),
            ),
          ),
          const Spacer(),
          Button(label: 'Save Profile', variant: ButtonVariant.primary, onPressed: _showSaveDialog),
        ],
      ),
    );
  }

  Widget _buildEditList(PrimeColorScheme scheme) {
    final fields = _getFields(scheme);
    return ListView.builder(
      itemCount: fields.length,
      itemBuilder: (context, index) {
        final entry = fields.entries.elementAt(index);
        return ListItem(
          title: Text('${entry.key} - ${entry.value.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}'),
          leading: const Icon(PrimeIcons.tools, size: 20),
          onPressed: () => _pickColor(entry.key, entry.value),
          trailing: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: entry.value,
              border: Border.all(color: PrimeColors.borderSubtle),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      },
    );
  }

  void _pickColor(String name, Color currentColor) {
    _showCustomDialog(
      title: 'Pick Color',
      content: _SimpleColorPicker(
        initialColor: currentColor,
        onColorChanged: (color) {
          _manager.updateColor(name, color);
        },
      ),
      actions: [Button(label: 'Done', onPressed: () => Navigator.of(context).pop())],
    );
  }

  void _export() {
    final code = _generateCode(_manager.currentScheme);
    _showCustomDialog(
      title: 'Export Theme',
      content: SingleChildScrollView(
        child: Text(
          code,
          style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: PrimeColors.gray9),
        ),
      ),
      actions: [
        Button(
          label: 'Copy',
          onPressed: () {
            Clipboard.setData(ClipboardData(text: code));
            _showToast('Copied to clipboard');
          },
        ),
        Button(label: 'Close', variant: ButtonVariant.secondary, onPressed: () => Navigator.of(context).pop()),
      ],
    );
  }

  void _showSaveDialog() {
    final controller = TextEditingController(text: _manager.currentThemeName);
    _showCustomDialog(
      title: 'Save Theme As',
      content: Input(controller: controller, placeholder: 'Theme Name'),
      actions: [
        Button(label: 'Cancel', variant: ButtonVariant.secondary, onPressed: () => Navigator.pop(context)),
        Button(
          label: 'Save',
          onPressed: () {
            if (controller.text.isNotEmpty) {
              _manager.saveTheme(controller.text);
              Navigator.pop(context);
              _showToast('Theme saved!');
            }
          },
        ),
      ],
    );
  }

  void _showCustomDialog({required String title, required Widget content, required List<Widget> actions}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: PrimeColors.gray0,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: const Color(0x1A000000), blurRadius: 16, offset: const Offset(0, 4))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: PrimeTypography.heading),
                const SizedBox(height: 16),
                Flexible(child: content),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions.map((a) => Padding(padding: const EdgeInsets.only(left: 8), child: a)).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showToast(String message) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 50,
        left: 0,
        right: 0,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: PrimeColors.gray9, borderRadius: BorderRadius.circular(8)),
            child: Text(message, style: const TextStyle(color: PrimeColors.gray0)),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 2), () {
      entry.remove();
    });
  }

  Map<String, Color> _getFields(PrimeColorScheme s) {
    return {
      'surfaceBase': s.surfaceBase,
      'surfaceOffset': s.surfaceOffset,
      'surfaceHighlight': s.surfaceHighlight,
      'textPrimary': s.textPrimary,
      'textSecondary': s.textSecondary,
      'textTertiary': s.textTertiary,
      'textPlaceholder': s.textPlaceholder,
      'iconPrimary': s.iconPrimary,
      'iconSecondary': s.iconSecondary,
      'iconDisabled': s.iconDisabled,
      'actionPrimaryBg': s.actionPrimaryBg,
      'actionPrimaryFg': s.actionPrimaryFg,
      'actionNeutralBg': s.actionNeutralBg,
      'borderSubtle': s.borderSubtle,
      'inputText': s.inputText,
      'inputFocus': s.inputFocus,
      'statusDangerLight': s.statusDangerLight,
      'statusDangerDark': s.statusDangerDark,
      'statusInfoLight': s.statusInfoLight,
      'statusInfoDark': s.statusInfoDark,
      'statusSuccessLight': s.statusSuccessLight,
      'statusSuccessDark': s.statusSuccessDark,
      'statusWarningLight': s.statusWarningLight,
      'statusWarningDark': s.statusWarningDark,
    };
  }

  String _generateCode(PrimeColorScheme s) {
    String getColorString(Color c) {
      for (final entry in _primeColorsMap.entries) {
        if (entry.value.toARGB32() == c.toARGB32()) {
          return 'PrimeColors.${entry.key}';
        }
      }
      return 'Color(0x${c.toARGB32().toRadixString(16).toUpperCase()})';
    }

    return '''
PrimeColorScheme(
  surfaceBase: ${getColorString(s.surfaceBase)},
  surfaceOffset: ${getColorString(s.surfaceOffset)},
  surfaceHighlight: ${getColorString(s.surfaceHighlight)},
  textPrimary: ${getColorString(s.textPrimary)},
  textSecondary: ${getColorString(s.textSecondary)},
  textTertiary: ${getColorString(s.textTertiary)},
  textPlaceholder: ${getColorString(s.textPlaceholder)},
  iconPrimary: ${getColorString(s.iconPrimary)},
  iconSecondary: ${getColorString(s.iconSecondary)},
  iconDisabled: ${getColorString(s.iconDisabled)},
  actionPrimaryBg: ${getColorString(s.actionPrimaryBg)},
  actionPrimaryFg: ${getColorString(s.actionPrimaryFg)},
  actionNeutralBg: ${getColorString(s.actionNeutralBg)},
  borderSubtle: ${getColorString(s.borderSubtle)},
  inputText: ${getColorString(s.inputText)},
  inputFocus: ${getColorString(s.inputFocus)},
  statusDangerLight: ${getColorString(s.statusDangerLight)},
  statusDangerDark: ${getColorString(s.statusDangerDark)},
  statusInfoLight: ${getColorString(s.statusInfoLight)},
  statusInfoDark: ${getColorString(s.statusInfoDark)},
  statusSuccessLight: ${getColorString(s.statusSuccessLight)},
  statusSuccessDark: ${getColorString(s.statusSuccessDark)},
  statusWarningLight: ${getColorString(s.statusWarningLight)},
  statusWarningDark: ${getColorString(s.statusWarningDark)},
);
''';
  }
}

class _SimpleColorPicker extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color> onColorChanged;

  const _SimpleColorPicker({required this.initialColor, required this.onColorChanged});

  @override
  State<_SimpleColorPicker> createState() => _SimpleColorPickerState();
}

class _SimpleColorPickerState extends State<_SimpleColorPicker> {
  late Color _color;
  final TextEditingController _hexController = TextEditingController();
  final TextEditingController _rController = TextEditingController();
  final TextEditingController _gController = TextEditingController();
  final TextEditingController _bController = TextEditingController();
  final TextEditingController _aController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  List<MapEntry<String, Color>> _filteredColors = [];
  bool _showColorList = false;

  @override
  void initState() {
    super.initState();
    _color = widget.initialColor;
    _filteredColors = _primeColorsMap.entries.toList();
    _updateControllers();
  }

  void _updateControllers() {
    _hexController.text = _color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase();
    _rController.text = (_color.r * 255).round().toString();
    _gController.text = (_color.g * 255).round().toString();
    _bController.text = (_color.b * 255).round().toString();
    _aController.text = (_color.a * 255).round().toString();
  }

  void _updateColor(Color color) {
    setState(() {
      _color = color;
    });
    _updateControllers();
    widget.onColorChanged(color);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(width: 100, height: 50, color: _color, margin: const EdgeInsets.only(bottom: 16)),

        // PrimeColors Search
        GestureDetector(
          onTap: () {
            setState(() => _showColorList = !_showColorList);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: PrimeColors.borderSubtle),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(PrimeIcons.magnify, size: 16),
                const SizedBox(width: 8),
                Text(_showColorList ? 'Hide PrimeColors' : 'Select from PrimeColors', style: const TextStyle(fontSize: 14)),
                const Spacer(),
                Icon(_showColorList ? PrimeIcons.chevronUp : PrimeIcons.chevronDown, size: 16),
              ],
            ),
          ),
        ),

        if (_showColorList) ...[
          const SizedBox(height: 8),
          Input(
            placeholder: 'Search colors...',
            controller: _searchController,
            onChanged: (val) {
              setState(() {
                _filteredColors = _primeColorsMap.entries.where((e) => e.key.toLowerCase().contains(val.toLowerCase())).toList();
              });
            },
          ),
          Container(
            height: 150,
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              border: Border.all(color: PrimeColors.borderSubtle),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.builder(
              itemCount: _filteredColors.length,
              itemBuilder: (context, index) {
                final entry = _filteredColors[index];
                return GestureDetector(
                  onTap: () {
                    _updateColor(entry.value);
                    setState(() => _showColorList = false);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    color: const Color(0x00000000), // Hit test
                    child: Row(
                      children: [
                        Container(width: 20, height: 20, color: entry.value, margin: const EdgeInsets.only(right: 12)),
                        Text(entry.key, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],

        const SizedBox(height: 16),
        Input(
          placeholder: 'Hex Code',
          controller: _hexController,
          onSubmitted: () {
            try {
              final val = int.parse(_hexController.text, radix: 16);
              _updateColor(Color(val));
            } catch (_) {}
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildChannelInput('R', _rController, (v) => _color.withRed(v))),
            const SizedBox(width: 8),
            Expanded(child: _buildChannelInput('G', _gController, (v) => _color.withGreen(v))),
            const SizedBox(width: 8),
            Expanded(child: _buildChannelInput('B', _bController, (v) => _color.withBlue(v))),
            const SizedBox(width: 8),
            Expanded(child: _buildChannelInput('A', _aController, (v) => _color.withAlpha(v))),
          ],
        ),
      ],
    );
  }

  Widget _buildChannelInput(String label, TextEditingController controller, Color Function(int) transform) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Input(
          controller: controller,
          onSubmitted: () {
            try {
              final val = int.parse(controller.text).clamp(0, 255);
              _updateColor(transform(val));
            } catch (_) {}
          },
        ),
      ],
    );
  }
}

const Map<String, Color> _primeColorsMap = {
  'gray9': PrimeColors.gray9,
  'gray8': PrimeColors.gray8,
  'gray7': PrimeColors.gray7,
  'gray6': PrimeColors.gray6,
  'gray5': PrimeColors.gray5,
  'gray2': PrimeColors.gray2,
  'gray1': PrimeColors.gray1,
  'gray0': PrimeColors.gray0,
  'dangerLight': PrimeColors.dangerLight,
  'dangerDark': PrimeColors.dangerDark,
  'infoLight': PrimeColors.infoLight,
  'infoDark': PrimeColors.infoDark,
  'successLight': PrimeColors.successLight,
  'successDark': PrimeColors.successDark,
  'warningLight': PrimeColors.warningLight,
  'warningDark': PrimeColors.warningDark,
  'focusBlue': PrimeColors.focusBlue,
  'borderSubtle': PrimeColors.borderSubtle,
};
