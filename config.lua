Config = Config or {}

Config.distance = 50.0 -- Distance for ped spawning (to reduce load, ped disappears when player is far)
Config.Lang = 'EN' -- Language: 'EN' for English, 'AR' for Arabic

Config.Blips = {
    enable = true, -- If enabled, blips will always be shown
    sprite = 811, -- Blip sprite/icon
    color = 5, -- Blip color
    scale = 0.8, -- Blip size
}

Config.Rentals = {
    {
        label = "Central Rental",
        coords = vector4(-746.1027, -1054.9187, 12.0626, 301.3538), -- Ped coordinates
        pedModel = "a_m_y_business_03", -- Ped model
        spawnPoints = { -- Vehicle spawn points (first available spot is used)
            vector4(-735.0875, -1065.4390, 11.7316, 30.9874),
            vector4(-727.2913, -1061.2238, 12.3508, 35.0333),
        },
        vehicles = { -- Available vehicles at this location
            { model = "blista", price = 500 },
            { model = "panto", price = 300 },
            { model = "sultan", price = 700 },
        }
    },
}
