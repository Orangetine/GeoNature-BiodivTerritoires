
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

DROP FOREIGN TABLE IF EXISTS synthese.cor_sensitivity_area_type CASCADE;

IMPORT FOREIGN SCHEMA gn_sensitivity
LIMIT TO (cor_sensitivity_area_type) FROM SERVER geonaturedbserver INTO synthese;

GRANT SELECT ON ALL TABLES IN SCHEMA ref_nomenclatures TO geonatatlas;
GRANT USAGE ON SCHEMA ref_nomenclatures TO geonatatlas;

GRANT USAGE ON SCHEMA atlas to geonatatlas;
GRANT USAGE ON SCHEMA taxonomie to geonatatlas;
GRANT USAGE ON SCHEMA gn_biodivterritory to geonatatlas;

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA atlas to geonatatlas;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA taxonomie to geonatatlas;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA gn_biodivterritory to geonatatlas;

GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA atlas to geonatatlas;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA taxonomie to geonatatlas;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA gn_biodivterritory to geonatatlas;