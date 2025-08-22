CREATE OR REPLACE VIEW synthese.syntheseff_territoire AS
WITH areas AS (
    SELECT DISTINCT ON (sa.id_synthese, t.type_code)
        sa.id_synthese,
        sa.id_area,
        a.centroid,
        st_transform(a.centroid, 4326) AS centroid_4326,
        t.type_code
    FROM atlas.vm_cor_area_synthese sa
    JOIN atlas.vm_l_areas a ON sa.id_area = a.id_area
    JOIN atlas.vm_bib_areas_types t ON a.id_type = t.id_type
    WHERE t.type_code::text = ANY (
        ARRAY['M10','COM','DEP']  -- ici tu peux élargir la liste
    )
),
obs_data AS (
    SELECT
        s.id_synthese,
        s.cd_nom,
        s.id_dataset,
        s.date_min AS dateobs,
        s.observers AS observateurs,
        (s.altitude_min + s.altitude_max) / 2 AS altitude_retenue,
        CASE
            WHEN dl.cd_nomenclature::text = '1' THEN (
                SELECT a.centroid_4326
                FROM areas a
                WHERE a.id_synthese = s.id_synthese
                  AND a.type_code = 'COM'
                LIMIT 1
            )
            WHEN dl.cd_nomenclature::text = '2' THEN (
                SELECT a.centroid_4326
                FROM areas a
                WHERE a.id_synthese = s.id_synthese
                  AND a.type_code = 'M10'
                LIMIT 1
            )
            WHEN dl.cd_nomenclature::text = '3' THEN (
                SELECT a.centroid_4326
                FROM areas a
                WHERE a.id_synthese = s.id_synthese
                  AND a.type_code = 'DEP'
                LIMIT 1
            )
            ELSE st_transform(s.the_geom_point, 4326)
        END AS the_geom_point,
        s.count_min AS effectif_total,
        dl.cd_nomenclature::integer AS diffusion_level
    FROM atlas.vm_synthese s
    LEFT JOIN atlas.vm_t_nomenclatures dl
        ON s.id_nomenclature_diffusion_level = dl.id_nomenclature
    LEFT JOIN atlas.vm_t_nomenclatures st
        ON s.id_nomenclature_observation_status = st.id_nomenclature
    WHERE (
        NOT dl.cd_nomenclature::text = '4'
        OR s.id_nomenclature_diffusion_level IS NULL
    )
    AND st.cd_nomenclature::text = 'Pr'
    AND s.id_nomenclature_valid_status <> ALL (ARRAY[317, 318, 319, 458])
),
joined AS (
    SELECT DISTINCT ON (d.id_synthese, c.id_area)
        d.id_synthese,
        d.id_dataset,
        d.cd_nom,
        d.dateobs,
        d.observateurs,
        d.altitude_retenue,
        d.the_geom_point,
        d.effectif_total,
        c.id_area AS id_area_geom,
        c.area_code,
        d.diffusion_level
    FROM obs_data d
    JOIN atlas.vm_l_areas c
      ON ST_Intersects(d.the_geom_point, c.the_geom)
    ORDER BY d.id_synthese, c.id_area
)
SELECT *
FROM joined;
