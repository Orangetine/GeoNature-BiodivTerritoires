# coding: utf-8
from geoalchemy2 import Geometry
from sqlalchemy import (
    Boolean,
    Column,
    ForeignKey,
    Integer,
    String,
)
from sqlalchemy.orm import relationship
from sqlalchemy.dialects.postgresql import JSONB
from utils_flask_sqla.serializers import serializable
from utils_flask_sqla_geo.serializers import geoserializable
from config.config import APP_SCHEMA_NAME, LOCAL_SRID
from app.core.env import DB

# Materialized View
@serializable
class BibAreasTypes(DB.Model):
    __tablename__ = "vm_bib_areas_types"
    __table_args__ = {"schema": "atlas", "extend_existing": True}
    id_type = Column(Integer, primary_key=True)
    type_name = Column(String)
    type_code = Column(String)
    type_desc = Column(String)


# Materialized View
@geoserializable
class LAreas(DB.Model):
    __tablename__ = "vm_l_areas"
    __table_args__ = {"schema": "atlas"}
    id_area = Column(Integer, primary_key=True)
    id_type = Column(Integer, ForeignKey("atlas.vm_bib_areas_types.id_type"))
    area_name = Column(String)
    area_code = Column(String)
    geom = Column(Geometry("GEOMETRY", LOCAL_SRID))
    enable = Column(Boolean)
    the_geom = Column(Geometry("GEOMETRY", "4326"))
    area_type = relationship(
        "BibAreasTypes",
        backref=DB.backref("atlas.vm_bib_areas_types", lazy=True),
    )

    def get_geofeature(self, recursif=True, columns=None):
        return self.as_geofeature("geom", "id_area", recursif, columns=columns)

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
    __table_args__ = {"schema": APP_SCHEMA_NAME}
    id_selection = Column(Integer, primary_key=True)
    id_type = Column(
        Integer, ForeignKey("atlas.vm_bib_areas_types.id_type"), unique=True
    )
    searchable = Column(Boolean)
