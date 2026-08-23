
--
-- Base de données : `iupflymgus`
--

-- --------------------------------------------------------

--
-- Structure de la table `MW_Armee`
--

CREATE TABLE `MW_Armee` (
  `idAr` int(11) NOT NULL,
  `nomAr` varchar(32) NOT NULL,
  `short` varchar(3) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Déchargement des données de la table `MW_Armee`
--

INSERT INTO `MW_Armee` (`idAr`, `nomAr`, `short`) VALUES
(1, 'Beast Herds', 'BH'),
(2, 'Daemon Legion', 'DL'),
(3, 'Dread Elves', 'DE'),
(4, 'Dwarven Holds', 'DH'),
(5, 'Empire of Sonnstahl', 'EoS'),
(6, 'Highborn Elves', 'HE'),
(7, 'Infernal Dwarves', 'ID'),
(8, 'Kingdom of Equitaine', 'KoE'),
(9, 'Ogre Khans', 'OK'),
(10, 'Orcs and Goblins', 'O&G'),
(11, 'Saurian Ancients', 'SA'),
(12, 'Sylvan Elves', 'SE'),
(13, 'Undying Dynasties', 'UD'),
(14, 'Vampire Covenant', 'VC'),
(15, 'Vermin Swarm', 'VS'),
(16, 'Warriors of the Dark Gods', 'WDG');

-- --------------------------------------------------------

--
-- Structure de la table `MW_Choix`
--

CREATE TABLE `MW_Choix` (
  `idCh` int(11) NOT NULL,
  `libelle` varchar(16) NOT NULL,
  `short` varchar(5) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Déchargement des données de la table `MW_Choix`
--

INSERT INTO `MW_Choix` (`idCh`, `libelle`, `short`) VALUES
(1, 'Dicy', 'Dicy'),
(2, 'Moins de 5', '5-'),
(3, 'Entre 5 et 7', '5-7'),
(4, 'Entre 8 et 12', '8-12'),
(5, 'Entre 13 et 14', '13-14'),
(6, 'Plus de 15', '15+');

-- --------------------------------------------------------

--
-- Structure de la table `MW_Estim`
--

CREATE TABLE `MW_Estim` (
  `idJo` int(11) NOT NULL,
  `idTe` int(11) NOT NULL,
  `idAr` int(11) NOT NULL,
  `idCh` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Déchargement des données de la table `MW_Estim`
--

INSERT INTO `MW_Estim` (`idJo`, `idTe`, `idAr`, `idCh`) VALUES
(1, 9, 1, 1),
(1, 9, 16, 1),
(4, 9, 1, 1),
(4, 9, 11, 1),
(1, 9, 5, 2),
(1, 9, 12, 3),
(4, 9, 4, 3),
(4, 9, 16, 3),
(1, 9, 13, 4),
(4, 9, 13, 4),
(1, 9, 4, 5),
(1, 9, 11, 5),
(4, 9, 5, 5),
(1, 9, 6, 6),
(4, 9, 6, 6),
(4, 9, 12, 6);

-- --------------------------------------------------------

--
-- Structure de la table `MW_Joueur`
--

CREATE TABLE `MW_Joueur` (
  `idJo` int(11) NOT NULL,
  `nomJo` varchar(16) NOT NULL,
  `short` varchar(6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Déchargement des données de la table `MW_Joueur`
--

INSERT INTO `MW_Joueur` (`idJo`, `nomJo`, `short`) VALUES
(1, 'Augustin', 'Gus'),
(2, 'Fabien', 'Fabou'),
(3, 'Mathieu', 'Mat'),
(4, 'Pierre', 'Pierre'),
(5, 'Yohann', 'Touba'),
(6, 'Romain', 'Dom'),
(7, 'Aurélien', 'Izno'),
(8, 'Maxime', 'Max'),
(9, 'Arny', 'Arny');

-- --------------------------------------------------------

--
-- Structure de la table `MW_MetaAdv`
--

CREATE TABLE `MW_MetaAdv` (
  `idTe` int(11) NOT NULL,
  `idAr` int(11) NOT NULL,
  `nomJoAdv` varchar(48) DEFAULT NULL,
  `listeAdv` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Déchargement des données de la table `MW_MetaAdv`
--

INSERT INTO `MW_MetaAdv` (`idTe`, `idAr`, `nomJoAdv`, `listeAdv`) VALUES
(9, 1, 'random', '600 - Minotaur Warlord, General, Light Armour (Aaghor\'s Affliction), Great Weapon (Cleansing Light)\r\n470 - Minotaur Chieftain, Greater Totem Bearer, Shield (Willow\'s Ward), Battle Standard Bearer, Heavy Armour (Alchemist\'s Alloy), Beast Axe, Talisman of Shielding, Dragonfire Gem\r\n415 - Soothsayer, Wizard Master, Shamanism\r\n315 - Centaur Chieftain, Throwing Weapons, Light Armour (Essence of Mithril), Paired Weapons (Twin Hungers), Dragon Staff\r\n425 - 50 Mongrel Herd, Spear, Standard Bearer (Banner of the Wild Herd), Musician, Champion\r\n284 - 16 Wildhorn Herd, Paired Weapons and Throwing Weapons, Ambush, Standard Bearer (Banner of Discipline), Musician, Champion (Totem Bearer (Blooded Horn Totem))\r\n104 - 8 Feral Hounds\r\n90 - 10 Mongrel Raiders\r\n668 - 7 Minotaurs, Shield, Standard Bearer (Flaming Standard), Musician, Champion (Totem Bearer (Gnarled Hide Totem))\r\n433 - 14 Centaurs, Great Weapon, Throwing Weapons, Standard Bearer, Musician, Champion (Totem Bearer (Gnarled Hide Totem))\r\n414 - 11 Centaurs, Paired Weapons, Throwing Weapons, Standard Bearer (Banner of Discipline), Musician, Champion (Totem Bearer (Black Wing Totem))\r\n195 - 10 Longhorn Herd, Ambush, Halberd, Musician, Champion (Totem Bearer (Blooded Horn Totem))\r\n85 - Razortusk Herd\r\n4498'),
(9, 4, 'oszf', '160 - Engineer, Forge Repeater, Rune of Storms\r\n145 - Engineer, General, Forge Repeater\r\n250 - 10 Greybeards, Shield, Throwing Weapons, Musician, Champion\r\n240 - 10 Greybeards, Shield, Throwing Weapons, Musician\r\n230 - 10 Greybeards, Great Weapon, Throwing Weapons, Musician\r\n230 - 10 Greybeards, Great Weapon, Throwing Weapons, Musician\r\n175 - 10 Clan Warriors, Throwing Weapons, Vanguard, Musician\r\n295 - Grudge Buster\r\n295 - Grudge Buster\r\n174 - 8 Rangers, Crag Warden, Crossbow\r\n168 - 8 Rangers, Crossbow, Musician\r\n120 - Vengeance Seeker\r\n120 - Vengeance Seeker\r\n105 - 5 Seekers\r\n220 - Steam Copters, Shrapnel Bombs\r\n185 - Steam Copters, Shrapnel Grenades\r\n185 - Steam Copters, Shrapnel Grenades\r\n210 - 10 Forge Wardens, Musician\r\n210 - 10 Forge Wardens, Musician\r\n210 - 10 Forge Wardens, Musician\r\n325 - Field Artillery, Organ Gun (Rune Crafted)\r\n245 - Field Artillery, Organ Gun\r\n4497'),
(9, 5, 'yann', '535 - Prelate, Altar of Battle, Shield, Plate Armour (Alchemist\'s Alloy), Lucky Charm\r\n475 - Marshal, General, Great Griffon, Shield, Lance, Ghostly Guard, Winter Cloak, Great Tactician\r\n190 - Marshal, Battle Standard Bearer, Shield, Blacksteel\r\n455 - Wizard, Arcane Engine (Arcane Shield), Wizard Adept, Alchemy, Light Armour, Book of Arcane Mastery\r\n446 - 47 Heavy Infantry, Spear, Parent Unit, Standard Bearer (Flaming Standard), Musician, Champion\r\n170 - 20 Heavy Infantry, Support Unit, Standard Bearer, Musician, Champion\r\n262 - 18 Light Infantry, Crossbow, Musician\r\n248 - 17 Light Infantry, Crossbow, Musician\r\n444 - 27 Imperial Guard, Shield, Standard Bearer (Flaming Standard), Musician, Champion\r\n295 - 3 Knights of the Sun Griffon, Halberd, Standard Bearer, Musician\r\n295 - 3 Knights of the Sun Griffon, Halberd, Standard Bearer, Musician\r\n235 - Artillery, Cannon\r\n450 - Steam Tank\r\n4500'),
(9, 6, 'os f', '745 - High Prince, General, Griffon, Shield, Dragonforged Armour (Daemon\'s Bane), Lance (Nova Flare), Diadem of Protection, Dragon Staff\r\n415 - Commander, Longbow (Elu\'s Heartwood), Battle Standard Bearer, Light Armour, Master of Canreig Tower\r\n280 - Mage, Wizard Adept, Pyromancy, Magical Heirloom\r\n366 - 24 Citizen Archers, Musician, Champion\r\n366 - 24 Citizen Archers, Musician, Champion\r\n198 - 12 Citizen Archers, Musician, Champion\r\n195 - 5 Elein Reavers, Bow, Champion\r\n405 - Phoenix, Fire Phoenix, Warden\'s Bond\r\n390 - Phoenix, Frost Phoenix, Warden\'s Bond\r\n280 - 15 Flame Wardens, Musician, Champion\r\n280 - 15 Flame Wardens, Musician, Champion\r\n220 - Sky Sloop\r\n220 - Sky Sloop\r\n140 - 5 Grey Watchers, Shield\r\n4500'),
(9, 11, 'tarbak', '770 - Tegu Veteran, Alpha Carnosaur, Great Weapon (Cleansing Light), Starfall Lodestone, Obsidian Rock\r\n615 - Anurarch Archmage, Druidism, Stampede Resonator Crystal, Forbidden Mastery, Mystifying Mastery\r\n485 - 26 Tegu Warriors, Spear, Champion (Enclave Wizard), Standard Bearer (Banner of the Relentless Company)\r\n308 - 38 Skink Warriors, Spear and Shield, Champion, Standard Bearer (Legion Standard)\r\n170 - 12 Skink Hunters, Poisoned Javelin\r\n170 - 12 Skink Hunters, Poisoned Javelin\r\n597 - 24 Tegu Guards, Champion, Standard Bearer (Koru Stone)\r\n280 - Thyroscutus Herd, Great Protector, Venomous Fortress\r\n215 - 3 Pteradon Riders, Poisoned Javelin, Marking Lure\r\n560 - Titanopod, Suncatcher Crystal\r\n330 - 2 Stygiosaur Pack, Champion with Enclave Wizard\r\n4500'),
(9, 12, 'oszf', '735 - Treefather Ancient, General, Wizard Master, Druidism\r\n530 - Forest Prince, Eagle King, Light Armour (Destiny\'s Call), Sylvan Blades (Oaken Might), Glyph of Amryl, Dragon Staff\r\n300 - Thicket Shepherd, Battle Standard Bearer, Oaken Crown\r\n215 - Dryad Ancient, Wizard Adept, Divination\r\n294 - 13 Sylvan Archers, Musician\r\n276 - 12 Sylvan Archers, Musician\r\n276 - 12 Sylvan Archers, Musician\r\n280 - 16 Dryads, Champion\r\n435 - Treefather\r\n435 - Treefather\r\n369 - 18 Forest Rangers, Standard Bearer (Aether Icon), Musician, Champion\r\n355 - 4 Thicket Beasts, Champion\r\n4500'),
(9, 13, 'osef', '440 - Pharaoh, Skeletal Horse, Light Armour (Destiny\'s Call), Great Weapon (Godslayer), Blessed Wrappings\r\n305 - Death Cult Hierarch, Wizard Adept, Divination, Binding Scroll, Book of the Dead\r\n205 - Death Cult Hierarch, General, Wizard Apprentice, Evocation, Book of Arcane Mastery, Crown of Autocracy, Hierophant\r\n265 - Tomb Harbinger, Shield, Battle Standard Bearer, Light Armour (Essence of Mithril), Death Mask of Teput\r\n417 - 46 Skeletons, Spear, Standard Bearer (Banner of the Relentless Company), Musician, Champion\r\n200 - 20 Skeletons, Standard Bearer (Banner of the Entombed)\r\n200 - 20 Skeletons, Standard Bearer (Banner of the Entombed)\r\n165 - 20 Skeletons, Musician, Champion\r\n145 - 5 Skeleton Scouts\r\n611 - 32 Necropolis Guard, Paired Weapons, Standard Bearer (Banner of the Relentless Company), Musician, Champion\r\n295 - 3 Tomb Cataphracts, Musician\r\n425 - Battle Sphinx\r\n425 - Battle Sphinx\r\n400 - Dread Sphinx\r\n4498'),
(9, 16, 'dicon', '780 - Exalted Herald, General\r\n780 - Exalted Herald\r\n350 - Sorcerer, Black Steed, Wizard Adept, Alchemy, Light Armour, Binding Scroll, Veilgate Orb\r\n295 - 15 Fallen\r\n235 - 11 Fallen\r\n251 - 9 Barbarian Horsemen, Light Lance, Shield, Musician\r\n120 - 8 Warhounds\r\n615 - 4 Chosen Knights, Lust, Standard Bearer (Wasteland Torch), Musician, Champion\r\n540 - 8 Chosen, Paired Weapons, Great Weapon, Halberd, Greed, Standard Bearer (Flaming Standard), Musician, Champion\r\n532 - 4 Feldraks, Great Weapon, Standard Bearer (Banner of Discipline), Musician\r\n4498');

-- --------------------------------------------------------

--
-- Structure de la table `MW_Team`
--

CREATE TABLE `MW_Team` (
  `idTe` int(11) NOT NULL,
  `nomTe` varchar(48) NOT NULL,
  `idTo` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Déchargement des données de la table `MW_Team`
--

INSERT INTO `MW_Team` (`idTe`, `nomTe`, `idTo`) VALUES
(9, 'trc2', 12);

-- --------------------------------------------------------

--
-- Structure de la table `MW_Tournoi`
--

CREATE TABLE `MW_Tournoi` (
  `idTo` int(11) NOT NULL,
  `nomTo` varchar(48) NOT NULL,
  `lienNR` varchar(128) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Déchargement des données de la table `MW_Tournoi`
--

INSERT INTO `MW_Tournoi` (`idTo`, `nomTo`, `lienNR`) VALUES
(12, 'training trc2', '');

-- --------------------------------------------------------

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `MW_Armee`
--
ALTER TABLE `MW_Armee`
  ADD PRIMARY KEY (`idAr`);

--
-- Index pour la table `MW_Choix`
--
ALTER TABLE `MW_Choix`
  ADD PRIMARY KEY (`idCh`);

--
-- Index pour la table `MW_Estim`
--
ALTER TABLE `MW_Estim`
  ADD PRIMARY KEY (`idJo`,`idTe`,`idAr`),
  ADD KEY `idJo` (`idJo`),
  ADD KEY `idTe` (`idTe`),
  ADD KEY `idAr` (`idAr`),
  ADD KEY `idCh` (`idCh`);

--
-- Index pour la table `MW_Joueur`
--
ALTER TABLE `MW_Joueur`
  ADD PRIMARY KEY (`idJo`);

--
-- Index pour la table `MW_MetaAdv`
--
ALTER TABLE `MW_MetaAdv`
  ADD PRIMARY KEY (`idTe`,`idAr`),
  ADD KEY `idTe` (`idTe`),
  ADD KEY `idAr` (`idAr`);

--
-- Index pour la table `MW_Team`
--
ALTER TABLE `MW_Team`
  ADD PRIMARY KEY (`idTe`),
  ADD KEY `idTo` (`idTo`);

--
-- Index pour la table `MW_Tournoi`
--
ALTER TABLE `MW_Tournoi`
  ADD PRIMARY KEY (`idTo`);


--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `MW_Armee`
--
ALTER TABLE `MW_Armee`
  MODIFY `idAr` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT pour la table `MW_Choix`
--
ALTER TABLE `MW_Choix`
  MODIFY `idCh` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT pour la table `MW_Joueur`
--
ALTER TABLE `MW_Joueur`
  MODIFY `idJo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT pour la table `MW_Team`
--
ALTER TABLE `MW_Team`
  MODIFY `idTe` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT pour la table `MW_Tournoi`
--
ALTER TABLE `MW_Tournoi`
  MODIFY `idTo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `MW_Estim`
--
ALTER TABLE `MW_Estim`
  ADD CONSTRAINT `MW_Estim_ibfk_1` FOREIGN KEY (`idJo`) REFERENCES `MW_Joueur` (`idJo`),
  ADD CONSTRAINT `MW_Estim_ibfk_2` FOREIGN KEY (`idTe`) REFERENCES `MW_Team` (`idTe`),
  ADD CONSTRAINT `MW_Estim_ibfk_3` FOREIGN KEY (`idAr`) REFERENCES `MW_Armee` (`idAr`),
  ADD CONSTRAINT `MW_Estim_ibfk_4` FOREIGN KEY (`idCh`) REFERENCES `MW_Choix` (`idCh`);

--
-- Contraintes pour la table `MW_MetaAdv`
--
ALTER TABLE `MW_MetaAdv`
  ADD CONSTRAINT `MW_MetaAdv_ibfk_1` FOREIGN KEY (`idTe`) REFERENCES `MW_Team` (`idTe`),
  ADD CONSTRAINT `MW_MetaAdv_ibfk_2` FOREIGN KEY (`idAr`) REFERENCES `MW_Armee` (`idAr`),
  ADD CONSTRAINT `MW_MetaAdv_ibfk_3` FOREIGN KEY (`idTe`) REFERENCES `MW_Team` (`idTe`),
  ADD CONSTRAINT `MW_MetaAdv_ibfk_4` FOREIGN KEY (`idAr`) REFERENCES `MW_Armee` (`idAr`);

--
-- Contraintes pour la table `MW_Team`
--
ALTER TABLE `MW_Team`
  ADD CONSTRAINT `MW_Team_ibfk_1` FOREIGN KEY (`idTo`) REFERENCES `MW_Tournoi` (`idTo`),
  ADD CONSTRAINT `MW_Team_ibfk_2` FOREIGN KEY (`idTo`) REFERENCES `MW_Tournoi` (`idTo`);
