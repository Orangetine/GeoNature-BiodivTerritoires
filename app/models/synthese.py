from flask import current_app
from geoalchemy2 import Geometry
from sqlalchemy import Column, DateTime, Integer, String
from sqlalchemy.dialects.postgresql import UUID, JSONB
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
    # unique_id_sinp = Column(UUID(as_uuid=True))
    # unique_id_sinp_grp = Column(UUID(as_uuid=True))
    # id_source = Column(Integer)
    # id_module = Column(Integer)
    # entity_source_pk_value = Column(Integer)
    id_dataset = Column(Integer)
    # id_nomenclature_geo_object_nature = Column(Integer)
    # id_nomenclature_grp_typ = Column(Integer)
    # grp_method = Column(String)
    # id_nomenclature_obs_meth = Column(Integer)
    # id_nomenclature_obs_technique = Column(Integer)
    id_nomenclature_bio_status = Column(Integer)
    # id_nomenclature_bio_condition = Column(Integer)
    # id_nomenclature_naturalness = Column(Integer)
    # id_nomenclature_exist_proof = Column(Integer)
    # id_nomenclature_valid_status = Column(Integer)
    id_nomenclature_diffusion_level = Column(Integer)
    # id_nomenclature_life_stage = Column(Integer)
    # id_nomenclature_sex = Column(Integer)
    # id_nomenclature_obj_count = Column(Integer)
    # id_nomenclature_type_count = Column(Integer)
    id_nomenclature_sensitivity = Column(Integer)
    id_nomenclature_observation_status = Column(Integer)
    # id_nomenclature_blurring = Column(Integer)
    # id_nomenclature_source_status = Column(Integer)
    # id_nomenclature_info_geo_type = Column(Integer)
    # id_nomenclature_behaviour = Column(Integer)
    # id_nomenclature_biogeo_status = Column(Integer)
    # reference_biblio = Column(String)
    # count_min = Column(Integer)
    # count_max = Column(Integer)
    cd_nom = Column(Integer)
    # cd_hab = Column(Integer)
    # nom_cite = Column(String)
    # meta_v_taxref = Column(String)
    # sample_number_proof = Column(String)
    # digital_proof = Column(String)
    # non_digital_proof = Column(String)
    # altitude_min = Column(String)
    # altitude_max = Column(String)
    # depth_min = Column(Integer)
    # depth_max = Column(Integer)
    # place_name = Column(String)
    # the_geom_4326 = Column(Geometry("GEOMETRY", 4326))
    # the_geom_point = Column(Geometry("GEOMETRY", 4326))
    the_geom_local = Column(
        Geometry("GEOMETRY", LOCAL_SRID)
    )
    # precision = Column(Integer)
    # id_area_attachment = Column(Integer)
    date_min = Column(DateTime)
    # date_max = Column(DateTime)
    # validator = Column(String)
    # validation_comment = Column(String)
    observers = Column(String)
    # determiner = Column(String)
    # id_digitiser = Column(Integer)
    # id_nomenclature_determination_method = Column(Integer)
    # comment_context = Column(String)
    # comment_description = Column(String)
    # additional_data = Column(JSONB, default=dict)
    # meta_validation_date = Column(DateTime)
    # meta_create_date = Column(DateTime)
    # meta_update_date = Column(DateTime)
    # last_action = Column(String)
    # id_import = Column(String)

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
    id_type = Column(Integer)
    type_code = Column(String(25))
