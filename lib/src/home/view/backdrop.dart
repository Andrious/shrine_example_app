// Copyright 2018-present the Flutter authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

import 'package:prefs/prefs.dart' show Prefs;

import '/src/model.dart' show AppStateModel;

import '/src/view.dart' show AppMenu, L10n;

const Cubic _kAccelerateCurve = Cubic(0.548, 0, 0.757, 0.464);
const Cubic _kDecelerateCurve = Cubic(0.23, 0.94, 0.41, 1);
const double _kPeakVelocityTime = 0.248210;
const double _kPeakVelocityProgress = 0.379146;

class _FrontLayer extends StatelessWidget {
  const _FrontLayer({
    Key? key,
    required this.onTap,
    required this.child,
  }) : super(key: key);

  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 16,
      shape: const BeveledRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(46)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Container(
              height: 40,
              alignment: AlignmentDirectional.centerStart,
            ),
          ),
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}

class _BackdropTitle extends AnimatedWidget {
  const _BackdropTitle({
    Key? key,
    required Listenable listenable,
    required this.onPress,
    required this.frontTitle,
    required this.backTitle,
  }) : super(key: key, listenable: listenable);

  final void Function() onPress;
  final Widget frontTitle;
  final Widget backTitle;

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = CurvedAnimation(
      curve: const Interval(0, 0.78),
      parent: listenable as Animation<double>,
    );

    return DefaultTextStyle(
      style: Theme.of(context).primaryTextTheme.titleSmall!,
      softWrap: false,
      overflow: TextOverflow.ellipsis,
      child: Row(children: <Widget>[
        // branded icon
        SizedBox(
          width: 72,
          child: IconButton(
            padding: const EdgeInsets.only(right: 8),
            onPressed: onPress,
            icon: Stack(children: <Widget>[
              Opacity(
                opacity: animation.value,
                child: const ImageIcon(AssetImage('assets/slanted_menu.png')),
              ),
              FractionalTranslation(
                translation: Tween<Offset>(
                  begin: Offset.zero,
                  end: const Offset(1, 0),
                ).evaluate(animation),
                child: const ImageIcon(AssetImage('assets/diamond.png')),
              ),
            ]),
          ),
        ),
        // Here, we do a custom cross fade between backTitle and frontTitle.
        // This makes a smooth animation between the two texts.
        Stack(
          children: <Widget>[
            Opacity(
              opacity: CurvedAnimation(
                parent: ReverseAnimation(animation),
                curve: const Interval(0.5, 1),
              ).value,
              child: FractionalTranslation(
                translation: Tween<Offset>(
                  begin: Offset.zero,
                  end: const Offset(0.5, 0),
                ).evaluate(animation),
                child: backTitle,
              ),
            ),
            Opacity(
              opacity: CurvedAnimation(
                parent: animation,
                curve: const Interval(0.5, 1),
              ).value,
              child: FractionalTranslation(
                translation: Tween<Offset>(
                  begin: const Offset(-0.25, 0),
                  end: Offset.zero,
                ).evaluate(animation),
                child: frontTitle,
              ),
            ),
          ],
        ),
      ]),
    );
  }
}

/// Builds a Backdrop.
///
/// A Backdrop widget has two layers, front and back. The front layer is shown
/// by default, and slides down to show the back layer, from which a user
/// can make a selection. The user can also configure the titles for when the
/// front or back layer is showing.
class Backdrop extends StatefulWidget {
  ///
  const Backdrop({
    Key? key,
    required this.frontLayer,
    required this.backLayer,
    required this.frontTitle,
    required this.backTitle,
    required this.controller,
  }) : super(key: key);

  ///
  final Widget frontLayer;

  ///
  final Widget backLayer;

  ///
  final Widget frontTitle;

  ///
  final Widget backTitle;

  ///
  final AnimationController controller;

  @override
  _BackdropState createState() => _BackdropState();
}

class _BackdropState extends State<Backdrop>
    with SingleTickerProviderStateMixin {
  _BackdropState() : super();

  final GlobalKey _backdropKey = GlobalKey(debugLabel: 'Backdrop');
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _frontLayerVisible {
    final AnimationStatus status = _controller.status;
    return status == AnimationStatus.completed ||
        status == AnimationStatus.forward;
  }

  void _toggleBackdropLayerVisibility() {
    // Call setState here to update layerAnimation if that's necessary
    setState(() {
      _frontLayerVisible ? _controller.reverse() : _controller.forward();
    });
  }

  // _layerAnimation animates the front layer between open and close.
  // _getLayerAnimation adjusts the values in the TweenSequence so the
  // curve and timing are correct in both directions.
  Animation<RelativeRect> _getLayerAnimation(Size layerSize, double layerTop) {
    Curve firstCurve; // Curve for first TweenSequenceItem
    Curve secondCurve; // Curve for second TweenSequenceItem
    double firstWeight; // Weight of first TweenSequenceItem
    double secondWeight; // Weight of second TweenSequenceItem
    Animation<double> animation; // Animation on which TweenSequence runs

    if (_frontLayerVisible) {
      firstCurve = _kAccelerateCurve;
      secondCurve = _kDecelerateCurve;
      firstWeight = _kPeakVelocityTime;
      secondWeight = 1.0 - _kPeakVelocityTime;
      animation = CurvedAnimation(
        parent: _controller.view,
        curve: const Interval(0, 0.78),
      );
    } else {
      // These values are only used when the controller runs from t=1.0 to t=0.0
      firstCurve = _kDecelerateCurve.flipped;
      secondCurve = _kAccelerateCurve.flipped;
      firstWeight = 1.0 - _kPeakVelocityTime;
      secondWeight = _kPeakVelocityTime;
      animation = _controller.view;
    }

    return TweenSequence<RelativeRect>(
      <TweenSequenceItem<RelativeRect>>[
        TweenSequenceItem<RelativeRect>(
          tween: RelativeRectTween(
            begin: RelativeRect.fromLTRB(
              0,
              layerTop,
              0,
              layerTop - layerSize.height,
            ),
            end: RelativeRect.fromLTRB(
              0,
              layerTop * _kPeakVelocityProgress,
              0,
              (layerTop - layerSize.height) * _kPeakVelocityProgress,
            ),
          ).chain(CurveTween(curve: firstCurve)),
          weight: firstWeight,
        ),
        TweenSequenceItem<RelativeRect>(
          tween: RelativeRectTween(
            begin: RelativeRect.fromLTRB(
              0,
              layerTop * _kPeakVelocityProgress,
              0,
              (layerTop - layerSize.height) * _kPeakVelocityProgress,
            ),
            end: RelativeRect.fill,
          ).chain(CurveTween(curve: secondCurve)),
          weight: secondWeight,
        ),
      ],
    ).animate(animation);
  }

  Widget _buildStack(BuildContext context, BoxConstraints constraints) {
    const double layerTitleHeight = 48;
    final Size layerSize = constraints.biggest;
    final double layerTop = layerSize.height - layerTitleHeight;

    final Animation<RelativeRect> _layerAnimation =
        _getLayerAnimation(layerSize, layerTop);

    return Stack(
      key: _backdropKey,
      children: <Widget>[
        widget.backLayer,
        PositionedTransition(
          rect: _layerAnimation,
          child: _FrontLayer(
            onTap: _toggleBackdropLayerVisibility,
            child: widget.frontLayer,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppBar appBar = AppBar(
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      elevation: 0,
      titleSpacing: 0,
      title: _BackdropTitle(
        listenable: _controller.view,
        onPress: _toggleBackdropLayerVisibility,
        frontTitle: widget.frontTitle,
        backTitle: widget.backTitle,
      ),
      actions: [AppMenu()],
    );
    return Scaffold(
      appBar: appBar,
      body: LayoutBuilder(
        builder: _buildStack,
      ),
    );
  }
}

// class _PopMenu extends AppMenu<Locale> {
//   _PopMenu()
//       : super(
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//           position: PopupMenuPosition.under,
//         );
//   @override
//   List<PopupMenuItem<Locale>> get menuItems => [
//         PopupMenuItem<Locale>(
//             value: const Locale('en', 'US'), child: L10n.t('English')),
//         PopupMenuItem<Locale>(
//             value: const Locale('fr', 'FR'), child: L10n.t('French')),
//         PopupMenuItem<Locale>(
//             value: const Locale('es', 'AR'), child: L10n.t('Spanish')),
//       ];
//
//   @override
//   void selected(Locale value) {
//     L10n.locale = value;
//     Prefs.setString('locale', value.toString());
//     AppStateModel().refresh();
//   }
// }
