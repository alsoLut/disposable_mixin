library disposable_mixin;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

mixin DeferDisposeMixin<T extends StatefulWidget> on State<T> {
  final _deferrers = <VoidCallback>[];

  @override
  void dispose() {
    for (var deferrer in _deferrers) {
      deferrer();
    }
    super.dispose();
  }

  /// Example:
  /// ```dart
  /// late Timer timer = defer(
  ///    Timer.periodic(
  ///      const Duration(seconds: 1),
  ///      (t) {},
  ///    ),
  ///    onDefer: (ref) {
  ///      ref.cancel();
  ///    },
  ///  );
  /// ```
  /// #### Using `late` on `timer` will not call `defer()` until you use that timer.
  ///
  /// Another example:
  /// ```dart
  /// Timer timer = Timer.periodic(
  ///   const Duration(seconds: 1),
  ///   (t) {},
  /// );
  ///
  /// @override
  /// void initState() {
  ///   super.initState();
  ///
  ///   defer(
  ///     timer,
  ///     onDefer: (ref) => ref.cancel(),
  ///   );
  /// }
  /// ```
  @nonVirtual
  R defer<R extends Object>(
    R ref, {
    required void Function(R ref) onDefer,
    String? debugLabel,
  }) {
    _deferrers.add(
      () {
        try {
          onDefer(ref);
        } catch (error, stacktrace) {
          if (kDebugMode) {
            print(
              'There was an error disposing ${debugLabel != null ? '\'$debugLabel\' of type ' : ''}${ref.runtimeType}!',
            );
            print('Error: $error');
            print(stacktrace);
          }
        }
      },
    );
    return ref;
  }
}
