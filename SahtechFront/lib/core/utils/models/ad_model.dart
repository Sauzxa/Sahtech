class AdModel {
  final String id;
  final String companyName;
  final String imageUrl;
  final String title;
  final String description;
  final String link;
  final bool isActive;
  final DateTime startDate;
  final DateTime endDate;

  AdModel({
    required this.id,
    required this.companyName,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.link,
    required this.isActive,
    required this.startDate,
    required this.endDate,
  });

  // Factory method to create an ad from a map
  factory AdModel.fromMap(Map<String, dynamic> map) {
    return AdModel(
      id: map['_id'] ?? '',
      companyName: map['companyName'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      link: map['link'] ?? '',
      isActive: map['isActive'] ?? false,
      startDate: map['startDate'] != null
          ? DateTime.parse(map['startDate'])
          : DateTime.now(),
      endDate: map['endDate'] != null
          ? DateTime.parse(map['endDate'])
          : DateTime.now().add(const Duration(days: 30)),
    );
  }

  // Convert ad data to a map
  Map<String, dynamic> toMap() {
    return {
      'companyName': companyName,
      'imageUrl': imageUrl,
      'title': title,
      'description': description,
      'link': link,
      'isActive': isActive,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }
}
