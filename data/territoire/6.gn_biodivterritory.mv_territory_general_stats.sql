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
