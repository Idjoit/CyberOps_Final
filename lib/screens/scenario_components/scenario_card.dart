import 'package:flutter/material.dart';
import 'package:cyberops/models/scenario_model.dart';
import 'dart:async';
import 'dart:ui' as ui;

class ScenarioCard extends StatefulWidget {
  final Scenario scenario;
  final bool showFeedback;
  final String feedback;

  const ScenarioCard({
    super.key,
    required this.scenario,
    required this.showFeedback,
    required this.feedback,
  });

  @override
  State<ScenarioCard> createState() => _ScenarioCardState();
}

class _ScenarioCardState extends State<ScenarioCard> {
  double _aspectRatio = 16 / 9;
  bool _imageLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAspectRatioSafely();
  }

  Future<void> _loadAspectRatioSafely() async {
    final imagePath = widget.scenario.imagePath?.isNotEmpty == true
        ? widget.scenario.imagePath!
        : 'assets/images/placeholder.jpg';

    final ImageProvider<Object> provider = imagePath.startsWith('http')
        ? NetworkImage(imagePath)
        : AssetImage(imagePath) as ImageProvider<Object>;

    final completer = Completer<ui.Image>();
    provider.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener(
        (info, _) => completer.complete(info.image),
        onError: (error, _) => completer.completeError(error),
      ),
    );

    try {
      final image = await completer.future;
      if (mounted) {
        setState(() {
          final ratio = image.width / image.height;
          _aspectRatio = ratio.clamp(1.2, 1.9); // prevent extreme shapes
          _imageLoaded = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _imageLoaded = true);
    }
  }

  Widget _buildScenarioImage(String imagePath, double maxHeight) {
    final ImageProvider<Object> imageProvider = imagePath.startsWith('http')
        ? NetworkImage(imagePath)
        : AssetImage(imagePath) as ImageProvider<Object>;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: FadeInImage(
        placeholder: const AssetImage('assets/images/placeholder.jpg'),
        image: imageProvider,
        fit: BoxFit.cover,
        width: double.infinity,
        height: maxHeight,
        imageErrorBuilder: (context, error, stackTrace) => Image.asset(
          'assets/images/placeholder.jpg',
          fit: BoxFit.cover,
          height: maxHeight,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scenario = widget.scenario;
    final feedback = widget.feedback;
    final screenHeight = MediaQuery.of(context).size.height;
    final imageHeight = screenHeight * 0.25; // dynamically scale image size

    return Container(
      constraints: const BoxConstraints(maxHeight: 520),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🖼️ Image container with safe height
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: imageHeight,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black12,
                ),
                clipBehavior: Clip.hardEdge,
                child: _imageLoaded
                    ? _buildScenarioImage(
                        scenario.imagePath?.isNotEmpty == true
                            ? scenario.imagePath!
                            : 'assets/images/placeholder.jpg',
                        imageHeight,
                      )
                    : const Center(
                        child: CircularProgressIndicator(
                          color: Colors.teal,
                          strokeWidth: 2,
                        ),
                      ),
              ),

              const SizedBox(height: 12),

              // 🧠 Title
              Text(
                scenario.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              // 📜 Description
              Text(
                scenario.description,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              // 💬 Feedback text
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: widget.showFeedback
                    ? Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          feedback,
                          key: ValueKey(feedback),
                          style: const TextStyle(
                            color: Colors.teal,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
