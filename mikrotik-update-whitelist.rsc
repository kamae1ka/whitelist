# MikroTik RouterOS 7 - Whitelist auto-updater installer
# Import once: /import file-name=mikrotik-update-whitelist.rsc
#
# Or upload whitelist-update.script + whitelist-do-import.script via Winbox Files, then run commands below.

/system script remove [find name=whitelist-update]
/system script remove [find name=whitelist-do-import]
/system scheduler remove [find name=whitelist-update-hourly]
/file remove [find name=whitelist-update.script]
/file remove [find name=whitelist-do-import.script]

/tool fetch url="https://raw.githubusercontent.com/kamae1ka/whitelist/main/whitelist-update.script" mode=https dst-path=whitelist-update.script
/tool fetch url="https://raw.githubusercontent.com/kamae1ka/whitelist/main/whitelist-do-import.script" mode=https dst-path=whitelist-do-import.script

/system script add name=whitelist-do-import owner=admin policy=read,write,policy,test source=[/file get whitelist-do-import.script contents]
/system script add name=whitelist-update owner=admin policy=read,write,policy,test source=[/file get whitelist-update.script contents]

/system scheduler add name=whitelist-update-hourly interval=1h start-time=startup on-event=whitelist-update comment="Auto-update whitelist from GitHub (hourly)"

/system script run whitelist-update
