// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Paper Blossoms';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get importCharacterTooltip => 'Importar personaje';

  @override
  String get newCharacter => 'Nuevo personaje';

  @override
  String get noCharactersYet =>
      'Aún no hay personajes.\nCrea uno para empezar tu historia.';

  @override
  String deleteCharacterTitle(String name) {
    return '¿Eliminar a $name?';
  }

  @override
  String get deleteCannotBeUndone => 'Esta acción no se puede deshacer.';

  @override
  String rankN(int rank) {
    return 'Rango $rank';
  }

  @override
  String get toolsTitle => 'Herramientas';

  @override
  String get languageSection => 'Idioma';

  @override
  String get appearanceSection => 'Apariencia';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get rulesTextSection => 'Textos de reglas';

  @override
  String get editRulesDescriptions => 'Editar descripciones de reglas';

  @override
  String get editRulesDescriptionsSubtitle =>
      'Los datos incluidos no contienen textos de reglas. Si posees los libros, puedes introducir aquí tus propias descripciones; aparecerán en el editor y en la hoja PDF.';

  @override
  String get importDescriptions => 'Importar descripciones…';

  @override
  String get importDescriptionsSubtitle =>
      'Combina descripciones de un archivo JSON exportado o del user_descriptions.csv del Paper Blossoms original; las entradas importadas sobrescriben las del mismo nombre.';

  @override
  String get exportDescriptions => 'Exportar descripciones…';

  @override
  String get exportDescriptionsSubtitle =>
      'Guarda todas las descripciones en un archivo JSON como copia de seguridad o para compartirlas.';

  @override
  String get homebrewSection => 'Contenido propio';

  @override
  String get homebrewFolder => 'Carpeta de contenido propio';

  @override
  String homebrewFolderSubtitle(String path) {
    return '$path\n\nColoca archivos JSON con los mismos nombres que los datos incluidos (weapons.json, titles.json, techniques.json, …) y la misma estructura; las entradas se combinan tras el contenido oficial al iniciar.';
  }

  @override
  String get reloadHomebrew => 'Recargar contenido propio ahora';

  @override
  String get nothingMergedThisSession => 'Nada combinado en esta sesión.';

  @override
  String mergedFiles(String files) {
    return 'Combinado: $files';
  }

  @override
  String get noHomebrewFilesFound =>
      'No se encontraron archivos de contenido propio.';

  @override
  String importedDescriptions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count descripciones importadas.',
      one: '1 descripción importada.',
    );
    return '$_temp0';
  }

  @override
  String exportedDescriptions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count descripciones exportadas.',
      one: '1 descripción exportada.',
    );
    return '$_temp0';
  }

  @override
  String get couldNotReadDescriptionsFile =>
      'No se pudo leer ese archivo como JSON o CSV de descripciones.';

  @override
  String get noDescriptionsToExport => 'No hay descripciones que exportar.';

  @override
  String get tabCharacter => 'Personaje';

  @override
  String get tabBackground => 'Trasfondo';

  @override
  String get tabTraits => 'Rasgos';

  @override
  String get tabBonds => 'Vínculos';

  @override
  String get tabTechniques => 'Técnicas';

  @override
  String get tabEquipment => 'Equipo';

  @override
  String get tabAdvancement => 'Progreso';

  @override
  String get unnamedSamurai => 'Samurái sin nombre';

  @override
  String get saved => 'Guardado';

  @override
  String get save => 'Guardar';

  @override
  String get saveUnsavedTooltip => 'Guardar (cambios sin guardar)';

  @override
  String get exportTooltip => 'Exportar';

  @override
  String get printExportPdf => 'Imprimir / exportar hoja PDF…';

  @override
  String get shareCharacterJson => 'Compartir JSON del personaje…';

  @override
  String get fullSkillTableOnSheet =>
      'Tabla completa de habilidades en la hoja';

  @override
  String get portraitOnSheet => 'Retrato en la hoja';

  @override
  String get unsavedChanges => 'Cambios sin guardar';

  @override
  String get saveBeforeClosing => '¿Guardar este personaje antes de cerrar?';

  @override
  String get keepEditing => 'Seguir editando';

  @override
  String get discard => 'Descartar';

  @override
  String get saveAndClose => 'Guardar y cerrar';

  @override
  String get characterExported => 'Personaje exportado.';

  @override
  String get nameLabel => 'Nombre';

  @override
  String get familyLabel => 'Familia';

  @override
  String get noClan => 'Sin clan';

  @override
  String get noSchool => 'Sin escuela';

  @override
  String get socialStandingSection => 'Posición social';

  @override
  String get honor => 'Honor';

  @override
  String get glory => 'Gloria';

  @override
  String get statusLabel => 'Estatus';

  @override
  String get wealthSection => 'Riqueza';

  @override
  String get koku => 'Koku';

  @override
  String get bu => 'Bu';

  @override
  String get zeni => 'Zeni';

  @override
  String get abilitiesSection => 'Aptitudes';

  @override
  String get noAbilitiesYet => 'Aún no hay aptitudes.';

  @override
  String get ringsSection => 'Anillos';

  @override
  String get derivedAttributesSection => 'Atributos derivados';

  @override
  String get endurance => 'Aguante';

  @override
  String get composure => 'Compostura';

  @override
  String get focusStat => 'Concentración';

  @override
  String get vigilance => 'Vigilancia';

  @override
  String get schoolRank => 'Rango de escuela';

  @override
  String get fatigueStrifeSection => 'Fatiga y conflicto';

  @override
  String fatigueOf(int max) {
    return 'Fatiga / $max';
  }

  @override
  String strifeOf(int max) {
    return 'Conflicto / $max';
  }

  @override
  String get clearAllFatigue => 'Eliminar toda la fatiga';

  @override
  String get recover => 'Recuperarse';

  @override
  String get clearAllStrife => 'Eliminar todo el conflicto';

  @override
  String get unmask => 'Desenmascararse';

  @override
  String get conditionsSection => 'Estados';

  @override
  String get addCondition => 'Añadir estado';

  @override
  String get noConditions => 'Sin estados.';

  @override
  String get incapacitatedRule =>
      'La fatiga supera el aguante: no puede realizar acciones que requieran pruebas ni defenderse del daño.';

  @override
  String get compromisedRule =>
      'El conflicto supera la compostura: no puede quedarse dados que muestren conflicto; la vigilancia cuenta como 1.';

  @override
  String get criticalStrike => 'Golpe crítico…';

  @override
  String get skillsSection => 'Habilidades';

  @override
  String get heritageSection => 'Herencia';

  @override
  String get ninjoSection => 'Ninjō (deseo personal)';

  @override
  String get giriSection => 'Giri (deber)';

  @override
  String get notesSection => 'Notas';

  @override
  String get add => 'Añadir';

  @override
  String get remove => 'Quitar';

  @override
  String get undo => 'Deshacer';

  @override
  String removedName(String name) {
    return 'Eliminado: $name';
  }

  @override
  String get unknownCustomSection => 'Desconocido (datos propios o ausentes)';

  @override
  String get bondsSection => 'Vínculos';

  @override
  String get addBond => 'Añadir vínculo';

  @override
  String get noBondsYet =>
      'Aún no se ha formado ningún vínculo — toca + para añadir uno.';

  @override
  String get rankLabel => 'Rango';

  @override
  String get techniquesSection => 'Técnicas';

  @override
  String get noTechniquesYet => 'Aún no se conoce ninguna técnica.';

  @override
  String restrictionLabel(String restriction) {
    return 'Restricción: $restriction';
  }

  @override
  String get customOrUnknownTechnique => 'Técnica propia o desconocida';

  @override
  String get weaponsSection => 'Armas';

  @override
  String get armorSection => 'Armadura';

  @override
  String get personalEffectsSection => 'Efectos personales';

  @override
  String get addItem => 'Añadir objeto';

  @override
  String get noWeaponsYet => 'Aún no hay armas — toca + para añadir una.';

  @override
  String get noArmorYet => 'Aún no hay armadura — toca + para añadir una.';

  @override
  String get noPersonalEffectsYet =>
      'Aún no hay efectos personales — toca + para añadir uno.';

  @override
  String gripStats(
    String grip,
    int min,
    int max,
    String damage,
    String deadliness,
  ) {
    return '$grip: Alcance $min-$max · Daño $damage · Let. $deadliness';
  }

  @override
  String armorStats(int physical, int supernatural) {
    return 'Física $physical · Sobrenatural $supernatural';
  }

  @override
  String priceLine(int price, String unit, int rarity) {
    return '$price $unit · Rareza $rarity';
  }

  @override
  String get colName => 'Nombre';

  @override
  String get colCategory => 'Categoría';

  @override
  String get colSkill => 'Habilidad';

  @override
  String get colGrip => 'Empuñadura';

  @override
  String get colRange => 'Alcance';

  @override
  String get colDamage => 'Daño';

  @override
  String get colDeadliness => 'Let.';

  @override
  String get colQualities => 'Cualidades';

  @override
  String get colPhysical => 'Física';

  @override
  String get colSupernatural => 'Sobrenatural';

  @override
  String addedAdvanceRankUp(String name, int rank) {
    return '$name añadido — ¡el rango de escuela ahora es $rank!';
  }

  @override
  String addedAdvance(String name, int cost, String track) {
    return '$name añadido — $cost PX ($track)';
  }

  @override
  String get xpInRank => 'PX en el rango';

  @override
  String get xpSpentLabel => 'PX gastados';

  @override
  String get noTitleInProgress => 'Ningún título en curso';

  @override
  String currentTitleLine(String title, int xp, int total) {
    return 'Título actual: $title — $xp / $total PX';
  }

  @override
  String curriculumSection(String school) {
    return 'Plan de estudios — $school';
  }

  @override
  String get noSchoolFallback => 'sin escuela';

  @override
  String get addAdvance => 'Añadir mejora';

  @override
  String get noSchoolNoCurriculum =>
      'No se ha elegido escuela, así que no hay plan de estudios.';

  @override
  String get currentLabel => 'actual';

  @override
  String skillRankLabel(int rank) {
    return 'rango $rank';
  }

  @override
  String get specialAccess => 'acceso especial';

  @override
  String ranksRange(int min, int max) {
    return 'rangos $min-$max';
  }

  @override
  String get atRank5 => 'En el rango 5';

  @override
  String get alreadyLearnedLabel => 'Ya aprendida';

  @override
  String get buyThisAdvance => 'Comprar esta mejora';

  @override
  String get titlesSection => 'Títulos';

  @override
  String get addTitle => 'Añadir título';

  @override
  String get finishCurrentTitleFirst => 'Termina primero el título actual';

  @override
  String get noTitlesYet => 'Aún no hay títulos — toca + para añadir uno.';

  @override
  String get inProgressLabel => 'En curso';

  @override
  String completedWithAbility(String ability) {
    return 'Completado — $ability';
  }

  @override
  String maxRankLabel(int rank) {
    return 'rango máximo $rank';
  }

  @override
  String get advancesTakenSection => 'Mejoras adquiridas';

  @override
  String get noAdvancesYet =>
      'Aún no se han comprado mejoras — toca + o una entrada del plan de estudios.';

  @override
  String advanceSubtitle(String type, String track, int cost) {
    return '$type · $track · $cost PX';
  }

  @override
  String get addAdvanceTitle => 'Añadir mejora';

  @override
  String get advTypeSkill => 'Habilidad';

  @override
  String get advTypeRing => 'Anillo';

  @override
  String get advTypeTechnique => 'Técnica';

  @override
  String get advanceSection => 'Mejora';

  @override
  String get groupLabel => 'Grupo';

  @override
  String get allGroups => 'Todos los grupos';

  @override
  String get mahoWarning =>
      'El mahō está prohibido. Aprenderlo tiene consecuencias.';

  @override
  String get typeToFilter => 'Escribe para filtrar';

  @override
  String get clearFilter => 'Borrar filtro';

  @override
  String techSubtitle(String subcategory, int rank, int xp) {
    return '$subcategory · Rango $rank · $xp PX';
  }

  @override
  String get ignoreRestrictions =>
      'Ignorar restricciones (rango, acceso de escuela)';

  @override
  String get trackSection => 'Vía';

  @override
  String get trackCurriculumLabel => 'Plan de estudios';

  @override
  String get trackTitleLabel => 'Título';

  @override
  String get trackFreeLabel => 'Gratis (sin coste de PX)';

  @override
  String get reasonOptional => 'Motivo (opcional)';

  @override
  String get halfXpLabel => 'Mitad de PX (descuento de escuela/título)';

  @override
  String get chooseAnAdvance => 'Elige una mejora.';

  @override
  String alreadyLearnedError(String name) {
    return '«$name» ya está aprendida.';
  }

  @override
  String costXp(int cost) {
    return 'Coste: $cost PX';
  }

  @override
  String get addItemTitle => 'Añadir objeto';

  @override
  String get itemWeapon => 'Arma';

  @override
  String get itemArmor => 'Armadura';

  @override
  String get itemPersonalEffect => 'Efecto personal';

  @override
  String get chooseWeapon => 'Elegir arma';

  @override
  String get chooseArmor => 'Elegir armadura';

  @override
  String get choosePersonalEffect => 'Elegir efecto personal';

  @override
  String weaponPickSubtitle(
    String category,
    String skill,
    String damage,
    String deadliness,
  ) {
    return '$category · $skill · Daño $damage · Let. $deadliness';
  }

  @override
  String get chooseFromBook => 'Elegir del libro…';

  @override
  String get changeBaseItem => 'Cambiar objeto base…';

  @override
  String get customItem => 'Objeto personalizado';

  @override
  String get detailsSection => 'Detalles';

  @override
  String get priceLabel => 'Precio';

  @override
  String get rarityLabel => 'Rareza';

  @override
  String get qualitiesCommaSeparated => 'Cualidades (separadas por comas)';

  @override
  String addNGrips(int count) {
    return 'Añadir ($count empuñaduras)';
  }

  @override
  String gripEditorLabel(String grip) {
    return 'Empuñadura: $grip';
  }

  @override
  String get minRange => 'Alcance mín.';

  @override
  String get maxRange => 'Alcance máx.';

  @override
  String get damageLabel => 'Daño';

  @override
  String get deadlinessLabel => 'Letalidad';

  @override
  String get addTrait => 'Añadir rasgo';

  @override
  String addCategoryLower(String category) {
    return 'Añadir $category';
  }

  @override
  String get addBondTitle => 'Añadir vínculo';

  @override
  String get addTitleTitle => 'Añadir título';

  @override
  String xpAmount(int xp) {
    return '$xp PX';
  }

  @override
  String get criticalStrikeTitle => 'Golpe crítico';

  @override
  String get severityLabel => 'Gravedad (letalidad de la fuente)';

  @override
  String get razorEdgedLabel => 'El ataque era con arma afilada';

  @override
  String get ringUsedToResist => 'Anillo usado para resistir';

  @override
  String get ringResistHelper =>
      'El anillo de la postura en un conflicto, cualquiera en una escena narrativa';

  @override
  String get tnFitnessCheck => 'Prueba de Aptitud física NO 1 superada';

  @override
  String get rollOwnDice => 'Tira tus propios dados e introduce el resultado';

  @override
  String get bonusSuccessesLabel =>
      'Éxitos adicionales (−1 de gravedad cada uno, además del −1)';

  @override
  String finalSeverityLine(int severity, String band) {
    return 'Gravedad final $severity — $band';
  }

  @override
  String get apply => 'Aplicar';

  @override
  String chooseScarTitle(String band, String ring) {
    return '$band: elige una cicatriz ($ring)';
  }

  @override
  String severityResult(int severity, String band, String effect) {
    return 'Gravedad $severity: $band — $effect';
  }

  @override
  String get rulesDescriptionsTitle => 'Descripciones de reglas';

  @override
  String get shortDescriptionLabel => 'Descripción breve';

  @override
  String get fullDescriptionLabel => 'Descripción completa';

  @override
  String get searchHint => 'Buscar…';

  @override
  String get withText => 'Con texto';

  @override
  String get wizPart1 => 'Parte 1: Clan y familia';

  @override
  String get wizPart2 => 'Parte 2: Rol y escuela';

  @override
  String get wizPart3 => 'Parte 3: Honor y gloria';

  @override
  String get wizPart4 => 'Parte 4: Fortalezas y debilidades';

  @override
  String get wizPart5 => 'Parte 5: Personalidad y comportamiento';

  @override
  String get wizPart6 => 'Parte 6: Linaje y familia';

  @override
  String get wizPart7 => 'Parte 7: Muerte';

  @override
  String get wizErrChooseClan => 'Elige un clan (pregunta 1).';

  @override
  String get wizErrChooseFamily => 'Elige una familia (pregunta 2).';

  @override
  String get wizErrChooseFamilyRing =>
      'Elige el aumento de anillo de tu familia.';

  @override
  String get wizErrChooseRegion => 'Elige una región (pregunta 1).';

  @override
  String get wizErrChooseUpbringing => 'Elige una crianza (pregunta 2).';

  @override
  String get wizErrChooseUpbringingRing =>
      'Elige el aumento de anillo de tu crianza.';

  @override
  String wizErrChooseUpbringingSkill(int n) {
    return 'Elige la habilidad de crianza $n.';
  }

  @override
  String get wizErrChooseSchool => 'Elige una escuela.';

  @override
  String get wizErrInsufficientSkills =>
      'No se han seleccionado suficientes habilidades.';

  @override
  String get wizErrSchoolRings => 'Elige los aumentos de anillo de tu escuela.';

  @override
  String get wizErrStandoutRing => 'Elige tu anillo destacado.';

  @override
  String get wizErrStartingTechniques => 'Elige tus técnicas iniciales.';

  @override
  String get wizErrQ7Option => 'Elige una opción para la pregunta 7.';

  @override
  String get wizErrQ7Skill => 'Elige una habilidad para la pregunta 7.';

  @override
  String get wizErrQ8Option => 'Elige una opción para la pregunta 8.';

  @override
  String get wizErrQ8Skill => 'Elige una habilidad para la pregunta 8.';

  @override
  String get wizErrQ8Item => 'Elige un objeto para la pregunta 8.';

  @override
  String get wizErrDistinction => 'Elige una distinción (pregunta 9).';

  @override
  String get wizErrAdversity => 'Elige una adversidad (pregunta 10).';

  @override
  String get wizErrPassion => 'Elige una pasión (pregunta 11).';

  @override
  String get wizErrAnxiety => 'Elige una ansiedad (pregunta 12).';

  @override
  String get wizErrQ13Option => 'Elige una opción para la pregunta 13.';

  @override
  String get wizErrQ13Advantage => 'Elige una ventaja para la pregunta 13.';

  @override
  String get wizErrQ13DisadvSkill =>
      'Elige una desventaja y una habilidad para la pregunta 13.';

  @override
  String get wizErrQ16Item =>
      'Elige un objeto de recuerdo para la pregunta 16.';

  @override
  String get wizErrReplacementRings => 'Selecciona anillo(s) de reemplazo.';

  @override
  String get wizErrReplacementSkills =>
      'Selecciona habilidad(es) de reemplazo.';

  @override
  String get wizDiscardTitle => '¿Descartar este personaje?';

  @override
  String get wizDiscardBody => 'Se perderán tus respuestas hasta ahora.';

  @override
  String get wizSummaryTooltip => 'Anillos y habilidades hasta ahora';

  @override
  String get wizNoSkillsYet => 'Aún no hay habilidades.';

  @override
  String wizStepOf(int page, int total) {
    return 'Paso $page de $total';
  }

  @override
  String get back => 'Atrás';

  @override
  String get next => 'Siguiente';

  @override
  String get finish => 'Terminar';

  @override
  String get characterTypeLabel => 'Tipo de personaje';

  @override
  String get wizQ1Clan => '1. ¿A qué clan pertenece tu personaje?';

  @override
  String get clanLabel => 'Clan';

  @override
  String clanStatsLine(
    String ring,
    String skill,
    int status,
    String reference,
  ) {
    return '+1 $ring · +1 $skill · Estatus $status · $reference';
  }

  @override
  String get wizQ2Family => '2. ¿A qué familia pertenece tu personaje?';

  @override
  String familyStatsLine(String skills, int glory, int wealth) {
    return '+1 $skills · Gloria $glory · Riqueza $wealth koku';
  }

  @override
  String get familyRingIncrease => 'Aumento de anillo de la familia';

  @override
  String get wizQ1Region => '1. ¿De dónde procede tu personaje?';

  @override
  String get regionLabel => 'Región';

  @override
  String get wizQ2Upbringing => '2. ¿Cómo se crio tu personaje?';

  @override
  String get upbringingLabel => 'Crianza';

  @override
  String get upbringingRingIncrease => 'Aumento de anillo de la crianza';

  @override
  String upbringingSkillN(int n) {
    return 'Habilidad de crianza $n';
  }

  @override
  String get wizQ3Samurai =>
      '3. ¿Cuál es la escuela de tu personaje y a qué roles corresponde?';

  @override
  String get wizQ3Ronin =>
      '3. ¿Cuál es la escuela de tu personaje y cuáles son sus roles asociados?';

  @override
  String get showSchoolsOutsideClan => 'Mostrar escuelas de fuera de mi clan';

  @override
  String get schoolLabel => 'Escuela';

  @override
  String schoolStatsLine(String roles, int honor, String reference) {
    return '$roles · Honor $honor · $reference';
  }

  @override
  String get kitsuneImpersonate => 'Escuela que imitar (origen del equipo)';

  @override
  String get additionalBurden => 'Carga adicional';

  @override
  String chooseSchoolSkills(int size, int chosen) {
    return 'Elige $size habilidades de escuela ($chosen elegidas)';
  }

  @override
  String get schoolRingIncreases => 'Aumentos de anillo de la escuela';

  @override
  String fixedRings(String rings) {
    return 'Fijos: +1 $rings';
  }

  @override
  String get ringOfYourChoice => 'Anillo a tu elección';

  @override
  String get wizQ4Samurai =>
      '4. ¿Cómo destacas dentro de tu escuela? (+1 anillo)';

  @override
  String get wizQ4Ronin =>
      '4. ¿Qué te mete en problemas y qué te saca de ellos? (+1 anillo)';

  @override
  String get standoutRing => 'Anillo destacado';

  @override
  String get describeIt => 'Descríbelo';

  @override
  String startingTechniqueFixed(String name) {
    return 'Técnica inicial: $name';
  }

  @override
  String get chooseStartingTechnique => 'Elige una técnica inicial';

  @override
  String get startingOutfit => 'Equipo inicial';

  @override
  String get chooseAnItem => 'Elige un objeto';

  @override
  String includedItems(String items) {
    return 'Incluye: $items';
  }

  @override
  String get wizQ5Samurai =>
      '5. ¿Quién es tu señor y cuál es tu deber para con él? (Giri)';

  @override
  String get wizQ5Ronin => '5. ¿Cuál es tu pasado y cómo te afecta?';

  @override
  String get answerLabel => 'Respuesta';

  @override
  String get wizQ6Samurai =>
      '6. ¿Qué anhelas y cómo podría esto entorpecer tu deber? (Ninjō)';

  @override
  String get wizQ6Ronin =>
      '6. ¿Qué anhelas y cómo podría tu pasado afectar a tu ninjō?';

  @override
  String get wizQ7Samurai => '7. ¿Cuál es tu relación con tu clan?';

  @override
  String get wizQ7Ronin => '7. ¿Por qué eres conocido?';

  @override
  String get q7Positive => 'Positiva (+5 de gloria)';

  @override
  String get q7Negative => 'Negativa (+1 rango en una habilidad que no tengas)';

  @override
  String get wizQ8 => '8. ¿Qué opinas del bushidō?';

  @override
  String get q8Pos => 'Fe ortodoxa firme (+10 de honor)';

  @override
  String get q8Mid =>
      'Superviviente pragmático (un objeto de rareza 5 o inferior)';

  @override
  String get q8Neg =>
      'Se aparta de las creencias comunes (+1 rango de habilidad)';

  @override
  String get itemLabel => 'Objeto';

  @override
  String get wizQ9 => '9. ¿Cuál es tu mayor logro hasta la fecha? (Distinción)';

  @override
  String get distinctionLabel => 'Distinción';

  @override
  String get wizQ10 => '10. ¿Qué frena a tu personaje? (Adversidad)';

  @override
  String get adversityLabel => 'Adversidad';

  @override
  String get wizQ11 => '11. ¿Qué actividad te hace sentir en paz? (Pasión)';

  @override
  String get passionLabel => 'Pasión';

  @override
  String get wizQ12 =>
      '12. ¿Qué preocupación o miedo te quita el sueño? (Ansiedad)';

  @override
  String get anxietyLabel => 'Ansiedad';

  @override
  String get wizQ13 =>
      '13. ¿En quién confías más y cuál es la naturaleza de esa relación?';

  @override
  String get q13GainAdvantage => 'Obtener una ventaja';

  @override
  String get q13GainDisadvantage =>
      'Obtener una desventaja y +1 rango de habilidad';

  @override
  String get advantageLabel => 'Ventaja';

  @override
  String get disadvantageLabel => 'Desventaja';

  @override
  String get describeRelationship => 'Describe la relación';

  @override
  String get wizQ14Samurai =>
      '14. ¿Qué es lo primero que la gente nota al encontrarse contigo?';

  @override
  String get wizQ14Ronin =>
      '14. ¿Cuál es la posesión más preciada de tu personaje?';

  @override
  String get possessionRarity5 => 'Posesión (rareza 5 o inferior)';

  @override
  String get wizQ15 => '15. ¿Cómo reaccionas ante situaciones de estrés?';

  @override
  String get wizQ16Samurai =>
      '16. ¿Qué relaciones previas tienes con otros clanes, familias, organizaciones y tradiciones?';

  @override
  String get wizQ16Ronin =>
      '16. ¿Qué relación tienes con tu familia, los clanes, los campesinos y los demás?';

  @override
  String get mementoRarity7 => 'Objeto de recuerdo (rareza 7 o inferior)';

  @override
  String get describeThem => 'Descríbelas';

  @override
  String get wizQ17Parents =>
      '17. ¿Cómo te describirían tus padres? (+1 rango de habilidad)';

  @override
  String get wizQ17Raised => '18. ¿Quién te crio? (+1 rango de habilidad)';

  @override
  String get wizQ17Bond => '17. ¿Con quién compartes un vínculo?';

  @override
  String get bondLabel => 'Vínculo';

  @override
  String get wizQ18Ancestry =>
      '18. ¿Cuál es tu deber hacia tu familia y a cuál de tus antepasados emulas?';

  @override
  String get heritageTable => 'Tabla de herencia';

  @override
  String ancestorN(int n) {
    return 'Antepasado $n';
  }

  @override
  String get rollTooltip => 'Tirar (1d10)';

  @override
  String heritageHeader(String name) {
    return 'Herencia: $name';
  }

  @override
  String grantedLabel(String name) {
    return 'Otorgado: $name';
  }

  @override
  String get bonusSkill => 'Habilidad adicional';

  @override
  String get traitGained => 'Rasgo obtenido';

  @override
  String get heirloomCategory => 'Categoría de la reliquia';

  @override
  String get lostHeirloomCategory => 'Categoría de la reliquia perdida';

  @override
  String get techniqueGroupLabel => 'Grupo de técnicas';

  @override
  String get effectLabel => 'Efecto';

  @override
  String get giftLabel => 'Regalo';

  @override
  String get ringToRaise => 'Anillo que aumentar';

  @override
  String get ringToLower => 'Anillo que reducir';

  @override
  String get qualityYourChoice => 'Cualidad (a tu elección)';

  @override
  String get qualityGmChoice => 'Cualidad (a elección del DJ)';

  @override
  String get wizQ19 => '19. ¿Cómo te llamas?';

  @override
  String get personalNameLabel => 'Nombre personal';

  @override
  String get wizQ20 => '20. ¿Cómo debería morir tu personaje?';

  @override
  String get answerOptional => 'Respuesta (opcional)';

  @override
  String ringOverflowMsg(int n) {
    return 'Un anillo supera el límite de creación de 3. Elige $n anillo(s) de reemplazo:';
  }

  @override
  String skillOverflowMsg(int n) {
    return 'Una habilidad supera el límite de creación de 3. Elige $n habilidad(es) de reemplazo:';
  }

  @override
  String replacementRingN(int n) {
    return 'Anillo de reemplazo $n';
  }

  @override
  String replacementSkillN(int n) {
    return 'Habilidad de reemplazo $n';
  }

  @override
  String get readyHeader => 'Listo';

  @override
  String get finishCreates => '«Terminar» crea el personaje y abre el editor.';

  @override
  String get ok => 'Aceptar';

  @override
  String get tapToTypeValue => 'Toca para escribir un valor';

  @override
  String get unlockIdentityTooltip =>
      'Desbloquear nombre, familia, ninjō y giri';

  @override
  String get lockIdentityTooltip => 'Bloquear nombre, familia, ninjō y giri';

  @override
  String get changePortraitTooltip =>
      'Toca para cambiar el retrato, mantén pulsado para quitarlo';

  @override
  String get addPortraitTooltip => 'Toca para añadir un retrato';

  @override
  String get pdfFatigueStrifeConditions => 'Fatiga, conflicto y estados';

  @override
  String get pdfWealthProgress => 'Riqueza y progreso';

  @override
  String pdfWealthLine(
    int koku,
    int bu,
    int zeni,
    int spent,
    int total,
    int inRank,
  ) {
    return 'Riqueza: $koku koku, $bu bu, $zeni zeni    ·    PX: $spent gastados / $total en total    ·    PX en el rango: $inRank';
  }

  @override
  String pdfTitlePart(String title, int xp) {
    return '    ·    Título: $title ($xp PX)';
  }

  @override
  String get pdfTraitsHeader => 'Distinciones y adversidades';

  @override
  String get colAbility => 'Aptitud';

  @override
  String get ninjoHeader => 'Ninjō';

  @override
  String get giriHeader => 'Giri';
}
