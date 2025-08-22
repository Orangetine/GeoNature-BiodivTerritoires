from sqlalchemy import (
    Column,
    ForeignKey,
    Integer,
    String,
    Text,
)
from utils_flask_sqla.serializers import serializable

from app.core.env import DB

class TNomenclatures(DB.Model):
    __tablename__ = "vm_t_nomenclatures"
    __table_args__ = {"schema": "atlas"}

    id_nomenclature = Column(Integer, primary_key=True)
    cd_nomenclature = Column(String(255))
    mnemonique = Column(String(255))
    definition_fr = Column(Text)

    id_type = Column(
        Integer, ForeignKey("atlas.vm_bib_nomenclatures_types.id_type")
    )


@serializable
class BibNomenclaturesTypes(DB.Model):
    __tablename__ = "vm_bib_nomenclatures_types"
    __table_args__ = {"schema": "atlas"}
    id_type = Column(Integer, primary_key=True)
    mnemonique = Column(String(255))



