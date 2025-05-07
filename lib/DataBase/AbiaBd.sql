-- -----------------------------------------------------
-- Script MySQL complet pour l'application de gestion de poubelles intelligentes
-- -----------------------------------------------------

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

-- -----------------------------------------------------
-- Schéma de base de données
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `db_abia` 
  DEFAULT CHARACTER SET utf8mb4 
  COLLATE utf8mb4_unicode_ci;
USE `db_abia`;

-- -----------------------------------------------------
-- Tables pour les énumérations
-- -----------------------------------------------------

-- TypeUtilisateur
CREATE TABLE IF NOT EXISTS `type_utilisateur` (
  `id` TINYINT NOT NULL AUTO_INCREMENT,
  `nom` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `nom_UNIQUE` (`nom` ASC)
) ENGINE = InnoDB;

INSERT IGNORE INTO `type_utilisateur` (`nom`) VALUES 
  ('ADMIN'), 
  ('AGENT_COLLECTE'), 
  ('UTILISATEUR_STANDARD');

-- StatutPoubelle
CREATE TABLE IF NOT EXISTS `statut_poubelle` (
  `id` TINYINT NOT NULL AUTO_INCREMENT,
  `nom` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `nom_UNIQUE` (`nom` ASC)
) ENGINE = InnoDB;

INSERT IGNORE INTO `statut_poubelle` (`nom`) VALUES 
  ('VIDE'), 
  ('A_MOITIE_PLEINE'), 
  ('PLEINE');

-- StatutCollecte
CREATE TABLE IF NOT EXISTS `statut_collecte` (
  `id` TINYINT NOT NULL AUTO_INCREMENT,
  `nom` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `nom_UNIQUE` (`nom` ASC)
) ENGINE = InnoDB;

INSERT IGNORE INTO `statut_collecte` (`nom`) VALUES 
  ('PLANIFIEE'), 
  ('EN_COURS'), 
  ('TERMINEE'), 
  ('ANNULEE');

-- TypeNotification
CREATE TABLE IF NOT EXISTS `type_notification` (
  `id` TINYINT NOT NULL AUTO_INCREMENT,
  `nom` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `nom_UNIQUE` (`nom` ASC)
) ENGINE = InnoDB;

INSERT IGNORE INTO `type_notification` (`nom`) VALUES 
  ('ALERTE_REMPLISSAGE'), 
  ('DYSFONCTIONNEMENT'), 
  ('RAPPEL_COLLECTE'), 
  ('SYSTEME');

-- TypeEvenementHistorique
CREATE TABLE IF NOT EXISTS `type_evenement_historique` (
  `id` TINYINT NOT NULL AUTO_INCREMENT,
  `nom` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `nom_UNIQUE` (`nom` ASC)
) ENGINE = InnoDB;

INSERT IGNORE INTO `type_evenement_historique` (`nom`) VALUES 
  ('OUVERTURE'), 
  ('FERMETURE'), 
  ('REMPLISSAGE'), 
  ('VIDAGE'), 
  ('MAINTENANCE');

-- TypeStatistique
CREATE TABLE IF NOT EXISTS `type_statistique` (
  `id` TINYINT NOT NULL AUTO_INCREMENT,
  `nom` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `nom_UNIQUE` (`nom` ASC)
) ENGINE = InnoDB;

INSERT IGNORE INTO `type_statistique` (`nom`) VALUES 
  ('REMPLISSAGE_MOYEN'), 
  ('FREQUENCE_COLLECTE'), 
  ('NOMBRE_POUBELLE_PLEINE');

-- PeriodeStatistique
CREATE TABLE IF NOT EXISTS `periode_statistique` (
  `id` TINYINT NOT NULL AUTO_INCREMENT,
  `nom` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `nom_UNIQUE` (`nom` ASC)
) ENGINE = InnoDB;

INSERT IGNORE INTO `periode_statistique` (`nom`) VALUES 
  ('JOUR'), 
  ('SEMAINE'), 
  ('MOIS'), 
  ('ANNEE');

-- TypeBadge
CREATE TABLE IF NOT EXISTS `type_badge` (
  `id` TINYINT NOT NULL AUTO_INCREMENT,
  `nom` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `nom_UNIQUE` (`nom` ASC)
) ENGINE = InnoDB;

INSERT IGNORE INTO `type_badge` (`nom`) VALUES 
  ('ADMIN'), 
  ('AGENT_COLLECTE');

-- -----------------------------------------------------
-- Table des utilisateurs
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `utilisateur` (
  `id` VARCHAR(36) NOT NULL,
  `nom` VARCHAR(100) NOT NULL,
  `prenom` VARCHAR(100) NOT NULL,
  `email` VARCHAR(255) NOT NULL,
  `mot_de_passe` VARCHAR(255) NOT NULL,
  `type_utilisateur_id` TINYINT NOT NULL,
  `date_inscription` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `email_UNIQUE` (`email` ASC),
  INDEX `fk_utilisateur_type_utilisateur_idx` (`type_utilisateur_id`),
  CONSTRAINT `fk_utilisateur_type_utilisateur`
    FOREIGN KEY (`type_utilisateur_id`)
    REFERENCES `type_utilisateur` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table des poubelles
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `poubelle` (
  `id` VARCHAR(36) NOT NULL,
  `nom` VARCHAR(100) NOT NULL,
  `capacite_totale` FLOAT NOT NULL,
  `niveau_remplissage` FLOAT NOT NULL DEFAULT 0,
  `statut_id` TINYINT NOT NULL,
  `latitude` DECIMAL(10,8) NOT NULL,
  `longitude` DECIMAL(11,8) NOT NULL,
  `adresse` VARCHAR(255) NOT NULL,
  `date_derniere_collecte` DATETIME NULL,
  `seuil_alerte` FLOAT NOT NULL DEFAULT 0.9,
  `verrouille` BOOLEAN NOT NULL DEFAULT TRUE,
  `alerte` BOOLEAN NOT NULL DEFAULT FALSE,
  PRIMARY KEY (`id`),
  INDEX `fk_poubelle_statut_idx` (`statut_id`),
  CONSTRAINT `fk_poubelle_statut`
    FOREIGN KEY (`statut_id`)
    REFERENCES `statut_poubelle` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table des routes
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `route` (
  `id` VARCHAR(36) NOT NULL,
  `nom` VARCHAR(100) NOT NULL,
  `description` TEXT NULL,
  `distance_estimee` FLOAT NULL,
  `duree_estimee` INT NULL,
  `nombre_de_poubelles` INT NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table des poubelles dans les routes
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `poubelle_dans_route` (
  `poubelle_id` VARCHAR(36) NOT NULL,
  `route_id` VARCHAR(36) NOT NULL,
  `ordre` INT NOT NULL,
  `temps_estime` INT NULL,
  PRIMARY KEY (`poubelle_id`, `route_id`),
  INDEX `fk_poubelle_dans_route_route_idx` (`route_id`),
  CONSTRAINT `fk_poubelle_dans_route_poubelle`
    FOREIGN KEY (`poubelle_id`)
    REFERENCES `poubelle` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_poubelle_dans_route_route`
    FOREIGN KEY (`route_id`)
    REFERENCES `route` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table des collectes planifiées
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `collecte_planifiee` (
  `id` VARCHAR(36) NOT NULL,
  `date` DATE NOT NULL,
  `heure_estimee` TIME NOT NULL,
  `statut_id` TINYINT NOT NULL,
  `agent_collecte_id` VARCHAR(36) NULL,
  `route_id` VARCHAR(36) NOT NULL,
  `commentaires` TEXT NULL,
  `date_creation` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `fk_collecte_statut_idx` (`statut_id`),
  INDEX `fk_collecte_agent_idx` (`agent_collecte_id`),
  INDEX `fk_collecte_route_idx` (`route_id`),
  CONSTRAINT `fk_collecte_statut`
    FOREIGN KEY (`statut_id`)
    REFERENCES `statut_collecte` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_collecte_agent`
    FOREIGN KEY (`agent_collecte_id`)
    REFERENCES `utilisateur` (`id`)
    ON DELETE SET NULL
    ON UPDATE CASCADE,
  CONSTRAINT `fk_collecte_route`
    FOREIGN KEY (`route_id`)
    REFERENCES `route` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table des badges de déverrouillage
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `badge_deverrouillage` (
  `id` VARCHAR(36) NOT NULL,
  `code` VARCHAR(50) NOT NULL,
  `nom` VARCHAR(100) NOT NULL,
  `type_badge_id` TINYINT NOT NULL,
  `date_creation` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `date_expiration` DATETIME NOT NULL,
  `actif` BOOLEAN NOT NULL DEFAULT TRUE,
  `utilisateur_id` VARCHAR(36) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `code_UNIQUE` (`code` ASC),
  INDEX `fk_badge_utilisateur_idx` (`utilisateur_id`),
  INDEX `fk_badge_type_idx` (`type_badge_id`),
  CONSTRAINT `fk_badge_utilisateur`
    FOREIGN KEY (`utilisateur_id`)
    REFERENCES `utilisateur` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_badge_type`
    FOREIGN KEY (`type_badge_id`)
    REFERENCES `type_badge` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table des historiques
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `historique` (
  `id` VARCHAR(36) NOT NULL,
  `poubelle_id` VARCHAR(36) NOT NULL,
  `date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `type_evenement_id` TINYINT NOT NULL,
  `valeur` FLOAT NULL,
  `utilisateur_id` VARCHAR(36) NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_historique_poubelle_idx` (`poubelle_id`),
  INDEX `fk_historique_type_idx` (`type_evenement_id`),
  INDEX `fk_historique_utilisateur_idx` (`utilisateur_id`),
  CONSTRAINT `fk_historique_poubelle`
    FOREIGN KEY (`poubelle_id`)
    REFERENCES `poubelle` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_historique_type`
    FOREIGN KEY (`type_evenement_id`)
    REFERENCES `type_evenement_historique` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_historique_utilisateur`
    FOREIGN KEY (`utilisateur_id`)
    REFERENCES `utilisateur` (`id`)
    ON DELETE SET NULL
    ON UPDATE CASCADE
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table des notifications
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `notification` (
  `id` VARCHAR(36) NOT NULL,
  `type_id` TINYINT NOT NULL,
  `titre` VARCHAR(255) NOT NULL,
  `message` TEXT NOT NULL,
  `date_creation` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `poubelle_id` VARCHAR(36) NULL,
  `destinataire_id` VARCHAR(36) NOT NULL,
  `lue` BOOLEAN NOT NULL DEFAULT FALSE,
  PRIMARY KEY (`id`),
  INDEX `fk_notification_type_idx` (`type_id`),
  INDEX `fk_notification_poubelle_idx` (`poubelle_id`),
  INDEX `fk_notification_destinataire_idx` (`destinataire_id`),
  CONSTRAINT `fk_notification_type`
    FOREIGN KEY (`type_id`)
    REFERENCES `type_notification` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_notification_poubelle`
    FOREIGN KEY (`poubelle_id`)
    REFERENCES `poubelle` (`id`)
    ON DELETE SET NULL
    ON UPDATE CASCADE,
  CONSTRAINT `fk_notification_destinataire`
    FOREIGN KEY (`destinataire_id`)
    REFERENCES `utilisateur` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table des statistiques
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `statistique` (
  `id` VARCHAR(36) NOT NULL,
  `type_stat_id` TINYINT NOT NULL,
  `periode_id` TINYINT NOT NULL,
  `date_debut` DATE NOT NULL,
  `date_fin` DATE NOT NULL,
  `valeur` FLOAT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_statistique_type_idx` (`type_stat_id`),
  INDEX `fk_statistique_periode_idx` (`periode_id`),
  CONSTRAINT `fk_statistique_type`
    FOREIGN KEY (`type_stat_id`)
    REFERENCES `type_statistique` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_statistique_periode`
    FOREIGN KEY (`periode_id`)
    REFERENCES `periode_statistique` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Fonctions et procédures stockées
-- -----------------------------------------------------
DELIMITER //

-- Fonction pour générer un UUID
CREATE FUNCTION IF NOT EXISTS `generate_uuid`()
RETURNS VARCHAR(36)
DETERMINISTIC
BEGIN
    RETURN UUID();
END //

-- Procédure d'inscription d'un utilisateur
CREATE PROCEDURE IF NOT EXISTS `sp_creer_utilisateur` (
    IN p_nom VARCHAR(100),
    IN p_prenom VARCHAR(100),
    IN p_email VARCHAR(255),
    IN p_mot_de_passe VARCHAR(255),
    IN p_type_utilisateur VARCHAR(50)
)
BEGIN
    DECLARE v_type_id TINYINT;
    DECLARE v_user_id VARCHAR(36);

    SELECT id INTO v_type_id
      FROM type_utilisateur
     WHERE nom = p_type_utilisateur;

    SET v_user_id = generate_uuid();

    INSERT INTO utilisateur (
        id, nom, prenom, email, mot_de_passe, type_utilisateur_id, date_inscription
    ) VALUES (
        v_user_id, p_nom, p_prenom, p_email, p_mot_de_passe, v_type_id, NOW()
    );

    SELECT v_user_id AS utilisateur_id;
END //

-- Procédure de connexion
CREATE PROCEDURE IF NOT EXISTS `sp_connexion` (
    IN p_email VARCHAR(255),
    IN p_mot_de_passe VARCHAR(255)
)
BEGIN
    SELECT u.id,
           u.nom,
           u.prenom,
           u.email,
           tu.nom AS type_utilisateur
      FROM utilisateur u
      JOIN type_utilisateur tu
        ON u.type_utilisateur_id = tu.id
     WHERE u.email = p_email
       AND u.mot_de_passe = p_mot_de_passe;
END //

-- Procédure pour créer une poubelle
CREATE PROCEDURE IF NOT EXISTS `sp_creer_poubelle` (
    IN p_capacite_totale FLOAT,
    IN p_statut VARCHAR(50),
    IN p_latitude DECIMAL(10,8),
    IN p_longitude DECIMAL(11,8),
    IN p_adresse VARCHAR(255),
    IN p_nom VARCHAR(100)
)
BEGIN
    DECLARE v_statut_id TINYINT;
    DECLARE v_poubelle_id VARCHAR(36);

    SELECT id INTO v_statut_id
      FROM statut_poubelle
     WHERE nom = p_statut;

    SET v_poubelle_id = generate_uuid();

    INSERT INTO poubelle (
        id, capacite_totale, nom, niveau_remplissage,
        statut_id, latitude, longitude, adresse
    ) VALUES (
        v_poubelle_id, p_capacite_totale, p_nom, 0,
        v_statut_id, p_latitude, p_longitude, p_adresse
    );

    SELECT v_poubelle_id AS poubelle_id;
END //

-- Procédure pour verrouiller automatiquement une poubelle
CREATE PROCEDURE IF NOT EXISTS `sp_verrouiller_poubelle` (
    IN p_poubelle_id VARCHAR(36)
)
BEGIN
    DECLARE v_type_evenement_id TINYINT;

    SELECT id INTO v_type_evenement_id
      FROM type_evenement_historique
     WHERE nom = 'FERMETURE';

    UPDATE poubelle
       SET verrouille = TRUE
     WHERE id = p_poubelle_id;

    INSERT INTO historique (
        id, poubelle_id, date, type_evenement_id, valeur, utilisateur_id
    ) VALUES (
        generate_uuid(), p_poubelle_id, NOW(),
        v_type_evenement_id, NULL, NULL
    );

    SELECT TRUE AS succes, 'Poubelle verrouillée automatiquement' AS message;
END //

-- Procédure pour mettre à jour le niveau de remplissage d'une poubelle
CREATE PROCEDURE IF NOT EXISTS `sp_mettre_a_jour_niveau_remplissage` (
    IN p_poubelle_id VARCHAR(36),
    IN p_niveau_remplissage FLOAT,
    IN p_utilisateur_id VARCHAR(36)
)
BEGIN
    -- Toutes les déclarations de variables d'abord
    DECLARE v_type_evenement_id TINYINT;
    DECLARE v_seuil_alerte FLOAT;
    DECLARE v_type_notification_id TINYINT;
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_admin_id VARCHAR(36);
    
    -- Ensuite les déclarations de curseurs
    DECLARE v_admins_cursor CURSOR FOR
        SELECT id
          FROM utilisateur
         WHERE type_utilisateur_id = (SELECT id FROM type_utilisateur WHERE nom = 'ADMIN');
    
    -- Enfin les gestionnaires d'erreurs
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Mise à jour du niveau de remplissage
    SELECT id INTO v_type_evenement_id
      FROM type_evenement_historique
     WHERE nom = 'REMPLISSAGE';

    UPDATE poubelle
       SET niveau_remplissage = p_niveau_remplissage
     WHERE id = p_poubelle_id;

    INSERT INTO historique (
        id, poubelle_id, date, type_evenement_id, valeur, utilisateur_id
    ) VALUES (
        generate_uuid(), p_poubelle_id, NOW(),
        v_type_evenement_id, p_niveau_remplissage, p_utilisateur_id
    );

    -- Vérification du seuil d'alerte
    SELECT seuil_alerte INTO v_seuil_alerte
      FROM poubelle
     WHERE id = p_poubelle_id;

    -- Si le seuil est atteint, verrouiller automatiquement et envoyer des notifications
    IF p_niveau_remplissage >= v_seuil_alerte THEN
        SELECT id INTO v_type_notification_id
          FROM type_notification
         WHERE nom = 'ALERTE_REMPLISSAGE';

        -- Verrouillage automatique de la poubelle quand le seuil est atteint
        CALL sp_verrouiller_poubelle(p_poubelle_id);
        
        -- Envoi de notifications aux administrateurs
        OPEN v_admins_cursor;
        read_loop: LOOP
            FETCH v_admins_cursor INTO v_admin_id;
            IF done THEN
                LEAVE read_loop;
            END IF;

            INSERT INTO notification (
                id, type_id, titre, message,
                date_creation, poubelle_id, destinataire_id
            ) VALUES (
                generate_uuid(),
                v_type_notification_id,
                'Alerte de remplissage',
                CONCAT(
                  'La poubelle ', 
                  (SELECT nom FROM poubelle WHERE id = p_poubelle_id),
                  ' a atteint un niveau de remplissage de ',
                  ROUND(p_niveau_remplissage * 100, 2), '%'
                ),
                NOW(),
                p_poubelle_id,
                v_admin_id
            );
        END LOOP;
        CLOSE v_admins_cursor;
    END IF;
END //

-- Procédure pour déverrouiller une poubelle
CREATE PROCEDURE IF NOT EXISTS `sp_deverrouiller_poubelle` (
    IN p_poubelle_id VARCHAR(36),
    IN p_code_badge VARCHAR(50)
)
BEGIN
    DECLARE v_badge_valide BOOLEAN;
    DECLARE v_utilisateur_id VARCHAR(36);
    DECLARE v_type_evenement_id TINYINT;

    SELECT EXISTS(
        SELECT 1 FROM badge_deverrouillage
         WHERE code = p_code_badge
           AND actif = TRUE
           AND date_expiration > NOW()
    ) INTO v_badge_valide;

    IF v_badge_valide THEN
        SELECT utilisateur_id INTO v_utilisateur_id
          FROM badge_deverrouillage
         WHERE code = p_code_badge;

        SELECT id INTO v_type_evenement_id
          FROM type_evenement_historique
         WHERE nom = 'OUVERTURE';

        UPDATE poubelle
           SET verrouille = FALSE
         WHERE id = p_poubelle_id;

        INSERT INTO historique (
            id, poubelle_id, date, type_evenement_id, valeur, utilisateur_id
        ) VALUES (
            generate_uuid(), p_poubelle_id, NOW(),
            v_type_evenement_id, NULL, v_utilisateur_id
        );

        SELECT TRUE AS succes, 'Poubelle déverrouillée avec succès' AS message;
    ELSE
        SELECT FALSE AS succes, 'Code de badge invalide ou expiré' AS message;
    END IF;
END //

-- Procédure pour créer une route
CREATE PROCEDURE IF NOT EXISTS `sp_creer_route` (
    IN p_nom VARCHAR(100),
    IN p_description TEXT
)
BEGIN
    DECLARE v_route_id VARCHAR(36);

    SET v_route_id = generate_uuid();

    INSERT INTO route (
        id, nom, description, distance_estimee, duree_estimee, nombre_de_poubelles
    ) VALUES (
        v_route_id, p_nom, p_description, 0, 0, 0
    );

    SELECT v_route_id AS route_id;
END //

-- Procédure pour ajouter une poubelle à une route
CREATE PROCEDURE IF NOT EXISTS `sp_ajouter_poubelle_a_route` (
    IN p_poubelle_id VARCHAR(36),
    IN p_route_id VARCHAR(36),
    IN p_ordre INT,
    IN p_temps_estime INT
)
BEGIN
    INSERT INTO poubelle_dans_route (
        poubelle_id, route_id, ordre, temps_estime
    ) VALUES (
        p_poubelle_id, p_route_id, p_ordre, p_temps_estime
    );

    UPDATE route
       SET nombre_de_poubelles = (
           SELECT COUNT(*) FROM poubelle_dans_route WHERE route_id = p_route_id
       )
     WHERE id = p_route_id;

    CALL sp_calculer_estimations_route(p_route_id);
END //

-- Procédure pour recalculer les estimations d'une route
CREATE PROCEDURE IF NOT EXISTS `sp_calculer_estimations_route` (
    IN p_route_id VARCHAR(36)
)
BEGIN
    UPDATE route
       SET duree_estimee = (
           SELECT IFNULL(SUM(temps_estime),0)
             FROM poubelle_dans_route
            WHERE route_id = p_route_id
       )
     WHERE id = p_route_id;

    UPDATE route
       SET distance_estimee = nombre_de_poubelles * 0.5
     WHERE id = p_route_id;
END //

-- Procédure pour créer une collecte planifiée
CREATE PROCEDURE IF NOT EXISTS `sp_creer_collecte_planifiee` (
    IN p_date DATE,
    IN p_heure_estimee TIME,
    IN p_agent_collecte_id VARCHAR(36),
    IN p_route_id VARCHAR(36),
    IN p_commentaires TEXT
)
BEGIN
    DECLARE v_collecte_id VARCHAR(36);
    DECLARE v_statut_id TINYINT;

    SELECT id INTO v_statut_id
      FROM statut_collecte
     WHERE nom = 'PLANIFIEE';

    SET v_collecte_id = generate_uuid();

    INSERT INTO collecte_planifiee (
        id, date, heure_estimee, statut_id,
        agent_collecte_id, route_id, commentaires, date_creation
    ) VALUES (
        v_collecte_id, p_date, p_heure_estimee, v_statut_id,
        p_agent_collecte_id, p_route_id, p_commentaires, NOW()
    );

    SELECT v_collecte_id AS collecte_id;
END //

-- Procédure pour marquer une collecte comme débutée
CREATE PROCEDURE IF NOT EXISTS `sp_marquer_collecte_debutee` (
    IN p_collecte_id VARCHAR(36)
)
BEGIN
    DECLARE v_statut_id TINYINT;

    SELECT id INTO v_statut_id
      FROM statut_collecte
     WHERE nom = 'EN_COURS';

    UPDATE collecte_planifiee
       SET statut_id = v_statut_id
     WHERE id = p_collecte_id;
END //

-- Procédure pour marquer une collecte comme terminée
CREATE PROCEDURE IF NOT EXISTS `sp_marquer_collecte_terminee` (
    IN p_collecte_id VARCHAR(36)
)
BEGIN
    -- Toutes les déclarations de variables d'abord
    DECLARE v_statut_id TINYINT;
    DECLARE v_route_id VARCHAR(36);
    DECLARE v_type_evenement_id TINYINT;
    DECLARE v_poubelle_id VARCHAR(36);
    DECLARE done INT DEFAULT FALSE;
    
    -- Ensuite les déclarations de curseurs
    DECLARE v_poubelles_cursor CURSOR FOR
        SELECT pr.poubelle_id
          FROM poubelle_dans_route pr
          JOIN collecte_planifiee cp
            ON pr.route_id = cp.route_id
         WHERE cp.id = p_collecte_id;
    
    -- Enfin les gestionnaires d'erreurs
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Le reste du code
    SELECT id INTO v_statut_id
      FROM statut_collecte
     WHERE nom = 'TERMINEE';

    SELECT id INTO v_type_evenement_id
      FROM type_evenement_historique
     WHERE nom = 'VIDAGE';

    UPDATE collecte_planifiee
       SET statut_id = v_statut_id
     WHERE id = p_collecte_id;

    OPEN v_poubelles_cursor;
    read_loop: LOOP
        FETCH v_poubelles_cursor INTO v_poubelle_id;
        IF done THEN
            LEAVE read_loop;
        END IF;

        UPDATE poubelle
           SET date_derniere_collecte = NOW(),
               niveau_remplissage = 0
         WHERE id = v_poubelle_id;

        INSERT INTO historique (
            id, poubelle_id, date, type_evenement_id, valeur, utilisateur_id
        ) VALUES (
            generate_uuid(), v_poubelle_id, NOW(),
            v_type_evenement_id, 0,
            (SELECT agent_collecte_id FROM collecte_planifiee WHERE id = p_collecte_id)
        );
    END LOOP;
    CLOSE v_poubelles_cursor;
END //

-- Procédure pour obtenir l'état des poubelles
CREATE PROCEDURE IF NOT EXISTS `sp_obtenir_etat_poubelles` ()
BEGIN
    SELECT 
        p.id,
        p.nom,
        p.capacite_totale,
        p.niveau_remplissage,
        (p.niveau_remplissage / p.capacite_totale * 100) AS pourcentage_remplissage,
        sp.nom AS statut,
        p.latitude,
        p.longitude,
        p.adresse,
        p.date_derniere_collecte,
        p.seuil_alerte,
        p.verrouille
    FROM 
        poubelle p
    JOIN 
        statut_poubelle sp ON p.statut_id = sp.id
    ORDER BY 
        pourcentage_remplissage DESC;
END //

-- Procédure pour générer un nouveau badge
CREATE PROCEDURE IF NOT EXISTS `sp_generer_badge` (
    IN p_nom VARCHAR(100),
    IN p_type_badge VARCHAR(50),
    IN p_utilisateur_id VARCHAR(36),
    IN p_duree_validite INT -- en jours
)
BEGIN
    DECLARE v_badge_id VARCHAR(36);
    DECLARE v_code VARCHAR(50);
    DECLARE v_type_badge_id TINYINT;
    
    -- Générer un code unique pour le badge (combinaison de lettres et chiffres)
    SET v_code = CONCAT(
        UPPER(LEFT(UUID(), 8)),
        FLOOR(RAND() * 10000)
    );
    
    -- Obtenir l'ID du type de badge
    SELECT id INTO v_type_badge_id
      FROM type_badge
     WHERE nom = p_type_badge;
    
    -- Générer un UUID pour le badge
    SET v_badge_id = generate_uuid();
    
    -- Insérer le nouveau badge
    INSERT INTO badge_deverrouillage (
        id, code, nom, type_badge_id, date_creation, 
        date_expiration, actif, utilisateur_id
    ) VALUES (
        v_badge_id, v_code, p_nom, v_type_badge_id, NOW(),
        DATE_ADD(NOW(), INTERVAL p_duree_validite DAY), TRUE, p_utilisateur_id
    );
    
    -- Retourner les informations du badge
    SELECT 
        bd.id,
        bd.code,
        bd.nom,
        tb.nom AS type_badge,
        bd.date_creation,
        bd.date_expiration,
        bd.actif,
        CONCAT(u.prenom, ' ', u.nom) AS utilisateur
    FROM 
        badge_deverrouillage bd
    JOIN 
        type_badge tb ON bd.type_badge_id = tb.id
    JOIN 
        utilisateur u ON bd.utilisateur_id = u.id
    WHERE 
        bd.id = v_badge_id;
END //

DELIMITER ;

-- -----------------------------------------------------
-- Restauration des modes et contrôles
-- -----------------------------------------------------
SET SQL_MODE = @OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS = @OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS = @OLD_UNIQUE_CHECKS;