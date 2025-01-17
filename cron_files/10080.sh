#!/bin/bash

folder="$(cd ../ && pwd)"
source $folder/config.ini

# Logging
mkdir -p $PATH_TO_STATS/logs
touch $PATH_TO_STATS/logs/log_$(date '+%Y%m').log

query(){
if [ -z "$SQL_password" ]
then
  mysql -h$DB_IP -P$DB_PORT -u$SQL_user $STATS_DB $1
else
  mysql -h$DB_IP -P$DB_PORT -u$SQL_user -p$SQL_password $STATS_DB $1
fi
}

# rpl 10080 area stats
start=$(date '+%Y%m%d %H:%M:%S')
cat $PATH_TO_STATS/cron_files/10080_area.sql | query
stop=$(date '+%Y%m%d %H:%M:%S')
diff=$(printf '%02dm:%02ds\n' $(($(($(date -d "$stop" +%s) - $(date -d "$start" +%s)))/60)) $(($(($(date -d "$stop" +%s) - $(date -d "$start" +%s)))%60)))
echo "[$start] [$stop] [$diff] Stats rpl10080 mon area agggregation" >> $PATH_TO_STATS/logs/log_$(date '+%Y%m').log

# rpl 10080 quest stats
start=$(date '+%Y%m%d %H:%M:%S')
cat $PATH_TO_STATS/cron_files/10080_area_quest.sql | query
stop=$(date '+%Y%m%d %H:%M:%S')
diff=$(printf '%02dm:%02ds\n' $(($(($(date -d "$stop" +%s) - $(date -d "$start" +%s)))/60)) $(($(($(date -d "$stop" +%s) - $(date -d "$start" +%s)))%60)))
echo "[$start] [$stop] [$diff] Stats rpl10080 quest area aggregation" >> $PATH_TO_STATS/logs/log_$(date '+%Y%m').log

# rpl 10080 worker stats
start=$(date '+%Y%m%d %H:%M:%S')
cat $PATH_TO_STATS/cron_files/10080_worker.sql | query
stop=$(date '+%Y%m%d %H:%M:%S')
diff=$(printf '%02dm:%02ds\n' $(($(($(date -d "$stop" +%s) - $(date -d "$start" +%s)))/60)) $(($(($(date -d "$stop" +%s) - $(date -d "$start" +%s)))%60)))
echo "[$start] [$stop] [$diff] Stats rpl10080 worker aggregation" >> $PATH_TO_STATS/logs/log_$(date '+%Y%m').log

# optimize pokemon_history_temp, we stop doing this => useless as it will fill up anyway to its orgininal level
#echo "`date '+%Y%m%d %H:%M:%S'` Weekly StatsDB optimize pokemon_history_temp started" >> $PATH_TO_STATS/logs/log_$(date '+%Y%m').log
#if [ -z "$SQL_password" ]
#then
#  mysqloptimize --skip-write-binlog -h$DB_IP -P$DB_PORT -u$SQL_user $STATS_DB pokemon_history_temp
#  echo "`date '+%Y%m%d %H:%M:%S'` Weekly StatsDB optimize pokemon_history_temp finished" >> $PATH_TO_STATS/logs/log_$(date '+%Y%m').log
#else
#  mysqloptimize --skip-write-binlog -h$DB_IP -P$DB_PORT -u$SQL_user -p$SQL_password $STATS_DB pokemon_history_temp
#  echo "`date '+%Y%m%d %H:%M:%S'` Weekly StatsDB optimize pokemon_history_temp finished" >> $PATH_TO_STATS/logs/log_$(date '+%Y%m').log
#fi

# MAD log aggregation
if "$madlog"
then
start=$(date '+%Y%m%d %H:%M:%S')
cat $PATH_TO_STATS/cron_files/madlog10080.sql | query
stop=$(date '+%Y%m%d %H:%M:%S')
diff=$(printf '%02dm:%02ds\n' $(($(($(date -d "$stop" +%s) - $(date -d "$start" +%s)))/60)) $(($(($(date -d "$stop" +%s) - $(date -d "$start" +%s)))%60)))
echo "[$start] [$stop] [$diff] Stats rpl10080 MAD log aggregation" >> $PATH_TO_STATS/logs/log_$(date '+%Y%m').log
fi

# MAD log aggregation worker level
if "$madlog_worker"
then
start=$(date '+%Y%m%d %H:%M:%S')
cat $PATH_TO_STATS/cron_files/madlog_worker10080.sql | query
stop=$(date '+%Y%m%d %H:%M:%S')
diff=$(printf '%02dm:%02ds\n' $(($(($(date -d "$stop" +%s) - $(date -d "$start" +%s)))/60)) $(($(($(date -d "$stop" +%s) - $(date -d "$start" +%s)))%60)))
echo "[$start] [$stop] [$diff] Stats rpl10080 MAD log aggregation worker level" >> $PATH_TO_STATS/logs/log_$(date '+%Y%m').log
fi

# optimize pokemon_history
if "$mon_cleanup"
then
  start=$(date '+%Y%m%d %H:%M:%S')
  if [ -z "$SQL_password" ]
  then
    mysqloptimize --skip-write-binlog -h$DB_IP -P$DB_PORT -u$SQL_user $STATS_DB pokemon_history
    stop=$(date '+%Y%m%d %H:%M:%S')
    diff=$(printf '%02dm:%02ds\n' $(($(($(date -d "$stop" +%s) - $(date -d "$start" +%s)))/60)) $(($(($(date -d "$stop" +%s) - $(date -d "$start" +%s)))%60)))
    echo "[$start] [$stop] [$diff] Weekly StatsDB optimize pokemon_history" >> $PATH_TO_STATS/logs/log_$(date '+%Y%m').log
  else
    mysqloptimize --skip-write-binlog -h$DB_IP -P$DB_PORT -u$SQL_user -p$SQL_password $STATS_DB pokemon_history
    stop=$(date '+%Y%m%d %H:%M:%S')
    diff=$(printf '%02dm:%02ds\n' $(($(($(date -d "$stop" +%s) - $(date -d "$start" +%s)))/60)) $(($(($(date -d "$stop" +%s) - $(date -d "$start" +%s)))%60)))
    echo "[$start] [$stop] [$diff] Weekly StatsDB optimize pokemon_history" >> $PATH_TO_STATS/logs/log_$(date '+%Y%m').log
  fi
fi
