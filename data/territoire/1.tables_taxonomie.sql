/* Tables créées pour le schéma taxonomie */
/* 2 lignes > listes rouges mondiales et européennes*/
/* Redondance deux fois dans initdb */
CREATE TABLE taxonomie.bib_c_redlist_source (
    id_source serial PRIMARY KEY,
    name_source varchar(254),
    version varchar(50)
    desc_source text,
    url_source varchar(254),
    context varchar(50),
    area_name varchar(50),
    area_code varchar(50),
    area_type varchar(50),
    priority integer
);
COMMENT ON TABLE taxonomie.bib_c_redlist_source IS 'Liste des sources de statuts de liste rouge';

/* taxonomie.bib_c_bdc_type_statut Equivalent taxonomie.bdc_statut_type */

/* taxonomie.taxref_bdc_statuts Equivalent taxonomie.bdc_statut */


/* Déjà présent dans taxonomie.bib_taxref_categories_fr */
DROP TABLE IF EXISTS taxonomie.bib_c_redlist_categories;

CREATE TABLE taxonomie.bib_c_redlist_categories (
    code_category varchar(2) PRIMARY KEY,
    sup_category varchar(30),
    threatened boolean DEFAULT FALSE,
    priority_order int,
    name_fr varchar(100),
    desc_fr varchar(254),
    name_en varchar(100),
    desc_en varchar(254)
);
COMMENT ON TABLE taxonomie.bib_c_redlist_categories IS 'Liste des catégories de statuts de liste rouge';

DROP TABLE IF EXISTS taxonomie.t_c_redlist;
/* Redondance deux fois dans initdb */
CREATE TABLE taxonomie.t_c_redlist (
    id_redlist serial NOT NULL PRIMARY KEY,
    status_order integer,
    cd_nom integer REFERENCES taxonomie.taxref (cd_nom),
    cd_ref integer REFERENCES taxonomie.taxref (cd_nom),
    category char(2) NOT NULL REFERENCES taxonomie.bib_taxref_categories_lr (id_categorie_france),
    criteria varchar(50),
    id_source integer REFERENCES taxonomie.bib_c_redlist_source (id_source)
);
COMMENT ON TABLE taxonomie.t_c_redlist IS 'Liste des statuts de liste rouge par taxons';


/*******************************
 *   Territory species list    *
 **************************MVTerritoryGeneralStats*****/
/* Création de la table de statuts BDC Statuts */
DROP TABLE IF EXISTS taxonomie.bib_c_bdc_type_statut;
/* Equivalent bdc_statut_type */
CREATE TABLE taxonomie.bib_c_bdc_type_statut (
    id_type_statut varchar(50) PRIMARY KEY NOT NULL,
    cd_type_statut varchar(50),
    lb_type_statut varchar(254),
    regroupement_type varchar(254),
    thematique varchar(50),
    type_value varchar(20)
);
/* Equivalent bdc_statut */
CREATE TABLE IF NOT EXISTS taxonomie.taxref_bdc_statuts (
    id_taxref_bdc serial PRIMARY KEY,
    cd_nom integer REFERENCES taxonomie.taxref (cd_nom),
    cd_ref integer REFERENCES taxonomie.taxref (cd_nom),
    cd_sup integer REFERENCES taxonomie.taxref (cd_nom),
    cd_type_statut varchar(50) REFERENCES taxonomie.bib_c_bdc_type_statut (id_type_statut),
    lb_type_statut varchar(254),
    regroupement_type varchar(100),
    code_statut varchar(10),
    label_statut varchar(50),
    rq_statut varchar(1000),
    cd_sig varchar(50),
    cd_doc integer,
    lb_nom varchar(50),
    lb_auteur varchar(254),
    nom_complet_html varchar(254),
    nom_valide_html varchar(254),
    regne varchar(50),
    phylum varchar(50),
    classe varchar(50),
    ordre varchar(50),
    famille varchar(50),
    group1_inpn varchar(50),
    group2_inpn varchar(50),
    lb_adm_tr varchar(50),
    niveau_admin varchar(50),
    cd_iso3166_1 varchar(50),
    cd_iso3166_2 varchar(50),
    full_citation varchar(50),
    doc_url varchar(254),
    thematique varchar(50),
    type_value varchar(50),
    id_area integer REFERENCES ref_geo.l_areas (id_area)
);


CREATE TABLE taxonomie.taxref_protection_articles (
	cd_protection varchar(20) NOT NULL,
	article varchar(100) NULL,
	intitule text NULL,
	arrete text NULL,
	cd_arrete int4 NULL,
	url_inpn varchar(250) NULL,
	cd_doc int4 NULL,
	url varchar(250) NULL,
	date_arrete int4 NULL,
	type_protection varchar(250) NULL,
	concerne_mon_territoire bool NULL,
	CONSTRAINT taxref_protection_articles_pkey PRIMARY KEY (cd_protection)
);
 
CREATE TABLE taxonomie.taxref_protection_especes (
	cd_nom int4 NOT NULL,
	cd_protection varchar(20) NOT NULL,
	nom_cite varchar(200) NULL,
	syn_cite varchar(200) NULL,
	nom_francais_cite varchar(100) NULL,
	precisions text NULL,
	cd_nom_cite varchar(255) NOT NULL,
	CONSTRAINT taxref_protection_especes_pkey PRIMARY KEY (cd_nom, cd_protection, cd_nom_cite),
	CONSTRAINT taxref_protection_especes_cd_nom_fkey FOREIGN KEY (cd_nom) REFERENCES taxonomie.taxref(cd_nom) ON UPDATE CASCADE,
	CONSTRAINT taxref_protection_especes_cd_protection_fkey FOREIGN KEY (cd_protection) REFERENCES taxonomie.taxref_protection_articles(cd_protection)
);
CREATE INDEX fki_cd_nom_taxref_protection_especes ON taxonomie.taxref_protection_especes USING btree (cd_nom);

CREATE TABLE taxonomie.taxref_liste_rouge_fr (
	id_lr serial4 NOT NULL,
	ordre_statut int4 NULL,
	vide varchar(255) NULL,
	cd_nom int4 NULL,
	cd_ref int4 NULL,
	nomcite varchar(255) NULL,
	nom_scientifique varchar(255) NULL,
	auteur varchar(255) NULL,
	nom_vernaculaire varchar(255) NULL,
	nom_commun varchar(255) NULL,
	rang bpchar(4) NULL,
	famille varchar(50) NULL,
	endemisme varchar(255) NULL,
	population varchar(255) NULL,
	commentaire text NULL,
	id_categorie_france bpchar(2) NOT NULL,
	criteres_france varchar(255) NULL,
	liste_rouge varchar(255) NULL,
	fiche_espece varchar(255) NULL,
	tendance varchar(255) NULL,
	liste_rouge_source varchar(255) NULL,
	annee_publication int4 NULL,
	categorie_lr_europe varchar(2) NULL,
	categorie_lr_mondiale varchar(5) NULL,
	CONSTRAINT pk_taxref_liste_rouge_fr PRIMARY KEY (id_lr),
	CONSTRAINT fk_taxref_lr_bib_taxref_categories FOREIGN KEY (id_categorie_france) REFERENCES taxonomie.bib_taxref_categories_lr(id_categorie_france) ON UPDATE CASCADE
);