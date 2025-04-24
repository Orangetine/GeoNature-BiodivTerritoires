/* Lancer le script pour les tables du schema taxonomie avant */
/* Create dedicated db schema named gn_biodivterritory */
CREATE SCHEMA gn_biodivterritory;

/* INFO: Editable content: table for categories */
/* Vide */
CREATE TABLE IF NOT EXISTS gn_biodivterritory.bib_dynamic_pages_category (
    id_category serial NOT NULL,
    category_name varchar,
    category_desc varchar,
    PRIMARY KEY (id_category)
);

/* Remplie contient les pages dynamiques à enabler ou non 
Footer, Mention légales ... (is_active)*/
/* INFO: Editable content: table for pages */
CREATE TABLE IF NOT EXISTS gn_biodivterritory.t_dynamic_pages (
    id_page serial NOT NULL,
    id_category integer,
    title varchar,
    link_name varchar,
    navbar_link boolean,
    navbar_link_order integer,
    url varchar,
    short_desc varchar,
    ts_create timestamp without time zone,
    ts_update timestamp without time zone,
    creator varchar,
    is_active boolean,
    content text,
    PRIMARY KEY (id_page),
    FOREIGN KEY (id_category) REFERENCES gn_biodivterritory.bib_dynamic_pages_category (id_category),
    UNIQUE (link_name),
    UNIQUE (url)
);

/****************************************************************
 *   LISTING DATA TYPE                                          *
 ****************************************************************/
/* INFO: available data type */ 
/* Vide */
CREATE TABLE IF NOT EXISTS gn_biodivterritory.bib_datas_types (
    id_type serial NOT NULL,
    type_name varchar,
    type_protocol varchar,
    type_desc varchar,
    PRIMARY KEY (id_type)
);

/* Vide à l'installation */
CREATE TABLE IF NOT EXISTS gn_biodivterritory.t_released_datas (
    id_data_release serial NOT NULL,
    id_type integer,
    data_name varchar,
    data_desc text,
    data_url varchar,
    PRIMARY KEY (id_data_release),
    FOREIGN KEY (id_type) REFERENCES gn_biodivterritory.bib_datas_types (id_type)
);

/* Ne contient que le id_type 29 (M1), il faut rajouter 25 COM */
CREATE TABLE IF NOT EXISTS gn_biodivterritory.l_areas_type_selection (
    id_selection serial NOT NULL,
    id_type integer,
    searchable boolean,
    PRIMARY KEY (id_selection),
    UNIQUE (id_type),
    FOREIGN KEY (id_type) REFERENCES ref_geo.bib_areas_types (id_type)
);

/* Commentaires */
COMMENT ON COLUMN gn_biodivterritory.l_areas_type_selection.id_type IS 'reference to area id_type usable for app';
COMMENT ON COLUMN gn_biodivterritory.l_areas_type_selection.searchable IS 'searchable area from API with autocomplete';

CREATE TABLE IF NOT EXISTS gn_biodivterritory.t_max_threatened_status (
    cd_nom serial NOT NULL,
    threatened boolean NOT NULL,
    redlist_statut varchar,
    redlist_context varchar,
    id_source integer,
    PRIMARY KEY (cd_nom),
    FOREIGN KEY (id_source) REFERENCES taxonomie.bib_c_redlist_source (id_source)
);