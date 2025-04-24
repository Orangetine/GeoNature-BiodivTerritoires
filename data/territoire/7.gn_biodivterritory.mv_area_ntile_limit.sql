DROP MATERIALIZED VIEW IF EXISTS gn_biodivterritory.mv_area_ntile_limit CASCADE;

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
