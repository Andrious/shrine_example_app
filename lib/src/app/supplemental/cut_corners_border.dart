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

import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart'
    show
        BorderRadius,
        BorderSide,
        Canvas,
        OutlineInputBorder,
        Paint,
        Path,
        RRect,
        Radius,
        Rect,
        ShapeBorder,
        TextDirection;

///
class CutCornersBorder extends OutlineInputBorder {
  ///
  const CutCornersBorder({
    BorderSide borderSide = BorderSide.none,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(2)),
    this.cut = 7.0,
    double gapPadding = 2.0,
  }) : super(
          borderSide: borderSide,
          borderRadius: borderRadius,
          gapPadding: gapPadding,
        );

  @override
  OutlineInputBorder copyWith({
    BorderRadius? borderRadius,
    BorderSide? borderSide,
    double? gapPadding,
  }) {
    return CutCornersBorder(
      borderSide: borderSide ?? this.borderSide,
      borderRadius: borderRadius ?? this.borderRadius,
      gapPadding: gapPadding ?? this.gapPadding,
      cut: cut,
    );
  }

  ///
  final double cut;

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is CutCornersBorder) {
      final CutCornersBorder outline = a;
      return CutCornersBorder(
        borderRadius: BorderRadius.lerp(outline.borderRadius, borderRadius, t)!,
        borderSide: BorderSide.lerp(outline.borderSide, borderSide, t),
        cut: cut,
        gapPadding: outline.gapPadding,
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b is CutCornersBorder) {
      final CutCornersBorder outline = b;
      return CutCornersBorder(
        borderRadius: BorderRadius.lerp(borderRadius, outline.borderRadius, t)!,
        borderSide: BorderSide.lerp(borderSide, outline.borderSide, t),
        cut: cut,
        gapPadding: outline.gapPadding,
      );
    }
    return super.lerpTo(b, t);
  }

  Path _notchedCornerPath(Rect center,
      [double start = 0.0, double extent = 0.0]) {
    final Path path = Path();
    if (start > 0.0 || extent > 0.0) {
      path.relativeMoveTo(extent + start, center.top);
      _notchedSidesAndBottom(center, path);
      path
        ..lineTo(center.left + cut, center.top)
        ..lineTo(start, center.top);
    } else {
      path.moveTo(center.left + cut, center.top);
      _notchedSidesAndBottom(center, path);
      path.lineTo(center.left + cut, center.top);
    }
    return path;
  }

  Path _notchedSidesAndBottom(Rect center, Path path) {
    return path
      ..lineTo(center.right - cut, center.top)
      ..lineTo(center.right, center.top + cut)
      ..lineTo(center.right, center.top + center.height - cut)
      ..lineTo(center.right - cut, center.top + center.height)
      ..lineTo(center.left + cut, center.top + center.height)
      ..lineTo(center.left, center.top + center.height - cut)
      ..lineTo(center.left, center.top + cut);
  }

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    double? gapExtent = 0.0,
    double? gapPercentage = 0.0,
    double? gapStart,
    TextDirection? textDirection,
  }) {
    gapExtent = gapExtent ?? 0.0;
    gapPercentage = gapPercentage ?? 0.0;
    assert(gapPercentage >= 0.0 && gapPercentage <= 1.0);

    final Paint paint = borderSide.toPaint();
    final RRect outer = borderRadius.toRRect(rect);
    if (gapStart == null || gapExtent <= 0.0 || gapPercentage == 0.0) {
      canvas.drawPath(_notchedCornerPath(outer.middleRect), paint);
    } else {
      final double extent =
          lerpDouble(0.0, gapExtent + gapPadding * 2.0, gapPercentage) ?? 0;
      switch (textDirection) {
        case TextDirection.rtl:
          {
            final Path path = _notchedCornerPath(
                outer.middleRect, gapStart + gapPadding - extent, extent);
            canvas.drawPath(path, paint);
            break;
          }
        case TextDirection.ltr:
          {
            final Path path = _notchedCornerPath(
                outer.middleRect, gapStart - gapPadding, extent);
            canvas.drawPath(path, paint);
            break;
          }
        default:
      }
    }
  }
}
