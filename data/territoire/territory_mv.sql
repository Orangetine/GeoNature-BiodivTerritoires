---------------- Table gn_biodivterritory.bib_dynamic_pages_category 
DROP TABLE IF EXISTS gn_biodivterritory.bib_dynamic_pages_category CASCADE;
CREATE TABLE gn_biodivterritory.bib_dynamic_pages_category (
    id_category SERIAL PRIMARY KEY,
    category_name VARCHAR,
    category_desc VARCHAR
);

---------------- Table gn_biodivterritory.t_dynamic_pages
DROP TABLE IF EXISTS gn_biodivterritory.t_dynamic_pages CASCADE;
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
DROP TABLE IF EXISTS gn_biodivterritory.bib_datas_types CASCADE;
CREATE TABLE gn_biodivterritory.bib_datas_types (
    id_type SERIAL PRIMARY KEY,
    type_name VARCHAR,
    type_protocol VARCHAR,
    type_desc VARCHAR
);

---------------- Table gn_biodivterritory.t_released_datas
DROP TABLE IF EXISTS gn_biodivterritory.t_released_datas;
CREATE TABLE gn_biodivterritory.t_released_datas (
    id_data_release SERIAL PRIMARY KEY,
    id_type INTEGER,
    data_name VARCHAR,
    data_desc TEXT,
    data_url VARCHAR,
    FOREIGN KEY (id_type) REFERENCES gn_biodivterritory.bib_datas_types (id_type)
);

---------------- MATERIALIZED VIEW gn_biodivterritory.l_areas_type_selection
DROP MATERIALIZED VIEW IF EXISTS gn_biodivterritory.l_areas_type_selection CASCADE;
CREATE MATERIALIZED VIEW gn_biodivterritory.l_areas_type_selection AS
SELECT row_number() over() as id_selection, sr.* FROM(
SELECT
    id_type,
    CASE WHEN type_code = 'M1'
        THEN FALSE
        ELSE TRUE
    END AS searchable
FROM
    atlas.vm_bib_areas_types
WHERE
    type_code IN (
        SELECT
            unnest(string_to_array(:'_areas', ',')))) sr;

COMMENT ON COLUMN gn_biodivterritory.l_areas_type_selection.id_type IS 'reference to area id_type usable for app';
COMMENT ON COLUMN gn_biodivterritory.l_areas_type_selection.searchable IS 'searchable area from API with autocomplete';


---------------- Table gn_biodivterritory.t_max_threatened_status
DROP TABLE IF EXISTS gn_biodivterritory.t_max_threatened_status CASCADE;
CREATE TABLE gn_biodivterritory.t_max_threatened_status (
    cd_nom SERIAL PRIMARY KEY,
    threatened BOOLEAN NOT NULL,
    redlist_statut VARCHAR,
    id_source INTEGER
);

DO $$
DECLARE
    arrow RECORD;
BEGIN
    FOR arrow IN (
        SELECT DISTINCT cd_ref
        FROM gn_biodivterritory.t_c_redlist
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
        FROM gn_biodivterritory.t_c_redlist t
        JOIN gn_biodivterritory.bib_c_redlist_source s ON s.id_source = t.id_source
        JOIN gn_biodivterritory.bib_c_redlist_categories c ON c.code_category = t.category
        WHERE t.cd_ref = arrow.cd_ref
        ORDER BY annee_publication DESC, c.priority_order
        LIMIT 1;
    END LOOP;
END;
$$;

----------------------------- MV GN_BIODIVTERRITORY -----------------------------------------
CREATE EXTENSION IF NOT EXISTS unaccent;
------------ Materialized View gn_biodivterritory.mv_l_areas_autocomplete
DROP MATERIALIZED VIEW IF EXISTS gn_biodivterritory.mv_l_areas_autocomplete CASCADE;
CREATE MATERIALIZED VIEW gn_biodivterritory.mv_l_areas_autocomplete AS (
    SELECT DISTINCT
        vm_l_areas.id_area AS id,
        vm_bib_areas_types.type_name AS type_name,
        lower(unaccent (vm_l_areas.area_name)) AS search_area_name,
        vm_bib_areas_types.type_desc AS type_desc,
        vm_bib_areas_types.type_code AS type_code,
        vm_l_areas.area_name AS area_name,
        vm_l_areas.area_code AS area_code
    FROM
        atlas.vm_bib_areas_types
    LEFT OUTER JOIN atlas.vm_l_areas ON vm_l_areas.id_type = vm_bib_areas_types.id_type
    JOIN atlas.vm_cor_area_synthese ON vm_cor_area_synthese.id_area = vm_l_areas.id_area
    JOIN gn_biodivterritory.l_areas_type_selection ON vm_l_areas.id_type = l_areas_type_selection.id_type
WHERE
    vm_cor_area_synthese.id_area IS NOT NULL
    AND l_areas_type_selection.searchable);

CREATE UNIQUE INDEX index_unique_search_area_id_area ON gn_biodivterritory.mv_l_areas_autocomplete (id);

CREATE INDEX index_search_area_code ON gn_biodivterritory.mv_l_areas_autocomplete (area_code);

CREATE INDEX index_search_area_name_trgm ON gn_biodivterritory.mv_l_areas_autocomplete USING gist (search_area_name gist_trgm_ops);

------------ Materialized View gn_biodivterritory.mv_general_stats
DROP MATERIALIZED VIEW IF EXISTS gn_biodivterritory.mv_general_stats CASCADE;
CREATE MATERIALIZED VIEW gn_biodivterritory.mv_general_stats AS
WITH count_occtax AS (
    SELECT COUNT(*) AS count
    FROM atlas.vm_observations
),
count_observer AS (
    SELECT COUNT(*) as count 
    FROM (
            SELECT DISTINCT observateurs
            FROM atlas.vm_observations) as distinct_obs
),
count_taxa AS (
    SELECT COUNT(DISTINCT cd_ref) AS count
        FROM atlas.vm_taxons 
)
SELECT
    row_number() OVER () AS id,
        count_occtax.count AS count_occtax,
        count_observer.count AS count_observer,
        count_taxa.count AS count_taxa
    FROM
        count_occtax,
        count_observer,
        count_taxa;

------------ Materialized View gn_biodivterritory.mv_territory_general_stats
-- Requête Optimisée
DROP MATERIALIZED VIEW IF EXISTS gn_biodivterritory.mv_territory_general_stats CASCADE;
CREATE MATERIALIZED VIEW gn_biodivterritory.mv_territory_general_stats AS
WITH base AS (
  SELECT DISTINCT ON (s.id_synthese, s.id_area_geom)
      s.id_synthese,
      s.cd_nom,
      s.dateobs::date AS dateobs,
      s.observateurs,
      s.id_area_geom
  FROM synthese.syntheseff_territoire s
  JOIN atlas.vm_l_areas a ON a.id_area = s.id_area_geom
  JOIN atlas.vm_bib_areas_types t ON a.id_type = t.id_type
  WHERE EXISTS (
    SELECT 1 
    FROM gn_biodivterritory.l_areas_type_selection sel
    WHERE sel.id_type = a.id_type
  )
),
agg AS (
  SELECT
      b.id_area_geom,
      COUNT(DISTINCT b.id_synthese)                                         AS count_data,
      COUNT(DISTINCT tx.cd_ref)                                             AS count_taxa,
      COUNT(DISTINCT tx.cd_ref) FILTER (WHERE ts.threatened)                AS count_threatened,
      COUNT(DISTINCT b.id_synthese)                                         AS count_occtax,
      COUNT(DISTINCT b.dateobs)                                             AS count_date,
      COUNT(DISTINCT lower(trim(o.obs_raw)))                                AS count_observer,
      MAX(b.dateobs)                                                        AS last_obs
  FROM base b
  JOIN atlas.vm_taxref tx ON b.cd_nom = tx.cd_nom
  LEFT JOIN gn_biodivterritory.t_max_threatened_status ts ON tx.cd_ref = ts.cd_nom
  LEFT JOIN LATERAL unnest(string_to_array(COALESCE(b.observateurs,''), ',')) AS o(obs_raw) ON TRUE
  GROUP BY b.id_area_geom
)
SELECT
    a.id_area,
    t.type_code,
    a.area_code,
    a.area_name,
    ag.count_data,
    ag.count_taxa,
    ag.count_threatened,
    ag.count_occtax,
    ag.count_date,
    ag.count_observer,
    ag.last_obs,
    a.geom        AS geom_local,  
    a.the_geom
FROM agg ag
JOIN atlas.vm_l_areas a           ON a.id_area = ag.id_area_geom
JOIN atlas.vm_bib_areas_types t   ON a.id_type = t.id_type
WHERE EXISTS (
  SELECT 1
  FROM gn_biodivterritory.l_areas_type_selection sel
  WHERE sel.id_type = a.id_type
);

CREATE UNIQUE INDEX ON gn_biodivterritory.mv_territory_general_stats (id_area);
CREATE INDEX        ON gn_biodivterritory.mv_territory_general_stats (type_code);
CREATE INDEX        ON gn_biodivterritory.mv_territory_general_stats (area_name);
CREATE INDEX        ON gn_biodivterritory.mv_territory_general_stats (area_code);
CREATE INDEX        ON gn_biodivterritory.mv_territory_general_stats USING GIST (geom_local);
CREATE INDEX        ON gn_biodivterritory.mv_territory_general_stats USING GIST (the_geom);




-------------- Materialized View gn_biodivterritory.mv_area_ntile_limit
DROP MATERIALIZED VIEW IF EXISTS gn_biodivterritory.mv_area_ntile_limit CASCADE;
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
