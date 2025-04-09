import 'dart:ui';

import 'package:armour_app/widgets/home_page_sheet.dart';
import 'package:armour_app/widgets/map_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lucide_icons/lucide_icons.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            centerTitle: true,
            toolbarHeight: 68,
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: Colors.transparent,
            title: SvgPicture.asset(
              "assets/images/gradient-wordmark.svg",
              height: 24,
            ),
            flexibleSpace: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surface.withValues(alpha: 0.5),
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(onPressed: () {}, icon: Icon(LucideIcons.settings)),
            ],
          ),
          body: SafeArea(
            top: false,
            child: Stack(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  alignment: Alignment.topRight,
                  child: Stack(children: [
                    
                  ]
                ),
                ),
                MapView(),
              ],
            ),
          ),
        ),
        HomePageSheet(),
      ],
    );
  }
}
