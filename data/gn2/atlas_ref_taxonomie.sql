
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

CREATE SCHEMA IF NOT EXISTS ref_nomenclatures;

IMPORT FOREIGN SCHEMA ref_nomenclatures
FROM SERVER geonaturedbserver INTO ref_nomenclatures ;