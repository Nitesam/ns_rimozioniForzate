fx_version 'adamant'

games {'gta5'}

description 'Rimozioni Forzate by Nitesam'

version '1.0'

server_scripts {
  '@es_extended/locale.lua',
  '@mysql-async/lib/MySQL.lua',
  'config.lua',
  'server/main.lua'
}

client_scripts {
  '@es_extended/locale.lua',
  'config.lua',
  'client/main.lua'
}


