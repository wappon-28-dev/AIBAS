import 'dart:async';

import 'package:aibas/view/components/navbar.dart';
import 'package:aibas/view/routes/debug.dart';
import 'package:aibas/view/routes/home.dart';
import 'package:aibas/view/routes/projects.dart';
import 'package:aibas/view/routes/settings.dart';
import 'package:aibas/view/util/route.dart';
import 'package:aibas/view/util/window.dart';
import 'package:aibas/vm/now.dart';
import 'package:aibas/vm/page.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:window_manager/window_manager.dart';

class AppRoot extends ConsumerStatefulWidget {
  const AppRoot({super.key});

  @override
  ConsumerState<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends ConsumerState<AppRoot> with WindowListener {
  @override
  void initState() {
    windowManager.addListener(this);
    windowInit();
    RouteController(ref).appInit(context);
    super.initState();
  }

  void windowInit() {
    windowManager.setPreventClose(true);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  Future<void> onWindowClose() async =>
      WindowController(context: context, ref: ref).onWindowClose();

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final navbar = NavBar(ref: ref, orientation: orientation);
    final isPortrait = orientation == Orientation.portrait;

    final pageState = ref.watch(pageProvider);
    final nowState = ref.watch(nowProvider);
    final dateStr =
        DateFormat.yMMMMEEEEd('ja').format(nowState.value ?? DateTime.now());
    final timeStr = DateFormat.Hms().format(nowState.value ?? DateTime.now());
    final dest = NavBar(ref: ref, orientation: orientation).getDest();

    const pages = [
      PageHome(),
      PageProjects(),
      PageSettings(),
      PageDebug(),
    ];

    final content = CustomScrollView(
      slivers: <Widget>[
        SliverAppBar.large(
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'AIBAS',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 40,
                ),
              ),
              Text(
                ' / ${dest[pageState.navbarIndex].label}',
                style: const TextStyle(fontSize: 20),
              )
            ],
          ),
          leading: const SizedBox(),
          leadingWidth: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(10),
            child: AnimatedOpacity(
              opacity: pageState.isVisibleProgressBar ? 1 : 0,
              duration: const Duration(milliseconds: 600),
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                tween: Tween<double>(
                  begin: 0,
                  end: pageState.progress,
                ),
                builder: (context, value, _) => LinearProgressIndicator(
                  value: pageState.progress != -1 ? value : null,
                ),
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: AutoSizeText.rich(
                TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: '$dateStr???',
                      style: const TextStyle(
                        fontSize: 10,
                      ),
                    ),
                    TextSpan(
                      text: timeStr,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.right,
                minFontSize: 20,
                maxLines: 2,
              ),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: pages[pageState.navbarIndex],
        ),
      ],
    );

    return Scaffold(
      bottomNavigationBar: navbar.getBottomNavbar(),
      floatingActionButton: isPortrait ? navbar.fab(context) : null,
      body: navbar.getRailsNavbar(context, content),
    );
  }
}
