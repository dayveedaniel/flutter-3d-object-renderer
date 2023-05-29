import 'dart:ui' show Color;

import 'package:ditredi/ditredi.dart';
import 'package:vector_math/vector_math_64.dart' as v;

extension ToTransformModifier3D on Model3D<Model3D<dynamic>> {
  TransformModifier3D toTransform([v.Matrix4? transformation]) {
    return TransformModifier3D(
      this,
      transformation ?? v.Matrix4.identity(),
    );
  }
}

class EditableFigure {
  final int index;
  Model3D<Model3D<dynamic>> figure;
  final v.Matrix4 transformation;

  v.Vector3 get translation => transformation.getTranslation();

  TransformModifier3D get transformed =>
      TransformModifier3D(figure, transformation);

  EditableFigure({
    required this.index,
    required this.figure,
    v.Matrix4? transformation,
  }) : transformation = transformation ?? v.Matrix4.identity();

  // ..translate(2.0, 2.0, 2.0)
  // ..rotateZ(10)
  // ..rotateX(10)
  // ..translate(-2.0, -2.0, -2.0)
  bool get showSizeInput =>
      figure is Cube3D ||
      figure is Line3D ||
      figure is PointPlane3D ||
      figure is Plane3D;

  TransformModifier3D changeColor(Color color) {
    switch (figure.runtimeType) {
      case (Cube3D):
        figure = (figure as Cube3D).copyWith(color: color);
        return transformed;
      case (Face3D):
        figure = (figure as Face3D).copyWith(color: color);
        return transformed;
      case (Line3D):
        figure = (figure as Line3D).copyWith(color: color);
        return transformed;
      case (Plane3D):
        figure = (figure as Plane3D).copyWith(color: color);
        return transformed;
      case (PointPlane3D):
        figure = (figure as PointPlane3D).copyWith(color: color);
        return transformed;
    }
    return transformed;
  }

  TransformModifier3D changeSize(double size) {
    switch (figure.runtimeType) {
      case (Cube3D):
        figure = (figure as Cube3D).copyWith(size: size);
        return transformed;
      case (Line3D):
        figure = (figure as Line3D).copyWith(width: size);
        return transformed;
      case (Plane3D):
        figure = (figure as Plane3D).copyWith(size: size);
        return transformed;
      case (PointPlane3D):
        figure = (figure as PointPlane3D).copyWith(size: size);
        return transformed;
    }
    return transformed;
  }

  double get size {
    switch (figure.runtimeType) {
      case (Cube3D):
        return (figure as Cube3D).size;
      case (Line3D):
        return (figure as Line3D).width ?? 0.1;
      case (Plane3D):
        return (figure as Plane3D).size;
      case (PointPlane3D):
        return (figure as PointPlane3D).size;
    }
    return 0.1;
  }
}
