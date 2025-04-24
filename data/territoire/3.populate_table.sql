/* Création des zonages régionaux et nationaux pour associer aux listes rouges */
INSERT INTO ref_geo.bib_areas_types (type_name, type_code, type_desc)
    VALUES ('Régions', 'REG', 'Type région'), ('Pays', 'PAY', 'Type pays')
ON CONFLICT
    DO NOTHING;


/***************************************************
 *   CREATION D'UNE TABLE DE RECHERCHE DES ZONAGES  *
 *  La variable _areas est issue de la commande psql
 *  psql -v _areas=$AREAS monscript.sql
 ***************************************************/
INSERT INTO gn_biodivterritory.l_areas_type_selection (id_type)
SELECT
    id_type
FROM
    ref_geo.bib_areas_types
WHERE
    type_code IN (
        SELECT
            unnest(string_to_array(:'_areas', ' ')))
ON CONFLICT
    DO NOTHING;


INSERT INTO taxonomie.bib_c_redlist_categories (code_category, threatened, sup_category, priority_order)
SELECT DISTINCT
    id_categorie_france AS code_category,
    CASE WHEN id_categorie_france IN ('CR', 'EN', 'VU') THEN
        TRUE
    ELSE
        FALSE
    END AS threatened,
    CASE WHEN id_categorie_france IN ('CR', 'EN', 'VU') THEN
        'threatened'
    WHEN id_categorie_france IN ('RE', 'EW', 'EX') THEN
        'extinct'
    ELSE
        'other'
    END AS sup_category,
    CASE id_categorie_france
    WHEN 'EX' THEN
        10
    WHEN 'EW' THEN
        20
    WHEN 'RE' THEN
        30
    WHEN 'CR' THEN
        40
    WHEN 'EN' THEN
        50
    WHEN 'VU' THEN
        60
    WHEN 'NT' THEN
        70
    WHEN 'LC' THEN
        80
    WHEN 'DD' THEN
        90
    WHEN 'NE' THEN
        100
    WHEN 'NA' THEN
        110
    END AS priority_order
FROM
    taxonomie.taxref_liste_rouge_fr; /* Utiliser bdc_statut_values pour faire cette table */

-- bib_c_redlist_source ---------------------------
/* Insertion de la source UICN France*/
INSERT INTO taxonomie.bib_c_redlist_source (name_source, area_code, area_name)
SELECT DISTINCT
    liste_rouge_source,
    'FR',
    'France métropolitaine'
FROM
    taxonomie.taxref_liste_rouge_fr;

INSERT INTO taxonomie.bib_c_redlist_source (name_source, area_code, area_name)
    VALUES ('Liste rouge mondiale des espèces menacées (2019.1)', 'WORLD', 'Monde'), ('Liste rouge européenne des espèces menacées (2019.1)', 'EUROPE', 'Europe');

-- t_c_redlist ---------------------------------

INSERT INTO taxonomie.t_c_redlist (status_order, cd_nom, cd_ref, category, criteria, id_source)
SELECT
    ordre_statut,
    taxref.cd_nom,
    taxref.cd_ref,
    id_categorie_france,
    criteres_france,
    id_source
FROM
    taxonomie.taxref_liste_rouge_fr
    JOIN taxonomie.bib_c_redlist_source ON liste_rouge_source = bib_c_redlist_source.name_source
    JOIN taxonomie.taxref ON taxref_liste_rouge_fr.cd_nom = taxref.cd_nom;

INSERT INTO taxonomie.t_c_redlist (status_order, cd_nom, cd_ref, category, criteria, id_source)
SELECT
    ordre_statut,
    taxref.cd_nom,
    taxref.cd_ref,
    CASE WHEN categorie_lr_mondiale LIKE 'LR/%' THEN
        upper(
        RIGHT (categorie_lr_mondiale, 2))
    ELSE
        categorie_lr_mondiale
    END AS categorie_lr_mondiale,
    NULL,
    id_source
FROM
    taxonomie.taxref_liste_rouge_fr
    JOIN taxonomie.taxref ON taxref_liste_rouge_fr.cd_nom = taxref.cd_nom,
    (
        SELECT
            id_source
        FROM
            taxonomie.bib_c_redlist_source
        WHERE
            area_code LIKE 'WORLD') AS source
WHERE
    length(categorie_lr_mondiale) > 0;

INSERT INTO taxonomie.t_c_redlist (status_order, cd_nom, cd_ref, category, criteria, id_source)
SELECT
    ordre_statut,
    taxref.cd_nom,
    taxref.cd_ref,
    CASE WHEN categorie_lr_europe LIKE 'LR/%' THEN
        upper(
        RIGHT (categorie_lr_europe, 2))
    ELSE
        categorie_lr_europe
    END AS categorie_lr_mondiale,
    NULL,
    id_source
FROM
    taxonomie.taxref_liste_rouge_fr
    JOIN taxonomie.taxref ON taxref_liste_rouge_fr.cd_nom = taxref.cd_nom,
    (
        SELECT
            id_source
        FROM
            taxonomie.bib_c_redlist_source
        WHERE
            area_code LIKE 'EUROPE') AS source
WHERE
    length(categorie_lr_europe) > 0;
