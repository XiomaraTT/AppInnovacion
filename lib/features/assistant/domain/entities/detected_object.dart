class DetectedObject {
  final String label;
  final String relativePosition;
  final String riskLevel;
  final List<int> box;

  DetectedObject({
    required this.label,
    required this.relativePosition,
    required this.riskLevel,
    required this.box,
  });
}
