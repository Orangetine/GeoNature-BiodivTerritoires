. config/settings.ini

# Vide le fichier de log
> var/log/install_db.log

echo "[$(date +'%H:%M:%S')] Création des tables du schéma taxonomy ..." &>> var/log/install_db.log
export PGPASSWORD=$user_pg_pass &>> var/log/install_db.log
time_temp=$SECONDS
psql -d $db_name -U $user_pg -h $db_host -p $db_port\
     -f data/territoire/taxonomie.sql &>> var/log/install_db.log
echo "[$(date +'%H:%M:%S')] Passed - Duration : $((($SECONDS-$time_temp)/60))m$((($SECONDS-$time_temp)%60))s"

echo "[$(date +'%H:%M:%S')] Création du schéma gn_biodivterritory et de ses tables ..." &>> var/log/install_db.log
export PGPASSWORD=$user_pg_pass &>> var/log/install_db.log
time_temp=$SECONDS
psql -d $db_name -U $user_pg -h $db_host -p $db_port\
     -v _areas=$areas\
     -f data/territoire/territory.sql &>> var/log/install_db.log
echo "[$(date +'%H:%M:%S')] Passed - Duration : $((($SECONDS-$time_temp)/60))m$((($SECONDS-$time_temp)%60))s"

echo "[$(date +'%H:%M:%S')] Création du schéma gn_biodivterritory et de ses tables ..." &>> var/log/install_db.log
export PGPASSWORD=$user_pg_pass &>> var/log/install_db.log
time_temp=$SECONDS
psql -d $db_name -U $user_pg -h $db_host -p $db_port\
     -v _areas=$areas\
     -f data/territoire/MVs.sql &>> var/log/install_db.log
echo "[$(date +'%H:%M:%S')] Passed - Duration : $((($SECONDS-$time_temp)/60))m$((($SECONDS-$time_temp)%60))s"
