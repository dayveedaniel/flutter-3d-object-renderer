import 'package:ditredi/ditredi.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:windows_app/models/editable_figure_model.dart';
import 'package:windows_app/ui/3d_renderer_lab/renderer.dart';
import 'package:vector_math/vector_math_64.dart' as v;
import 'package:windows_app/widget/widget_button.dart';

class RendererPage extends StatefulWidget {
  const RendererPage({Key? key}) : super(key: key);

  @override
  State<RendererPage> createState() => _RendererPageState();
}

class _RendererPageState extends State<RendererPage> {
  List<TransformModifier3D> figures = [
    PointPlane3D(
      5,
      Axis3D.y,
      0.1,
      v.Vector3(0, -0.5, 0),
      pointWidth: 3,
    ).toTransform(),
    Cube3D(0.1, v.Vector3(0.5, 0, 0)).toTransform(),
    ...Cube3D(0.1, v.Vector3(0, 0, 0)).toLines().map((e) => e.toTransform()),
  ];

  int planeTypeIndex = 1;

  EditableFigure? chosenFigure;

  Color currentColor = const Color.fromARGB(255, 200, 200, 200);

  void setEditableFigureByIndex(int index) {
    final figure = figures[index];
    chosenFigure = EditableFigure(
      index: index,
      figure: figure.figure,
      transformation: figure.transformation,
    );

    scrollController.animateTo(
      scrollController.position.maxScrollExtent + 50,
      duration: Duration(milliseconds: 200),
      curve: Curves.bounceInOut,
    );
    setState(() {});
  }

  bool get isFirstPlane =>
      figures[0].figure.runtimeType is PointPlane3D ||
      figures[0].figure.runtimeType is Plane3D;

  DiTreDiController controller =
      DiTreDiController(maxUserScale: 20, userScale: 8);

  final scrollController = ScrollController();

  void addCube() {
    figures.add(
      Cube3D(0.1, v.Vector3(0, 0.5, 0.1), color: currentColor).toTransform(),
    );
    setEditableFigureByIndex(figures.length - 1);
  }

  bool value = false;

  void toWireFrame(int index) {
    final copy = figures[index];
    figures.removeAt(index);
    figures.addAll(copy.toLines().map((e) => e.toTransform()));
    setState(() {});
  }

  void changePlaneType() {
    if (planeTypeIndex == 0) {
      figures.removeAt(0);
    } else if (planeTypeIndex == 1) {
      final plane =
          PointPlane3D(2, Axis3D.y, 0.1, v.Vector3(0, -0.5, 0), pointWidth: 3)
              .toTransform();
      if (isFirstPlane) {
        figures[0] = plane;
      } else {
        figures.insert(0, plane);
      }
    } else if (planeTypeIndex == 2) {
      final plane =
          Plane3D(1, Axis3D.y, false, v.Vector3(0, -0.5, 0)).toTransform();

      if (isFirstPlane) {
        figures[0] = plane;
      } else {
        figures.insert(0, plane);
      }
    }
    setState(() {});
  }

  void removeItem(int index) {
    figures.removeAt(index);
    setState(() {});
  }

  void updateItem({
    required int index,
    required TransformModifier3D fig,
  }) {
    figures[index] = fig;
    setState(() {});
  }

  void addFace() {
    figures.add(
      Face3D(
        v.Triangle.points(
          v.Vector3(0, 0 - 0.5, 0 - 0.5),
          v.Vector3(0, 0 - 0.5, 0 + 0.5),
          v.Vector3(0, 0 + 0.5, 0 + 0.5),
        ),
        color: currentColor,
      ).toTransform(),
    );
    setEditableFigureByIndex(figures.length - 1);
  }

  void addPlane() {
    figures.add(
      Plane3D(
        0.5,
        Axis3D.y,
        false,
        v.Vector3(0, 0.5, 0),
        color: currentColor,
      ).toTransform(),
    );
    setEditableFigureByIndex(figures.length - 1);
  }

  void addLine() {
    figures.add(
      Line3D(
        v.Vector3(0, 0.1, 0),
        v.Vector3(0.2, 0.1, 0.4),
        width: 1,
        color: currentColor,
      ).toTransform(),
    );
    setEditableFigureByIndex(figures.length - 1);
  }

  void changeColor(Color color) {
    currentColor = color;
    if (chosenFigure != null) {
      figures[chosenFigure!.index] = chosenFigure!.changeColor(color);
    }
    setState(() {});
  }

  void changeSize(double size) {
    figures[chosenFigure!.index] = chosenFigure!.changeSize(size);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            child: Row(
              children: [
                Container(
                  color: Colors.grey.withOpacity(0.2),
                  padding: EdgeInsets.all(8),
                  width: 180,
                  height: 900,
                  child: Column(
                    children: [
                      Text('Figures'),
                      SizedBox(height: 4),
                      Container(
                        height: 2,
                        width: 100,
                        color: Colors.black,
                      ),
                      SizedBox(height: 8),
                      FigureList(),
                      SizedBox(height: 12),
                      if (chosenFigure?.showSizeInput == true) ...[
                        Text('Размер'),
                        Container(
                          height: 2,
                          width: 100,
                          color: Colors.black,
                        ),
                        SizedBox(height: 4),
                        SizedBox(
                            width: 150,
                            child: NumberBox<double>(
                              mode: SpinButtonPlacementMode.compact,
                              value: chosenFigure!.size,
                              smallChange: 0.1,
                              largeChange: 0.5,
                              onChanged: (double? value) {
                                if (value == null) return;
                                changeSize(value);
                              },
                            )),
                        SizedBox(height: 12),
                      ],
                      Text('масштабирование'),
                      SizedBox(height: 4),
                      Container(
                        height: 2,
                        width: 100,
                        color: Colors.black,
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'X:',
                          ),
                          SizedBox(
                              width: 40,
                              child: TextBox(
                                onChanged: (val) {
                                  if (chosenFigure != null) {
                                    chosenFigure!.transformation
                                        .scale(double.parse(val));
                                    updateItem(
                                      index: chosenFigure!.index,
                                      fig: chosenFigure!.transformed,
                                    );
                                  }
                                },
                              )),
                          Text('Y:'),
                          SizedBox(width: 40, child: TextBox()),
                          Text('Z:'),
                          SizedBox(width: 40, child: TextBox()),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text('перемещение'),
                      SizedBox(height: 4),
                      Container(
                        height: 2,
                        width: 100,
                        color: Colors.black,
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Text('X:'),
                          SizedBox(
                              width: 40,
                              child: TextBox(
                                placeholder: chosenFigure == null
                                    ? ''
                                    : chosenFigure!.translation.x.toString(),
                                onChanged: (val) {
                                  final dig = double.tryParse(val);
                                  if (chosenFigure != null && dig != null) {
                                    chosenFigure!.transformation.translate(dig);
                                    updateItem(
                                      index: chosenFigure!.index,
                                      fig: chosenFigure!.transformed,
                                    );
                                  }
                                },
                              )),
                          Text('Y:'),
                          SizedBox(
                              width: 40,
                              child: TextBox(
                                placeholder: chosenFigure == null
                                    ? ''
                                    : chosenFigure!.translation.y.toString(),
                                onChanged: (val) {
                                  final dig = double.tryParse(val);
                                  if (chosenFigure != null && dig != null) {
                                    chosenFigure!.transformation.translate(
                                      chosenFigure!.translation.x,
                                      dig,
                                    );
                                    updateItem(
                                      index: chosenFigure!.index,
                                      fig: chosenFigure!.transformed,
                                    );
                                  }
                                },
                              )),
                          Text('Z:'),
                          SizedBox(
                              width: 40,
                              child: TextBox(
                                placeholder: chosenFigure == null
                                    ? ''
                                    : chosenFigure!.translation.z.toString(),
                                onChanged: (val) {
                                  final dig = double.tryParse(val);
                                  if (chosenFigure != null && dig != null) {
                                    chosenFigure!.transformation.translate(
                                      chosenFigure!.translation.x,
                                      chosenFigure!.translation.y,
                                      dig,
                                    );
                                    updateItem(
                                      index: chosenFigure!.index,
                                      fig: chosenFigure!.transformed,
                                    );
                                  }
                                },
                              )),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text('Rotation'),
                      SizedBox(height: 4),
                      Container(
                        height: 2,
                        width: 100,
                        color: Colors.black,
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Text('X:'),
                          SizedBox(
                              width: 40,
                              child: TextBox(
                                onChanged: (val) {
                                  final dig = double.tryParse(val);
                                  if (chosenFigure != null && dig != null) {
                                    chosenFigure!.transformation
                                        .setRotationX(dig);
                                    updateItem(
                                      index: chosenFigure!.index,
                                      fig: chosenFigure!.transformed,
                                    );
                                  }
                                },
                              )),
                          Text('Y:'),
                          SizedBox(
                              width: 40,
                              child: TextBox(
                                onChanged: (val) {
                                  final dig = double.tryParse(val);
                                  if (chosenFigure != null && dig != null) {
                                    chosenFigure!.transformation
                                        .setRotationY(dig);
                                    updateItem(
                                      index: chosenFigure!.index,
                                      fig: chosenFigure!.transformed,
                                    );
                                  }
                                },
                              )),
                          Text('Z:'),
                          SizedBox(
                              width: 40,
                              child: TextBox(
                                onChanged: (val) {
                                  final dig = double.tryParse(val);
                                  if (chosenFigure != null && dig != null) {
                                    chosenFigure!.transformation
                                        .setRotationZ(dig);
                                    updateItem(
                                      index: chosenFigure!.index,
                                      fig: chosenFigure!.transformed,
                                    );
                                  }
                                },
                              )),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text('Plane'),
                      SizedBox(height: 4),
                      Container(
                        height: 2,
                        width: 100,
                        color: Colors.black,
                      ),
                      const SizedBox(height: 4),
                      ComboBox<int>(
                        onChanged: (value) {
                          if (value == planeTypeIndex) return;
                          planeTypeIndex = value ?? 0;
                          changePlaneType();
                        },
                        value: planeTypeIndex,
                        items: const [
                          ComboBoxItem<int>(
                            child: Text('None'),
                            value: 0,
                          ),
                          ComboBoxItem<int>(
                            child: Text('Point'),
                            value: 1,
                          ),
                          ComboBoxItem<int>(
                            child: Text('Plain'),
                            value: 2,
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text('WireFrame'),
                      SizedBox(height: 4),
                      Container(
                        height: 2,
                        width: 100,
                        color: Colors.black,
                      ),
                      const SizedBox(height: 4),
                      ToggleSwitch(
                        checked: value,
                        onChanged: (val) {
                          if (chosenFigure != null)
                            toWireFrame(chosenFigure!.index);
                        },
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      _ToolBar(),
                      Expanded(
                          child: Renderer(
                        controller: controller,
                        figures: figures,
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolBar extends StatelessWidget {
  const _ToolBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.grey.withOpacity(0.2),
      child: Row(
        children: [
          FilledButton(
            onPressed:
                context.findAncestorStateOfType<_RendererPageState>()?.addCube,
            style: ButtonStyle(
                backgroundColor:
                    ButtonState.all(Colors.black.withOpacity(0.2))),
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                border: Border.all(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          FilledButton(
            onPressed:
                context.findAncestorStateOfType<_RendererPageState>()?.addFace,
            style: ButtonStyle(
                backgroundColor:
                    ButtonState.all(Colors.black.withOpacity(0.2))),
            child: SizedBox(
              width: 30,
              height: 30,
              child: DiTreDi(
                figures: [
                  Face3D(
                    v.Triangle.points(
                      v.Vector3(0, 0 - 1, 0 - 1),
                      v.Vector3(0, 0 - 1, 0 + 1),
                      v.Vector3(0, 0 + 1, 0 + 1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          FilledButton(
            onPressed:
                context.findAncestorStateOfType<_RendererPageState>()?.addLine,
            style: ButtonStyle(
                backgroundColor:
                    ButtonState.all(Colors.black.withOpacity(0.2))),
            child: Container(
              height: 4,
              width: 20,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 10),
          WidgetButton(
            onPressed: () async {
              final color = await showContentDialog(context);
              if (color != null) {
                context
                    .findAncestorStateOfType<_RendererPageState>()
                    ?.changeColor(color);
              }
            },
            child: Container(
              height: 20,
              width: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context
                    .findAncestorStateOfType<_RendererPageState>()
                    ?.currentColor,
              ),
            ),
          ),
          const SizedBox(width: 10),
          FilledButton(
            onPressed:
                context.findAncestorStateOfType<_RendererPageState>()?.addPlane,
            style: ButtonStyle(
                backgroundColor:
                    ButtonState.all(Colors.black.withOpacity(0.2))),
            child: SizedBox(
              width: 20,
              height: 20,
              child: Placeholder(),
            ),
          ),
        ],
      ),
    );
  }
}

class FigureList extends StatelessWidget {
  const FigureList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final figures =
        context.findAncestorStateOfType<_RendererPageState>()!.figures;
    final chosenIndex = context
        .findAncestorStateOfType<_RendererPageState>()!
        .chosenFigure
        ?.index;
    return SizedBox(
      height: 200,
      child: ListView(
        controller: context
            .findAncestorStateOfType<_RendererPageState>()!
            .scrollController,
        children: List.generate(
            figures.length,
            (index) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: WidgetButton(
                    color: index == chosenIndex
                        ? Colors.blue
                        : const Color(0x5060abe4),
                    onPressed: () {
                      context
                          .findAncestorStateOfType<_RendererPageState>()
                          ?.setEditableFigureByIndex(index);
                    },
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                              'Figure $index : ${figures[index].figure.runtimeType.toString()}'),
                        ),
                        IconButton(
                          onPressed: () {
                            context
                                .findAncestorStateOfType<_RendererPageState>()
                                ?.removeItem(index);
                          },
                          icon: Icon(
                            FluentIcons.delete,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
      ),
    );
  }
}

Future<Color?> showContentDialog(BuildContext context) async {
  Color? chosenColor;
  await showDialog<Color>(
    context: context,
    builder: (context) => ContentDialog(
      title: const Text('Choose Color'),
      content: MaterialPicker(
        enableLabel: true,
        portraitOnly: true,
        pickerColor: chosenColor ?? Colors.red,
        onPrimaryChanged: (color) {
          chosenColor = color;
        },
        onColorChanged: (color) {
          chosenColor = color;
        },
      ),
      actions: [
        SizedBox(
          width: 100,
          child: FilledButton(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context, chosenColor),
          ),
        ),
      ],
    ),
  );
  return chosenColor;
}
