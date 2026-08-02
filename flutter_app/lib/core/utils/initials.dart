/// User initials from the first letters of the first and last words,
/// per the UI Style Guide avatar content rule (e.g. "Business Owner"
/// → "BO").
String initialsFor(String? name) {
  if (name == null || name.isEmpty) return '';
  final List<String> parts = name.trim().split(RegExp(r'\s+'));
  if (parts.length == 1) {
    return parts.first.substring(0, 1).toUpperCase();
  }
  return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
      .toUpperCase();
}
