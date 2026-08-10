import 'package:flutter/material.dart';

import '../../core/router/app_router.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    required this.title,
    this.actions = const [],
    this.showSearch = true,
    super.key,
  });

  final Widget title;
  final List<Widget> actions;
  final bool showSearch;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) => AppBar(
    title: title,
    actions: [
      ...actions,
      if (showSearch)
        IconButton(
          tooltip: MaterialLocalizations.of(context).searchFieldLabel,
          onPressed: () => const SearchRoute().push<void>(context),
          icon: const Icon(Icons.search),
        ),
    ],
  );
}
