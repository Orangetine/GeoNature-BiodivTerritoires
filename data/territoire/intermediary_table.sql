
------------------ MATERIALIZED VIEW atlas.vm_cor_area_synthese

DROP MATERIALIZED VIEW IF EXISTS atlas.vm_cor_area_synthese CASCADE;
CREATE MATERIALIZED VIEW atlas.vm_cor_area_synthese AS
SELECT
      id_synthese
    , id_area
FROM synthese.cor_area_synthese 
WITH DATA;

CREATE UNIQUE INDEX i_vm_cor_area_synthese ON atlas.vm_cor_area_synthese USING btree (id_synthese, id_area );
CREATE INDEX i_id_area ON atlas.vm_cor_area_synthese USING btree (id_area);
CREATE INDEX i_id_synthese ON atlas.vm_cor_area_synthese USING btree (id_synthese);

------------------ MATERIALIZED VIEW atlas.vm_bib_areas_types

DROP MATERIALIZED VIEW IF EXISTS atlas.vm_bib_areas_types CASCADE;
CREATE MATERIALIZED VIEW atlas.vm_bib_areas_types AS
SELECT t.id_type, t.type_code, t.type_name, t.type_desc
FROM ref_geo.bib_areas_types t
WHERE
    type_code IN (SELECT * from string_to_table(:'_areas', ','));

CREATE INDEX ON atlas.vm_bib_areas_types (id_type);
CREATE INDEX ON atlas.vm_bib_areas_types (type_code);
CREATE INDEX ON atlas.vm_bib_areas_types (type_name);

---------------- MATERIALIZED VIEW atlas.vm_l_areas

DROP MATERIALIZED VIEW IF EXISTS atlas.vm_l_areas;
CREATE MATERIALIZED VIEW atlas.vm_l_areas AS
SELECT
       a.id_area                                AS id_area
     , a.area_code                              AS area_code
     , a.area_name                              AS area_name
     , a.id_type                                AS id_type
     , a.geom                                   AS geom_local    
     , a.geom_4326                              AS the_geom
     , st_asgeojson(a.geom_4326)                AS area_geojson
     , ''::text                                 AS description
     , a.enable
FROM ref_geo.l_areas a
JOIN ref_geo.bib_areas_types b on a.id_type = b.id_type
    JOIN atlas.t_layer_territoire layer ON ST_INTERSECTS(layer.the_geom, a.geom_4326)
WHERE
    enable = TRUE AND
    (b.type_code IN (
        SELECT * from string_to_table(:'_type', ',')
        )
        OR a.id_type in (
            SELECT id_area_type
            FROM synthese.cor_sensitivity_area_type
        ))
WITH DATA;

CREATE UNIQUE INDEX vm_l_areas_id_area_idx
    ON atlas.vm_l_areas (id_area);

CREATE INDEX vm_l_areas_the_geom_gidx
    ON atlas.vm_l_areas
        USING gist
        (the_geom);

CREATE INDEX vm_l_areas_geom_local_gidx
    ON atlas.vm_l_areas
        USING gist
        (geom_local);

CREATE INDEX vm_l_areas_area_code_idx
    ON atlas.vm_l_areas (area_code);

------------------ MATERIALIZED VIEW atlas.vm_synthese

DROP MATERIALIZED VIEW IF EXISTS atlas.vm_synthese;
CREATE MATERIALIZED VIEW atlas.vm_synthese AS
SELECT id_synthese
       , cd_nom
       , observers
       , date_min
       , id_dataset
       , id_nomenclature_bio_status
       , id_nomenclature_observation_status
       , id_nomenclature_diffusion_level
       , id_nomenclature_sensitivity
       , id_nomenclature_valid_status   ---> Piste réalignement colonne pour filtre comme syntheseff
       , the_geom_local
FROM synthese.synthese;

CREATE UNIQUE INDEX vm_synthese_idx
    ON atlas.vm_synthese (id_synthese);

CREATE INDEX vm_synthese_the_geom_local_gidx
    ON atlas.vm_synthese
        USING gist (the_geom_local);

------------------ MATERIALIZED VIEW atlas.vm_t_nomenclatures

DROP MATERIALIZED VIEW IF EXISTS atlas.vm_t_nomenclatures;
CREATE MATERIALIZED VIEW atlas.vm_t_nomenclatures AS
SELECT id_nomenclature
       , id_type
       , cd_nomenclature
       , mnemonique
       , definition_fr  
FROM ref_nomenclatures.t_nomenclatures;

CREATE UNIQUE INDEX vm_t_nomenclatures_idx
    ON atlas.vm_t_nomenclatures (id_nomenclature);

------------------ MATERIALIZED VIEW atlas.vm_bib_nomenclatures_types

DROP MATERIALIZED VIEW IF EXISTS atlas.vm_bib_nomenclatures_types;
CREATE MATERIALIZED VIEW atlas.vm_bib_nomenclatures_types AS
SELECT id_type, mnemonique 
FROM ref_nomenclatures.bib_nomenclatures_types;

CREATE UNIQUE INDEX  vm_bib_nomenclatures_types_idx
    ON atlas.vm_bib_nomenclatures_types (id_type);







