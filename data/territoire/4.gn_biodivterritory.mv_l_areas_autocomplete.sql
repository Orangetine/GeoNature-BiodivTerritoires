DROP MATERIALIZED VIEW IF EXISTS gn_biodivterritory.mv_l_areas_autocomplete;

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
