import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/refresh_provider.dart';

class AutoRefreshWrapper extends StatefulWidget {
  final Widget child;
  final Function() onRefresh;

  const AutoRefreshWrapper({
    Key? key,
    required this.child,
    required this.onRefresh,
  }) : super(key: key);

  @override
  State<AutoRefreshWrapper> createState() => _AutoRefreshWrapperState();
}

class _AutoRefreshWrapperState extends State<AutoRefreshWrapper> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final refreshProvider = Provider.of<RefreshProvider>(context);
    if (refreshProvider.shouldRefresh) {
      widget.onRefresh();
      refreshProvider.refreshCompleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
