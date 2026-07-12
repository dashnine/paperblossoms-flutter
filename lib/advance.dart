import 'rules_constants.dart';

/// One purchased advance. Semantically identical to the original app's
/// pipe-delimited "Type|Name|Track|Cost" rows: [type] is Skill/Ring/Technique,
/// and [track] is Curriculum, Title, or a free-advance reason string.
class Advance {
  String type;
  String name;
  String track;
  int cost;

  Advance({
    required this.type,
    required this.name,
    required this.track,
    required this.cost,
  });

  bool get isSkill => type == advanceTypeSkill;
  bool get isRing => type == advanceTypeRing;
  bool get isTechnique => type == advanceTypeTechnique;
  bool get onCurriculumTrack => track == trackCurriculum;
  bool get onTitleTrack => track == trackTitle;
  bool get isFree => !onCurriculumTrack && !onTitleTrack;

  Advance.fromJson(Map<String, dynamic> json)
      : type = json['type'] ?? advanceTypeSkill,
        name = json['name'] ?? '',
        track = json['track'] ?? trackCurriculum,
        cost = json['cost'] ?? 0;

  Map<String, dynamic> toJson() => {
        'type': type,
        'name': name,
        'track': track,
        'cost': cost,
      };
}
