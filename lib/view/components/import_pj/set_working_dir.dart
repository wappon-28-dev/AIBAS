import 'dart:io';

import 'package:aibas/model/error/exception.dart';
import 'package:aibas/model/helper/config.dart';
import 'package:aibas/model/helper/snackbar.dart';
import 'package:aibas/repository/config.dart';
import 'package:aibas/view/components/wizard.dart';
import 'package:aibas/view/routes/fab/import_pj.dart';
import 'package:aibas/vm/svn.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CompSetWorkingDir extends ConsumerWidget {
  const CompSetWorkingDir({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // global ref
    final cmdSVNNotifier = ref.read(cmdSVNProvider.notifier);

    // wizard ref
    final isValidContentsNotifier =
        ref.read(CompWizard.isValidContentsProvider.notifier);

    // local ref
    final workingDirState = ref.watch(PageImportPj.workingDirProvider);
    final workingDirNotifier =
        ref.read(PageImportPj.workingDirProvider.notifier);

    final textController = TextEditingController(text: workingDirState?.path);
    final snackBar = SnackBarController(context, ref);

    bool isValidContents() =>
        workingDirState != null && workingDirState.existsSync();

    // state callback
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => isValidContentsNotifier.state = isValidContents(),
    );

    ref.listen(PageImportPj.workingDirProvider, (_, workingDir) async {
      if (workingDir == null) return;
      try {
        final backupDir = await cmdSVNNotifier.getBackupDir(workingDir);
        final importedPjNotifier =
            ref.read(PageImportPj.importedPjProvider.notifier);

        final pjConfig =
            await PjConfigRepository().getPjConfigFromBackupDir(backupDir);
        if (pjConfig == null) throw AIBASException.pjConfigIsNull;
        final importedPj = await PjConfigHelper().pjConfig2Project(pjConfig);

        importedPjNotifier.state = importedPj;
        snackBar.pushSnackBarSuccess(
          content: '?????????????????? ???${pjConfig.name}??? ??????????????????????????????',
        );
      } on AIBASException catch (err) {
        isValidContentsNotifier.state = false;
        SnackBarController(context, ref).errHandlerBanner(err);
        // ignore: avoid_catches_without_on_clauses
      } catch (err, __) {
        isValidContentsNotifier.state = false;
        SnackBarController(context, ref).errHandlerBanner(err);
      }
    });

    Future<void> handleClick() async {
      final selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory == null) return;
      final dir = Directory(selectedDirectory);
      workingDirNotifier.state = dir;
      textController.text = dir.path;
    }

    String? validator(String? newVal) {
      if (newVal == null || newVal.isEmpty) {
        return '?????????????????????????????????????????????????????????';
      }

      try {
        if (!Directory(newVal).existsSync()) {
          return '???????????????????????????????????????????????????????????????';
        }
        // ignore: avoid_catches_without_on_clauses
      } catch (_, __) {
        return '???????????????????????????????????????????????????????????????';
      }

      return null;
    }

    final workingDirField = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: const [
              Icon(Icons.folder, size: 47),
              Text('?????????????????????', textAlign: TextAlign.center),
            ],
          ),
        ),
        Expanded(
          flex: 12,
          child: Focus(
            child: TextFormField(
              controller: textController,
              autovalidateMode: AutovalidateMode.always,
              validator: validator,
              decoration: const InputDecoration(
                hintText: '(????????????????????????????????????????????????)',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => isValidContentsNotifier.state =
                  validator(textController.text) == null,
            ),
            onFocusChange: (hasFocus) {
              if (!hasFocus) {
                if (validator(textController.text) == null) {
                  workingDirNotifier.state = Directory(textController.text);
                }
              }
            },
          ),
        ),
        Expanded(
          child: IconButton(
            onPressed: handleClick,
            icon: const Icon(Icons.more_horiz),
          ),
        ),
      ],
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: handleClick,
          child: DottedBorder(
            color: Theme.of(context).colorScheme.tertiary,
            dashPattern: const [15, 6],
            strokeWidth: 3,
            child: Container(
              height: 400,
              width: 400,
              color: Theme.of(context).colorScheme.tertiaryContainer,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  Text(
                    '????????????????????????????????????????????????\n???????????? & ????????????',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  Icon(Icons.create_new_folder, size: 100),
                  Text(
                    '?????????, ??????????????????????????????????????????',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
        workingDirField,
        SizedBox(
          height: 40,
          child: TextButton.icon(
            label: const Text('????????????'),
            icon: const Icon(Icons.restart_alt),
            onPressed: isValidContents()
                ? () => workingDirNotifier.state = null
                : null,
          ),
        ),
      ],
    );
  }
}
