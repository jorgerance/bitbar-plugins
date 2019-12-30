#!/usr/bin/env bash
####################################################################################
#  Title         : totp.sh
#  Description   : Bitbar plugin - Copy generated TOTP codes into clipboard.
#  Author        : Jorge Rancé Cardet <jorge@rsa4096.xyz>
#  Creation      : 2019-03-22
#  Version       : 1.0
#  Usage         : Bitbar plugin - Place this script inside Bitbars plugins path.
#  Notes         :
#  Bash version  : 5.0.11(1)-release
####################################################################################

source ${HOME}/.secrets

PATH="/usr/local/bin:/usr/bin:$PATH"
echo "🐳 | dropdown=false"
echo "---"

function listServices() {
  _services="$(docker service ls --format "{{.Name}};{{.Image}};{{.Replicas}}" | sort -t ';' -k3 -r)"
  if [ -z "$_services" ]; then
    echo "No services found."
  else
    _last_service=$(echo "$_services" | tail -n1)
    echo "$_services" | while read -r _swarm_service; do
      _service_name=$(echo "$_swarm_service" | awk -F";" '{print $1}')
      _stack_name=$(echo "$_service_name" | awk -F"_" '{print $1}')
      _service_image=$(echo "$_swarm_service" | awk -F";" '{print $2}' | cut -d':' -f1 | cut -d'/' -f2)
      _service_running_instances=$(echo "$_swarm_service" | awk -F";" '{print $3}' | cut -d'/' -f1)
      _service_expected_instances=$(echo "$_swarm_service" | awk -F";" '{print $3}' | cut -d'/' -f2)
      _service_status=$((_service_expected_instances - _service_running_instances))

      # status text color
      _color_ok='#5cb85c'
      _color_warn='#edc951'
      _color_ko='#cc2a36'

      # status emojis
      _ico_ok='🌴'
      _ico_warn='🙈'
      _ico_ko='👻'

      # if last element -> change left side symbol
      if [ $_swarm_service == $_last_service ]; then _left_bar='└'; else _left_bar='├'; fi

      # outpur format / command depends on: services_running Vs. services_expected
      if [ $_service_running_instances -eq $_service_expected_instances ]; then
        echo "$_left_bar $_ico_ok $_service_name $_service_running_instances/$_service_expected_instances| color=$_color_ok bash="docker service logs -f $_service_name" terminal=true refresh=true"
      elif [ "$_service_running_instances" -gt 0 -a "$_service_running_instances" -lt "$_service_expected_instances" ]; then
        echo "$_left_bar $_ico_warn $_service_name $_service_running_instances/$_service_expected_instances| color=$_color_warn bash="docker service logs -f $_service_name" terminal=true refresh=true"
      else
        echo "$_left_bar $_ico_ko $_service_name $_service_running_instances/$_service_expected_instances| color=$_color_ko bash="docker stack deploy $_stack_name\; docker service logs -f $_service_name" terminal=true refresh=true"
      fi
    done
  fi
}

if ! which docker >/dev/null; then
  echo 'Docker not in $PATH.'
  exit 1
else
  listServices
  exit 0
fi
