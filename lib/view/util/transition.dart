import 'package:aibas/view/components/wizard.dart';
import 'package:aibas/view/routes/fab/checkout.dart';
import 'package:aibas/view/routes/fab/create_pj.dart';
import 'package:aibas/view/routes/fab/import_pj.dart';
import 'package:aibas/vm/contents.dart';
import 'package:aibas/vm/page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RouteController {
  RouteController(this.ref);
  WidgetRef ref;

  static void runPush({
    required BuildContext context,
    required Widget page,
    bool isReplace = false,
  }) {
    if (!isReplace) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) => page,
        ),
      );
    } else {
      Navigator.pushAndRemoveUntil<void>(
        context,
        MaterialPageRoute<void>(builder: (context) => page),
        (_) => false,
      );
    }
  }

  void _home2fabInit() {
    ref.read(pageProvider.notifier).updateWizardIndex(0);
    ref.read(CompWizard.isValidContentsProvider.notifier).state = false;
  }

  void home2createPj() {
    final contentsState = ref.watch(contentsProvider);
    final contentsNotifier = ref.read(contentsProvider.notifier);

    // local
    final pjNameNotifier = ref.read(PageCreatePj.pjNameProvider.notifier);
    final workingDirNotifier =
        ref.read(PageCreatePj.workingDirProvider.notifier);
    final backupDirNotifier = ref.read(PageCreatePj.backupDirProvider.notifier);
    final ignoreFilesNotifier =
        ref.read(PageCreatePj.ignoreFilesProvider.notifier);

    debugPrint('-- init (home -> createPj) --');
    _home2fabInit();
    pjNameNotifier.state = '';
    workingDirNotifier.state = null;
    backupDirNotifier.state = contentsState.defaultBackupDir;
    ignoreFilesNotifier.state = [];
    contentsNotifier.updateDragAndDropSendTo(workingDirNotifier);
    debugPrint('-- end --');
  }

  void home2importPj() {
    final contentsNotifier = ref.read(contentsProvider.notifier);

    // local
    final workingDirNotifier =
        ref.read(PageImportPj.workingDirProvider.notifier);
    final importedPjNotifier =
        ref.read(PageImportPj.importedPjProvider.notifier);

    debugPrint('-- init (home -> importPj) --');
    _home2fabInit();
    workingDirNotifier.state = null;
    importedPjNotifier.state = null;
    contentsNotifier.updateDragAndDropSendTo(workingDirNotifier);
    debugPrint('-- end --');
  }

  void home2checkout() {
    final contentsNotifier = ref.read(contentsProvider.notifier);

    // local
    final backupDirNotifier = ref.read(PageCheckout.backupDirProvider.notifier);
    final workingDirNotifier =
        ref.read(PageCheckout.workingDirProvider.notifier);
    final newPjDataNotifier = ref.read(PageCheckout.newPjDataProvider.notifier);

    debugPrint('-- init (home -> createPj) --');
    _home2fabInit();
    workingDirNotifier.state = null;
    newPjDataNotifier.state = null;
    contentsNotifier.updateDragAndDropSendTo(backupDirNotifier);
    debugPrint('-- end --');
  }
}
