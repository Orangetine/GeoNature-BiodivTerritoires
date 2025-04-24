DROP MATERIALIZED VIEW IF EXISTS gn_biodivterritory.mv_general_stats;

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
