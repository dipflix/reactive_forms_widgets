library;

// Copyright 2020 Vasyl Dytsiak. All rights reserved.
// Use of this source code is governed by the MIT license that can be
// found in the LICENSE file.

import 'package:direct_select/direct_select.dart';
import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

export 'package:direct_select/direct_select.dart';

typedef ItemBuilder<V> = Widget Function(BuildContext context, V? item);

/// A [ReactiveDirectSelect] that contains a [DirectSelect].
///
/// This is a convenience widget that wraps a [DirectSelect] widget in a
/// [ReactiveDirectSelect].
///
/// A [ReactiveForm] ancestor is required.
///
class ReactiveDirectSelect<T, V> extends ReactiveFormField<T, V> {
  /// Creates a [ReactiveDirectSelect] that contains a [DirectSelect].
  ///
  /// Can optionally provide a [formControl] to bind this widget to a control.
  ///
  /// Can optionally provide a [formControlName] to bind this ReactiveFormField
  /// to a [FormControl].
  ///
  /// Must provide one of the arguments [formControl] or a [formControlName],
  /// but not both at the same time.
  ///
  /// Can optionally provide a [validationMessages] argument to customize a
  /// message for different kinds of validation errors.
  ///
  /// Can optionally provide a [valueAccessor] to set a custom value accessors.
  /// See [ControlValueAccessor].
  ///
  /// Can optionally provide a [showErrors] function to customize when to show
  /// validation messages. Reactive Widgets make validation messages visible
  /// when the control is INVALID and TOUCHED, this behavior can be customized
  /// in the [showErrors] function.
  ///
  /// ### Example:
  /// Binds a text field.
  /// ```
  /// final form = fb.group({'email': Validators.required});
  ///
  /// ReactiveDirectSelect(
  ///   formControlName: 'email',
  /// ),
  ///
  /// ```
  ///
  /// Binds a text field directly with a *FormControl*.
  /// ```
  /// final form = fb.group({'email': Validators.required});
  ///
  /// ReactiveDirectSelect(
  ///   formControl: form.control('email'),
  /// ),
  ///
  /// ```
  ///
  /// Customize validation messages
  /// ```dart
  /// ReactiveDirectSelect(
  ///   formControlName: 'email',
  ///   validationMessages: {
  ///     ValidationMessage.required: 'The email must not be empty',
  ///     ValidationMessage.email: 'The email must be a valid email',
  ///   }
  /// ),
  /// ```
  ///
  /// Customize when to show up validation messages.
  /// ```dart
  /// ReactiveDirectSelect(
  ///   formControlName: 'email',
  ///   showErrors: (control) => control.invalid && control.touched && control.dirty,
  /// ),
  /// ```
  ///
  /// For documentation about the various parameters, see the [DirectSelect] class
  /// and [DirectSelect], the constructor.
  ReactiveDirectSelect({
    super.key,
    super.formControlName,
    super.formControl,
    super.validationMessages,
    super.valueAccessor,
    super.showErrors,

    ////////////////////////////////////////////////////////////////////////////
    InputDecoration decoration = const InputDecoration(),
    required List<V> items,
    required ItemBuilder<V> itemBuilder,
    required ItemBuilder<V> selectedItemBuilder,
    required double itemExtent,
    FocusNode? focusNode,
    DirectSelectMode mode = DirectSelectMode.drag,
    double itemMagnification = 1.15,
    Color backgroundColor = Colors.white,
    Color selectionColor = Colors.black12,
  }) : super(
          builder: (field) {
            final state = field as _ReactiveMacosTextFieldState<T, V>;

            final InputDecoration effectiveDecoration = decoration
                .applyDefaults(Theme.of(field.context).inputDecorationTheme);

            state._setFocusNode(focusNode);

            return DirectSelect(
              items: items.map((i) => itemBuilder(field.context, i)).toList(),
              onSelectedItemChanged: (i) => field.didChange(
                i != null ? items[i] : null,
              ),
              itemExtent: itemExtent,
              selectedIndex: items.indexWhere((e) => e == field.value),
              mode: mode,
              itemMagnification: itemMagnification,
              backgroundColor: backgroundColor,
              selectionColor: selectionColor,
              child: InputDecorator(
                decoration: effectiveDecoration.copyWith(
                  errorText: field.errorText,
                  enabled: field.control.enabled,
                ),
                child: selectedItemBuilder(
                  field.context,
                  field.value,
                ),
              ),
            );
          },
        );

  @override
  ReactiveFormFieldState<T, V> createState() =>
      _ReactiveMacosTextFieldState<T, V>();
}

class _ReactiveMacosTextFieldState<T, V> extends ReactiveFormFieldState<T, V> {
  late TextEditingController _textController;
  FocusNode? _focusNode;
  late FocusController _focusController;

  @override
  FocusNode get focusNode => _focusNode ?? _focusController.focusNode;

  @override
  void initState() {
    super.initState();

    final initialValue = value;
    _textController = TextEditingController(
        text: initialValue == null ? '' : initialValue.toString());
  }

  @override
  void subscribeControl() {
    _registerFocusController(FocusController());
    super.subscribeControl();
  }

  @override
  void unsubscribeControl() {
    _unregisterFocusController();
    super.unsubscribeControl();
  }

  @override
  void onControlValueChanged(dynamic value) {
    final effectiveValue = (value == null) ? '' : value.toString();
    _textController.value = _textController.value.copyWith(
      text: effectiveValue,
      selection: TextSelection.collapsed(offset: effectiveValue.length),
      composing: TextRange.empty,
    );

    super.onControlValueChanged(value);
  }

  // @override
  // ControlValueAccessor<T, V> selectValueAccessor() {
  //   if (control is FormControl<int>) {
  //     return IntValueAccessor() as ControlValueAccessor<T, String>;
  //   } else if (control is FormControl<double>) {
  //     return DoubleValueAccessor() as ControlValueAccessor<T, String>;
  //   } else if (control is FormControl<DateTime>) {
  //     return DateTimeValueAccessor() as ControlValueAccessor<T, String>;
  //   } else if (control is FormControl<TimeOfDay>) {
  //     return TimeOfDayValueAccessor() as ControlValueAccessor<T, String>;
  //   }
  //
  //   return super.selectValueAccessor();
  // }

  void _registerFocusController(FocusController focusController) {
    _focusController = focusController;
    control.registerFocusController(focusController);
  }

  void _unregisterFocusController() {
    control.unregisterFocusController(_focusController);
    _focusController.dispose();
  }

  void _setFocusNode(FocusNode? focusNode) {
    if (_focusNode != focusNode) {
      _focusNode = focusNode;
      _unregisterFocusController();
      _registerFocusController(FocusController(focusNode: _focusNode));
    }
  }
}
