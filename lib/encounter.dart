/// A saved encounter: a named roster of NPCs by name with counts. NPCs are
/// resolved by name at display time so later edits to a custom NPC flow
/// through; unresolvable names render as "missing" and are excluded from
/// rank math, never a crash.
class EncounterEntry {
  String npc;
  int count;

  EncounterEntry({this.npc = '', this.count = 1});

  EncounterEntry.fromJson(Map<String, dynamic> json)
      : npc = json['npc']?.toString() ?? '',
        count = json['count'] ?? 1;

  Map<String, dynamic> toJson() => {'npc': npc, 'count': count};
}

class Encounter {
  String name;
  List<EncounterEntry> entries;
  String notes;

  Encounter({this.name = '', List<EncounterEntry>? entries, this.notes = ''})
      : entries = entries ?? [];

  Encounter.fromJson(Map<String, dynamic> json)
      : name = json['name']?.toString() ?? '',
        entries = [
          for (final e in json['entries'] ?? []) EncounterEntry.fromJson(e)
        ],
        notes = json['notes']?.toString() ?? '';

  Map<String, dynamic> toJson() => {
        'name': name,
        'entries': [for (final e in entries) e.toJson()],
        if (notes.isNotEmpty) 'notes': notes,
      };

  Encounter clone() => Encounter.fromJson(toJson());
}
