. config/settings.ini

export PGPASSWORD=$user_pg_pass
psql -d $db_name -U $user_pg -h $db_host -p $db_port\
    -f data/territoire/4.gn_biodivterritory.mv_l_areas_autocomplete.sql

export PGPASSWORD=$user_pg_pass
psql -d $db_name -U $user_pg -h $db_host -p $db_port\
    -f data/territoire/5.gn_biodivterritory.mv_general_stats.sql

export PGPASSWORD=$user_pg_pass
psql -d $db_name -U $user_pg -h $db_host -p $db_port\
    -f data/territoire/6.gn_biodivterritory.mv_territory_general_stats.sql

export PGPASSWORD=$user_pg_pass
psql -d $db_name -U $user_pg -h $db_host -p $db_port\
    -f data/territoire/7.gn_biodivterritory.mv_area_ntile_limit.sql



