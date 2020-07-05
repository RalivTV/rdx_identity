
fx_version 'adamant'

game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

description 'RDX Identity'

version '1.2.0'

server_scripts {
	'@redm_extended/locale.lua',
	'@mysql-async/lib/MySQL.lua',
	'locales/en.lua',
	'locales/cs.lua',
	'config.lua',
	'server/main.lua'
}

client_scripts {
	'@redm_extended/locale.lua',
	'locales/en.lua',
	'locales/cs.lua',
	'config.lua',
	'client/main.lua'
}

ui_page 'html/index.html'

files {
	'html/index.html',
	'html/script.js',
	'html/style.css'
}

dependency 'redm_extended'
