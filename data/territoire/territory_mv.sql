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

---------------- MATERIALIZED VIEW gn_biodivterritory.l_areas_type_selection

CREATE MATERIALIZED VIEW gn_biodivterritory.l_areas_type_selection AS
SELECT row_number() over() as id_selection, sr.* FROM(
SELECT
    id_type,
    CASE WHEN type_code = 'COM'
        THEN TRUE
        ELSE FALSE
    END AS searchable
FROM
    ref_geo.bib_areas_types
WHERE
    type_code IN (
        SELECT
            unnest(string_to_array(:'_areas', ',')))) sr;

COMMENT ON COLUMN gn_biodivterritory.l_areas_type_selection.id_type IS 'reference to area id_type usable for app';
COMMENT ON COLUMN gn_biodivterritory.l_areas_type_selection.searchable IS 'searchable area from API with autocomplete';


---------------- Table gn_biodivterritory.t_max_threatened_status

CREATE TABLE gn_biodivterritory.t_max_threatened_status (
    cd_nom SERIAL PRIMARY KEY,
    threatened BOOLEAN NOT NULL,
    redlist_statut VARCHAR,
   -- redlist_context VARCHAR,
    id_source INTEGER
    -- FOREIGN KEY (id_source) REFERENCES taxonomie.bib_c_redlist_source (id_source)
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
            id_source
        )
        SELECT
            t.cd_nom,
            c.threatened,
            t.category,
            s.id_source
        FROM taxonomie.t_c_redlist t
        JOIN taxonomie.bib_c_redlist_source s ON s.id_source = t.id_source
        JOIN taxonomie.bib_c_redlist_categories c ON c.code_category = t.category
        WHERE t.cd_ref = arrow.cd_ref
        ORDER BY annee_publication DESC, c.priority_order
        LIMIT 1;
    END LOOP;
END;
$$;

----------------------------- MV GN_BIODIVTERRITORY -----------------------------------------
CREATE EXTENSION IF NOT EXISTS unaccent;
------------ Materialized View gn_biodivterritory.mv_l_areas_autocomplete

CREATE MATERIALIZED VIEW gn_biodivterritory.mv_l_areas_autocomplete AS (
    SELECT DISTINCT
        l_areas.id_area AS id,
        bib_areas_types.type_name AS type_name,
        lower(unaccent (l_areas.area_name)) AS search_area_name,
        bib_areas_types.type_desc AS type_desc,
        bib_areas_types.type_code AS type_code,
        l_areas.area_name AS area_name,
        l_areas.area_code AS area_code
    FROM
        ref_geo.bib_areas_types
    LEFT OUTER JOIN ref_geo.l_areas ON l_areas.id_type = ref_geo.bib_areas_types.id_type
    NATURAL JOIN synthese.cor_area_synthese
    JOIN gn_biodivterritory.l_areas_type_selection ON l_areas.id_type = l_areas_type_selection.id_type
WHERE
    cor_area_synthese.id_area IS NOT NULL
    AND l_areas_type_selection.searchable);

CREATE UNIQUE INDEX index_unique_search_area_id_area ON gn_biodivterritory.mv_l_areas_autocomplete (id);

CREATE INDEX index_search_area_code ON gn_biodivterritory.mv_l_areas_autocomplete (area_code);

CREATE INDEX index_search_area_name_trgm ON gn_biodivterritory.mv_l_areas_autocomplete USING gist (search_area_name gist_trgm_ops);

------------ Materialized View gn_biodivterritory.mv_general_stats

CREATE MATERIALIZED VIEW gn_biodivterritory.mv_general_stats AS
WITH count_occtax AS (
    SELECT COUNT(*) AS count
    FROM atlas.vm_observations
),
count_observer AS (
    SELECT COUNT(*) as count 
    FROM (
            SELECT DISTINCT observateurs
            FROM atlas.vm_observations)
),
count_taxa AS (
    SELECT COUNT(DISTINCT cd_ref) AS count
        FROM atlas.vm_taxons
),
count_dataset AS (
    SELECT COUNT(*) AS count
    FROM ( 
        SELECT DISTINCT id_dataset
        FROM atlas.vm_observations) 
)
SELECT
    row_number() OVER () AS id,
        count_occtax.count AS count_occtax,
        count_observer.count AS count_observer,
        count_taxa.count AS count_taxa,
        count_dataset.count AS count_dataset
    FROM
        count_occtax,
        count_observer,
        count_dataset,
        count_taxa;

------------ Materialized View gn_biodivterritory.mv_territory_general_stats

CREATE MATERIALIZED VIEW gn_biodivterritory.mv_territory_general_stats AS
SELECT
    l_areas.id_area,
    bib_areas_types.type_code,
    l_areas.area_code,
    l_areas.area_name,
    count(DISTINCT syntheseff.id_synthese) AS count_data,
    count(DISTINCT taxref.cd_ref) AS count_taxa,
    count(DISTINCT taxref.cd_ref) FILTER (WHERE gn_biodivterritory.t_max_threatened_status.threatened = TRUE) AS count_threatened,
    count(DISTINCT syntheseff.id_synthese) AS count_occtax,
    count(DISTINCT syntheseff.id_dataset) AS count_dataset,
    count(DISTINCT syntheseff.dateobs) AS count_date,
    count(DISTINCT syntheseff.observateurs) AS count_observer,
    max(dateobs) AS last_obs,
    l_areas.geom AS geom_local,
    st_transform (l_areas.geom, 4326) AS geom_4326
FROM
    synthese.syntheseff
    JOIN synthese.cor_area_synthese ON syntheseff.id_synthese = cor_area_synthese.id_synthese
    JOIN ref_geo.l_areas ON cor_area_synthese.id_area = l_areas.id_area
    JOIN gn_biodivterritory.l_areas_type_selection ON l_areas_type_selection.id_type = l_areas.id_type
    JOIN ref_geo.bib_areas_types ON l_areas_type_selection.id_type = bib_areas_types.id_type
    JOIN taxonomie.taxref ON syntheseff.cd_nom = taxref.cd_nom
    LEFT OUTER JOIN gn_biodivterritory.t_max_threatened_status ON gn_biodivterritory.t_max_threatened_status.cd_nom = taxonomie.taxref.cd_ref

GROUP BY
    l_areas.id_area,
    l_areas.area_code,
    l_areas.area_name,
    bib_areas_types.type_code,
    l_areas.geom;

CREATE UNIQUE INDEX ON gn_biodivterritory.mv_territory_general_stats (id_area);
CREATE INDEX ON gn_biodivterritory.mv_territory_general_stats (type_code);
CREATE INDEX ON gn_biodivterritory.mv_territory_general_stats (area_name);
CREATE INDEX ON gn_biodivterritory.mv_territory_general_stats (area_code);
CREATE INDEX ON gn_biodivterritory.mv_territory_general_stats USING gist (geom_local);
CREATE INDEX ON gn_biodivterritory.mv_territory_general_stats USING gist (geom_4326);

-- ------------ Materialized View gn_biodivterritory.mv_area_ntile_limit

CREATE MATERIALIZED VIEW gn_biodivterritory.mv_area_ntile_limit AS 
    WITH occtax AS (
        SELECT
            id_area,
            type_code,
            count_occtax AS count,
            ntile(5) OVER (ORDER BY count_occtax) AS ntile
        FROM
            gn_biodivterritory.mv_territory_general_stats),
        taxa AS (
        SELECT
            id_area,
            type_code,
            count_taxa AS count,
            ntile(5) OVER (ORDER BY count_taxa) AS ntile
        FROM
            gn_biodivterritory.mv_territory_general_stats),
        threatened AS (
            SELECT
                id_area,
                type_code,
                count_threatened AS count,
                ntile(5) OVER (ORDER BY count_threatened) AS ntile
            FROM
                gn_biodivterritory.mv_territory_general_stats),
        observer AS (
            SELECT
                id_area,
                type_code,
                count_observer AS count,
                ntile(5) OVER (ORDER BY count_observer) AS ntile
            FROM
                gn_biodivterritory.mv_territory_general_stats),
        date AS (
            SELECT
                id_area,
                type_code,
                count_date AS count,
                ntile(5) OVER (ORDER BY count_date) AS ntile
            FROM
                gn_biodivterritory.mv_territory_general_stats),
        u AS (
            SELECT
                'occtax' AS type,
                min(count) AS min,
                max(count) AS max,
                ntile
            FROM occtax GROUP BY ntile
            UNION
            SELECT
                'taxa',
                min(count),
                max(count),
                ntile
            FROM taxa GROUP BY ntile
            UNION
            SELECT
                'threatened',
                min(count),
                max(count),
                ntile
            FROM threatened GROUP BY ntile
            UNION
            SELECT
                'observer',
                min(count),
                max(count),
                ntile
            FROM observer GROUP BY ntile
            UNION
            SELECT
                'date',
                min(count),
                max(count),
                ntile
            FROM date GROUP BY ntile)

SELECT 
    row_number() OVER () AS id, *
FROM u ORDER BY type, ntile;