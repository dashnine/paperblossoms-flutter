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
  String get horSection => 'Heroes of Rokugan';

  @override
  String get horModeTitle => 'Mode Heroes of Rokugan';

  @override
  String get horModeSubtitle =>
      'Les nouveaux personnages suivent les règles de création de la campagne communautaire Heroes of Rokugan 5 (non officiel, sans affiliation avec la campagne ni Edge Studio). heroes-of-rokugan.net';

  @override
  String get wizErrHorRoninRing =>
      'Choisissez l\'augmentation d\'anneau du rōnin.';

  @override
  String get wizErrHorBackground => 'Choisissez un passé de rōnin.';

  @override
  String get wizErrHorBackgroundRing => 'Choisissez l\'anneau du passé.';

  @override
  String wizErrHorBackgroundSkill(int n) {
    return 'Choisissez la compétence $n du passé.';
  }

  @override
  String get wizErrHorService => 'Choisissez qui votre personnage sert.';

  @override
  String get wizErrHorQ5Skill => 'Choisissez une compétence liée à votre giri.';

  @override
  String get wizErrHorQ6Skill =>
      'Choisissez une compétence liée à votre ninjō (différente de la question 5).';

  @override
  String get wizErrHorAccessory => 'Choisissez un accessoire personnel.';

  @override
  String get wizErrHorHeritage => 'Choisissez un résultat d\'héritage.';

  @override
  String get wizErrHorQ19 =>
      'Choisissez la technique supplémentaire de la question 19.';

  @override
  String get wizErrHorOutfitItem =>
      'Choisissez quel objet de l\'équipement porte les qualités Sacré et Interdit.';

  @override
  String horRoninStatsLine(String skill, int status) {
    return 'Rōnin : +1 à un anneau au choix, +1 $skill, Statut $status';
  }

  @override
  String get horRoninRingLabel => 'Augmentation d\'anneau';

  @override
  String get horBackgroundLabel => 'Passé';

  @override
  String horBackgroundStatsLine(int glory, String wealth) {
    return 'Gloire $glory, richesse de départ $wealth';
  }

  @override
  String get horBackgroundRingLabel => 'Anneau du passé';

  @override
  String horBackgroundSkillN(int n) {
    return 'Compétence du passé $n';
  }

  @override
  String get horAllSchoolSkills => '+1 à chaque compétence de départ :';

  @override
  String get horServiceLabel => 'Service';

  @override
  String get horRelatedSkill => 'Compétence liée (+1)';

  @override
  String get horQ7Positive =>
      '+5 de gloire et 1 rang dans une compétence d\'une autre famille de votre clan';

  @override
  String get horQ7Negative =>
      '−5 de gloire et 1 rang dans une compétence qu\'aucune famille de votre clan ne propose';

  @override
  String get horQ8Pos =>
      '+5 d\'honneur et 1 rang dans une compétence traditionnelle de samouraï';

  @override
  String get horQ8Neg =>
      '−3 d\'honneur et 1 rang dans une compétence indigne d\'un samouraï';

  @override
  String get horAccessoryRarity7 =>
      'Accessoire personnel (pas une arme, rareté 7 ou moins)';

  @override
  String get horHeritageLabel => 'Héritage (choisissez-en un)';

  @override
  String get horQ19TechniqueLabel =>
      'Technique supplémentaire (rang d\'école 1)';

  @override
  String horCampaignTitleLine(String title, int stipend) {
    return 'Titre de campagne : $title — Statut fixé à 40, solde de $stipend koku par module.';
  }

  @override
  String get horInstallPack => 'Installer le pack d\'errata';

  @override
  String get horInstallPackSubtitle =>
      'Copie les erratas d\'écoles et les modifications d\'équipement de la campagne dans votre dossier de contenu maison. Ils s\'appliquent à toutes les parties jusqu\'au retrait.';

  @override
  String get horRemovePack => 'Retirer le pack d\'errata';

  @override
  String get horRemovePackSubtitle =>
      'Ne retire que les entrées installées par le pack ; votre propre contenu maison est conservé.';

  @override
  String horPackInstalledMsg(int count) {
    return 'Pack d\'errata HoR installé ($count écoles).';
  }

  @override
  String get horPackRemovedMsg => 'Pack d\'errata HoR retiré.';

  @override
  String get aboutSection => 'À propos';

  @override
  String get aboutApp => 'À propos de Paper Blossoms';

  @override
  String get aboutAppSubtitle => 'Version, crédits et licences.';

  @override
  String get aboutTagline =>
      'Un générateur de personnages pour La Légende des Cinq Anneaux 5e édition.';

  @override
  String get aboutPortNote =>
      'Portage Flutter de l’application de bureau PaperBlossoms d’origine, par le même développeur.';

  @override
  String get aboutLegalese =>
      'Projet de fans, sans affiliation avec Fantasy Flight Games, Edge Studio ou Asmodee. La Légende des Cinq Anneaux et tout le contenu associé sont la propriété de Fantasy Flight Games.';

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

  @override
  String get customSchools => 'Écoles personnalisées';

  @override
  String get customSchoolsSubtitle =>
      'Créez votre propre école avec les règles de Path of Waves (p. 76) et gérez les écoles maison.';

  @override
  String get homebrewFolderIos =>
      'Le dossier paperblossoms est visible dans l’app Fichiers (Sur mon iPhone/iPad). Déposez-y des fichiers JSON nommés comme les données incluses ; ils sont fusionnés au lancement.';

  @override
  String get homebrewFolderAndroid =>
      'Sur Android, le contenu maison se gère dans l’app ; utilisez le créateur d’école et son import/export.';

  @override
  String get sbStep1 => 'Étape 1 : Rôle de l’école';

  @override
  String get sbStep2 => 'Étape 2 : Affiliation et résumé';

  @override
  String get sbStep3 => 'Étape 3 : Capacité d’école';

  @override
  String get sbStep4 => 'Étape 4 : Augmentations d’anneaux';

  @override
  String get sbStep5 => 'Étape 5 : Compétences de départ';

  @override
  String get sbStep6 => 'Étape 6 : Techniques';

  @override
  String get sbStep7 => 'Étape 7 : Cursus et maîtrise';

  @override
  String get sbStep8 => 'Étape 8 : Équipement de départ';

  @override
  String get sbStep9 => 'Étape 9 : Nom et enregistrement';

  @override
  String get sbSaveSchool => 'Enregistrer l’école';

  @override
  String get sbSaveAnyway => 'Enregistrer';

  @override
  String get sbUnnamedSchool => '(école sans nom)';

  @override
  String get sbDiscardTitle => 'Abandonner cette école ?';

  @override
  String get sbDiscardBody => 'Vos réponses seront perdues.';

  @override
  String get sbErrChooseRole => 'Choisissez au moins un rôle.';

  @override
  String get sbErrAbilityName => 'Nommez la capacité d’école.';

  @override
  String get sbErrRings => 'Choisissez les deux augmentations d’anneaux.';

  @override
  String get sbErrNoSkills => 'Choisissez au moins une compétence.';

  @override
  String sbErrSkillPicks(int picks) {
    return 'L’école doit proposer au moins autant de compétences que les $picks qu’un joueur choisit.';
  }

  @override
  String sbWarnSkillCount(int count) {
    return 'La recette du livre pour ce rôle est de $count compétences (table 2–7).';
  }

  @override
  String get sbErrDirectiveAlone =>
      'Un choix « rareté … ou moins » doit être la seule option de sa ligne, sinon la création de personnage l’ignorera silencieusement.';

  @override
  String get sbAffiliationNone => 'Aucune (sans affiliation)';

  @override
  String get sbAffiliationCustom => 'Personnalisée…';

  @override
  String get sbErrCategory => 'Ouvrez au moins une catégorie de techniques.';

  @override
  String get sbErrChoiceSet =>
      'Chaque ligne de choix doit proposer des options, au moins autant que de choix.';

  @override
  String sbErrCurriculumIncomplete(int rank) {
    return 'Remplissez chaque progression des rangs 1 à 5 (le rang $rank a des cases vides).';
  }

  @override
  String get sbErrMasteryName => 'Nommez la capacité de maîtrise.';

  @override
  String get sbErrName => 'Nommez l’école.';

  @override
  String get sbOverrideBundledTitle => 'Remplacer l’école officielle ?';

  @override
  String sbOverrideBundledBody(String name) {
    return '« $name » correspond à une école officielle ; votre version maison la remplacera jusqu’à sa suppression.';
  }

  @override
  String get sbOverwriteHomebrewTitle => 'Écraser l’école maison ?';

  @override
  String sbOverwriteHomebrewBody(String name) {
    return 'Une école maison nommée « $name » existe déjà.';
  }

  @override
  String get sbRolesQuestion => 'Quel(s) rôle(s) l’école incarne-t-elle ?';

  @override
  String get sbRolesHelp =>
      'Choisissez un ou deux rôles (jusqu’à trois pour une école complexe). Le rôle principal détermine les tables suggérées qui préremplissent les étapes suivantes.';

  @override
  String get sbWarnThreeRoles => 'Le livre recommande au plus deux rôles.';

  @override
  String get sbRolesOrder => 'Ordre des rôles';

  @override
  String get sbPrimaryRole => 'Rôle principal';

  @override
  String get sbMakePrimary => 'Rendre principal';

  @override
  String get sbAffiliationQuestion =>
      'À quel clan ou faction l’école est-elle associée ?';

  @override
  String get sbCustomAffiliationLabel => 'Affiliation personnalisée';

  @override
  String get sbNoteRonin =>
      'Une école Rōnin apparaît pour les personnages rōnin et paysans dans l’assistant Nouveau personnage.';

  @override
  String get sbNoteNoAffiliation =>
      'Une école sans affiliation n’est accessible que via la case « toute école » de l’assistant Nouveau personnage.';

  @override
  String get sbNoteCustomAffiliation =>
      'Une faction personnalisée ne correspond à aucun clan ni région : l’école n’est accessible que via la case « toute école » de l’assistant Nouveau personnage.';

  @override
  String get sbSummaryHeader => 'Résumé de l’école';

  @override
  String get sbSummaryLabel => 'Résumé (le livre demande 3 à 5 phrases)';

  @override
  String get sbSummaryShortLabel =>
      'Résumé en une ligne (affiché sous l’école dans les listes)';

  @override
  String get sbWarnNoSummary =>
      'Pas encore de résumé — le livre demande un argumentaire de 3 à 5 phrases.';

  @override
  String get sbAbilityQuestion => 'Quelle est la capacité d’école ?';

  @override
  String get sbAbilityHelp =>
      'La capacité doit évoluer avec le rang d’école. Partez d’un modèle générique (table 2–4) ou inventez la vôtre ; le texte des règles est stocké comme votre propre description, comme dans l’éditeur de descriptions.';

  @override
  String get sbAbilityTemplate => 'Partir d’un modèle (table 2–4)';

  @override
  String sbSeeBook(String page) {
    return 'Texte du modèle de Path of Waves p. $page inséré ci-dessous — modifiez-le librement.';
  }

  @override
  String get sbAbilityName => 'Nom de la capacité d’école';

  @override
  String get sbAbilityText => 'Texte des règles de la capacité';

  @override
  String get sbWarnNoAbilityText =>
      'Aucun texte de règles saisi ; vous pourrez l’ajouter plus tard dans l’éditeur de descriptions.';

  @override
  String get sbShortDescLabel => 'Description courte (une ligne)';

  @override
  String get sbRingsQuestion => 'Quels deux anneaux l’école augmente-t-elle ?';

  @override
  String sbHintFirstRing(String role, String rings) {
    return 'Les écoles $role prennent généralement leur première augmentation en $rings (table 2–5).';
  }

  @override
  String get sbHintShugenjaRing =>
      'Les écoles de shugenja augmentent généralement l’élément auquel l’école est liée (table 2–5).';

  @override
  String get sbRing1 => 'Première augmentation d’anneau';

  @override
  String get sbRing2 => 'Seconde augmentation d’anneau';

  @override
  String get sbWarnDoubledRing =>
      'Deux augmentations sur le même anneau, c’est rare mais permis (les écoles Isawa Tensai le font).';

  @override
  String sbWarnRingsSuggestion(String role) {
    return 'Cela diffère de la suggestion du livre pour une école $role. C’est permis — beaucoup d’écoles sortent du moule.';
  }

  @override
  String get sbSecondRingHintsTitle =>
      'Second anneau selon ce qui fait la renommée de l’école (table 2–6)';

  @override
  String get sbRingTraitAir => 'Précision, grâce ou bonnes manières';

  @override
  String get sbRingTraitEarth => 'Patience, tradition ou résilience';

  @override
  String get sbRingTraitFire => 'Inventivité, férocité ou vitesse';

  @override
  String get sbRingTraitVoid => 'Philosophie, abnégation ou intuition';

  @override
  String get sbRingTraitWater => 'Adaptabilité, souplesse ou vigilance';

  @override
  String sbSkillsQuestion(int count) {
    return 'Choisissez les $count compétences offertes par l’école';
  }

  @override
  String sbSkillsProgress(int selected, int count, int picks) {
    return '$selected sur $count sélectionnées — les joueurs en choisiront $picks à la création du personnage (table 2–7).';
  }

  @override
  String get sbAccessQuestion => 'Accès libre aux techniques';

  @override
  String get sbAccessHelp =>
      'La plupart des écoles ont Rituels plus deux parmi Katas, Kihōs, Invocations et Shūjis. Dépliez une catégorie pour n’accorder que certaines sous-catégories (accès limité).';

  @override
  String get sbWarnForbidden =>
      'Le ninjutsu et le mahō sont des arts interdits — le livre ne les accorde que dans des cas uniques.';

  @override
  String get sbWarnManyCategories =>
      'Les écoles typiques ouvrent Rituels plus deux autres catégories.';

  @override
  String get sbWarnShugenjaInvocations =>
      'Les écoles de shugenja ont normalement un accès libre aux Invocations.';

  @override
  String get sbStartingTechniques => 'Techniques de départ';

  @override
  String sbStartingTechniquesHelp(int count, String role) {
    return 'Une école $role accorde $count techniques de départ (table 2–8). Chaque ligne peut offrir un choix, comme « 1 de ces 2 katas ».';
  }

  @override
  String get sbShowAllTechniques =>
      'Afficher toutes les techniques (pas seulement rang 1 dans l’accès)';

  @override
  String get sbAddRow => 'Ajouter une ligne';

  @override
  String get sbWarnCommune =>
      'Les écoles de shugenja commencent avec Communion avec les esprits (table 2–8).';

  @override
  String sbWarnStartingTechRank(String name) {
    return '$name dépasse le rang 1 ou sort de l’accès libre de l’école — acceptable si c’est voulu (le livre le permet).';
  }

  @override
  String get sbSlotSkillGroup => 'Groupe de compétences';

  @override
  String get sbSlotSkill => 'Compétence';

  @override
  String get sbSlotTechniqueGroup => 'Groupe de techniques';

  @override
  String get sbSlotTechnique => 'Technique';

  @override
  String get sbChooseTechnique => 'Choisir une technique…';

  @override
  String sbCopyPrevRank(int rank) {
    return 'Copier depuis le rang $rank';
  }

  @override
  String get sbClearRank => 'Vider le rang';

  @override
  String get sbMaxTechRank => 'Rang de technique max :';

  @override
  String get sbMaxTechRankDefault => 'Jusqu’au rang d’école';

  @override
  String get sbSpecialAccessChip => 'Accès spécial';

  @override
  String get sbSpecialAccessWhy =>
      'Les élèves peuvent prendre ceci même au-dessus du rang du cursus ou hors de l’accès libre de l’école. Déterminé automatiquement.';

  @override
  String get sbWarnSkillInGroup =>
      'Cette compétence est déjà couverte par le groupe de ce rang — le livre suggère des compétences extérieures au groupe.';

  @override
  String get sbWarnRankShape =>
      'Ce rang s’écarte du schéma du livre (1 groupe de compétences, 3 compétences, 1 groupe de techniques, 2 techniques). Permis, mais avec parcimonie selon le livre.';

  @override
  String get sbMastery => 'Maîtrise';

  @override
  String get sbMasteryQuestion => 'Quelle est la capacité de maîtrise ?';

  @override
  String get sbMasteryHelp =>
      'Le rang 6 ne contient que la capacité de maîtrise — quelque chose de puissant et d’impressionnant. Utilisez un modèle (table 2–10) ou inventez ; les capacités purement narratives gagnent à être limitées à une fois par session.';

  @override
  String get sbMasteryTemplate => 'Partir d’un modèle (table 2–10)';

  @override
  String get sbMasteryName => 'Nom de la capacité de maîtrise';

  @override
  String get sbMasteryText => 'Texte des règles de la maîtrise';

  @override
  String get sbOutfitQuestion => 'Équipement de départ';

  @override
  String get sbOutfitHelp =>
      'La table 2–11 suggère un équipement pour le rôle principal ; il est prérempli ici et librement modifiable. Les lignes comme « One Weapon of Rarity 6 or Lower » deviennent des sélecteurs à la création du personnage.';

  @override
  String get sbWarnNoOutfit =>
      'Aucune ligne d’équipement — les personnages de cette école commenceront sans équipement.';

  @override
  String get sbNameQuestion => 'Nommez l’école';

  @override
  String get sbNameLabel => 'Nom de l’école';

  @override
  String get sbHonorLabel =>
      'Honneur de départ (suggéré pour le rôle ; le livre ne le précise pas)';

  @override
  String get sbRefBookLabel => 'Livre de référence';

  @override
  String get sbRefPageLabel => 'Page de référence';

  @override
  String get sbReviewTitle => 'Récapitulatif';

  @override
  String get sbReviewRoles => 'Rôles';

  @override
  String get sbReviewRings => 'Anneaux';

  @override
  String get sbReviewSkills => 'Compétences / choix';

  @override
  String get sbReviewAccess => 'Accès aux techniques';

  @override
  String get sbReviewCurriculum => 'Progressions du cursus';

  @override
  String sbChooseOf(int size) {
    return 'Choisir $size parmi :';
  }

  @override
  String get sbAddOption => 'Ajouter une option';

  @override
  String get sbRemoveRow => 'Supprimer la ligne';

  @override
  String get sbBuildNew => 'Créer une nouvelle école';

  @override
  String get sbBuildNewSubtitle =>
      'Un assistant en neuf étapes suivant Path of Waves pp. 76–84.';

  @override
  String get sbEmptyHint =>
      'Aucune école maison pour l’instant.\nCréez-en une, ou déposez un schools.json dans le dossier de contenu maison.';

  @override
  String sbSavedSnack(String name) {
    return '« $name » enregistrée dans homebrew/schools.json — elle apparaît maintenant dans l’assistant Nouveau personnage.';
  }

  @override
  String sbDeleteTitle(String name) {
    return 'Supprimer $name ?';
  }

  @override
  String get sbDeleteBody =>
      'Les personnages existants gardent l’école par son nom mais perdent son cursus et ses capacités.';

  @override
  String get sbDeleteAlsoText =>
      'Supprimer aussi ses textes de règles (résumé, capacité d’école, capacité de maîtrise)';

  @override
  String get sbDeleteAll => 'Supprimer toutes les écoles maison';

  @override
  String get sbDeleteAllBody =>
      'Cela supprime toutes les écoles de homebrew/schools.json.';

  @override
  String get sbImportSchools => 'Importer des écoles…';

  @override
  String get sbExportSchools => 'Exporter les écoles…';

  @override
  String sbImportedSchools(int count) {
    return '$count écoles importées';
  }

  @override
  String sbExportedSchools(int count) {
    return '$count écoles exportées';
  }

  @override
  String get sbNoSchoolsToExport => 'Aucune école maison à exporter.';

  @override
  String get sbCouldNotReadSchoolsFile =>
      'Ce fichier n’a pas pu être lu comme un tableau JSON d’écoles.';
}
