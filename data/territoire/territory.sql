CREATE SCHEMA gn_biodivterritory;

---------------- Table gn_biodivterritory.bib_dynamic_pages_category 

CREATE TABLE gn_biodivterritory.bib_dynamic_pages_category (
    id_category SERIAL PRIMARY KEY,
    category_name VARCHAR,
    category_desc VARCHAR
);

---------------- Table gn_biodivterritory.t_dynamic_pages

CREATE TABLE gn_biodivterritory.t_dynamic_pages (
    id_page SERIAL PRIMARY KEY,
    id_category INTEGER,
    title VARCHAR,
    link_name VARCHAR UNIQUE,
    navbar_link BOOLEAN,
    navbar_link_order INTEGER,
    url VARCHAR UNIQUE,
    short_desc VARCHAR,
    ts_create TIMESTAMP WITHOUT TIME ZONE,
    ts_update TIMESTAMP WITHOUT TIME ZONE,
    creator VARCHAR,
    is_active BOOLEAN,
    content TEXT,
    FOREIGN KEY (id_category) REFERENCES gn_biodivterritory.bib_dynamic_pages_category (id_category)
);

---------------- Table gn_biodivterritory.bib_datas_types

CREATE TABLE gn_biodivterritory.bib_datas_types (
    id_type SERIAL PRIMARY KEY,
    type_name VARCHAR,
    type_protocol VARCHAR,
    type_desc VARCHAR
);

---------------- Table gn_biodivterritory.t_released_datas

CREATE TABLE gn_biodivterritory.t_released_datas (
    id_data_release SERIAL PRIMARY KEY,
    id_type INTEGER,
    data_name VARCHAR,
    data_desc TEXT,
    data_url VARCHAR,
    FOREIGN KEY (id_type) REFERENCES gn_biodivterritory.bib_datas_types (id_type)
);

---------------- Table gn_biodivterritory.l_areas_type_selection

CREATE TABLE gn_biodivterritory.l_areas_type_selection (
    id_selection SERIAL PRIMARY KEY,
    id_type INTEGER UNIQUE,
    searchable BOOLEAN,
    FOREIGN KEY (id_type) REFERENCES ref_geo.bib_areas_types (id_type)
);

COMMENT ON COLUMN gn_biodivterritory.l_areas_type_selection.id_type IS 'reference to area id_type usable for app';
COMMENT ON COLUMN gn_biodivterritory.l_areas_type_selection.searchable IS 'searchable area from API with autocomplete';

INSERT INTO gn_biodivterritory.l_areas_type_selection (id_type, searchable)
SELECT
    id_type,
    CASE WHEN id_type = 25
        THEN TRUE
        ELSE FALSE
    END AS searchable
FROM
    ref_geo.bib_areas_types
WHERE
    type_code IN (
        SELECT
            unnest(string_to_array(:'_areas', ',')))
ON CONFLICT
    DO NOTHING;


---------------- Table gn_biodivterritory.t_max_threatened_status

CREATE TABLE gn_biodivterritory.t_max_threatened_status (
    cd_nom serial NOT NULL,
    threatened boolean NOT NULL,
    redlist_statut varchar,
    redlist_context varchar,
    id_source integer,
    PRIMARY KEY (cd_nom),
    FOREIGN KEY (id_source) REFERENCES taxonomie.bib_c_redlist_source (id_source)
);

DO $$
DECLARE
    arrow RECORD;
BEGIN
    FOR arrow IN (
        SELECT DISTINCT cd_ref
        FROM taxonomie.t_c_redlist
    ) LOOP
        INSERT INTO gn_biodivterritory.t_max_threatened_status (
            cd_nom,
            threatened,
            redlist_statut,
            redlist_context,
            id_source
        )
        SELECT
            t.cd_nom,
            c.threatened,
            t.category,
            s.context,
            s.id_source
        FROM taxonomie.t_c_redlist t
        JOIN taxonomie.bib_c_redlist_source s ON s.id_source = t.id_source
        JOIN taxonomie.bib_c_redlist_categories c ON c.code_category = t.category
        WHERE t.cd_ref = arrow.cd_ref
        ORDER BY s.priority, c.priority_order
        LIMIT 1;
    END LOOP;
END;
$$;
