import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/cupertino.dart';


const duration_200ms = Duration(milliseconds: 200);
const double inactiveOpacity = 0.5;
const _fadeDuration = duration_200ms;

class WidgetButton extends StatefulWidget {
  const WidgetButton({Key? key,
    required this.child,
    required this.onPressed,
    this.padding,
    this.minSize = kMinInteractiveDimensionCupertino,
    this.pressedOpacity = inactiveOpacity,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.alignment = Alignment.center,
    this.color = const Color(0x5060abe4),
  }) : assert(pressedOpacity == null ||
      (pressedOpacity >= 0.0 && pressedOpacity <= 1.0)), super(key: key);

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onPressed;
  final double? minSize;
  final double? pressedOpacity;
  final BorderRadius? borderRadius;
  final Color? color;
  final AlignmentGeometry alignment;

  bool get enabled => onPressed != null;

  @override
  State<WidgetButton> createState() => _WidgetButtonState();
}

class _WidgetButtonState extends State<WidgetButton>
    with SingleTickerProviderStateMixin {
  final Tween<double> _opacityTween = Tween<double>(begin: 1.0);

  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: duration_200ms,
      value: 0.0,
      vsync: this,
    );
    _opacityAnimation = _animationController
        .drive(CurveTween(curve: Curves.decelerate))
        .drive(_opacityTween);
    _setTween();
  }

  @override
  void didUpdateWidget(WidgetButton old) {
    super.didUpdateWidget(old);
    _setTween();
  }

  void _setTween() {
    _opacityTween.end = widget.pressedOpacity ?? 1.0;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool _buttonHeldDown = false;

  void _handleTapDown(TapDownDetails event) {
    if (!_buttonHeldDown) {
      _buttonHeldDown = true;
      _animate();
    }
  }

  void _handleTapUp(TapUpDetails event) {
    if (_buttonHeldDown) {
      _buttonHeldDown = false;
      _animate();
    }
  }

  void _handleTapCancel() {
    if (_buttonHeldDown) {
      _buttonHeldDown = false;
      _animate();
    }
  }

  void _animate() {
    if (_animationController.isAnimating) {
      return;
    }
    final bool wasHeldDown = _buttonHeldDown;
    final TickerFuture ticker = _buttonHeldDown
        ? _animationController.animateTo(
      1.0,
      duration: _fadeDuration,
      curve: Curves.easeInOutCubicEmphasized,
    )
        : _animationController.animateTo(
      0.0,
      duration: _fadeDuration,
      curve: Curves.easeOutCubic,
    );
    ticker.then<void>((void value) {
      if (mounted && wasHeldDown != _buttonHeldDown) {
        _animate();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.enabled;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? _handleTapDown : null,
      onTapUp: enabled ? _handleTapUp : null,
      onTapCancel: enabled ? _handleTapCancel : null,
      onTap: widget.onPressed,
      child: Semantics(
        button: true,
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: widget.borderRadius,
            ),
            child: Padding(
              padding: widget.padding ?? EdgeInsets.zero,
              child: Opacity(
                opacity: enabled ? 1 : 0.4,
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
