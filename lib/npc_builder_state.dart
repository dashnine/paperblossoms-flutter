import 'npc_math.dart';
import 'npc_models.dart';

/// Per-template choices in the quick builder: the demeanor pick, technique
/// picks (seeded with the template's defaults), and which of the suggested
/// advantages/disadvantages to take (none by default — the book says
/// "add/replace 0–2").
class TemplateChoices {
  String demeanor;
  List<String> techniques;
  Set<String> advantages;
  Set<String> disadvantages;

  TemplateChoices({
    this.demeanor = '',
    List<String>? techniques,
    Set<String>? advantages,
    Set<String>? disadvantages,
  })  : techniques = techniques ?? [],
        advantages = advantages ?? {},
        disadvantages = disadvantages ?? {};

  TemplateChoices.defaultsFor(NpcTemplate template)
      : demeanor = template.defaultDemeanor,
        techniques = List.of(template.defaultTechniques),
        advantages = {},
        disadvantages = {};
}

/// All answers of the quick-build flow, UI-free and unit-testable: a base
/// profile, stacked templates with per-template choices, and name/type
/// overrides. [result] recomputes the finished NPC from scratch on demand,
/// so toggling a template off cleanly restores the base.
class NpcBuilderState {
  Npc? base;

  /// Selected templates in application order, each with its choices.
  final Map<String, TemplateChoices> selected = {};

  /// User-typed name; empty means "use [autoName]".
  String name = '';

  /// Type override ('minion' | 'adversary'); empty keeps the base's type.
  /// The book itself promotes minions this way (Goblin Chieftain, p. 311).
  String typeOverride = '';

  /// Hand-picked techniques outside any template ("just give him a kata").
  final List<String> extraTechniques = [];

  /// Technique names removed from the working NPC — covers techniques the
  /// base profile itself carries (an edited custom NPC used as base).
  final Set<String> removedTechniques = {};

  /// Removes [name] from every source at once — extra picks, all templates'
  /// choices, and (via [removedTechniques]) the base profile — so one tap
  /// always makes the chip disappear, however many sources carried it.
  void removeTechnique(String name) {
    extraTechniques.remove(name);
    for (final choices in selected.values) {
      choices.techniques.remove(name);
    }
    removedTechniques.add(name);
  }

  bool get hasBase => base != null;

  /// Swaps the base profile. Removals refer to the old base's techniques,
  /// so they are cleared; template selections and extra picks carry over.
  void setBase(Npc? npc) {
    base = npc;
    removedTechniques.clear();
  }

  void toggleTemplate(NpcTemplate template) {
    if (selected.containsKey(template.name)) {
      selected.remove(template.name);
    } else {
      selected[template.name] = TemplateChoices.defaultsFor(template);
      // A fresh selection means fresh defaults: resurrect any of them the
      // user had removed earlier, or the card would show chips that never
      // reach the result.
      removedTechniques.removeAll(template.defaultTechniques);
    }
  }

  bool isSelected(String templateName) => selected.containsKey(templateName);

  /// "Warrior Loyal Bushi" — suggested name until the user types their own.
  String autoName() {
    if (base == null) return '';
    return [...selected.keys, base!.name].join(' ');
  }

  String effectiveName() => name.trim().isEmpty ? autoName() : name.trim();

  /// The finished NPC, recomputed from the base through every selected
  /// template. Null until a base is chosen.
  Npc? result(List<NpcTemplate> templates) {
    final b = base;
    if (b == null) return null;
    var npc = b.clone()..custom = true;
    for (final e in selected.entries) {
      final template = templates.where((t) => t.name == e.key).firstOrNull;
      if (template == null) continue;
      npc = applyTemplate(
        npc,
        template,
        demeanor: e.value.demeanor,
        techniques: e.value.techniques,
        advantages: [
          for (final a in template.suggestedAdvantages)
            if (e.value.advantages.contains(a.name)) a
        ],
        disadvantages: [
          for (final d in template.suggestedDisadvantages)
            if (e.value.disadvantages.contains(d.name)) d
        ],
      );
    }
    npc.name = effectiveName();
    if (typeOverride.isNotEmpty) npc.type = typeOverride;
    for (final t in extraTechniques) {
      if (!npc.techniques.contains(t)) npc.techniques.add(t);
    }
    npc.techniques.removeWhere(removedTechniques.contains);
    npc.blurb = '';
    return npc;
  }
}
