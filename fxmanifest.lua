fx_version 'cerulean'
game 'gta5'

shared_script {
	'@ox_lib/init.lua',
	"config.lua"
}

ui_page {
	'html/index.html'
}

files {
	'html/index.html',
	'html/*.js',
	'html/*.css',
	'html/img/*.png',
	'html/img/*.svg',
}

client_scripts {
	'utils/client.lua',
	'client/main.lua',
	'client/nui.lua',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'utils/server.lua',
	'server/main.lua'
}

export 'GetBleedingStatus'

escrow_ignore {
	'utils/client.lua',
	'utils/server.lua',
	"config.lua",

	'client/main.lua',
	'client/nui.lua',
	'server/main.lua',
}

lua54 'on'
dependency '/assetpacks'
dependency '/assetpacks'
dependency '/assetpacks'
dependency '/assetpacks'