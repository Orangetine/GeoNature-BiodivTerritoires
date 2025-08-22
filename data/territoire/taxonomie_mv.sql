
--------------------- MATERIALIZED VIEW taxonomie.taxref_liste_rouge_fr
DROP MATERIALIZED VIEW IF EXISTS gn_biodivterritory.taxref_liste_rouge_fr CASCADE;
CREATE MATERIALIZED VIEW gn_biodivterritory.taxref_liste_rouge_fr AS
    SELECT row_number() OVER () AS id_lr, sr.*
        FROM (
    SELECT DISTINCT ON (
          tr.cd_nom,
		  liste_rouge_source
        )
        tr.cd_nom,
        tr.cd_ref,
        tr.lb_nom,
        tr.lb_auteur,
        tr.nom_vern,
        tr.id_rang,
        tr.famille,
        LEFT(bs.code_statut::text, 2) AS id_categorie_france,
        bs.rq_statut AS criteres_france,
        bs.lb_type_statut AS liste_rouge,
        tr.url AS fiche_espece,
        (regexp_matches(bs.full_citation, '<em>(.*?)</em>'))[1] AS liste_rouge_source,
        (regexp_matches(bs.full_citation, '\m\d{4}\M'))[1]::integer AS annee_publication,
        CASE LEFT(bs.code_statut::text, 2)
            WHEN 'EX' THEN 5
            WHEN 'EW' THEN 10
            WHEN 'RE' THEN 15
            WHEN 'CR' THEN 20
            WHEN 'EN' THEN 25
            WHEN 'VU' THEN 30
            WHEN 'NT' THEN 35
            WHEN 'LC' THEN 40
            WHEN 'DD' THEN 45
            WHEN 'NA' THEN 55
            WHEN 'NE' THEN 60
            ELSE NULL
        END AS ordre_statut
    FROM atlas.vm_taxref tr
        JOIN taxonomie.bdc_statut bs ON tr.cd_nom = bs.cd_nom
    WHERE bs.cd_sig IN ('ETATFRA','TERFXFR','INSEER11','INSEED75','INSEED77','INSEED78','INSEED91','INSEED92','INSEED93','INSEED94','INSEED95')
    AND bs.regroupement_type = 'Liste rouge' 
    ORDER BY
        tr.cd_nom,
        liste_rouge_source,
        (regexp_matches(bs.full_citation, '\m\d{4}\M'))[1]::integer DESC) sr;


--------------------- MATERIALIZED VIEW taxonomie.taxref_protection_articles
DROP MATERIALIZED VIEW IF EXISTS gn_biodivterritory.taxref_protection_articles CASCADE;
CREATE MATERIALIZED VIEW gn_biodivterritory.taxref_protection_articles AS
    SELECT DISTINCT code_statut as cd_protection, 
        split_part(label_statut, ':', 2) as article, 
        split_part(label_statut, ':', 1) as intitule,  
        replace(full_citation, '&nbsp;', '') as arrete, 
        'https://inpn.mnhn.fr/reglementation/protection/listeEspecesParArrete/' || cd_doc as url_inpn,
        cd_doc,
        doc_url as url, 
        (regexp_matches(full_citation, '\m\d{4}\M'))[1]::integer as date_arrete, 
        lb_type_statut as type_protection
    FROM taxonomie.bdc_statut
    WHERE cd_sig in ('ETATFRA','TERFXFR' , 'INSEER11', 'INSEED75', 'INSEED77',  'INSEED78', 
                     'INSEED91', 'INSEED92',  'INSEED93', 'INSEED94', 'INSEED95')
    AND regroupement_type IN ('Protection', 'Réglementation')
    ORDER BY code_statut ASC;

--------------------- MATERIALIZED VIEW taxonomie.taxref_protection_especes
DROP MATERIALIZED VIEW IF EXISTS gn_biodivterritory.taxref_protection_especes CASCADE;
CREATE MATERIALIZED VIEW gn_biodivterritory.taxref_protection_especes AS
    SELECT bs.cd_nom, 
        bs.code_statut as cd_protection, 
        bs.lb_nom as nom_cite, 
        tr.nom_vern as nom_francais_cite
    FROM taxonomie.bdc_statut bs
	    JOIN atlas.vm_taxref tr on bs.cd_nom = tr.cd_nom
    WHERE cd_sig in ('ETATFRA','TERFXFR' , 'INSEER11', 'INSEED75', 'INSEED77',  'INSEED78', 
                     'INSEED91', 'INSEED92',  'INSEED93', 'INSEED94', 'INSEED95')
    AND regroupement_type IN ('Protection', 'Réglementation') 
    ORDER BY cd_nom ASC;
CREATE INDEX fki_cd_nom_taxref_protection_especes ON gn_biodivterritory.taxref_protection_especes USING btree (cd_nom);

--------------------- MATERIALIZED VIEW taxonomie.bib_c_redlist_source
DROP MATERIALIZED VIEW IF EXISTS gn_biodivterritory.bib_c_redlist_source CASCADE;
CREATE MATERIALIZED VIEW gn_biodivterritory.bib_c_redlist_source AS
SELECT 
    row_number() OVER () AS id_source, sr.*
FROM 
(
SELECT DISTINCT
        on (liste_rouge_source)
		
	    liste_rouge_source as name_source,
	
        CASE WHEN liste_rouge in ('Liste rouge régionale', 'Liste rouge nationale')
		    THEN 'FR' 
	    END AS area_code,

        CASE WHEN liste_rouge in ('Liste rouge régionale', 'Liste rouge nationale')
		    THEN 'France métropolitaine'
	    END AS area_name,
	    doc_url as url_source,
        annee_publication
    FROM
        gn_biodivterritory.taxref_liste_rouge_fr lr
        JOIN taxonomie.bdc_statut st ON lr.cd_nom = st.cd_nom
    WHERE cd_sig in ('ETATFRA','TERFXFR' , 'INSEER11', 'INSEED75', 'INSEED77',  'INSEED78', 
                     'INSEED91', 'INSEED92',  'INSEED93', 'INSEED94', 'INSEED95')
    AND regroupement_type IN ('Liste rouge')
	) sr ;

--------------------- MATERIALIZED VIEW taxonomie.bib_c_redlist_categories
DROP MATERIALIZED VIEW IF EXISTS gn_biodivterritory.bib_c_redlist_categories CASCADE;
CREATE MATERIALIZED VIEW gn_biodivterritory.bib_c_redlist_categories AS
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
    gn_biodivterritory.taxref_liste_rouge_fr
ORDER BY priority_order ASC;

COMMENT ON MATERIALIZED VIEW gn_biodivterritory.bib_c_redlist_categories IS 'Liste des catégories de statuts de liste rouge';

--------------------- MATERIALIZED VIEW taxonomie.t_c_redlist
DROP MATERIALIZED VIEW IF EXISTS gn_biodivterritory.t_c_redlist CASCADE;
CREATE MATERIALIZED VIEW gn_biodivterritory.t_c_redlist AS
SELECT row_number() over() as id_redlist, sr.* FROM(
    SELECT
        ordre_statut as status_order,
        vm_taxref.cd_nom,
        vm_taxref.cd_ref,
        id_categorie_france as category,
        criteres_france as criteria,
        id_source
    FROM
        gn_biodivterritory.taxref_liste_rouge_fr
        JOIN gn_biodivterritory.bib_c_redlist_source ON liste_rouge_source = bib_c_redlist_source.name_source
        JOIN atlas.vm_taxref ON taxref_liste_rouge_fr.cd_nom = vm_taxref.cd_nom) sr;

COMMENT ON MATERIALIZED VIEW gn_biodivterritory.t_c_redlist IS 'Liste des statuts de liste rouge par taxons';

