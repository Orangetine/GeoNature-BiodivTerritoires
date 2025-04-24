. config/settings.ini

export PGPASSWORD=$user_pg_pass
psql -d $db_name -U $user_pg -h $db_host -p $db_port\
    -v _areas=$areas\
    -f data/territoire/3.populate_table.sql