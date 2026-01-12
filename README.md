# z5-rental

A premium, modern vehicle rental system for QBCore Framework with a custom UI and multi-language support.

## Features

*   **Modern Custom UI**: A sleek, dark-themed interface with orange accents, glassmorphism effects, and smooth animations.
*   **Multi-Language Support**: Fully localized in English (EN) and Arabic (AR), configurable via `config.lua`.
*   **Dynamic Localization**: The UI text updates instantly based on the selected language config without needing HTML edits.
*   **Ped spawning**: Spaws NPC peds at rental locations that disappear when the player is far away to save performance.
*   **qb-target Integration**: Interact with rental peds using `qb-target`.
*   **Flexible Configuration**: Easily add/remove rental locations, change vehicles, prices, and spawn points.
*   **Payment Options**: Support for both Cash and Bank payments.
*   **Blip Management**: configurable map blips.

## Dependencies

*   [qb-core](https://github.com/qbcore-framework/qb-core)
*   [qb-target](https://github.com/qbcore-framework/qb-target)

## Installation

1.  Download the resource and place it in your resources folder.
2.  Add `ensure z5-rental` to your `server.cfg`.
3.  Configure the `config.lua` to your liking.

## Configuration

### Language
Open `config.lua` and set the `Config.Lang` variable to your preferred language.
```lua
Config.Lang = 'EN' -- 'EN' for English, 'AR' for Arabic
```

### Adding Rental Locations
You can add as many rental locations as you want in the `Config.Rentals` table.

```lua
{
    label = "Central Rental", -- Display name
    coords = vector4(-746.1, -1054.9, 12.0, 301.3), -- Ped Location (x, y, z, h)
    pedModel = "a_m_y_business_03", -- NPC Model
    spawnPoints = { -- Array of possible spawn coordinates
        vector4(-735.0, -1065.4, 11.7, 30.9),
    },
    vehicles = { -- List of vehicles available at this location
        { model = "blista", price = 500 },
        { model = "sultan", price = 700 },
    }
}
```

## Adding New Languages
1. Create a new file in the `lang/` folder (e.g., `FR.lua`).
2. Copy the structure from `EN.lua`.
3. Translate the strings.
4. Set `Config.Lang = 'FR'` in `config.lua`.