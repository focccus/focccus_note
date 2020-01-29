import 'package:undo/undo.dart';

class ClassChange<T> extends Change {
  T _oldValue;
  void Function(T) _execute;
  void Function(T) _undo;

  ClassChange(
    this._oldValue,
    this._execute,
    this._undo,
  );

  void execute() => _execute(_oldValue);
  void undo() => _undo(_oldValue);
}

class TwoClassChange<T, I> extends Change {
  T _oldValue1;
  I _oldValue2;
  void Function(T, I) _execute;
  void Function(T, I) _undo;

  TwoClassChange(
    this._oldValue1,
    this._oldValue2,
    this._execute,
    this._undo,
  );

  void execute() => _execute(_oldValue1, _oldValue2);
  void undo() => _undo(_oldValue1, _oldValue2);
}
