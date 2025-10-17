-- 1er type de requetes : projection et selections

-- Profils (infos de base), triés par date de création 
SELECT p.id_profil, p.prenom_profil, p.nom_profil, p.email_profil, p.promo_code, p.creation_profil
FROM profil p
ORDER BY p.creation_profil DESC;

-- Profils dont l’email est sur le domaine EFREI et pseudo commençant par 'a'
SELECT p.id_profil, p.pseudo_profil, p.email_profil
FROM profil p
WHERE p.email_profil LIKE '%@efrei.fr'
  AND p.pseudo_profil LIKE 'a%';

-- Publications entre le 1er et le 15 nov. 2024 (BETWEEN)
SELECT id_publication, id_profil, creation_post, maj_post
FROM publication
WHERE creation_post BETWEEN '2024-11-01' AND '2024-11-15'
ORDER BY creation_post DESC;

-- Publications dont le texte mentionne SQL ou IA (LIKE + OR)
SELECT id_publication, id_profil, creation_post
FROM publication
WHERE texte_publication LIKE '%SQL%' OR texte_publication LIKE '%Louvres%'
ORDER BY id_publication;

-- Liste des codes promo distincts parmi les étudiants EFREI (DISTINCT)
SELECT DISTINCT p.promo_code
FROM profil p
JOIN etablissement e ON e.id_etablissement = p.id_etablissement
WHERE e.code_etablissement = 'EFREI'
ORDER BY promo_code;


-- Profils appartenant à l’un de ces établissements (IN)
SELECT p.id_profil, p.prenom_profil, p.nom_profil, e.nom_etablissement
FROM profil p
JOIN etablissement e ON e.id_etablissement = p.id_etablissement
WHERE e.code_etablissement IN ('EFREI','UPCITE','SORBN')
ORDER BY e.code_etablissement, p.id_profil; 

-- Selectionne les profils des étudiants inscrits à l'EFREI uniquement
SELECT p.id_profil, p.prenom_profil, p.nom_profil, p.email_profil, p.promo_code, p.creation_profil
FROM profil p
JOIN etablissement e ON e.id_etablissement = p.id_etablissement
WHERE e.code_etablissement = 'EFREI'
ORDER BY p.creation_profil DESC;

-- 2eme groupe de requetes (fonctions d'agregations)

-- Nombre de publications par profil
SELECT p.id_profil, p.pseudo_profil, COUNT(pub.id_publication) AS nb_publications
FROM profil p
LEFT JOIN publication pub ON pub.id_profil = p.id_profil
GROUP BY p.id_profil, p.pseudo_profil
ORDER BY nb_publications DESC;

-- Nombre de réactions par publication (seulement celles avec au moins 3 réactions)
SELECT r.id_publication, COUNT(*) AS nb_reactions
FROM reaction_publication r
GROUP BY r.id_publication
HAVING COUNT(*) >= 3
ORDER BY nb_reactions DESC;

-- Taille des groupes (nombre de membres), ordre décroissant
SELECT g.id_groupe, g.nom_groupe, COUNT(pg.id_profil) AS nb_membres
FROM groupe g
LEFT JOIN profil_groupe pg ON pg.id_groupe = g.id_groupe
GROUP BY g.id_groupe, g.nom_groupe
ORDER BY nb_membres DESC;

-- Nombre de commentaires par jour
SELECT creation_commentaire AS jour, COUNT(*) AS nb_commentaires
FROM commentaire
GROUP BY creation_commentaire
ORDER BY jour;

-- Répartition des types de réactions
SELECT type_reaction, COUNT(*) AS nb
FROM reaction_publication
GROUP BY type_reaction
ORDER BY nb DESC;


-- 3eme groupe de requetes centré autour des Jointures

-- Publications avec le nom de l’auteur
SELECT pub.id_publication, pub.creation_post, p.pseudo_profil AS auteur
FROM publication pub
JOIN profil p ON p.id_profil = pub.id_profil
ORDER BY pub.id_publication DESC;

-- Publications sans média 
SELECT pub.id_publication, pub.creation_post
FROM publication pub
LEFT JOIN media m ON m.id_publication = pub.id_publication
WHERE m.id_media IS NULL
ORDER BY pub.id_publication;

-- Groupes avec leur établissement
SELECT g.id_groupe, g.nom_groupe, g.type_groupe, e.nom_etablissement
FROM groupe g
JOIN etablissement e ON e.id_etablissement = g.id_etablissement
ORDER BY e.nom_etablissement, g.nom_groupe;

-- Messages avec auteur et conversation (JOIN multiples)
SELECT msg.id_message, msg.creation_message, msg.contenu_message, conv.sujet_conversation, p.pseudo_profil AS auteur
FROM message msg
JOIN conversation conv ON conv.id_conversation = msg.id_conversation
JOIN profil p ON p.id_profil = msg.id_profil
ORDER BY msg.creation_message DESC
LIMIT 50;

-- Profils sans appartenance à aucun groupe
SELECT p.id_profil, p.pseudo_profil, e.nom_etablissement
FROM profil p
LEFT JOIN profil_groupe pg ON pg.id_profil = p.id_profil
JOIN etablissement e ON e.id_etablissement = p.id_etablissement
WHERE pg.id_groupe IS NULL
ORDER BY e.nom_etablissement, p.id_profil;


-- 4eme groupe de requetes : les requetes imbriquées

-- Profils qui n’ont jamais publié (NOT EXISTS)
SELECT p.id_profil, p.pseudo_profil
FROM profil p
WHERE NOT EXISTS (
  SELECT 1 FROM publication pub WHERE pub.id_profil = p.id_profil
)
ORDER BY p.id_profil;

-- Publications ayant au moins une réaction "LOVE" (EXISTS)
SELECT pub.id_publication, pub.id_profil, pub.creation_post
FROM publication pub
WHERE EXISTS (
  SELECT 1
  FROM reaction_publication r
  WHERE r.id_publication = pub.id_publication
    AND r.type_reaction = 'LOVE'
)
ORDER BY pub.id_publication;

-- Profils qui suivent au moins 5 autres profils (IN avec sous-requête + HAVING)
SELECT p.id_profil, p.pseudo_profil
FROM profil p
WHERE p.id_profil IN (
  SELECT rp.id_profil_suiveur
  FROM relation_profil rp
  GROUP BY rp.id_profil_suiveur
  HAVING COUNT(*) >= 5
)
ORDER BY p.id_profil;

-- Publications ayant strictement plus de réactions que la moyenne (sous-requête dérivée)
SELECT r.id_publication, COUNT(*) AS nb_reactions
FROM reaction_publication r
GROUP BY r.id_publication
HAVING COUNT(*) > (
  SELECT AVG(sub.cnt)
  FROM (
    SELECT COUNT(*) AS cnt
    FROM reaction_publication
    GROUP BY id_publication
  ) AS sub
)
ORDER BY nb_reactions DESC;

-- Controle de Qualité, une conversation privée ne devrait pas compter plus de 2 participants 
SELECT c.id_conversation, c.sujet_conversation
FROM conversation c
WHERE c.type_conversation = 'prive'
  AND c.id_conversation IN (
    SELECT cp.id_conversation
    FROM conversation_participant cp
    GROUP BY cp.id_conversation
    HAVING COUNT(*) >= 3
  )
ORDER BY c.id_conversation;
