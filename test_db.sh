. config/settings.ini # sourcing settings.ini parameters

export PGPASSWORD=$user_pg_pass 
psql -d $db_name -U $user_pg -h $db_host -p $db_port\
	-c "SELECT unnest(string_to_array('$areas', ' '))" 


