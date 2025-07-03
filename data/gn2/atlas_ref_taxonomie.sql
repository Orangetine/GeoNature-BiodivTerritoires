
--TAXONOMIE
--################################
--  Import FDW
--################################

CREATE SCHEMA IF NOT EXISTS taxonomie;

DROP FOREIGN TABLE IF EXISTS taxonomie.bdc_statut CASCADE;

IMPORT FOREIGN SCHEMA taxonomie
LIMIT TO (taxonomie.bdc_statut)
FROM SERVER geonaturedbserver INTO taxonomie ;

ALTER TABLE taxonomie.bdc_statut OWNER TO myuser;
GRANT ALL ON TABLE taxonomie.bdc_statut TO myuser;

DROP SCHEMA IF EXISTS ref_nomenclatures CASCADE;
CREATE SCHEMA IF NOT EXISTS ref_nomenclatures;

IMPORT FOREIGN SCHEMA ref_nomenclatures
LIMIT TO (ref_nomenclatures.t_nomenclatures, ref_nomenclatures.bib_nomenclatures_types)
FROM SERVER geonaturedbserver INTO ref_nomenclatures;

ALTER TABLE ref_nomenclatures.t_nomenclatures OWNER TO myuser;
GRANT ALL ON TABLE ref_nomenclatures.t_nomenclatures TO myuser;

ALTER TABLE ref_nomenclatures.bib_nomenclatures_types OWNER TO myuser;
GRANT ALL ON TABLE ref_nomenclatures.bib_nomenclatures_types TO myuser;

GRANT SELECT ON ALL TABLES IN SCHEMA ref_nomenclatures TO geonatatlas;
GRANT USAGE ON SCHEMA ref_nomenclatures TO geonatatlas;

-- GRANT SELECT ON ALL TABLES IN SCHEMA ref_geo TO myuser;
-- GRANT USAGE ON SCHEMA ref_geo TO myuser;