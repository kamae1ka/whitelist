# MikroTik RouterOS 7 Script - Simple version
# Downloads mikrotik-whitelist.rsc from GitHub and imports it

:local fileName "mikrotik-whitelist.rsc"

# Download file
/tool fetch url="https://raw.githubusercontent.com/kamae1ka/whitelist/main/mikrotik-whitelist.rsc" mode=https dst-path=$fileName

# Import the script (it will remove old entries and add new ones)
/import file-name=$fileName

# Cleanup
/file remove $fileName
:put "Whitelist updated successfully"
