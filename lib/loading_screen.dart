import 'package:flutter/material.dart';

LoadingScreenHandler showLoadingScreen(
  BuildContext context, {
  String? text,
  Color? color,
}) {
  final overlayState = Overlay.of(context, rootOverlay: true);

  if (overlayState == null) {
    throw StateError('No Overlay found to show the loading screen');
  }

  late final OverlayEntry overlayEntry;
  final handler = LoadingScreenHandler(
    color: color,
    text: text,
    removeEntry: () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    },
  );

  overlayEntry = OverlayEntry(
    builder: (overlayContext) => LoadingScreenBody(
      handler: handler,
    ),
  );

  overlayState.insert(overlayEntry);

  return handler;
}

class LoadingScreen {
  final Color? color;
  final GlobalKey<NavigatorState> globalKey;

  LoadingScreen({
    this.color,
    required this.globalKey,
  });

  LoadingScreenHandler show({
    String? text,
  }) {
    return showLoadingScreen(
      globalKey.currentContext!,
      text: text,
      color: color,
    );
  }
}

@protected
class LoadingScreenHandler {
  String? id, text;
  Color? color;
  double? _progress;
  late void Function() refresh;
  late final VoidCallback _removeEntry;
  bool expired = false;

  LoadingScreenHandler({
    this.id,
    this.color,
    this.text,
    double? progress,
    void Function()? refresh,
    required VoidCallback removeEntry,
  }) {
    this.refresh = refresh ?? () {};
    this.progress = progress;
    _removeEntry = removeEntry;
  }

  double? get progress => _progress;
  set progress(double? value) {
    _progress = value;
    refresh();
  }

  void hide() {
    if (expired) return;

    expired = true;

    _removeEntry();
  }
}

@protected
class LoadingScreenBody extends StatefulWidget {
  final LoadingScreenHandler handler;
  const LoadingScreenBody({super.key, required this.handler});

  @override
  State<LoadingScreenBody> createState() => _LoadingScreenBodyState();
}

class _LoadingScreenBodyState extends State<LoadingScreenBody> {
  @override
  void initState() {
    widget.handler.refresh = () {
      if (mounted) {
        setState(() {});
      }
    };

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ModalBarrier(
          color: Colors.black.withOpacity(0.35),
          dismissible: false,
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              CircularProgressIndicator(
                color: widget.handler.color ?? Colors.white,
                value: widget.handler.progress,
                semanticsLabel: widget.handler.text,
              ),
              if (widget.handler.progress != null) const SizedBox(height: 8),
              if (widget.handler.progress != null)
                Text(
                  '${(widget.handler.progress! * 100).toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: widget.handler.color ?? Colors.white,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
