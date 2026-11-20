import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:prime_flutter/prime_flutter.dart';

enum IconPageStyle { example, gallery }

class IconPage extends StatefulWidget {
  final IconPageStyle style;

  const IconPage({super.key, required this.style});

  @override
  State<IconPage> createState() => _IconPageState();
}

class _IconPageState extends State<IconPage> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.style == IconPageStyle.example) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [Icon(PrimeIcons.viamFlutter, size: 48), SizedBox(height: 16), Text('PrimeIcons.viamFlutter')],
          ),
        ),
      );
    }

    final filteredIcons = _allIcons.entries.where((entry) => entry.key.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Input(
              controller: _searchController,
              placeholder: 'Search icons...',
              leading: const Icon(PrimeIcons.magnify),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 60,
                childAspectRatio: 1.0,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: filteredIcons.length,
              itemBuilder: (context, index) {
                final entry = filteredIcons[index];
                return _IconCard(name: entry.key, icon: entry.value);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _IconCard extends StatefulWidget {
  final String name;
  final IconData icon;

  const _IconCard({required this.name, required this.icon});

  @override
  State<_IconCard> createState() => _IconCardState();
}

class _IconCardState extends State<_IconCard> {
  bool _hovering = false;

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: 'PrimeIcons.${widget.name}'));
    Toast.show(context, message: 'Copied PrimeIcons.${widget.name} to clipboard', duration: const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.name,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: _copyToClipboard,
          child: Container(
            decoration: BoxDecoration(
              color: _hovering
                  ? PrimeTheme.of(context).colorScheme.surfaceHighlight
                  : const Color(0x00000000), // Transparent when not hovered for cleaner look
              borderRadius: BorderRadius.circular(4),
              border: _hovering ? Border.all(color: PrimeTheme.of(context).colorScheme.borderSubtle.withValues(alpha: 0.5)) : null,
            ),
            child: Icon(widget.icon, size: 24, color: PrimeTheme.of(context).colorScheme.iconPrimary),
          ),
        ),
      ),
    );
  }
}

final Map<String, IconData> _allIcons = {
  'checkboxIndeterminate': PrimeIcons.checkboxIndeterminate,
  'cursorMove': PrimeIcons.cursorMove,
  'gridOrthographic': PrimeIcons.gridOrthographic,
  'gridPerspective': PrimeIcons.gridPerspective,
  'magnetOff': PrimeIcons.magnetOff,
  'magnet': PrimeIcons.magnet,
  'maintenance': PrimeIcons.maintenance,
  'resize': PrimeIcons.resize,
  'viamComponent': PrimeIcons.viamComponent,
  'viamFlutter': PrimeIcons.viamFlutter,
  'viamFragment': PrimeIcons.viamFragment,
  'viamLocalModule': PrimeIcons.viamLocalModule,
  'viamMixedPartStatus': PrimeIcons.viamMixedPartStatus,
  'viamMlModel': PrimeIcons.viamMlModel,
  'viamRemotePart': PrimeIcons.viamRemotePart,
  'viamRegistryModule': PrimeIcons.viamRegistryModule,
  'viamService': PrimeIcons.viamService,
  'viamProcess': PrimeIcons.viamProcess,
  'accountGroupOutline': PrimeIcons.accountGroupOutline,
  'accountMultiple': PrimeIcons.accountMultiple,
  'alertCircleOutline': PrimeIcons.alertCircleOutline,
  'alertCircle': PrimeIcons.alertCircle,
  'alertOutline': PrimeIcons.alertOutline,
  'alert': PrimeIcons.alert,
  'appleKeyboardCommand': PrimeIcons.appleKeyboardCommand,
  'apple': PrimeIcons.apple,
  'applicationOutline': PrimeIcons.applicationOutline,
  'arrowCollapseLeft': PrimeIcons.arrowCollapseLeft,
  'arrowCollapseRight': PrimeIcons.arrowCollapseRight,
  'arrowCollapse': PrimeIcons.arrowCollapse,
  'arrowExpandAll': PrimeIcons.arrowExpandAll,
  'arrowExpandLeft': PrimeIcons.arrowExpandLeft,
  'arrowExpandRight': PrimeIcons.arrowExpandRight,
  'arrowLeft': PrimeIcons.arrowLeft,
  'arrowRight': PrimeIcons.arrowRight,
  'arrowTopRightBottomLeft': PrimeIcons.arrowTopRightBottomLeft,
  'arrowUp': PrimeIcons.arrowUp,
  'article': PrimeIcons.article,
  'axisArrow': PrimeIcons.axisArrow,
  'backupRestore': PrimeIcons.backupRestore,
  'broadcastOff': PrimeIcons.broadcastOff,
  'broadcast': PrimeIcons.broadcast,
  'bugOutline': PrimeIcons.bugOutline,
  'bug': PrimeIcons.bug,
  'cameraFlipOutline': PrimeIcons.cameraFlipOutline,
  'cameraOutline': PrimeIcons.cameraOutline,
  'cancel': PrimeIcons.cancel,
  'cardTextOutline': PrimeIcons.cardTextOutline,
  'chartLine': PrimeIcons.chartLine,
  'checkCircle': PrimeIcons.checkCircle,
  'check': PrimeIcons.check,
  'checkboxMarked': PrimeIcons.checkboxMarked,
  'chevronDoubleUp': PrimeIcons.chevronDoubleUp,
  'chevronDown': PrimeIcons.chevronDown,
  'chevronLeft': PrimeIcons.chevronLeft,
  'chevronRight': PrimeIcons.chevronRight,
  'chevronUp': PrimeIcons.chevronUp,
  'circleMd': PrimeIcons.circleMd,
  'clockOutline': PrimeIcons.clockOutline,
  'close': PrimeIcons.close,
  'codeBraces': PrimeIcons.codeBraces,
  'codeJson': PrimeIcons.codeJson,
  'cog': PrimeIcons.cog,
  'console': PrimeIcons.console,
  'contentCopy': PrimeIcons.contentCopy,
  'contentDuplicate': PrimeIcons.contentDuplicate,
  'contentSaveOutline': PrimeIcons.contentSaveOutline,
  'creditCardOutline': PrimeIcons.creditCardOutline,
  'databaseOutline': PrimeIcons.databaseOutline,
  'domain': PrimeIcons.domain,
  'dotsHorizontal': PrimeIcons.dotsHorizontal,
  'download': PrimeIcons.download,
  'drag': PrimeIcons.drag,
  'earth': PrimeIcons.earth,
  'exportIcon': PrimeIcons.exportIcon,
  'fileChartOutline': PrimeIcons.fileChartOutline,
  'fileDownloadOutline': PrimeIcons.fileDownloadOutline,
  'fileSwapOutline': PrimeIcons.fileSwapOutline,
  'filterOutline': PrimeIcons.filterOutline,
  'gamepad': PrimeIcons.gamepad,
  'github': PrimeIcons.github,
  'helpCircleOutline': PrimeIcons.helpCircleOutline,
  'history': PrimeIcons.history,
  'imageFilterCenterFocus': PrimeIcons.imageFilterCenterFocus,
  'informationOutline': PrimeIcons.informationOutline,
  'information': PrimeIcons.information,
  'instagram': PrimeIcons.instagram,
  'lanConnect': PrimeIcons.lanConnect,
  'languageCpp': PrimeIcons.languageCpp,
  'languageGo': PrimeIcons.languageGo,
  'languagePython': PrimeIcons.languagePython,
  'languageTypescript': PrimeIcons.languageTypescript,
  'layersTripleOutline': PrimeIcons.layersTripleOutline,
  'linkVariant': PrimeIcons.linkVariant,
  'link': PrimeIcons.link,
  'linkedin': PrimeIcons.linkedin,
  'linux': PrimeIcons.linux,
  'lock': PrimeIcons.lock,
  'logout': PrimeIcons.logout,
  'magnify': PrimeIcons.magnify,
  'menu': PrimeIcons.menu,
  'minus': PrimeIcons.minus,
  'monitorDashboard': PrimeIcons.monitorDashboard,
  'multiplicationBox': PrimeIcons.multiplicationBox,
  'navigationVariantOutline': PrimeIcons.navigationVariantOutline,
  'navigationVariant': PrimeIcons.navigationVariant,
  'networkOutline': PrimeIcons.networkOutline,
  'openInNew': PrimeIcons.openInNew,
  'packageVariantClosed': PrimeIcons.packageVariantClosed,
  'pauseCircleOutline': PrimeIcons.pauseCircleOutline,
  'pause': PrimeIcons.pause,
  'pencilOutline': PrimeIcons.pencilOutline,
  'pictureInPictureTopRight': PrimeIcons.pictureInPictureTopRight,
  'playCircleOutline': PrimeIcons.playCircleOutline,
  'plus': PrimeIcons.plus,
  'radioboxBlank': PrimeIcons.radioboxBlank,
  'radioboxIndeterminateVariant': PrimeIcons.radioboxIndeterminateVariant,
  'radioboxMarked': PrimeIcons.radioboxMarked,
  'refresh': PrimeIcons.refresh,
  'robotOutline': PrimeIcons.robotOutline,
  'scriptTextOutline': PrimeIcons.scriptTextOutline,
  'selectionDrag': PrimeIcons.selectionDrag,
  'selectionEllipse': PrimeIcons.selectionEllipse,
  'send': PrimeIcons.send,
  'shieldKeyOutline': PrimeIcons.shieldKeyOutline,
  'stopCircleOutline': PrimeIcons.stopCircleOutline,
  'syncIcon': PrimeIcons.syncIcon,
  'table': PrimeIcons.table,
  'tagOutline': PrimeIcons.tagOutline,
  'textSearch': PrimeIcons.textSearch,
  'toggleSwitchOffOutline': PrimeIcons.toggleSwitchOffOutline,
  'toggleSwitchOff': PrimeIcons.toggleSwitchOff,
  'toggleSwitchOutline': PrimeIcons.toggleSwitchOutline,
  'toggleSwitch': PrimeIcons.toggleSwitch,
  'tools': PrimeIcons.tools,
  'trashCanOutline': PrimeIcons.trashCanOutline,
  'twitter': PrimeIcons.twitter,
  'undo': PrimeIcons.undo,
  'unfoldLessHorizontal': PrimeIcons.unfoldLessHorizontal,
  'unfoldMoreHorizontal': PrimeIcons.unfoldMoreHorizontal,
  'upload': PrimeIcons.upload,
  'videoOutline': PrimeIcons.videoOutline,
  'viewDashboardOutline': PrimeIcons.viewDashboardOutline,
  'webhook': PrimeIcons.webhook,
  'windows': PrimeIcons.windows,
  'accountPlusOutline': PrimeIcons.accountPlusOutline,
  'accountOutline': PrimeIcons.accountOutline,
  'asterisk': PrimeIcons.asterisk,
  'askAi': PrimeIcons.askAi,
  'arrowTopRight': PrimeIcons.arrowTopRight,
  'autoRenew': PrimeIcons.autoRenew,
  'block': PrimeIcons.block,
  'bookOpen': PrimeIcons.bookOpen,
  'bookmarkOutline': PrimeIcons.bookmarkOutline,
  'calendarBlank': PrimeIcons.calendarBlank,
  'checkCircleOutline': PrimeIcons.checkCircleOutline,
  'checkDecagram': PrimeIcons.checkDecagram,
  'checkboxBlankOutline': PrimeIcons.checkboxBlankOutline,
  'closeCircleOutline': PrimeIcons.closeCircleOutline,
  'cloudOutline': PrimeIcons.cloudOutline,
  'codeTags': PrimeIcons.codeTags,
  'contentPaste': PrimeIcons.contentPaste,
  'cropFree': PrimeIcons.cropFree,
  'dockLeft': PrimeIcons.dockLeft,
  'dockRight': PrimeIcons.dockRight,
  'fileOutline': PrimeIcons.fileOutline,
  'folder': PrimeIcons.folder,
  'keyVariant': PrimeIcons.keyVariant,
  'lightningBoltOutline': PrimeIcons.lightningBoltOutline,
  'externalArrow': PrimeIcons.externalArrow,
  'eyeOutline': PrimeIcons.eyeOutline,
  'eyeOffOutline': PrimeIcons.eyeOffOutline,
  'fileCodeOutline': PrimeIcons.fileCodeOutline,
  'fileDocumentOutline': PrimeIcons.fileDocumentOutline,
  'fileImageOutline': PrimeIcons.fileImageOutline,
  'fileMusicOutline': PrimeIcons.fileMusicOutline,
  'fileTableOutline': PrimeIcons.fileTableOutline,
  'fileVideoOutline': PrimeIcons.fileVideoOutline,
  'folderZipOutline': PrimeIcons.folderZipOutline,
  'cubeScan': PrimeIcons.cubeScan,
  'imageBrokenVariant': PrimeIcons.imageBrokenVariant,
  'fire': PrimeIcons.fire,
  'filterSliders': PrimeIcons.filterSliders,
  'inbox': PrimeIcons.inbox,
  'keyboardReturn': PrimeIcons.keyboardReturn,
  'laptop': PrimeIcons.laptop,
  'layersRemove': PrimeIcons.layersRemove,
  'manageHistory': PrimeIcons.manageHistory,
  'markdown': PrimeIcons.markdown,
  'megaphone': PrimeIcons.megaphone,
  'memory': PrimeIcons.memory,
  'menuRight': PrimeIcons.menuRight,
  'merge': PrimeIcons.merge,
  'messageAlertOutline': PrimeIcons.messageAlertOutline,
  'monitorShimmer': PrimeIcons.monitorShimmer,
  'noteOutline': PrimeIcons.noteOutline,
  'packageVariantClosedCheck': PrimeIcons.packageVariantClosedCheck,
  'pulse': PrimeIcons.pulse,
  'qrcode': PrimeIcons.qrcode,
  'robotIndustrialOutline': PrimeIcons.robotIndustrialOutline,
  'rocketLaunchOutline': PrimeIcons.rocketLaunchOutline,
  'sourceMerge': PrimeIcons.sourceMerge,
  'sparkles': PrimeIcons.sparkles,
  'stop': PrimeIcons.stop,
  'subdirectoryArrowRight': PrimeIcons.subdirectoryArrowRight,
  'thumbDown': PrimeIcons.thumbDown,
  'thumbUp': PrimeIcons.thumbUp,
  'unfoldMoreVertical': PrimeIcons.unfoldMoreVertical,
  'viewAgendaOutline': PrimeIcons.viewAgendaOutline,
  'viewGridOutline': PrimeIcons.viewGridOutline,
  'formatListBulleted': PrimeIcons.formatListBulleted,
  'webcam': PrimeIcons.webcam,
  'widgetsOutline': PrimeIcons.widgetsOutline,
  'wrenchOutline': PrimeIcons.wrenchOutline,
  'resourceDeprecated': PrimeIcons.resourceDeprecated,
  'imageClassification': PrimeIcons.imageClassification,
  'objectDetection': PrimeIcons.objectDetection,
  'onnx': PrimeIcons.onnx,
  'pytorch': PrimeIcons.pytorch,
  'tensorflow': PrimeIcons.tensorflow,
  'bluetooth': PrimeIcons.bluetooth,
  'wifi': PrimeIcons.wifi,
  'wifiStrength1': PrimeIcons.wifiStrength1,
  'wifiStrength2': PrimeIcons.wifiStrength2,
  'wifiStrength3': PrimeIcons.wifiStrength3,
  'wifiStrength4': PrimeIcons.wifiStrength4,
  'lockOpenOutline': PrimeIcons.lockOpenOutline,
  'power': PrimeIcons.power,
  'cellphoneWireless': PrimeIcons.cellphoneWireless,
};
