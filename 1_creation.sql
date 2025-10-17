DROP TABLE IF EXISTS 
reaction_publication,
relation_profil,
conversation_participant, 
profil_groupe,
commentaire,
message,
media, 
conversation,
groupe, 
publication, 
profil, 
etablissement;

CREATE TABLE etablissement (
    id_etablissement INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nom_etablissement VARCHAR(50) NOT NULL,
    code_etablissement VARCHAR(20) UNIQUE NOT NULL,
    creation_date DATE NOT NULL,
    PRIMARY KEY (id_etablissement)
);

CREATE TABLE profil (
    id_profil INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nom_profil VARCHAR(50)  NOT NULL,
    prenom_profil VARCHAR(50)  NOT NULL,
    pseudo_profil VARCHAR(50) UNIQUE NOT NULL,
    email_profil  VARCHAR(50) UNIQUE NOT NULL,
    mdp_hash VARCHAR(255) NOT NULL,
    avatar_url VARCHAR(255),
    biographie_profil VARCHAR(255),
    promo_code VARCHAR(50),
    creation_profil DATE NOT NULL,
    id_etablissement INT UNSIGNED NOT NULL,
    PRIMARY KEY (id_profil),
    FOREIGN KEY (id_etablissement)
        REFERENCES etablissement(id_etablissement)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE publication (
    id_publication INT UNSIGNED NOT NULL AUTO_INCREMENT,
    texte_publication VARCHAR(2000),
    creation_post DATE NOT NULL,
    maj_post DATE,
    id_profil INT UNSIGNED NOT NULL,
    PRIMARY KEY (id_publication),
    FOREIGN KEY (id_profil)
        REFERENCES profil(id_profil)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

CREATE TABLE commentaire (
    id_publication INT UNSIGNED NOT NULL,
    id_commentaire INT UNSIGNED NOT NULL,
    texte_commentaire VARCHAR(200) NOT NULL,
    creation_commentaire DATE NOT NULL,
    id_profil INT UNSIGNED NOT NULL,
    PRIMARY KEY (id_publication, id_commentaire),
    FOREIGN KEY (id_publication)
        REFERENCES publication(id_publication)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (id_profil)
        REFERENCES profil(id_profil)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

CREATE TABLE groupe (
    id_groupe INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nom_groupe VARCHAR(50) NOT NULL,
    type_groupe VARCHAR(50) NOT NULL,
    creation_groupe DATE NOT NULL,
    id_etablissement INT UNSIGNED NOT NULL,
    PRIMARY KEY (id_groupe),
    FOREIGN KEY (id_etablissement)
        REFERENCES etablissement(id_etablissement)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE conversation (
    id_conversation INT UNSIGNED NOT NULL AUTO_INCREMENT,
    type_conversation VARCHAR(10) NOT NULL,
    sujet_conversation VARCHAR(50),
    creation_conversation DATE NOT NULL,
    PRIMARY KEY (id_conversation)
);

CREATE TABLE media (
    id_media INT UNSIGNED NOT NULL AUTO_INCREMENT,
    url_media VARCHAR(500) NOT NULL,
    id_publication INT UNSIGNED NOT NULL,
    PRIMARY KEY (id_media),
    FOREIGN KEY (id_publication)
        REFERENCES publication(id_publication)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

CREATE TABLE message (
    id_message INT UNSIGNED NOT NULL AUTO_INCREMENT,
    contenu_message VARCHAR(400) NOT NULL,
    creation_message DATETIME     NOT NULL,
    id_profil INT UNSIGNED NOT NULL,
    id_conversation INT UNSIGNED NOT NULL,
    PRIMARY KEY (id_message),
    FOREIGN KEY (id_profil)
        REFERENCES profil(id_profil)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (id_conversation)
        REFERENCES conversation(id_conversation)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

CREATE TABLE profil_groupe (
    id_profil INT UNSIGNED NOT NULL,
    id_groupe INT UNSIGNED NOT NULL,
    role_groupe VARCHAR(50),
    a_rejoint_groupe DATE,
    PRIMARY KEY (id_profil, id_groupe),
    FOREIGN KEY (id_profil)
        REFERENCES profil(id_profil)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (id_groupe)
        REFERENCES groupe(id_groupe)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

CREATE TABLE conversation_participant (
    id_profil INT UNSIGNED NOT NULL,
    id_conversation INT UNSIGNED NOT NULL,
    role_participant VARCHAR(50),
    rejoint_le DATE,
    PRIMARY KEY (id_profil, id_conversation),
    FOREIGN KEY (id_profil)
        REFERENCES profil(id_profil)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (id_conversation)
        REFERENCES conversation(id_conversation)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

CREATE TABLE relation_profil (
    id_profil_suiveur INT UNSIGNED NOT NULL,
    id_profil_suivi INT UNSIGNED NOT NULL,
    suivi_depuis DATETIME NOT NULL,
    PRIMARY KEY (id_profil_suiveur, id_profil_suivi),
    FOREIGN KEY (id_profil_suiveur)
        REFERENCES profil(id_profil)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (id_profil_suivi)
        REFERENCES profil(id_profil)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

CREATE TABLE reaction_publication (
    id_profil INT UNSIGNED NOT NULL,
    id_publication INT UNSIGNED NOT NULL,
    creation_reaction DATETIME NOT NULL,
    type_reaction VARCHAR(10) NOT NULL,
    PRIMARY KEY (id_profil, id_publication),
    FOREIGN KEY (id_profil)
        REFERENCES profil(id_profil)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (id_publication)
        REFERENCES publication(id_publication)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

