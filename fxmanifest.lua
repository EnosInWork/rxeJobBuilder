fx_version 'cerulean'

game 'gta5'

lua54 'yes'

escrow_ignore {
    -- ↓ RageUI ↓ --
    "src/RMenu.lua",
    "src/menu/RageUI.lua",
    "src/menu/Menu.lua",
    "src/menu/MenuController.lua",
    "src/components/*.lua",
    "src/menu/elements/*.lua",
    "src/menu/items/*.lua",
    "src/menu/panels/*.lua",
    "src/menu/panels/*.lua",
    "src/menu/windows/*.lua",
    'client/*.lua',
    'menu/*.lua',
    "config.lua"
}

shared_script 'config.lua'

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server/*.lua'
}

client_scripts {
    -- ↓ RageUI ↓ --
    "src/RMenu.lua",
    "src/menu/RageUI.lua",
    "src/menu/Menu.lua",
    "src/menu/MenuController.lua",
    "src/components/*.lua",
    "src/menu/elements/*.lua",
    "src/menu/items/*.lua",
    "src/menu/panels/*.lua",
    "src/menu/panels/*.lua",
    "src/menu/windows/*.lua",
    
    'client/*.lua',
    'menu/*.lua'
}
