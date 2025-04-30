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
    NATURAL JOIN gn_synthese.cor_area_synthese
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
    SELECT
        count(*) AS count
    FROM ( SELECT DISTINCT
            id_synthese
        FROM
            gn_synthese.synthese) AS t
),
count_observer AS (
    SELECT
        count(*) AS count
    FROM ( SELECT DISTINCT
            observers
        FROM
            gn_synthese.synthese) AS t
),
count_taxa AS (
    SELECT
        count(*) AS count
    FROM ( SELECT DISTINCT
            cd_ref
        FROM
            gn_synthese.synthese
            JOIN taxonomie.taxref ON synthese.cd_nom = taxref.cd_nom
                AND taxref.id_rang = 'ES') AS t
),
count_dataset AS (
    SELECT
        count(*) AS count
    FROM ( SELECT DISTINCT
            id_dataset
        FROM
            gn_synthese.synthese) AS t
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
    count(DISTINCT synthese.id_synthese) AS count_data,
    count(DISTINCT taxref.cd_ref) AS count_taxa,
    count(DISTINCT taxref.cd_ref) FILTER (WHERE gn_biodivterritory.t_max_threatened_status.threatened = TRUE) AS count_threatened,
    count(DISTINCT synthese.id_synthese) AS count_occtax,
    count(DISTINCT synthese.id_dataset) AS count_dataset,
    count(DISTINCT synthese.date_min) AS count_date,
    count(DISTINCT synthese.observers) AS count_observer,
    max(date_min) AS last_obs,
    l_areas.geom AS geom_local,
    st_transform (l_areas.geom, 4326) AS geom_4326
FROM
    gn_synthese.synthese
    JOIN gn_synthese.cor_area_synthese ON synthese.id_synthese = cor_area_synthese.id_synthese
    JOIN ref_geo.l_areas ON cor_area_synthese.id_area = l_areas.id_area
    JOIN gn_biodivterritory.l_areas_type_selection ON l_areas_type_selection.id_type = l_areas.id_type
    JOIN ref_geo.bib_areas_types ON l_areas_type_selection.id_type = bib_areas_types.id_type
    JOIN taxonomie.taxref ON synthese.cd_nom = taxref.cd_nom
    LEFT OUTER JOIN gn_biodivterritory.t_max_threatened_status ON gn_biodivterritory.t_max_threatened_status.cd_nom = taxonomie.taxref.cd_ref
WHERE
    taxref.id_rang LIKE 'ES'
    AND taxref.cd_nom = taxref.cd_ref
    AND synthese.id_nomenclature_diffusion_level = ref_nomenclatures.get_id_nomenclature ('NIV_PRECIS', '5')
    AND l_areas.id_type IN (
        SELECT
            id_type
        FROM
            gn_biodivterritory.l_areas_type_selection)
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

------------ Materialized View gn_biodivterritory.mv_area_ntile_limit

CREATE MATERIALIZED VIEW gn_biodivterritory.mv_area_ntile_limit AS (
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
                    count_taxa AS count,
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
                            FROM
                                occtax
                            GROUP BY
                                ntile
                            UNION
                            SELECT
                                'taxa',
                                min(count),
                                max(count),
                                ntile
                            FROM
                                taxa
                            GROUP BY
                                ntile
                            UNION
                            SELECT
                                'threatened',
                                min(count),
                                max(count),
                                ntile
                            FROM
                                taxa
                            GROUP BY
                                ntile
                            UNION
                            SELECT
                                'observer',
                                min(count),
                                max(count),
                                ntile
                            FROM
                                observer
                            GROUP BY
                                ntile
                            UNION
                            SELECT
                                'date',
                                min(count),
                                max(count),
                                ntile
                            FROM
                                date
                            GROUP BY
                                ntile
)
                            SELECT
                                row_number() OVER () AS id,
                                *
                            FROM
                                u
                            ORDER BY
                                type,
                                ntile);
