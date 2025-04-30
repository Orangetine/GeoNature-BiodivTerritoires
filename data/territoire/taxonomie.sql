---------------- Table taxonomie.taxref_liste_rouge_fr

CREATE TABLE taxonomie.taxref_liste_rouge_fr (
    id_lr SERIAL PRIMARY KEY,
    ordre_statut INTEGER,
    cd_nom INTEGER,
    cd_ref INTEGER,
    nom_scientifique VARCHAR(255),
    auteur VARCHAR(255),
    nom_vernaculaire VARCHAR(255),
    rang CHAR(4),
    famille VARCHAR(50),
    id_categorie_france CHAR(2) NOT NULL,
    criteres_france VARCHAR(255),
    liste_rouge VARCHAR(255),
    fiche_espece VARCHAR(255),
    liste_rouge_source VARCHAR(255),
    annee_publication INTEGER,
    CONSTRAINT fk_cd_nom FOREIGN KEY (cd_nom) 
        REFERENCES taxonomie.taxref (cd_nom) 
        ON UPDATE CASCADE
);

INSERT INTO taxonomie.taxref_liste_rouge_fr
(cd_nom, cd_ref, nom_scientifique, auteur, nom_vernaculaire,
 rang, famille, id_categorie_france, criteres_france, liste_rouge,
 fiche_espece, liste_rouge_source, annee_publication )
    SELECT 
        tr.cd_nom, tr.cd_ref, tr.lb_nom, 
        tr.lb_auteur, tr.nom_vern, tr.id_rang, 
        tr.famille, LEFT(bs.code_statut, 2) as id_categorie_france, 
        bs.rq_statut as criteres_france, bs.lb_type_statut as liste_rouge, 
        url as fiche_espece, (regexp_matches(bs.full_citation, '<em>(.*?)</em>'))[1] as liste_rouge_source,  
        (regexp_matches(bs.full_citation, '\m\d{4}\M'))[1]::integer as annee_publication
    FROM taxonomie.taxref tr
	    JOIN taxonomie.bdc_statut bs on tr.cd_nom = bs.cd_nom
    WHERE cd_sig in ('ETATFRA','TERFXFR' , 'INSEER11', 'INSEED75', 'INSEED77',  
                    'INSEED78', 'INSEED91', 'INSEED92',  'INSEED93', 'INSEED94', 'INSEED95')
    AND regroupement_type = 'Liste rouge'
    ORDER BY cd_nom ASC;

UPDATE taxonomie.taxref_liste_rouge_fr    
    SET ordre_statut =
        CASE LEFT(id_categorie_france, 2) 
        WHEN 'EX' THEN 
            5
        WHEN 'EW' THEN
            10 
        WHEN 'RE' THEN
            15
        WHEN 'CR' THEN
            20
        WHEN 'EN' THEN
            25
        WHEN 'VU' THEN
            30
        WHEN 'NT' THEN
            35
        WHEN 'LC' THEN
            40
        WHEN 'DD' THEN
            45
        WHEN 'NA' THEN
            55
        WHEN 'NE' THEN
            60
        ELSE NULL
    END;

---------------- Table taxonomie.taxref_protection_articles

CREATE TABLE taxonomie.taxref_protection_articles (
    cd_protection       VARCHAR(20) PRIMARY KEY,
    article             VARCHAR(100),
    intitule            TEXT,
    arrete              TEXT,
    url_inpn            VARCHAR(255),
    cd_doc              INTEGER,
    url                 VARCHAR(255),
    date_arrete         INTEGER,
    type_protection     VARCHAR(255)
);

INSERT INTO taxonomie.taxref_protection_articles
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


---------------- Table taxonomie.taxref_protection_especes

CREATE TABLE taxonomie.taxref_protection_especes (
    id_pe SERIAL, 
	cd_nom INTEGER NOT NULL,
	cd_protection VARCHAR(20) NOT NULL,
	nom_cite VARCHAR(255) NULL,
	nom_francais_cite VARCHAR(255) NULL,
	CONSTRAINT pk_cd_nom_cd_protection
        PRIMARY KEY (cd_nom, cd_protection, id_pe),
	CONSTRAINT fk_cd_nom FOREIGN KEY (cd_nom) 
        REFERENCES taxonomie.taxref(cd_nom) 
        ON UPDATE CASCADE,
	CONSTRAINT fk_cd_protection FOREIGN KEY (cd_protection) 
        REFERENCES taxonomie.taxref_protection_articles(cd_protection) 
        ON UPDATE CASCADE
);
CREATE INDEX fki_cd_nom_taxref_protection_especes ON taxonomie.taxref_protection_especes USING btree (cd_nom);

INSERT INTO taxonomie.taxref_protection_especes
    (cd_nom, cd_protection, nom_cite, nom_francais_cite)
    SELECT bs.cd_nom, 
        bs.code_statut as cd_protection, 
        bs.lb_nom as nom_cite, 
        tr.nom_vern as nom_francais_cite
    FROM taxonomie.bdc_statut bs
	    JOIN taxonomie.taxref tr on bs.cd_nom = tr.cd_nom
    WHERE cd_sig in ('ETATFRA','TERFXFR' , 'INSEER11', 'INSEED75', 'INSEED77',  'INSEED78', 
                 'INSEED91', 'INSEED92',  'INSEED93', 'INSEED94', 'INSEED95')
    AND regroupement_type IN ('Protection', 'Réglementation') 
    ORDER BY cd_nom ASC;

---------------- Table taxonomie.bib_c_redlist_source

CREATE TABLE taxonomie.bib_c_redlist_source (
    id_source SERIAL PRIMARY KEY,
    name_source VARCHAR(255),
    version VARCHAR(50),
    desc_source TEXT,
    url_source TEXT,
    context VARCHAR(50),
    area_name VARCHAR(50),
    area_code VARCHAR(50),
    area_type VARCHAR(50),
    priority INTEGER
);
COMMENT ON TABLE taxonomie.bib_c_redlist_source IS 'Liste des sources de statuts de liste rouge';

INSERT INTO taxonomie.bib_c_redlist_source (name_source, area_code, area_name, url_source)
SELECT DISTINCT
    on (liste_rouge_source)
	liste_rouge_source,
    'FR',
    'France métropolitaine',
	doc_url as url_source
FROM
    taxonomie.taxref_liste_rouge_fr lr
    JOIN taxonomie.bdc_statut st ON lr.cd_nom = st.cd_nom
WHERE cd_sig in ('ETATFRA','TERFXFR' , 'INSEER11', 'INSEED75', 'INSEED77',  'INSEED78', 
                 'INSEED91', 'INSEED92',  'INSEED93', 'INSEED94', 'INSEED95')
AND regroupement_type IN ('Liste rouge') ;

INSERT INTO taxonomie.bib_c_redlist_source (name_source, area_code, area_name, url_source)
    VALUES ('Liste rouge mondiale des espèces menacées (2023.1)', 'WORLD', 'Monde', 'https://inpn.mnhn.fr/espece/listerouge/W'), 
           ('Liste rouge européenne des espèces menacées (2023.1)', 'EUROPE', 'Europe', 'https://inpn.mnhn.fr/espece/listerouge/EU');


---------------- Table taxonomie.bib_c_redlist_categories

CREATE TABLE taxonomie.bib_c_redlist_categories (
    code_category VARCHAR(2) PRIMARY KEY,
    sup_category VARCHAR(30),
    threatened BOOLEAN DEFAULT FALSE,
    priority_order INTEGER,
    name_fr VARCHAR(100),
    desc_fr VARCHAR(255),
    name_en VARCHAR(100),
    desc_en VARCHAR(255)
);
COMMENT ON TABLE taxonomie.bib_c_redlist_categories IS 'Liste des catégories de statuts de liste rouge';

INSERT INTO taxonomie.bib_c_redlist_categories 
(code_category, threatened, sup_category, priority_order)
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
    taxonomie.taxref_liste_rouge_fr
ORDER BY priority_order ASC;

---------------- Table taxonomie.t_c_redlist

CREATE TABLE taxonomie.t_c_redlist (
    id_redlist SERIAL PRIMARY KEY,
    status_order INTEGER,
    cd_nom INTEGER REFERENCES taxonomie.taxref (cd_nom),
    cd_ref INTEGER REFERENCES taxonomie.taxref (cd_nom),
    category CHAR(2), 
    criteria VARCHAR(150),
    id_source INTEGER REFERENCES taxonomie.bib_c_redlist_source (id_source)
);
COMMENT ON TABLE taxonomie.t_c_redlist IS 'Liste des statuts de liste rouge par taxons';

-- t_c_redlist ---------------------------------

INSERT INTO taxonomie.t_c_redlist 
(status_order, cd_nom, cd_ref, category, criteria, id_source)
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

