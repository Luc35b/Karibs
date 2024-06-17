//Trial
import 'package:flutter/material.dart';

class HelpOverlay extends StatefulWidget {
  @override
  _HelpOverlayState createState() => _HelpOverlayState();
}

class _HelpOverlayState extends State<HelpOverlay> {
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  OverlayEntry _createOverlayEntry(BuildContext context) {
    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Background to dim the screen
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggleOverlay, // Close overlay on tap
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
          ),
          // Add overlay items (arrows and descriptions)
          _buildOverlayItem(
            context,
            Offset(100, 150),
            'This button adds a new test',
            Icons.arrow_downward,
          ),
          _buildOverlayItem(
            context,
            Offset(200, 250),
            'This button generates a report',
            Icons.arrow_downward,
          ),
          // Add more overlay items as needed
        ],
      ),
    );
  }

  Widget _buildOverlayItem(BuildContext context, Offset position, String description, IconData arrowIcon) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Column(
        children: [
          Icon(arrowIcon, color: Colors.white, size: 36),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              description,
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleOverlay() {
    if (_overlayEntry == null) {
      _overlayEntry = _createOverlayEntry(context);
      Overlay.of(context)?.insert(_overlayEntry!);
    } else {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _toggleOverlay,
      child: Text('Show Help'),
    );
  }
}
