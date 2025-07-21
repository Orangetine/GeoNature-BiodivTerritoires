# coding: utf-8
from flask import current_app
from geoalchemy2 import Geometry
from sqlalchemy import (
    BigInteger,
    Boolean,
    Column,
    DateTime,
    Float,
    ForeignKey,
    Integer,
    String,
    Text,
)
from sqlalchemy.orm import relationship
from sqlalchemy.dialects.postgresql import JSONB
from utils_flask_sqla.serializers import serializable
from utils_flask_sqla_geo.serializers import geoserializable
from config.config import APP_SCHEMA_NAME, LOCAL_SRID
from app.core.env import DB

# Table
@serializable
class BibAreasTypes(DB.Model):
    __tablename__ = "vm_bib_areas_types"
    __table_args__ = {"schema": "atlas", "extend_existing": True}
    id_type = Column(Integer, primary_key=True)
    type_name = Column(String)
    type_code = Column(String)
    type_desc = Column(String)
    # ref_name = Column(String)
    # ref_version = Column(Integer)
    # num_version = Column(String)
    # size_hierarchy = Column(Integer)

# Table
@geoserializable
class LAreas(DB.Model):
    __tablename__ = "vm_l_areas"
    __table_args__ = {"schema": "atlas"}
    id_area = Column(Integer, primary_key=True)
    id_type = Column(Integer, ForeignKey("atlas.vm_bib_areas_types.id_type"))
    area_name = Column(String)
    area_code = Column(String)
    geom_local = Column(Geometry("GEOMETRY", LOCAL_SRID))
    #centroid = Column(Geometry("GEOMETRY", LOCAL_SRID))
    #source = Column(String)
    #comment = Column(String)
    enable = Column(Boolean)
    #additional_data = Column(JSONB)
    #meta_create_date = Column(DateTime)
    #meta_update_date = Column(DateTime)
    the_geom = Column(Geometry("GEOMETRY", "4326"))
    area_geojson = Column(Text)
    area_type = relationship(
        "BibAreasTypes",
        backref=DB.backref("atlas.vm_bib_areas_types", lazy=True),
    )

    def get_geofeature(self, recursif=True, columns=None):
        return self.as_geofeature("the_geom", "id_area", recursif, columns=columns)

# Commenting because this table is not used elsewhere
# @serializable
# class LiMunicipalities(DB.Model):
#     __tablename__ = "li_municipalities"
#     __table_args__ = {"schema": "ref_geo"}
#     id_municipality = Column(Integer, primary_key=True)
#     id_area = Column(Integer)
#     status = Column(String)
#     insee_com = Column(String)
#     nom_com = Column(String)
#     insee_arr = Column(String)
#     nom_dep = Column(String)
#     insee_dep = Column(String)
#     nom_reg = Column(String)
#     insee_reg = Column(String)
#     code_epci = Column(String)
#     plani_precision = Column(Float)
#     siren_code = Column(String)
#     canton = Column(String)
#     population = Column(Integer)
#     multican = Column(String)
#     cc_nom = Column(String)
#     cc_siren = Column(BigInteger)
#     cc_nature = Column(String)
#     cc_date_creation = Column(String)
#     cc_date_effet = Column(String)
#     insee_commune_nouvelle = Column(String)
#     meta_create_date = Column(DateTime)
#     meta_update_date = Column(DateTime)

# Materialized View
@serializable
class MVLAreasAutocomplete(DB.Model):
    __tablename__ = "mv_l_areas_autocomplete"
    __table_args__ = {"schema": APP_SCHEMA_NAME, "extend_existing": True}
    id = Column(Integer, primary_key=True)
    type_name = Column(String)
    search_area_name = Column(String)
    type_desc = Column(String)
    type_code = Column(String)
    area_name = Column(String)
    area_code = Column(String)

# Materialized View
@serializable
class LAreasTypeSelection(DB.Model):
    __tablename__ = "l_areas_type_selection"
    __table_args__ = ({"schema": APP_SCHEMA_NAME},)
    id_selection = Column(Integer, primary_key=True)
    id_type = Column(
        Integer, ForeignKey("atlas.vm_bib_areas_types.id_type"), unique=True
    )
    searchable = Column(Boolean)
