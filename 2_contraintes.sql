-- Contrainte sur les reactions aux publications
ALTER TABLE reaction_publication
ADD CONSTRAINT check_type_reaction
CHECK (type_reaction IN ('LIKE','LOVE','HAHA','WOW','SAD','ANGRY'));

-- Contrainte cohérence des dates liées à une publication
ALTER TABLE publication
ADD CONSTRAINT check_date_reaction
CHECK (maj_post IS NULL OR maj_post >= creation_post);

-- Type de conversation limité à certaines valeurs
ALTER TABLE conversation
ADD CONSTRAINT check_conversation_type
CHECK (type_conversation IN ('prive','groupe'));

-- Verifier que le pseudo n'est pas un contenu vide (TRIM va permettre de ne pas compter les espaces comme des caractères en les supprimant au début du contenu de l'attribut)
ALTER TABLE profil
ADD CONSTRAINT check_profil_pseudo_non_vide
CHECK (CHAR_LENGTH(TRIM(pseudo_profil)) > 0);

-- Vérifie que les messages, commentaires et publications ne sont pas vides
ALTER TABLE message
ADD CONSTRAINT check_message_non_vide
CHECK (CHAR_LENGTH(TRIM(contenu_message)) > 0);

ALTER TABLE commentaire
ADD CONSTRAINT check_commentaire_non_vide
CHECK (CHAR_LENGTH(TRIM(texte_commentaire)) > 0);

ALTER TABLE publication
ADD CONSTRAINT check_publication_non_vide
CHECK (texte_publication IS NULL OR CHAR_LENGTH(TRIM(texte_publication)) > 0);

-- Vérifie que les URL de média commencent bien par http
ALTER TABLE media
ADD CONSTRAINT check_media_url
CHECK (LOWER(url_media) LIKE 'http%');

-- Verification du format de l'Email au format simple (ex: a@b.cc) grace a un regexp qu'on a simplifié avec le LOWER pour le CHECK
ALTER TABLE profil
ADD CONSTRAINT chk_profil_email_format
CHECK (LOWER(email_profil) REGEXP '^[a-z0-9.]+@[a-z0-9.-]+\.[a-z]{2,}$');