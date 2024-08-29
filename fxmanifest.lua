fx_version 'cerulean'
game 'gta5'

version '1.0.0'

client_scripts {
    'client/client.lua',
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server/server.lua'
}