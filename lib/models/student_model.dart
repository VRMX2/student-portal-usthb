class Student {
  final String id; // Firebase Auth Uid
  final String email;
  final String fullName;
  final String matricule;
  final String faculty;
  final String academicLevel; // L1, L2, L3, M1, M2
  final String department;
  final String? profilePhotoUrl;
  final List<String> enrolledModuleIds;
  final Map<String, dynamic> metadata;
  
  // Social fields
  final String? bio;
  final int followerCount;
  final int followingCount;
  final bool isPrivate;
  final DateTime? lastSeen;
  final bool isOnline;

  Student({
    required this.id,
    required this.email,
    required this.fullName,
    required this.matricule,
    required this.faculty,
    required this.academicLevel,
    required this.department,
    this.profilePhotoUrl,
    this.enrolledModuleIds = const [],
    this.metadata = const {},
    this.bio,
    this.followerCount = 0,
    this.followingCount = 0,
    this.isPrivate = false,
    this.lastSeen,
    this.isOnline = false,
  });

  factory Student.fromMap(Map<String, dynamic> data, String id) {
    return Student(
      id: id,
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      matricule: data['matricule'] ?? '',
      faculty: data['faculty'] ?? '',
      academicLevel: data['academicLevel'] ?? '',
      department: data['department'] ?? '',
      profilePhotoUrl: data['profilePhotoUrl'],
      enrolledModuleIds: List<String>.from(data['enrolledModuleIds'] ?? []),
      metadata: data['metadata'] ?? {},
      bio: data['bio'],
      followerCount: data['followerCount'] ?? 0,
      followingCount: data['followingCount'] ?? 0,
      isPrivate: data['isPrivate'] ?? false,
      lastSeen: data['lastSeen']?.toDate(),
      isOnline: data['isOnline'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'fullName': fullName,
      'matricule': matricule,
      'faculty': faculty,
      'academicLevel': academicLevel,
      'department': department,
      'profilePhotoUrl': profilePhotoUrl,
      'enrolledModuleIds': enrolledModuleIds,
      'metadata': metadata,
      'bio': bio,
      'followerCount': followerCount,
      'followingCount': followingCount,
      'isPrivate': isPrivate,
      'lastSeen': lastSeen,
      'isOnline': isOnline,
    };
  }
}
