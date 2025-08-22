from flask import current_app
from geoalchemy2 import Geometry
from sqlalchemy import Column, DateTime, Integer, String
from utils_flask_sqla.serializers import serializable
from utils_flask_sqla_geo.serializers import geoserializable

from app.core.env import DB
from config.config import LOCAL_SRID


@serializable
@geoserializable
class Synthese(DB.Model):
    __tablename__ = "vm_synthese"
    __table_args__ = {"schema": "atlas"}
    id_synthese = Column(Integer, primary_key=True)
    id_dataset = Column(Integer)
    id_nomenclature_bio_status = Column(Integer)
    id_nomenclature_valid_status = Column(Integer)
    id_nomenclature_diffusion_level = Column(Integer)
    id_nomenclature_sensitivity = Column(Integer)
    id_nomenclature_observation_status = Column(Integer)
    cd_nom = Column(Integer)
    the_geom_4326 = Column(Geometry("GEOMETRY", 4326))
    the_geom_local = Column(
        Geometry("GEOMETRY", LOCAL_SRID)
    )
    date_min = Column(DateTime)
    observers = Column(String)

    def get_geofeature(self, recursif=True, columns=None):
        return self.as_geofeature(
            "the_geom_4326", "id_synthese", recursif, columns=columns
        )


@serializable
class CorAreaSynthese(DB.Model):
    __tablename__ = "vm_cor_area_synthese"
    __table_args__ = {"schema": "atlas"}
    id_synthese = Column(Integer, primary_key=True)
    id_area = Column(Integer)
