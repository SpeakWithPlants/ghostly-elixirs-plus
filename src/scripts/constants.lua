local STRINGS = GLOBAL.STRINGS
local CHARACTERS = GLOBAL.STRINGS.CHARACTERS

local NEW_ELIXIRS = {
    "sanityaura",
    "lightaura",
    "healthdamage",
    "cleanse",
    "insanitydamage",
    "shadowfighter",
    "lightning",
}

-- add elixir descriptions for non-Wendy characters
for _, ELIXIR in ipairs(NEW_ELIXIRS) do
    for NAME, _ in pairs(STRINGS.CHARACTERS) do
        CHARACTERS[NAME].DESCRIBE["NEWELIXIR_" .. string.upper(ELIXIR)] = CHARACTERS[NAME].DESCRIBE.GHOSTLYELIXIR_SPEED
    end
end

-- Item names, recipe descriptions, and Wendy inspect dialogue
CHARACTERS.WENDY.ACTIONFAIL.GIVE = {
    WRONG_ELIXIR = "I can't apply it without cleansing her!",
    NO_ELIXIR = "It won't stick!",
}
CHARACTERS.WENDY.ACTIONFAIL.MOONOFFERING = {
    NO_FULLMOON = "I will have to wait for a full moon.",
    NO_NIGHT = "I will have to wait for night.",
    GLASSED = "There is no water for an offering.",
    NO_VALUE = "Maybe something more sentimental...",
}

CHARACTERS.WENDY.DESCRIBE.ABIGAIL.NIGHTMARE = "A-...Abigail...?"
CHARACTERS.WENDY.DESCRIBE.MOONDIAL = {
    RITUAL_STARTED = "I can see shapes in the water.",
    RITUAL_COMPLETE = "Abigail? Abigail!",
}

STRINGS.RECIPE_DESC.GRAVESTONE = "Revenant relocation."

CHARACTERS.WENDY.DESCRIBE.MOUND = {
    GENERIC = "Now we can help.",
    DUG = "All it needs is an offering.",
}

STRINGS.NAMES.NEWELIXIR_SANITYAURA = "Floral Incense"
STRINGS.RECIPE_DESC.NEWELIXIR_SANITYAURA = "Spirit-scents."
CHARACTERS.WENDY.DESCRIBE.NEWELIXIR_SANITYAURA = "It smells of hyacinth and lily."

STRINGS.NAMES.NEWELIXIR_LIGHTAURA = "Radiant Remedy"
STRINGS.RECIPE_DESC.NEWELIXIR_LIGHTAURA = "A brilliant blazing brew."
CHARACTERS.WENDY.DESCRIBE.NEWELIXIR_LIGHTAURA = "Abigail would love this one."

STRINGS.NAMES.NEWELIXIR_HEALTHDAMAGE = "Sanguine Solution"
STRINGS.RECIPE_DESC.NEWELIXIR_HEALTHDAMAGE = "Harness the power of your grevious wounds."
CHARACTERS.WENDY.DESCRIBE.NEWELIXIR_HEALTHDAMAGE = "The closer we get, the stronger we become."

STRINGS.NAMES.NEWELIXIR_CLEANSE = "Purifying Balm"
STRINGS.RECIPE_DESC.NEWELIXIR_CLEANSE = "Cleanse your sister's soul."
CHARACTERS.WENDY.DESCRIBE.NEWELIXIR_CLEANSE = "This will help you stay calm."

STRINGS.NAMES.NEWELIXIR_INSANITYDAMAGE = "Nightmare Serum"
STRINGS.RECIPE_DESC.NEWELIXIR_INSANITYDAMAGE = "Harness the power of your bad dreams."
CHARACTERS.WENDY.DESCRIBE.NEWELIXIR_INSANITYDAMAGE = "Oh, but it wasn't a dream."

STRINGS.NAMES.NEWELIXIR_SHADOWFIGHTER = "Tenebrous Tincture"
STRINGS.RECIPE_DESC.NEWELIXIR_SHADOWFIGHTER = "Cloak your spirit in the shadows."
CHARACTERS.WENDY.DESCRIBE.NEWELIXIR_SHADOWFIGHTER = "This will help you see them too."

STRINGS.NAMES.NEWELIXIR_LIGHTNING = "Distilled Wrath"
STRINGS.RECIPE_DESC.NEWELIXIR_LIGHTNING = "Smite with the fury of the dead."
CHARACTERS.WENDY.DESCRIBE.NEWELIXIR_LIGHTNING = "It tingles."

--STRINGS.NAMES.NEWELIXIR_ = "item_name"
--STRINGS.RECIPE_DESC.NEWELIXIR_ = "recipe_description"
--CHARACTERS.WENDY.DESCRIBE.NEWELIXIR_ = "inspect_dialogue"