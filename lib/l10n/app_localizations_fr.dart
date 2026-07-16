// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Paper Blossoms';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get importCharacterTooltip => 'Importer un personnage';

  @override
  String get newCharacter => 'Nouveau personnage';

  @override
  String get noCharactersYet =>
      'Aucun personnage pour l’instant.\nCréez-en un pour commencer votre histoire.';

  @override
  String deleteCharacterTitle(String name) {
    return 'Supprimer $name ?';
  }

  @override
  String get deleteCannotBeUndone => 'Cette action est irréversible.';

  @override
  String rankN(int rank) {
    return 'Rang $rank';
  }

  @override
  String get toolsTitle => 'Outils';

  @override
  String get languageSection => 'Langue';

  @override
  String get languageInterface => 'Interface';

  @override
  String get languageContent => 'Contenu de jeu';

  @override
  String get languageMatchInterface => 'Comme l’interface';

  @override
  String get appearanceSection => 'Apparence';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get themeSystem => 'Système';

  @override
  String get rulesTextSection => 'Textes de règles';

  @override
  String get editRulesDescriptions => 'Modifier les descriptions de règles';

  @override
  String get editRulesDescriptionsSubtitle =>
      'Les données fournies ne contiennent aucun texte de règles. Si vous possédez les livres, saisissez vos propres descriptions ici ; elles apparaîtront dans l’éditeur et sur la fiche PDF.';

  @override
  String get importDescriptions => 'Importer des descriptions…';

  @override
  String get importDescriptionsSubtitle =>
      'Fusionne les descriptions d’un fichier JSON exporté ou du user_descriptions.csv du Paper Blossoms original ; les entrées importées remplacent celles du même nom.';

  @override
  String get exportDescriptions => 'Exporter les descriptions…';

  @override
  String get exportDescriptionsSubtitle =>
      'Enregistre toutes les descriptions dans un fichier JSON pour sauvegarde ou partage.';

  @override
  String get homebrewSection => 'Contenu maison';

  @override
  String get homebrewFolder => 'Dossier de contenu maison';

  @override
  String homebrewFolderSubtitle(String path) {
    return '$path\n\nDéposez-y des fichiers JSON nommés comme les données fournies (weapons.json, titles.json, techniques.json, …) avec la même structure ; les entrées sont fusionnées après le contenu officiel au lancement.';
  }

  @override
  String get reloadHomebrew => 'Recharger le contenu maison';

  @override
  String get nothingMergedThisSession => 'Rien n’a été fusionné cette session.';

  @override
  String mergedFiles(String files) {
    return 'Fusionné : $files';
  }

  @override
  String get noHomebrewFilesFound => 'Aucun fichier de contenu maison trouvé.';

  @override
  String importedDescriptions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count descriptions importées.',
      one: '1 description importée.',
    );
    return '$_temp0';
  }

  @override
  String exportedDescriptions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count descriptions exportées.',
      one: '1 description exportée.',
    );
    return '$_temp0';
  }

  @override
  String get couldNotReadDescriptionsFile =>
      'Impossible de lire ce fichier comme descriptions JSON ou CSV.';

  @override
  String get noDescriptionsToExport => 'Aucune description à exporter.';

  @override
  String get tabCharacter => 'Personnage';

  @override
  String get tabBackground => 'Passé';

  @override
  String get tabTraits => 'Traits';

  @override
  String get tabBonds => 'Liens';

  @override
  String get tabTechniques => 'Techniques';

  @override
  String get tabEquipment => 'Équipement';

  @override
  String get tabAdvancement => 'Progression';

  @override
  String get unnamedSamurai => 'Samouraï sans nom';

  @override
  String get saved => 'Enregistré';

  @override
  String get save => 'Enregistrer';

  @override
  String get saveUnsavedTooltip =>
      'Enregistrer (modifications non enregistrées)';

  @override
  String get exportTooltip => 'Exporter';

  @override
  String get printExportPdf => 'Imprimer / exporter la fiche PDF…';

  @override
  String get shareCharacterJson => 'Partager le personnage en JSON…';

  @override
  String get fullSkillTableOnSheet =>
      'Table complète des compétences sur la fiche';

  @override
  String get portraitOnSheet => 'Portrait sur la fiche';

  @override
  String get unsavedChanges => 'Modifications non enregistrées';

  @override
  String get saveBeforeClosing => 'Enregistrer ce personnage avant de fermer ?';

  @override
  String get keepEditing => 'Continuer l’édition';

  @override
  String get discard => 'Abandonner';

  @override
  String get saveAndClose => 'Enregistrer et fermer';

  @override
  String get characterExported => 'Personnage exporté.';

  @override
  String get nameLabel => 'Nom';

  @override
  String get familyLabel => 'Famille';

  @override
  String get noClan => 'Sans clan';

  @override
  String get noSchool => 'Sans école';

  @override
  String get socialStandingSection => 'Position sociale';

  @override
  String get honor => 'Honneur';

  @override
  String get glory => 'Gloire';

  @override
  String get statusLabel => 'Statut';

  @override
  String get wealthSection => 'Fortune';

  @override
  String get koku => 'Koku';

  @override
  String get bu => 'Bu';

  @override
  String get zeni => 'Zeni';

  @override
  String get abilitiesSection => 'Capacités';

  @override
  String get noAbilitiesYet => 'Aucune capacité pour l’instant.';

  @override
  String get ringsSection => 'Anneaux';

  @override
  String get derivedAttributesSection => 'Attributs dérivés';

  @override
  String get endurance => 'Endurance';

  @override
  String get composure => 'Sang-froid';

  @override
  String get focusStat => 'Concentration';

  @override
  String get vigilance => 'Vigilance';

  @override
  String get schoolRank => 'Rang d’école';

  @override
  String get fatigueStrifeSection => 'Fatigue et Conflit';

  @override
  String fatigueOf(int max) {
    return 'Fatigue / $max';
  }

  @override
  String strifeOf(int max) {
    return 'Conflit / $max';
  }

  @override
  String get clearAllFatigue => 'Effacer toute la fatigue';

  @override
  String get recover => 'Récupérer';

  @override
  String get clearAllStrife => 'Effacer tout le conflit';

  @override
  String get unmask => 'Se démasquer';

  @override
  String get conditionsSection => 'États';

  @override
  String get addCondition => 'Ajouter un état';

  @override
  String get noConditions => 'Aucun état.';

  @override
  String get incapacitatedRule =>
      'La fatigue dépasse l’endurance : aucune action nécessitant un test et aucune défense contre les dégâts.';

  @override
  String get compromisedRule =>
      'Le conflit dépasse le sang-froid : impossible de conserver des dés montrant du conflit ; la vigilance compte pour 1.';

  @override
  String get criticalStrike => 'Coup critique…';

  @override
  String get skillsSection => 'Compétences';

  @override
  String get heritageSection => 'Héritage';

  @override
  String get ninjoSection => 'Ninjō (désir personnel)';

  @override
  String get giriSection => 'Giri (devoir)';

  @override
  String get notesSection => 'Notes';

  @override
  String get add => 'Ajouter';

  @override
  String get remove => 'Retirer';

  @override
  String get undo => 'Annuler';

  @override
  String removedName(String name) {
    return '$name retiré';
  }

  @override
  String get unknownCustomSection =>
      'Inconnu (personnalisé ou données manquantes)';

  @override
  String get bondsSection => 'Liens';

  @override
  String get addBond => 'Ajouter un lien';

  @override
  String get noBondsYet =>
      'Aucun lien noué pour l’instant — touchez + pour en ajouter.';

  @override
  String get rankLabel => 'Rang';

  @override
  String get techniquesSection => 'Techniques';

  @override
  String get noTechniquesYet => 'Aucune technique connue pour l’instant.';

  @override
  String restrictionLabel(String restriction) {
    return 'Restriction : $restriction';
  }

  @override
  String get customOrUnknownTechnique => 'Technique personnalisée ou inconnue';

  @override
  String get weaponsSection => 'Armes';

  @override
  String get armorSection => 'Armures';

  @override
  String get personalEffectsSection => 'Effets personnels';

  @override
  String get addItem => 'Ajouter un objet';

  @override
  String get noWeaponsYet =>
      'Aucune arme pour l’instant — touchez + pour en ajouter.';

  @override
  String get noArmorYet =>
      'Aucune armure pour l’instant — touchez + pour en ajouter.';

  @override
  String get noPersonalEffectsYet =>
      'Aucun effet personnel pour l’instant — touchez + pour en ajouter.';

  @override
  String gripStats(
    String grip,
    int min,
    int max,
    String damage,
    String deadliness,
  ) {
    return '$grip : Portée $min-$max · Dég $damage · Mor $deadliness';
  }

  @override
  String armorStats(int physical, int supernatural) {
    return 'Physique $physical · Surnaturel $supernatural';
  }

  @override
  String priceLine(int price, String unit, int rarity) {
    return '$price $unit · Rareté $rarity';
  }

  @override
  String get colName => 'Nom';

  @override
  String get colCategory => 'Catégorie';

  @override
  String get colSkill => 'Compétence';

  @override
  String get colGrip => 'Prise';

  @override
  String get colRange => 'Portée';

  @override
  String get colDamage => 'Dég';

  @override
  String get colDeadliness => 'Mor';

  @override
  String get colQualities => 'Qualités';

  @override
  String get colPhysical => 'Physique';

  @override
  String get colSupernatural => 'Surnaturel';

  @override
  String addedAdvanceRankUp(String name, int rank) {
    return '$name ajouté — le rang d’école passe à $rank !';
  }

  @override
  String addedAdvance(String name, int cost, String track) {
    return '$name ajouté — $cost XP ($track)';
  }

  @override
  String get xpInRank => 'XP dans le rang';

  @override
  String get xpSpentLabel => 'XP dépensés';

  @override
  String get noTitleInProgress => 'Aucun titre en cours';

  @override
  String currentTitleLine(String title, int xp, int total) {
    return 'Titre en cours : $title — $xp / $total XP';
  }

  @override
  String curriculumSection(String school) {
    return 'Cursus — $school';
  }

  @override
  String get noSchoolFallback => 'sans école';

  @override
  String get addAdvance => 'Ajouter une amélioration';

  @override
  String get noSchoolNoCurriculum =>
      'Aucune école choisie, donc pas de cursus.';

  @override
  String get currentLabel => 'actuel';

  @override
  String skillRankLabel(int rank) {
    return 'rang $rank';
  }

  @override
  String get specialAccess => 'accès spécial';

  @override
  String ranksRange(int min, int max) {
    return 'rangs $min-$max';
  }

  @override
  String get atRank5 => 'Au rang 5';

  @override
  String get alreadyLearnedLabel => 'Déjà appris';

  @override
  String get buyThisAdvance => 'Acheter cette amélioration';

  @override
  String get titlesSection => 'Titres';

  @override
  String get addTitle => 'Ajouter un titre';

  @override
  String get finishCurrentTitleFirst => 'Terminez d’abord le titre en cours';

  @override
  String get noTitlesYet =>
      'Aucun titre pour l’instant — touchez + pour en ajouter.';

  @override
  String get inProgressLabel => 'En cours';

  @override
  String completedWithAbility(String ability) {
    return 'Terminé — $ability';
  }

  @override
  String maxRankLabel(int rank) {
    return 'rang max $rank';
  }

  @override
  String get advancesTakenSection => 'Améliorations acquises';

  @override
  String get noAdvancesYet =>
      'Aucune amélioration achetée pour l’instant — touchez + ou une entrée du cursus.';

  @override
  String advanceSubtitle(String type, String track, int cost) {
    return '$type · $track · $cost XP';
  }

  @override
  String get addAdvanceTitle => 'Ajouter une amélioration';

  @override
  String get advTypeSkill => 'Compétence';

  @override
  String get advTypeRing => 'Anneau';

  @override
  String get advTypeTechnique => 'Technique';

  @override
  String get advanceSection => 'Amélioration';

  @override
  String get groupLabel => 'Groupe';

  @override
  String get allGroups => 'Tous les groupes';

  @override
  String get mahoWarning =>
      'Le mahō est interdit. L’apprendre a des conséquences.';

  @override
  String get typeToFilter => 'Tapez pour filtrer';

  @override
  String get clearFilter => 'Effacer le filtre';

  @override
  String techSubtitle(String subcategory, int rank, int xp) {
    return '$subcategory · Rang $rank · $xp XP';
  }

  @override
  String get ignoreRestrictions =>
      'Ignorer les restrictions (rang, accès d’école)';

  @override
  String get trackSection => 'Voie';

  @override
  String get trackCurriculumLabel => 'Cursus';

  @override
  String get trackTitleLabel => 'Titre';

  @override
  String get trackFreeLabel => 'Libre (sans coût en XP)';

  @override
  String get reasonOptional => 'Raison (facultatif)';

  @override
  String get halfXpLabel => 'Demi-XP (remise d’école/de titre)';

  @override
  String get chooseAnAdvance => 'Choisissez une amélioration.';

  @override
  String alreadyLearnedError(String name) {
    return '« $name » est déjà appris.';
  }

  @override
  String costXp(int cost) {
    return 'Coût : $cost XP';
  }

  @override
  String get addItemTitle => 'Ajouter un objet';

  @override
  String get itemWeapon => 'Arme';

  @override
  String get itemArmor => 'Armure';

  @override
  String get itemPersonalEffect => 'Effet personnel';

  @override
  String get chooseWeapon => 'Choisir une arme';

  @override
  String get chooseArmor => 'Choisir une armure';

  @override
  String get choosePersonalEffect => 'Choisir un effet personnel';

  @override
  String weaponPickSubtitle(
    String category,
    String skill,
    String damage,
    String deadliness,
  ) {
    return '$category · $skill · Dég $damage · Mor $deadliness';
  }

  @override
  String get chooseFromBook => 'Choisir dans le livre…';

  @override
  String get changeBaseItem => 'Changer l’objet de base…';

  @override
  String get customItem => 'Objet personnalisé';

  @override
  String get detailsSection => 'Détails';

  @override
  String get priceLabel => 'Prix';

  @override
  String get rarityLabel => 'Rareté';

  @override
  String get qualitiesCommaSeparated => 'Qualités (séparées par des virgules)';

  @override
  String addNGrips(int count) {
    return 'Ajouter ($count prises)';
  }

  @override
  String gripEditorLabel(String grip) {
    return 'Prise : $grip';
  }

  @override
  String get minRange => 'Portée min';

  @override
  String get maxRange => 'Portée max';

  @override
  String get damageLabel => 'Dégâts';

  @override
  String get deadlinessLabel => 'Létalité';

  @override
  String get addTrait => 'Ajouter un trait';

  @override
  String addCategoryLower(String category) {
    return 'Ajouter : $category';
  }

  @override
  String get addBondTitle => 'Ajouter un lien';

  @override
  String get addTitleTitle => 'Ajouter un titre';

  @override
  String xpAmount(int xp) {
    return '$xp XP';
  }

  @override
  String get criticalStrikeTitle => 'Coup critique';

  @override
  String get severityLabel => 'Gravité (létalité de la source)';

  @override
  String get razorEdgedLabel => 'L’attaque était Affûtée';

  @override
  String get ringUsedToResist => 'Anneau utilisé pour résister';

  @override
  String get ringResistHelper =>
      'Anneau de posture en conflit, au choix en narration';

  @override
  String get tnFitnessCheck => 'Test de Forme physique ND 1 réussi';

  @override
  String get rollOwnDice => 'Lancez vos propres dés et saisissez le résultat';

  @override
  String get bonusSuccessesLabel =>
      'Succès bonus (gravité −1 chacun, en plus du −1)';

  @override
  String finalSeverityLine(int severity, String band) {
    return 'Gravité finale $severity — $band';
  }

  @override
  String get apply => 'Appliquer';

  @override
  String chooseScarTitle(String band, String ring) {
    return '$band : choisissez une cicatrice ($ring)';
  }

  @override
  String severityResult(int severity, String band, String effect) {
    return 'Gravité $severity : $band — $effect';
  }

  @override
  String get rulesDescriptionsTitle => 'Descriptions de règles';

  @override
  String get shortDescriptionLabel => 'Description courte';

  @override
  String get fullDescriptionLabel => 'Description complète';

  @override
  String get searchHint => 'Rechercher…';

  @override
  String get withText => 'Avec texte';

  @override
  String get wizPart1 => 'Partie 1 : Clan et famille';

  @override
  String get wizPart2 => 'Partie 2 : Rôle et école';

  @override
  String get wizPart3 => 'Partie 3 : Honneur et gloire';

  @override
  String get wizPart4 => 'Partie 4 : Forces et faiblesses';

  @override
  String get wizPart5 => 'Partie 5 : Personnalité et comportement';

  @override
  String get wizPart6 => 'Partie 6 : Ascendance et famille';

  @override
  String get wizPart7 => 'Partie 7 : Mort';

  @override
  String get wizErrChooseClan => 'Choisissez un clan (question 1).';

  @override
  String get wizErrChooseFamily => 'Choisissez une famille (question 2).';

  @override
  String get wizErrChooseFamilyRing =>
      'Choisissez l’augmentation d’anneau de votre famille.';

  @override
  String get wizErrChooseRegion => 'Choisissez une région (question 1).';

  @override
  String get wizErrChooseUpbringing => 'Choisissez une éducation (question 2).';

  @override
  String get wizErrChooseUpbringingRing =>
      'Choisissez l’augmentation d’anneau de votre éducation.';

  @override
  String wizErrChooseUpbringingSkill(int n) {
    return 'Choisissez la compétence d’éducation $n.';
  }

  @override
  String get wizErrChooseSchool => 'Choisissez une école.';

  @override
  String get wizErrInsufficientSkills =>
      'Compétences sélectionnées insuffisantes.';

  @override
  String get wizErrSchoolRings =>
      'Choisissez les augmentations d’anneaux de votre école.';

  @override
  String get wizErrStandoutRing => 'Choisissez votre anneau distinctif.';

  @override
  String get wizErrStartingTechniques => 'Choisissez vos techniques de départ.';

  @override
  String get wizErrQ7Option => 'Choisissez une option pour la question 7.';

  @override
  String get wizErrQ7Skill => 'Choisissez une compétence pour la question 7.';

  @override
  String get wizErrQ8Option => 'Choisissez une option pour la question 8.';

  @override
  String get wizErrQ8Skill => 'Choisissez une compétence pour la question 8.';

  @override
  String get wizErrQ8Item => 'Choisissez un objet pour la question 8.';

  @override
  String get wizErrDistinction => 'Choisissez une distinction (question 9).';

  @override
  String get wizErrAdversity => 'Choisissez une adversité (question 10).';

  @override
  String get wizErrPassion => 'Choisissez une passion (question 11).';

  @override
  String get wizErrAnxiety => 'Choisissez une anxiété (question 12).';

  @override
  String get wizErrQ13Option => 'Choisissez une option pour la question 13.';

  @override
  String get wizErrQ13Advantage =>
      'Choisissez un avantage pour la question 13.';

  @override
  String get wizErrQ13DisadvSkill =>
      'Choisissez un désavantage et une compétence pour la question 13.';

  @override
  String get wizErrQ16Item =>
      'Choisissez un objet souvenir pour la question 16.';

  @override
  String get wizErrReplacementRings =>
      'Veuillez sélectionner un ou des anneaux de remplacement.';

  @override
  String get wizErrReplacementSkills =>
      'Veuillez sélectionner une ou des compétences de remplacement.';

  @override
  String get wizDiscardTitle => 'Abandonner ce personnage ?';

  @override
  String get wizDiscardBody => 'Vos réponses seront perdues.';

  @override
  String get wizSummaryTooltip => 'Anneaux et compétences en cours';

  @override
  String get wizNoSkillsYet => 'Aucune compétence pour l’instant.';

  @override
  String wizStepOf(int page, int total) {
    return 'Étape $page sur $total';
  }

  @override
  String get back => 'Retour';

  @override
  String get next => 'Suivant';

  @override
  String get finish => 'Terminer';

  @override
  String get characterTypeLabel => 'Type de personnage';

  @override
  String get wizQ1Clan => '1. À quel clan votre personnage appartient-il ?';

  @override
  String get clanLabel => 'Clan';

  @override
  String clanStatsLine(
    String ring,
    String skill,
    int status,
    String reference,
  ) {
    return '+1 $ring · +1 $skill · Statut $status · $reference';
  }

  @override
  String get wizQ2Family =>
      '2. À quelle famille votre personnage appartient-il ?';

  @override
  String familyStatsLine(String skills, int glory, int wealth) {
    return '+1 $skills · Gloire $glory · Fortune $wealth koku';
  }

  @override
  String get familyRingIncrease => 'Augmentation d’anneau de la famille';

  @override
  String get wizQ1Region => '1. D’où vient votre personnage ?';

  @override
  String get regionLabel => 'Région';

  @override
  String get wizQ2Upbringing =>
      '2. Quelle a été l’éducation de votre personnage ?';

  @override
  String get upbringingLabel => 'Éducation';

  @override
  String get upbringingRingIncrease => 'Augmentation d’anneau de l’éducation';

  @override
  String upbringingSkillN(int n) {
    return 'Compétence d’éducation $n';
  }

  @override
  String get wizQ3Samurai =>
      '3. Quelle est votre école, et de quels rôles relève-t-elle ?';

  @override
  String get wizQ3Ronin =>
      '3. Quelle est votre école, et quels sont ses rôles associés ?';

  @override
  String get showSchoolsOutsideClan => 'Afficher les écoles hors de mon clan';

  @override
  String get schoolLabel => 'École';

  @override
  String schoolStatsLine(String roles, int honor, String reference) {
    return '$roles · Honneur $honor · $reference';
  }

  @override
  String get kitsuneImpersonate => 'École à imiter (source de l’équipement)';

  @override
  String get additionalBurden => 'Fardeau supplémentaire';

  @override
  String chooseSchoolSkills(int size, int chosen) {
    return 'Choisissez $size compétences d’école ($chosen choisies)';
  }

  @override
  String get schoolRingIncreases => 'Augmentations d’anneaux de l’école';

  @override
  String fixedRings(String rings) {
    return 'Fixe : +1 $rings';
  }

  @override
  String get ringOfYourChoice => 'Anneau de votre choix';

  @override
  String get wizQ4Samurai =>
      '4. Comment vous distinguez-vous au sein de votre école ? (+1 anneau)';

  @override
  String get wizQ4Ronin =>
      '4. Qu’est-ce qui vous attire des ennuis — et vous en sort ? (+1 anneau)';

  @override
  String get standoutRing => 'Anneau distinctif';

  @override
  String get describeIt => 'Décrivez-le';

  @override
  String startingTechniqueFixed(String name) {
    return 'Technique de départ : $name';
  }

  @override
  String get chooseStartingTechnique => 'Choisissez une technique de départ';

  @override
  String get startingOutfit => 'Équipement de départ';

  @override
  String get chooseAnItem => 'Choisissez un objet';

  @override
  String includedItems(String items) {
    return 'Inclus : $items';
  }

  @override
  String get wizQ5Samurai =>
      '5. Qui est votre seigneur, et quel est votre devoir envers lui ? (Giri)';

  @override
  String get wizQ5Ronin =>
      '5. Quel est votre passé, et comment vous affecte-t-il ?';

  @override
  String get answerLabel => 'Réponse';

  @override
  String get wizQ6Samurai =>
      '6. À quoi aspirez-vous, et en quoi cela pourrait-il gêner votre devoir ? (Ninjō)';

  @override
  String get wizQ6Ronin =>
      '6. À quoi aspirez-vous, et en quoi votre passé pourrait-il influer sur votre Ninjō ?';

  @override
  String get wizQ7Samurai => '7. Quelle est votre relation avec votre clan ?';

  @override
  String get wizQ7Ronin => '7. Pour quoi êtes-vous connu ?';

  @override
  String get q7Positive => 'Positive (+5 Gloire)';

  @override
  String get q7Negative =>
      'Négative (+1 rang dans une compétence que vous n’avez pas)';

  @override
  String get wizQ8 => '8. Que pensez-vous du Bushidō ?';

  @override
  String get q8Pos => 'Croyance orthodoxe inébranlable (+10 Honneur)';

  @override
  String get q8Mid => 'Survivant pragmatique (un objet de rareté 5 ou moins)';

  @override
  String get q8Neg => 'S’écarte des croyances communes (+1 rang de compétence)';

  @override
  String get itemLabel => 'Objet';

  @override
  String get wizQ9 =>
      '9. Quel est votre plus grand accomplissement à ce jour ? (Distinction)';

  @override
  String get distinctionLabel => 'Distinction';

  @override
  String get wizQ10 =>
      '10. Qu’est-ce qui retient votre personnage ? (Adversité)';

  @override
  String get adversityLabel => 'Adversité';

  @override
  String get wizQ11 => '11. Quelle activité vous apaise ? (Passion)';

  @override
  String get passionLabel => 'Passion';

  @override
  String get wizQ12 =>
      '12. Quelle inquiétude ou peur vous empêche de dormir ? (Anxiété)';

  @override
  String get anxietyLabel => 'Anxiété';

  @override
  String get wizQ13 =>
      '13. Qui est la personne en qui vous avez le plus confiance, et quelle est la nature de cette relation ?';

  @override
  String get q13GainAdvantage => 'Gagner un avantage';

  @override
  String get q13GainDisadvantage =>
      'Gagner un désavantage et +1 rang de compétence';

  @override
  String get advantageLabel => 'Avantage';

  @override
  String get disadvantageLabel => 'Désavantage';

  @override
  String get describeRelationship => 'Décrivez la relation';

  @override
  String get wizQ14Samurai =>
      '14. Que remarque-t-on d’abord en vous rencontrant ?';

  @override
  String get wizQ14Ronin =>
      '14. Quel est le bien le plus précieux de votre personnage ?';

  @override
  String get possessionRarity5 => 'Possession (rareté 5 ou moins)';

  @override
  String get wizQ15 =>
      '15. Comment réagissez-vous aux situations stressantes ?';

  @override
  String get wizQ16Samurai =>
      '16. Quelles sont vos relations préexistantes avec les autres clans, familles, organisations et traditions ?';

  @override
  String get wizQ16Ronin =>
      '16. Quelles sont vos relations avec votre famille, les clans, les paysans et les autres ?';

  @override
  String get mementoRarity7 => 'Objet souvenir (rareté 7 ou moins)';

  @override
  String get describeThem => 'Décrivez-les';

  @override
  String get wizQ17Parents =>
      '17. Comment vos parents vous décriraient-ils ? (+1 rang de compétence)';

  @override
  String get wizQ17Raised => '18. Qui vous a élevé ? (+1 rang de compétence)';

  @override
  String get wizQ17Bond => '17. Avec qui partagez-vous un lien ?';

  @override
  String get bondLabel => 'Lien';

  @override
  String get wizQ18Ancestry =>
      '18. Quel est votre devoir envers votre famille, et quel ancêtre incarnez-vous ?';

  @override
  String get heritageTable => 'Table d’héritage';

  @override
  String ancestorN(int n) {
    return 'Ancêtre $n';
  }

  @override
  String get rollTooltip => 'Lancer (1d10)';

  @override
  String heritageHeader(String name) {
    return 'Héritage : $name';
  }

  @override
  String grantedLabel(String name) {
    return 'Accordé : $name';
  }

  @override
  String get bonusSkill => 'Compétence bonus';

  @override
  String get traitGained => 'Trait gagné';

  @override
  String get heirloomCategory => 'Catégorie d’héritage';

  @override
  String get lostHeirloomCategory => 'Catégorie d’héritage perdu';

  @override
  String get techniqueGroupLabel => 'Groupe de techniques';

  @override
  String get effectLabel => 'Effet';

  @override
  String get giftLabel => 'Don';

  @override
  String get ringToRaise => 'Anneau à augmenter';

  @override
  String get ringToLower => 'Anneau à réduire';

  @override
  String get qualityYourChoice => 'Qualité (votre choix)';

  @override
  String get qualityGmChoice => 'Qualité (choix du MJ)';

  @override
  String get wizQ19 => '19. Quel est votre nom ?';

  @override
  String get personalNameLabel => 'Nom personnel';

  @override
  String get wizQ20 => '20. Comment votre personnage devrait-il mourir ?';

  @override
  String get answerOptional => 'Réponse (facultatif)';

  @override
  String ringOverflowMsg(int n) {
    return 'Un anneau dépasse le plafond de création de 3. Choisissez $n anneau(x) de remplacement :';
  }

  @override
  String skillOverflowMsg(int n) {
    return 'Une compétence dépasse le plafond de création de 3. Choisissez $n compétence(s) de remplacement :';
  }

  @override
  String replacementRingN(int n) {
    return 'Anneau de remplacement $n';
  }

  @override
  String replacementSkillN(int n) {
    return 'Compétence de remplacement $n';
  }

  @override
  String get readyHeader => 'Prêt';

  @override
  String get finishCreates => 'Terminer crée le personnage et ouvre l’éditeur.';

  @override
  String get ok => 'OK';

  @override
  String get tapToTypeValue => 'Touchez pour saisir une valeur';

  @override
  String get unlockIdentityTooltip =>
      'Déverrouiller nom, famille, ninjō et giri';

  @override
  String get lockIdentityTooltip => 'Verrouiller nom, famille, ninjō et giri';

  @override
  String get changePortraitTooltip =>
      'Touchez pour changer le portrait, appui long pour le retirer';

  @override
  String get addPortraitTooltip => 'Touchez pour ajouter un portrait';

  @override
  String get pdfFatigueStrifeConditions => 'Fatigue, Conflit et États';

  @override
  String get pdfWealthProgress => 'Fortune et progression';

  @override
  String pdfWealthLine(
    int koku,
    int bu,
    int zeni,
    int spent,
    int total,
    int inRank,
  ) {
    return 'Fortune : $koku koku, $bu bu, $zeni zeni    ·    XP : $spent dépensés / $total au total    ·    XP dans le rang : $inRank';
  }

  @override
  String pdfTitlePart(String title, int xp) {
    return '    ·    Titre : $title ($xp XP)';
  }

  @override
  String get pdfTraitsHeader => 'Distinctions et Adversités';

  @override
  String get colAbility => 'Capacité';

  @override
  String get ninjoHeader => 'Ninjō';

  @override
  String get giriHeader => 'Giri';
}
