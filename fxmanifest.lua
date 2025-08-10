fx_version 'cerulean'
game 'gta5'

description 'Um-multicharacter'

shared_scripts {
    'config.lua',
    '@qb-core/shared/locale.lua',
}

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}


ui_page 'html/index.html'
files {
    'html/**/*.*',
    'html/*.*',
    'Locale/*',
    'Locale/*.*',
}

lua54 'yes'
