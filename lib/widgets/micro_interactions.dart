import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;

class AnimatedButton extends StatefulWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final bool isLoading;
  final AnimationType animationType;

  const AnimatedButton({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.borderRadius,
    this.isLoading = false,
    this.animationType = AnimationType.bounce,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

enum AnimationType { bounce, spring, pulse, ripple }

class _AnimatedButtonState extends State<AnimatedButton>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _rippleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rippleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
    if (widget.animationType == AnimationType.ripple) {
      _rippleController.forward().then((_) => _rippleController.reset());
    }
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Stack(
              children: [
                Container(
                  padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: widget.backgroundColor ?? Colors.deepOrangeAccent,
                    borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: (widget.backgroundColor ?? Colors.deepOrangeAccent).withOpacity(0.3),
                        blurRadius: _isPressed ? 4 : 8,
                        offset: Offset(0, _isPressed ? 2 : 4),
                      ),
                    ],
                  ),
                  child: widget.isLoading
                      ? _buildLoadingContent()
                      : _buildButtonContent(),
                ),
                if (widget.animationType == AnimationType.ripple)
                  _buildRippleEffect(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildButtonContent() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.icon != null) ...[
          Icon(
            widget.icon,
            color: widget.foregroundColor ?? Colors.white,
            size: 18,
          ),
          const SizedBox(width: 8),
        ],
        Text(
          widget.text,
          style: TextStyle(
            color: widget.foregroundColor ?? Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingContent() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              widget.foregroundColor ?? Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Loading...',
          style: TextStyle(
            color: widget.foregroundColor ?? Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildRippleEffect() {
    return AnimatedBuilder(
      animation: _rippleAnimation,
      builder: (context, child) {
        return Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.5 * (1 - _rippleAnimation.value)),
                width: 2 * _rippleAnimation.value,
              ),
            ),
          ),
        );
      },
    );
  }
}

class AnimatedTextField extends StatefulWidget {
  final String hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final Function(String)? onChanged;
  final TextEditingController? controller;
  final bool isPassword;
  final String? Function(String?)? validator;

  const AnimatedTextField({
    super.key,
    required this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.onChanged,
    this.controller,
    this.isPassword = false,
    this.validator,
  });

  @override
  State<AnimatedTextField> createState() => _AnimatedTextFieldState();
}

class _AnimatedTextFieldState extends State<AnimatedTextField>
    with TickerProviderStateMixin {
  late AnimationController _focusController;
  late AnimationController _validationController;
  late Animation<Color?> _borderColorAnimation;
  late Animation<double> _scaleAnimation;
  
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  bool _hasError = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _focusController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _validationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _borderColorAnimation = ColorTween(
      begin: Colors.white24,
      end: Colors.deepOrangeAccent,
    ).animate(_focusController);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _focusController,
      curve: Curves.easeOut,
    ));

    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
      if (_focusNode.hasFocus) {
        _focusController.forward();
        HapticFeedback.selectionClick();
      } else {
        _focusController.reverse();
        _validateField();
      }
    });
  }

  @override
  void dispose() {
    _focusController.dispose();
    _validationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _validateField() {
    if (widget.validator != null) {
      final error = widget.validator!(widget.controller?.text);
      setState(() {
        _hasError = error != null;
        _errorText = error;
      });
      
      if (_hasError) {
        _validationController.forward().then((_) {
          Future.delayed(const Duration(milliseconds: 100), () {
            _validationController.reverse();
          });
        });
        HapticFeedback.heavyImpact();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedBuilder(
          animation: Listenable.merge([_focusController, _validationController]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.translate(
                offset: Offset(
                  _hasError ? (math.sin(_validationController.value * math.pi * 4) * 3) : 0,
                  0,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _hasError 
                          ? Colors.red 
                          : _borderColorAnimation.value ?? Colors.white24,
                      width: _isFocused ? 2 : 1,
                    ),
                    boxShadow: _isFocused ? [
                      BoxShadow(
                        color: Colors.deepOrangeAccent.withOpacity(0.2),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ] : null,
                  ),
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    obscureText: widget.isPassword,
                    onChanged: widget.onChanged,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      labelText: widget.labelText,
                      hintStyle: const TextStyle(color: Colors.white54),
                      labelStyle: TextStyle(
                        color: _isFocused ? Colors.deepOrangeAccent : Colors.white70,
                      ),
                      prefixIcon: widget.prefixIcon != null
                          ? Icon(
                              widget.prefixIcon,
                              color: _isFocused ? Colors.deepOrangeAccent : Colors.white70,
                            )
                          : null,
                      suffixIcon: widget.suffixIcon != null
                          ? IconButton(
                              icon: Icon(
                                widget.suffixIcon,
                                color: _isFocused ? Colors.deepOrangeAccent : Colors.white70,
                              ),
                              onPressed: widget.onSuffixTap,
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        if (_hasError && _errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 16),
            child: Text(
              _errorText!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ).animate().fadeIn().slideX(begin: -0.3),
          ),
      ],
    );
  }
}

class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
      ),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.grey[800]!,
                  Colors.grey[600]!,
                  Colors.grey[800]!,
                ],
                stops: [
                  math.max(0.0, _animation.value - 0.3),
                  _animation.value,
                  math.min(1.0, _animation.value + 0.3),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class PullToRefreshWidget extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const PullToRefreshWidget({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  @override
  State<PullToRefreshWidget> createState() => _PullToRefreshWidgetState();
}

class _PullToRefreshWidgetState extends State<PullToRefreshWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    _controller.repeat();
    HapticFeedback.mediumImpact();
    
    try {
      await widget.onRefresh();
    } finally {
      _controller.stop();
      _controller.reset();
      setState(() => _isRefreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: widget.child,
      color: Colors.deepOrangeAccent,
      backgroundColor: const Color(0xFF0E1620),
      displacement: 60,
    );
  }
}

class ProgressIndicatorWidget extends StatefulWidget {
  final double progress;
  final String? label;
  final Color? color;
  final double height;

  const ProgressIndicatorWidget({
    super.key,
    required this.progress,
    this.label,
    this.color,
    this.height = 8,
  });

  @override
  State<ProgressIndicatorWidget> createState() => _ProgressIndicatorWidgetState();
}

class _ProgressIndicatorWidgetState extends State<ProgressIndicatorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void didUpdateWidget(ProgressIndicatorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: oldWidget.progress,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.white12,
            borderRadius: BorderRadius.circular(widget.height / 2),
          ),
          child: AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _progressAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.color ?? Colors.deepOrangeAccent,
                        (widget.color ?? Colors.deepOrangeAccent).withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(widget.height / 2),
                    boxShadow: [
                      BoxShadow(
                        color: (widget.color ?? Colors.deepOrangeAccent).withOpacity(0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}