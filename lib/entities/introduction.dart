class Introduction {
  final String title;
  final String subtitle;
  final String imageUrl;

  Introduction({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
  });

  factory Introduction.fromJson(Map<String, dynamic> json) {
    return Introduction(
      title: json['title'],
      subtitle: json['subtitle'],
      imageUrl: json['image_url'],
    );
  }
}
