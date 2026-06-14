# MikroTik RouterOS 7 - Whitelist auto-updater installer
# Import once: /import file-name=mikrotik-update-whitelist.rsc
#
# Requires: whitelist-update.script on router (downloaded automatically)
# Status:   /system script print where name=whitelist-update
# State:    /file print file=whitelist-state.txt

/system script remove [find name=whitelist-update]
/system scheduler remove [find name=whitelist-update-hourly]
/file remove [find name=whitelist-update.script]

/tool fetch url="https://raw.githubusercontent.com/kamae1ka/whitelist/main/whitelist-update.script" mode=https dst-path=whitelist-update.script

/system script add name=whitelist-update owner=admin policy=read,write,policy,test source=[/file get whitelist-update.script contents]

/system scheduler add name=whitelist-update-hourly interval=1h start-time=startup on-event=whitelist-update comment="Auto-update whitelist from GitHub (hourly)"

/system script run whitelist-update
