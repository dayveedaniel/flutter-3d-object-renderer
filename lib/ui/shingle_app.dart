import 'package:fluent_ui/fluent_ui.dart';
import '3d_renderer_lab/renderer_page.dart';

class ShingleApp extends StatefulWidget {
  const ShingleApp({Key? key}) : super(key: key);

  @override
  State<ShingleApp> createState() => _ShingleAppState();
}

class _ShingleAppState extends State<ShingleApp> {
  @override
  Widget build(BuildContext context) {
    return const RendererPage();
  }
}
