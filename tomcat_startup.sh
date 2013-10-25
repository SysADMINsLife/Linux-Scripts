#!/bin/bash
### BEGIN INIT INFO
# Provides:          tomcat
# Required-Start:    $local_fs $remote_fs $network
# Required-Stop:     $local_fs $remote_fs $network
# Should-Start:      $named
# Should-Stop:       $named
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start Tomcat Server
# Description:       Start the Tomcat Server
### END INIT INFO
  
# INIT Script by www.SysADMINsLife.com
######################################
# customize values for your needs
  
JAVA_HOME="/usr/lib/jvm/java-7-oracle"
JAVA_OPTS=""
TOMCAT_USER=tomcat;
TOMCAT_PATH=/usr/local/tomcat;
SHUTDOWN_TIME=30
  
###### Tomcat start/stop script ######
  
export JAVA_HOME
export JAVA_OPTS
 
tomcat_pid() {
   echo `ps aux | grep org.apache.catalina.startup.Bootstrap | grep -v grep | awk '{ print $2 }'`
   }
  
start() {
    if [ -f $TOMCAT_PATH/bin/startup.sh ];
      then
        pid=$(tomcat_pid)
        if [ -n "$pid" ]
          then
            echo "Start aborted because Tomcat already running with pid: $pid"
          else
            echo -n "Starting Tomcat\n"
            /bin/su $TOMCAT_USER -c $TOMCAT_PATH/bin/startup.sh
        fi
      else
        echo "$TOMCAT_PATH/bin/startup.sh does not exist - Please check your config"
    fi
     
    return 0
}
     
stop() {
    if [ -f $TOMCAT_PATH/bin/shutdown.sh ];
      then
        pid=$(tomcat_pid)
        if [ -n "$pid" ]
          then
            echo "Stopping Tomcat"
            /bin/su $TOMCAT_USER -c $TOMCAT_PATH/bin/shutdown.sh
             
            let waitfor=$SHUTDOWN_TIME      
            count=0;
            until [ `ps -p $pid | grep -c $pid` = '0' ] || [ $count -gt $waitfor ]
            do
                echo -n -e "\rWaiting $count of $waitfor seconds for Tomcat to exit until process kill ";
                sleep 1
                let count=$count+1;
            done
 
            if [ $count -gt $waitfor ]; then
                echo -n -e "\nKilling Tomcat which didn't stop after $SHUTDOWN_TIME seconds"
                kill -9 $pid
            fi
           else
            echo "Your Tomcat Instance is not running"         
         fi        
      else
        echo "$TOMCAT_PATH/bin/shutdown.sh does not exist - Please check your config"
    fi
     
    return 0  
      
 }
     
 
case $1 in
start)
  start
;; 
stop)   
  stop
;; 
restart)
  stop
  start
;;
status)
  pid=$(tomcat_pid)
  if [ -n "$pid" ]
  then
    echo "Your Tomcat Instance is running with pid: $pid"
  else
    echo "Your Tomcat Instance is not running"
  fi
;; 
*)
echo "Usage: $0 { start | stop | restart | status }"
;;
 
esac    
exit 0