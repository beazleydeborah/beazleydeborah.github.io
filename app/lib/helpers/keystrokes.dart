import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

final incrementKeySet = LogicalKeySet(LogicalKeyboardKey.arrowRight);
final decrementKeySet = LogicalKeySet(LogicalKeyboardKey.arrowLeft);
final searchKeySet = LogicalKeySet(LogicalKeyboardKey.tab);

class IncrementIntent extends Intent {}

class DecrementIntent extends Intent {}

class SearchIntent extends Intent {}

class KeyboardShortcuts extends StatelessWidget {
  const KeyboardShortcuts({
    Key? key,
    required this.child,
    required this.onRightArrow,
    required this.onLeftArrow,
    required this.onTab,
  }) : super(key: key);
  final Widget child;
  final VoidCallback onRightArrow;
  final VoidCallback onLeftArrow;
  final VoidCallback onTab;

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      autofocus: true,
      shortcuts: {
        incrementKeySet: IncrementIntent(),
        decrementKeySet: DecrementIntent(),
        searchKeySet: SearchIntent(),
      },
      actions: {
        IncrementIntent: CallbackAction(onInvoke: (e) => onRightArrow.call()),
        DecrementIntent: CallbackAction(onInvoke: (e) => onLeftArrow.call()),
        SearchIntent: CallbackAction(onInvoke: (e) => onTab.call()),
      },
      child: child,
    );
  }
}
