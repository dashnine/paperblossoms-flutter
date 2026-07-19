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
  String get horSection => 'Heroes of Rokugan';

  @override
  String get horModeTitle => 'Modo Heroes of Rokugan';

  @override
  String get horModeSubtitle =>
      'Los personajes nuevos siguen las reglas de creación de la campaña comunitaria Heroes of Rokugan 5 (no oficial, sin afiliación con la campaña ni con Edge Studio). heroes-of-rokugan.net';

  @override
  String get wizErrHorRoninRing => 'Elige el aumento de anillo del rōnin.';

  @override
  String get wizErrHorBackground => 'Elige un trasfondo.';

  @override
  String get wizErrHorBackgroundRing => 'Elige el anillo del trasfondo.';

  @override
  String wizErrHorBackgroundSkill(int n) {
    return 'Elige la habilidad $n del trasfondo.';
  }

  @override
  String get wizErrHorService => 'Elige a quién sirve tu personaje.';

  @override
  String get wizErrHorQ5Skill => 'Elige una habilidad relacionada con tu giri.';

  @override
  String get wizErrHorQ6Skill =>
      'Elige una habilidad relacionada con tu ninjō (distinta de la pregunta 5).';

  @override
  String get wizErrHorAccessory => 'Elige un accesorio personal.';

  @override
  String get wizErrHorHeritage => 'Elige un resultado de herencia.';

  @override
  String get wizErrHorQ19 => 'Elige la técnica adicional de la pregunta 19.';

  @override
  String get wizErrHorOutfitItem =>
      'Elige qué objeto del equipo lleva las cualidades Sagrado y Prohibido.';

  @override
  String horRoninStatsLine(String skill, int status) {
    return 'Rōnin: +1 a cualquier anillo, +1 $skill, Estatus $status';
  }

  @override
  String get horRoninRingLabel => 'Aumento de anillo';

  @override
  String get horBackgroundLabel => 'Trasfondo';

  @override
  String horBackgroundStatsLine(int glory, String wealth) {
    return 'Gloria $glory, riqueza inicial $wealth';
  }

  @override
  String get horBackgroundRingLabel => 'Anillo del trasfondo';

  @override
  String horBackgroundSkillN(int n) {
    return 'Habilidad del trasfondo $n';
  }

  @override
  String get horAllSchoolSkills => '+1 a todas las habilidades iniciales:';

  @override
  String get horServiceLabel => 'Servicio';

  @override
  String get horRelatedSkill => 'Habilidad relacionada (+1)';

  @override
  String get horQ7Positive =>
      '+5 de gloria y 1 rango en una habilidad de otra familia de tu clan';

  @override
  String get horQ7Negative =>
      '−5 de gloria y 1 rango en una habilidad que ninguna familia de tu clan ofrece';

  @override
  String get horQ8Pos =>
      '+5 de honor y 1 rango en una habilidad tradicional de samurái';

  @override
  String get horQ8Neg =>
      '−3 de honor y 1 rango en una habilidad impropia de un samurái';

  @override
  String get horAccessoryRarity7 =>
      'Accesorio personal (no un arma, rareza 7 o menos)';

  @override
  String get horHeritageLabel => 'Herencia (elige una)';

  @override
  String get horQ19TechniqueLabel => 'Técnica adicional (rango de escuela 1)';

  @override
  String horCampaignTitleLine(String title, int stipend) {
    return 'Título de campaña: $title — Estatus fijado en 40, estipendio de $stipend koku por módulo.';
  }

  @override
  String get horInstallPack => 'Instalar el paquete de erratas';

  @override
  String get horInstallPackSubtitle =>
      'Copia las erratas de escuelas y los cambios de equipo de la campaña a tu carpeta de contenido propio. Se aplican a todas las partidas hasta que se retiren.';

  @override
  String get horRemovePack => 'Retirar el paquete de erratas';

  @override
  String get horRemovePackSubtitle =>
      'Solo retira las entradas instaladas por el paquete; tu contenido propio se conserva.';

  @override
  String horPackInstalledMsg(int count) {
    return 'Paquete de erratas HoR instalado ($count escuelas).';
  }

  @override
  String get horPackRemovedMsg => 'Paquete de erratas HoR retirado.';

  @override
  String get aboutSection => 'Acerca de';

  @override
  String get aboutApp => 'Acerca de Paper Blossoms';

  @override
  String get aboutAppSubtitle => 'Versión, créditos y licencias.';

  @override
  String get aboutTagline =>
      'Un generador de personajes para La Leyenda de los Cinco Anillos, 5.ª edición.';

  @override
  String get aboutPortNote =>
      'Una adaptación a Flutter de la aplicación de escritorio PaperBlossoms original, del mismo desarrollador.';

  @override
  String get aboutLegalese =>
      'Proyecto hecho por aficionados, sin afiliación con Fantasy Flight Games, Edge Studio ni Asmodee. La Leyenda de los Cinco Anillos y todo su contenido asociado son propiedad de Fantasy Flight Games.';

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
  String get sheetStyleTitle => 'Estilo de la hoja de personaje';

  @override
  String get sheetStyleSubtitle =>
      'Diseño usado al imprimir o exportar la hoja en PDF.';

  @override
  String get sheetStyleMinimalist => 'Minimalista';

  @override
  String get sheetStyleStructured => 'Estructurada';

  @override
  String pdfPageOf(int page, int total) {
    return 'Página $page / $total';
  }

  @override
  String get pdfVoidPoints => 'Puntos de Vacío';

  @override
  String get pdfStancesHeader => 'Referencia rápida de conflicto: posturas';

  @override
  String get colStance => 'Postura';

  @override
  String get colEffect => 'Efecto';

  @override
  String get pdfStanceAir =>
      'Las pruebas de acción de Ataque e Intriga que te tienen como objetivo aumentan su NO en 1.';

  @override
  String get pdfStanceEarth =>
      'Los adversarios no pueden gastar Oportunidad en pruebas de Ataque e Intriga que te tienen como objetivo para infligir golpes críticos o estados.';

  @override
  String get pdfStanceFire =>
      'Cuando superas una prueba, obtienes un éxito adicional.';

  @override
  String get pdfStanceWater =>
      'Una vez por turno, puedes realizar una acción adicional de Movimiento o Apoyo que no requiera prueba.';

  @override
  String get pdfStanceVoid =>
      'No recibes conflicto de los símbolos de conflicto en tus pruebas.';

  @override
  String get pdfOtherCategory => 'Otros';

  @override
  String get pdfXpTotalLabel => 'PX en total';

  @override
  String pdfTitleBox(String title, int xp) {
    return 'Título: $title ($xp PX)';
  }

  @override
  String get colAbility => 'Aptitud';

  @override
  String get ninjoHeader => 'Ninjō';

  @override
  String get giriHeader => 'Giri';

  @override
  String get customSchools => 'Escuelas personalizadas';

  @override
  String get customSchoolsSubtitle =>
      'Crea tu propia escuela con las reglas de Path of Waves (pág. 76) y gestiona las escuelas propias.';

  @override
  String get homebrewFolderIos =>
      'La carpeta paperblossoms es visible en la app Archivos (En mi iPhone/iPad). Deja allí archivos JSON con los nombres de los datos incluidos; se fusionan al iniciar.';

  @override
  String get homebrewFolderAndroid =>
      'En Android el contenido propio se gestiona en la app; usa el creador de escuelas y su importación/exportación.';

  @override
  String get sbStep1 => 'Paso 1: Rol de la escuela';

  @override
  String get sbStep2 => 'Paso 2: Afiliación y resumen';

  @override
  String get sbStep3 => 'Paso 3: Habilidad de escuela';

  @override
  String get sbStep4 => 'Paso 4: Aumentos de anillo';

  @override
  String get sbStep5 => 'Paso 5: Habilidades iniciales';

  @override
  String get sbStep6 => 'Paso 6: Técnicas';

  @override
  String get sbStep7 => 'Paso 7: Currículo y maestría';

  @override
  String get sbStep8 => 'Paso 8: Equipo inicial';

  @override
  String get sbStep9 => 'Paso 9: Nombre y guardado';

  @override
  String get sbSaveSchool => 'Guardar escuela';

  @override
  String get sbSaveAnyway => 'Guardar';

  @override
  String get sbUnnamedSchool => '(escuela sin nombre)';

  @override
  String get sbDiscardTitle => '¿Descartar esta escuela?';

  @override
  String get sbDiscardBody => 'Se perderán tus respuestas.';

  @override
  String get sbErrChooseRole => 'Elige al menos un rol.';

  @override
  String get sbErrAbilityName => 'Pon nombre a la habilidad de escuela.';

  @override
  String get sbErrRings => 'Elige los dos aumentos de anillo.';

  @override
  String get sbErrNoSkills => 'Elige al menos una habilidad.';

  @override
  String sbErrSkillPicks(int picks) {
    return 'La escuela debe ofrecer al menos tantas habilidades como las $picks que elige un jugador.';
  }

  @override
  String sbWarnSkillCount(int count) {
    return 'La receta del libro para este rol son $count habilidades (tabla 2–7).';
  }

  @override
  String get sbErrDirectiveAlone =>
      'Una opción de «rareza … o menor» debe ser la única de su fila; si no, la creación de personaje la omitirá en silencio.';

  @override
  String get sbAffiliationNone => 'Ninguna (sin afiliación)';

  @override
  String get sbAffiliationCustom => 'Personalizada…';

  @override
  String get sbErrCategory => 'Abre al menos una categoría de técnicas.';

  @override
  String get sbErrChoiceSet =>
      'Cada fila de elección necesita opciones, al menos tantas como elecciones.';

  @override
  String sbErrCurriculumIncomplete(int rank) {
    return 'Completa cada avance de los rangos 1–5 (el rango $rank tiene casillas vacías).';
  }

  @override
  String get sbErrMasteryName => 'Pon nombre a la habilidad de maestría.';

  @override
  String get sbErrName => 'Pon nombre a la escuela.';

  @override
  String get sbOverrideBundledTitle => '¿Sustituir la escuela oficial?';

  @override
  String sbOverrideBundledBody(String name) {
    return '«$name» coincide con una escuela oficial; tu versión propia la sustituirá hasta que se borre.';
  }

  @override
  String get sbOverwriteHomebrewTitle => '¿Sobrescribir la escuela propia?';

  @override
  String sbOverwriteHomebrewBody(String name) {
    return 'Ya existe una escuela propia llamada «$name».';
  }

  @override
  String get sbRolesQuestion => '¿Qué rol o roles encarna la escuela?';

  @override
  String get sbRolesHelp =>
      'Elige uno o dos roles (hasta tres para una escuela compleja). El rol principal determina las tablas sugeridas que rellenan los pasos siguientes.';

  @override
  String get sbWarnThreeRoles => 'El libro recomienda como mucho dos roles.';

  @override
  String get sbRolesOrder => 'Orden de los roles';

  @override
  String get sbPrimaryRole => 'Rol principal';

  @override
  String get sbMakePrimary => 'Hacer principal';

  @override
  String get sbAffiliationQuestion =>
      '¿A qué clan o facción está asociada la escuela?';

  @override
  String get sbCustomAffiliationLabel => 'Afiliación personalizada';

  @override
  String get sbNoteRonin =>
      'Una escuela Rōnin aparece para personajes rōnin y campesinos en el asistente de nuevo personaje.';

  @override
  String get sbNoteNoAffiliation =>
      'Una escuela sin afiliación solo es accesible mediante la casilla «cualquier escuela» del asistente de nuevo personaje.';

  @override
  String get sbNoteCustomAffiliation =>
      'Una facción personalizada no coincide con ningún clan ni región: la escuela solo es accesible mediante la casilla «cualquier escuela» del asistente de nuevo personaje.';

  @override
  String get sbSummaryHeader => 'Resumen de la escuela';

  @override
  String get sbSummaryLabel => 'Resumen (el libro pide de 3 a 5 frases)';

  @override
  String get sbSummaryShortLabel =>
      'Resumen de una línea (se muestra bajo la escuela en las listas)';

  @override
  String get sbWarnNoSummary =>
      'Aún no hay resumen — el libro pide un argumento de venta de 3 a 5 frases.';

  @override
  String get sbAbilityQuestion => '¿Cuál es la habilidad de escuela?';

  @override
  String get sbAbilityHelp =>
      'La habilidad debe escalar con el rango de escuela. Parte de una plantilla genérica (tabla 2–4) o inventa la tuya; el texto de reglas se guarda como descripción propia, igual que en el editor de descripciones.';

  @override
  String get sbAbilityTemplate => 'Partir de una plantilla (tabla 2–4)';

  @override
  String sbSeeBook(String page) {
    return 'Texto de la plantilla de Path of Waves pág. $page insertado abajo — edítalo libremente.';
  }

  @override
  String get sbAbilityName => 'Nombre de la habilidad de escuela';

  @override
  String get sbAbilityText => 'Texto de reglas de la habilidad';

  @override
  String get sbWarnNoAbilityText =>
      'No se ha introducido texto de reglas; puedes añadirlo después en el editor de descripciones.';

  @override
  String get sbShortDescLabel => 'Descripción corta (una línea)';

  @override
  String get sbRingsQuestion => '¿Qué dos anillos aumenta la escuela?';

  @override
  String sbHintFirstRing(String role, String rings) {
    return 'Las escuelas de $role suelen tomar su primer aumento en $rings (tabla 2–5).';
  }

  @override
  String get sbHintShugenjaRing =>
      'Las escuelas de shugenja suelen aumentar el elemento al que está vinculada la escuela (tabla 2–5).';

  @override
  String get sbRing1 => 'Primer aumento de anillo';

  @override
  String get sbRing2 => 'Segundo aumento de anillo';

  @override
  String get sbWarnDoubledRing =>
      'Dos aumentos en el mismo anillo es raro pero válido (las escuelas Isawa Tensai lo hacen).';

  @override
  String sbWarnRingsSuggestion(String role) {
    return 'Esto difiere de la sugerencia del libro para una escuela de $role. Está permitido — muchas escuelas rompen el molde.';
  }

  @override
  String get sbSecondRingHintsTitle =>
      'Segundo anillo según aquello por lo que la escuela es conocida (tabla 2–6)';

  @override
  String get sbRingTraitAir => 'Precisión, gracia o modales';

  @override
  String get sbRingTraitEarth => 'Paciencia, tradición o resistencia';

  @override
  String get sbRingTraitFire => 'Inventiva, ferocidad o velocidad';

  @override
  String get sbRingTraitVoid => 'Filosofía, abnegación o perspicacia';

  @override
  String get sbRingTraitWater => 'Adaptabilidad, flexibilidad o atención';

  @override
  String sbSkillsQuestion(int count) {
    return 'Elige las $count habilidades que ofrece la escuela';
  }

  @override
  String sbSkillsProgress(int selected, int count, int picks) {
    return '$selected de $count seleccionadas — los jugadores elegirán $picks al crear el personaje (tabla 2–7).';
  }

  @override
  String get sbAccessQuestion => 'Acceso abierto a técnicas';

  @override
  String get sbAccessHelp =>
      'La mayoría de las escuelas tienen Rituales más dos entre Katas, Kihōs, Invocaciones y Shūjis. Despliega una categoría para conceder solo algunas subcategorías (acceso limitado).';

  @override
  String get sbWarnForbidden =>
      'El ninjutsu y el mahō son artes prohibidas — el libro solo los concede en casos únicos.';

  @override
  String get sbWarnManyCategories =>
      'Las escuelas típicas abren Rituales más otras dos categorías.';

  @override
  String get sbWarnShugenjaInvocations =>
      'Las escuelas de shugenja normalmente tienen acceso abierto a las Invocaciones.';

  @override
  String get sbStartingTechniques => 'Técnicas iniciales';

  @override
  String sbStartingTechniquesHelp(int count, String role) {
    return 'Una escuela de $role concede $count técnicas iniciales (tabla 2–8). Cada fila puede ofrecer una elección, como «1 de estos 2 katas».';
  }

  @override
  String get sbShowAllTechniques =>
      'Mostrar todas las técnicas (no solo rango 1 dentro del acceso)';

  @override
  String get sbAddRow => 'Añadir fila';

  @override
  String get sbWarnCommune =>
      'Las escuelas de shugenja empiezan con Comunión con los espíritus (tabla 2–8).';

  @override
  String sbWarnStartingTechRank(String name) {
    return '$name supera el rango 1 o queda fuera del acceso abierto de la escuela — válido si es intencionado (el libro lo permite).';
  }

  @override
  String get sbSlotSkillGroup => 'Grupo de habilidades';

  @override
  String get sbSlotSkill => 'Habilidad';

  @override
  String get sbSlotTechniqueGroup => 'Grupo de técnicas';

  @override
  String get sbSlotTechnique => 'Técnica';

  @override
  String get sbChooseTechnique => 'Elegir técnica…';

  @override
  String sbCopyPrevRank(int rank) {
    return 'Copiar del rango $rank';
  }

  @override
  String get sbClearRank => 'Vaciar el rango';

  @override
  String get sbMaxTechRank => 'Rango máx. de técnica:';

  @override
  String get sbMaxTechRankDefault => 'Hasta el rango de escuela';

  @override
  String get sbSpecialAccessChip => 'Acceso especial';

  @override
  String get sbSpecialAccessWhy =>
      'Los estudiantes pueden tomar esto aunque supere el rango del currículo o quede fuera del acceso abierto de la escuela. Se determina automáticamente.';

  @override
  String get sbWarnSkillInGroup =>
      'Esta habilidad ya está cubierta por el grupo de este rango — el libro sugiere habilidades de fuera del grupo.';

  @override
  String get sbWarnRankShape =>
      'Este rango se desvía del esquema del libro (1 grupo de habilidades, 3 habilidades, 1 grupo de técnicas, 2 técnicas). Permitido, pero el libro pide usarlo con moderación.';

  @override
  String get sbMastery => 'Maestría';

  @override
  String get sbMasteryQuestion => '¿Cuál es la habilidad de maestría?';

  @override
  String get sbMasteryHelp =>
      'El rango 6 solo contiene la habilidad de maestría — algo poderoso e impresionante. Usa una plantilla (tabla 2–10) o inventa una; las habilidades puramente narrativas funcionan mejor limitadas a una vez por sesión.';

  @override
  String get sbMasteryTemplate => 'Partir de una plantilla (tabla 2–10)';

  @override
  String get sbMasteryName => 'Nombre de la habilidad de maestría';

  @override
  String get sbMasteryText => 'Texto de reglas de la maestría';

  @override
  String get sbOutfitQuestion => 'Equipo inicial';

  @override
  String get sbOutfitHelp =>
      'La tabla 2–11 sugiere un equipo para el rol principal; aquí viene rellenado y es libremente editable. Filas como «One Weapon of Rarity 6 or Lower» se convierten en selectores al crear el personaje.';

  @override
  String get sbWarnNoOutfit =>
      'Sin filas de equipo — los personajes de esta escuela empezarán sin equipo.';

  @override
  String get sbNameQuestion => 'Pon nombre a la escuela';

  @override
  String get sbNameLabel => 'Nombre de la escuela';

  @override
  String get sbHonorLabel =>
      'Honor inicial (sugerido para el rol; el libro no lo indica)';

  @override
  String get sbRefBookLabel => 'Libro de referencia';

  @override
  String get sbRefPageLabel => 'Página de referencia';

  @override
  String get sbReviewTitle => 'Resumen final';

  @override
  String get sbReviewRoles => 'Roles';

  @override
  String get sbReviewRings => 'Anillos';

  @override
  String get sbReviewSkills => 'Habilidades / elecciones';

  @override
  String get sbReviewAccess => 'Acceso a técnicas';

  @override
  String get sbReviewCurriculum => 'Avances del currículo';

  @override
  String sbChooseOf(int size) {
    return 'Elige $size de:';
  }

  @override
  String get sbAddOption => 'Añadir opción';

  @override
  String get sbRemoveRow => 'Eliminar fila';

  @override
  String get sbBuildNew => 'Crear una nueva escuela';

  @override
  String get sbBuildNewSubtitle =>
      'Un asistente de nueve pasos siguiendo Path of Waves págs. 76–84.';

  @override
  String get sbEmptyHint =>
      'Aún no hay escuelas propias.\nCrea una, o deja un schools.json en la carpeta de contenido propio.';

  @override
  String sbSavedSnack(String name) {
    return '«$name» guardada en homebrew/schools.json — ya aparece en el asistente de nuevo personaje.';
  }

  @override
  String sbDeleteTitle(String name) {
    return '¿Borrar $name?';
  }

  @override
  String get sbDeleteBody =>
      'Los personajes existentes conservan la escuela por su nombre pero pierden su currículo y habilidades.';

  @override
  String get sbDeleteAlsoText =>
      'Borrar también sus textos de reglas (resumen, habilidad de escuela, habilidad de maestría)';

  @override
  String get sbDeleteAll => 'Eliminar todas las escuelas propias';

  @override
  String get sbDeleteAllBody =>
      'Esto borra todas las escuelas de homebrew/schools.json.';

  @override
  String get sbImportSchools => 'Importar escuelas…';

  @override
  String get sbExportSchools => 'Exportar escuelas…';

  @override
  String sbImportedSchools(int count) {
    return '$count escuelas importadas';
  }

  @override
  String sbExportedSchools(int count) {
    return '$count escuelas exportadas';
  }

  @override
  String get sbNoSchoolsToExport => 'No hay escuelas propias que exportar.';

  @override
  String get sbCouldNotReadSchoolsFile =>
      'Ese archivo no se pudo leer como un array JSON de escuelas.';
}
