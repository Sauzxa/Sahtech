class AdModel {
  final String id;
  final String companyName;
  final String imageUrl;
  final String title;
  final String description;
  final String link;
  final bool isActive;
  final String state;    // ACCEPTEE, REJECTEE, or EN_ATTENTE
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
    required this.state,
    required this.startDate,
    required this.endDate,
  });

  // Factory method to create an ad from a map
  factory AdModel.fromMap(Map<String, dynamic> map) {
    return AdModel(
      id: map['_id'] ?? '',
      companyName: map['partenaire']?['nom'] ?? map['titre'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      title: map['titre'] ?? '',
      description: map['description'] ?? '',
      link: map['lienRedirection'] ?? '',
      isActive: map['etatPublicite'] == 'PUBLIEE',
      state: map['statusPublicite'] ?? 'EN_ATTENTE',
      startDate: map['dateDebut'] != null
          ? DateTime.parse(map['dateDebut'])
          : DateTime.now(),
      endDate: map['dateFin'] != null
          ? DateTime.parse(map['dateFin'])
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
