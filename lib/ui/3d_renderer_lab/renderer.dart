import 'package:ditredi/ditredi.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:windows_app/ui/3d_renderer_lab/store.dart';

class Renderer extends StatelessWidget {
  const Renderer({
    Key? key,
    required this.figures,
    required this.controller,
  }) : super(key: key);

  final List<Model3D<Model3D<dynamic>>> figures;
  final DiTreDiController controller;

  @override
  Widget build(BuildContext context) {
    return DiTreDiDraggable(
      controller: controller,
      child: DiTreDi(
        // config: DiTreDiConfig(
        //   perspective: false,
        //   supportZIndex: false,
        // ),
        controller: controller,
        figures: figures,
      ),
    );
  }
}
