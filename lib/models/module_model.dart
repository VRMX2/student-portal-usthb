class Module {
  final String id;
  final String name;
  final String code; // e.g. INF 101
  final double coefficient;
  final double? gradeTD; // /20
  final double? gradeTP; // /20
  final double? gradeExam; // /20
  final double? gradeEMD; // Sometimes used
  
  // Weights (percentages, e.g. 0.6 for exam)
  // Usually fixed by university rules, but can be flexible
  final double weightExam;
  final double weightTD;
  final double weightTP;

  Module({
    required this.id,
    required this.name,
    required this.code,
    required this.coefficient,
    this.gradeTD,
    this.gradeTP,
    this.gradeExam,
    this.gradeEMD,
    this.weightExam = 0.6,
    this.weightTD = 0.2, // Default assumption
    this.weightTP = 0.2,
  });

  double get average {
    // Simple calculation logic, might need adjustment per module type
    double total = 0;
    double weights = 0;

    if (gradeExam != null) {
      total += gradeExam! * weightExam;
      weights += weightExam;
    }
    if (gradeTD != null) {
      total += gradeTD! * weightTD;
      weights += weightTD;
    }
    if (gradeTP != null) {
      total += gradeTP! * weightTP;
      weights += weightTP;
    }

    if (weights == 0) return 0.0;
    
    // Normalize to 20 if weights don't sum to 1.0 (though they should)
    return total; // Assuming weights sum to 1.0
  }

  factory Module.fromMap(Map<String, dynamic> data, String id) {
    return Module(
      id: id,
      name: data['name'] ?? '',
      code: data['code'] ?? '',
      coefficient: (data['coefficient'] ?? 1.0).toDouble(),
      gradeTD: data['gradeTD']?.toDouble(),
      gradeTP: data['gradeTP']?.toDouble(),
      gradeExam: data['gradeExam']?.toDouble(),
      gradeEMD: data['gradeEMD']?.toDouble(),
      weightExam: (data['weightExam'] ?? 0.6).toDouble(),
      weightTD: (data['weightTD'] ?? 0.2).toDouble(),
      weightTP: (data['weightTP'] ?? 0.2).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'code': code,
      'coefficient': coefficient,
      'gradeTD': gradeTD,
      'gradeTP': gradeTP,
      'gradeExam': gradeExam,
      'gradeEMD': gradeEMD,
      'weightExam': weightExam,
      'weightTD': weightTD,
      'weightTP': weightTP,
    };
  }
  
  Module copyWith({
    String? name,
    String? code,
    double? coefficient,
    double? gradeTD,
    double? gradeTP,
    double? gradeExam,
  }) {
    return Module(
      id: id,
      name: name ?? this.name,
      code: code ?? this.code,
      coefficient: coefficient ?? this.coefficient,
      gradeTD: gradeTD ?? this.gradeTD,
      gradeTP: gradeTP ?? this.gradeTP,
      gradeExam: gradeExam ?? this.gradeExam,
      weightExam: weightExam,
      weightTD: weightTD,
      weightTP: weightTP,
    );
  }
}
