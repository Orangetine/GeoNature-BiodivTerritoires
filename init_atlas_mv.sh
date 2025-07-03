. config/settings.ini
mkdir -p /tmp/gn2
cp data/gn2/* /tmp/gn2/

# Vide le fichier de log
> var/log/install_db.log

cp data/gn2/atlas_ref_taxonomie.sql /tmp/gn2/atlas_ref_taxonomie.sql &>> var/log/install_db.log
sed -i "s/myuser;$/$user_pg;/" /tmp/gn2/atlas_ref_taxonomie.sql

# Ajout de la table étrangère taxonomie.bdc_statut dans geonatureatlas et ref_nomenclatures
echo "[$(date +'%H:%M:%S')] Importation schema taxonomie ..." &>> var/log/install_db.log
export PGPASSWORD=$user_pg_pass 
time_temp=$SECONDS
psql -d $db_name -U $user_pg -h $db_host -p $db_port\
     -f /tmp/gn2/atlas_ref_taxonomie.sql &>> var/log/install_db.log
echo "[$(date +'%H:%M:%S')] Passed - Duration : $((($SECONDS-$time_temp)/60))m$((($SECONDS-$time_temp)%60))s"

echo "[$(date +'%H:%M:%S')] Création des MVs du schéma taxonomy ..." &>> var/log/install_db.log
export PGPASSWORD=$user_pg_pass 
time_temp=$SECONDS
psql -d $db_name -U $user_pg -h $db_host -p $db_port\
     -f data/territoire/taxonomie_mv.sql &>> var/log/install_db.log
echo "[$(date +'%H:%M:%S')] Passed - Duration : $((($SECONDS-$time_temp)/60))m$((($SECONDS-$time_temp)%60))s"


echo "[$(date +'%H:%M:%S')] Création des MVs du schéma territory ..." &>> var/log/install_db.log
export PGPASSWORD=$user_pg_pass 
time_temp=$SECONDS
psql -d $db_name -U $user_pg -h $db_host -p $db_port\
     -v _areas=$areas\
     -f data/territoire/territory_mv.sql &>> var/log/install_db.log
echo "[$(date +'%H:%M:%S')] Passed - Duration : $((($SECONDS-$time_temp)/60))m$((($SECONDS-$time_temp)%60))s"

