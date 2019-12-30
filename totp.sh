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

# Adding homebrew default bin path --> oathtool
PATH=/usr/local/bin/:$PATH

# Source secrets file
source ${HOME}/.secrets

# Hack for language not being set properly and unicode support
export LANG="${LANG:-en_US.UTF-8}"

# _serviceName - for your reference to identify a TOTP Account
# _serviceSeed - base32 secret key corresponding to the TOTP Account
# Each value on totp_secrets corresponds to a variable defined in the secrets file
# i.e. BITBAR_<SERVICE_NAME>='_serviceName;_serviceSeed'
# i.e. BITBAR_PROTON='Protonmail;QWERTYUIOPASDFGHJKLZXCVBNM123456'
totp_secrets=(BITBAR_TS121 BITBAR_PROTON BITBAR_BINANCE BITBAR_MAILCOW BITBAR_B2)

# Sorts totp secrets alfabetically
IFS=$'\n' totp_secrets=($(sort <<<"${totp_secrets[*]}"))
unset IFS

function get-totp() {
  oathtool --totp -b "$1"
}

if [[ "$1" == "copy" ]]; then
  echo -n "$(echo -n "$2")" | pbcopy
  exit
fi

echo "🔐"
echo '---'
echo "Clear Clipboard | bash='$0' param1=copy param2=' ' terminal=false"
echo "---"

for service in "${totp_secrets[@]}"; do
  _serviceName=$(echo ${!service} | awk -F';' '{print $1}')
  _serviceSeed=$(echo ${!service} | awk -F';' '{print $2}')
  _serviceTotp=$(get-totp "$_serviceSeed")
  printf "$(echo "🔑 $_serviceName") | bash='$0' param1=copy param2='$_serviceTotp' terminal=false\n"
done
