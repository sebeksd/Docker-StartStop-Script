#!/bin/bash

# This program is shared in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#
# Used naming scheme:
# cNAME - const, vName - variable, vNAME - all caps variable for "Text" (multiline) 

vPreScriptResult=-1

showHelp()
{
  echo "
Script to stop running containers and then start them without starting containers that were already stopped.
  
Additional options are:
  -s - will stop running containers and save them to a list
  -r - will start containers previously stopped by this script
  -x - pass the parameter as result, usefull to pass result of command executed before this script
      Usage example: Docker_StartStop.sh -x \$?
  -h - show this help
"
}

function restart()
{
  echo "Restarting all previously stopped containers"

  docker start $(cat /tmp/Docker_StartStop-runnig_list.tmp) &&\
    rm /tmp/Docker_StartStop-runnig_list.tmp

  echo "All containers restarted"
}

function stop()
{
  echo "Stopping all containers"

  # if there is no running containers do not modify the list
  # in case someone used stop more than once
  if [ "$(docker ps -aq -f status=running -f status=restarting)" ]; then
    # save list
    docker stop $(docker ps -q) > /tmp/Docker_StartStop-runnig_list.tmp
    echo "All containers stopped"
  else
    echo "No running containers, skipping"
  fi  
}

while getopts rshx: flag
do
  case "${flag}" in
      r) restart;; # restart previously stopped containers
      s) stop;; # stop running containers and put them on the list
      x) 
        # pass the parameter as result, usefull to pass result of command executed before this script
        vPreScriptResult=${OPTARG};; 
      h | *) 
        showHelp;;
  esac
done

if [ "$vPreScriptResult" != -1 ]; then
  exit $vPreScriptResult
fi  
