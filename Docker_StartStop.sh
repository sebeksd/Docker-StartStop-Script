#!/bin/bash

# This program is shared in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#
# Used naming scheme:
# cNAME - const, vName - variable, vNAME - all caps variable for "Text" (multiline) 

for arg in "$@" 
do
  case "$arg" in
    -restart) restart;; # restart previously stopped containers
    -stop) stop;; # stop running containers and put them on the list
    -h | --help)
      showHelp  
      exit 0
      ;;
  esac
done;

showHelp()
{
  echo "
Script to stop running containers and then start them without starting containers that were already stopped.
  
Additional options are:
  -stop - will stop running containers and save them to a list
  -restart - will start containers previously stopped by this script
  -h, --help - show this help
"
  exit 1
}

function restart()
{
  echo "Restarting all preciously stopped containers"

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
