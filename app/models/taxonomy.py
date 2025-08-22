from sqlalchemy import Boolean, Column, ForeignKey, Integer, String, Text
from utils_flask_sqla.serializers import serializable

from config.config import APP_SCHEMA_NAME
from app.core.env import DB

# Materialized View
@serializable
class TaxrefProtectionArticles(DB.Model):
    __tablename__ = "taxref_protection_articles"
    __table_args__ = {"schema": APP_SCHEMA_NAME}
    cd_protection = Column(String, primary_key=True)
    article = Column(String)
    intitule = Column(String)
    arrete = Column(String)
    url_inpn = Column(String)
    cd_doc = Column(Integer)
    url = Column(String)
    date_arrete = Column(Integer)
    type_protection = Column(String)

    def __repr__(self):
        return "<TaxrefProtectionArticles %r>" % self.article

# Materialized View
@serializable
class TaxrefProtectionEspeces(DB.Model):
    __tablename__ = "taxref_protection_especes"
    __table_args__ = {"schema": APP_SCHEMA_NAME}
    cd_nom = Column(String, primary_key=True)
    cd_protection = Column(String, primary_key=True)
    nom_cite = Column(String)
    nom_francais_cite = Column(String)

# Materialized view
@serializable
class Taxref(DB.Model):
    __tablename__ = "vm_taxref"
    __table_args__ = {"schema": "atlas"}
    cd_nom = Column(Integer, primary_key=True)
    cd_ref = Column(Integer)  
    cd_sup = Column(Integer)
    cd_taxsup = Column(Integer)
    classe = Column(String)
    famille = Column(String)
    group1_inpn = Column(String)
    group2_inpn = Column(String)
    group3_inpn = Column(String)
    id_habitat = Column(Integer)
    id_rang = Column(String)
    id_statut = Column(String)
    lb_auteur = Column(String)
    lb_nom = Column(String)
    nom_complet = Column(String)
    nom_complet_html = Column(String)
    nom_valide = Column(String)
    nom_vern = Column(String)
    nom_vern_eng = Column(String)
    ordre = Column(String)
    phylum = Column(String)
    regne = Column(String)
    sous_famille = Column(String)
    tribu = Column(String)
    url = Column(String)

    def __repr__(self):
        return "<Taxref %r>" % self.nom_complet

# Foreign Table
class CorTaxonAttribut(DB.Model):
    __tablename__ = "cor_taxon_attribut"
    __table_args__ = {"schema": "taxonomie"}
    id_attribut = Column(Integer, nullable=False, primary_key=True)
    cd_ref = Column(Integer, nullable=False, primary_key=True)
    valeur_attribut = Column(Text, nullable=False)

    def __repr__(self):
        return "<CorTaxonAttribut %r>" % self.valeur_attribut

# Materialized View
@serializable
class TaxrefLR(DB.Model):
    __tablename__ = "taxref_liste_rouge_fr"
    __table_args__ = {"schema": APP_SCHEMA_NAME}
    id_lr = Column(Integer, primary_key=True)
    cd_nom = Column(Integer)
    cd_ref = Column(Integer)
    lb_nom = Column(String)
    lb_auteur = Column(String)
    nom_vern = Column(String)
    id_rang = Column(String)
    famille = Column(String)
    id_categorie_france = Column(String)
    criteres_france = Column(String)
    liste_rouge = Column(String)
    fiche_espece = Column(String)
    liste_rouge_source = Column(String)
    annee_publication = Column(Integer)
    ordre_statut = Column(Integer)

# Materialized View
@serializable
class BibRedlistCategories(DB.Model):
    __tablename__ = "bib_c_redlist_categories"
    __table_args__ = {"schema": APP_SCHEMA_NAME}
    code_category = Column(String, primary_key=True)
    threatened = Column(Boolean)
    sup_category = Column(String)
    priority_order = Column(Integer)

# Materialized View
class BibRedlistSource(DB.Model):
    __tablename__ = "bib_c_redlist_source"
    __table_args__ = {"schema": APP_SCHEMA_NAME}
    id_source = Column(Integer, primary_key=True)
    name_source = Column(String)
    area_code = Column(String)
    area_name = Column(String)
    url_source = Column(String)

# Materialized View
class TRedlist(DB.Model):
    __tablename__ = "t_c_redlist"
    __table_args__ = {"schema": APP_SCHEMA_NAME}
    id_redlist = Column(Integer, primary_key=True)
    status_order = Column(Integer)
    cd_nom = Column(Integer)
    cd_ref = Column(Integer)
    category = Column(String)
    criteria = Column(String)
    id_source = Column(Integer)

# Table (gn_biodivterritory)
class TMaxThreatenedStatus(DB.Model):
    __tablename__ = "t_max_threatened_status"
    __table_args__ = {"schema": APP_SCHEMA_NAME}
    cd_nom = Column(Integer, primary_key=True)
    threatened = Column(Boolean, default=False, nullable=False)
    redlist_statut = Column(String)
    id_source = Column(
        Integer, ForeignKey("taxonomie.bib_c_redlist_source.id_source")
    )
