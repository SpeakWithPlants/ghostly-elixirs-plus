local Ingredient = GLOBAL.Ingredient
local TECH = GLOBAL.TECH

-- add recipes for new elixirs
AddCharacterRecipe("newelixir_sanityaura", {
    Ingredient("petals", 1),
    Ingredient("ghostflower", 1)
}, TECH.NONE, {
    builder_tag = "elixirbrewer",
    atlas = "images/inventoryimages/newelixir_sanityaura.xml",
    image = "newelixir_sanityaura.tex",
})

AddCharacterRecipe("newelixir_lightaura", {
    Ingredient("redgem", 1),
    Ingredient("ghostflower", 2)
}, TECH.NONE, {
    builder_tag = "elixirbrewer",
    atlas = "images/inventoryimages/newelixir_lightaura.xml",
    image = "newelixir_lightaura.tex",
})

AddCharacterRecipe("newelixir_healthdamage", {
    Ingredient("mosquitosack", 1),
    Ingredient(GLOBAL.CHARACTER_INGREDIENT.HEALTH, 30),
    Ingredient("ghostflower", 3)
}, TECH.NONE, {
    builder_tag = "elixirbrewer",
    atlas = "images/inventoryimages/newelixir_healthdamage.xml",
    image = "newelixir_healthdamage.tex",
})

AddCharacterRecipe("newelixir_insanitydamage", {
    Ingredient("stinger", 1),
    Ingredient("nightmarefuel", 3),
    Ingredient("ghostflower", 3)
}, TECH.MAGIC_THREE, {
    builder_tag = "elixirbrewer",
    atlas = "images/inventoryimages/newelixir_insanitydamage.xml",
    image = "newelixir_insanitydamage.tex",
})

AddCharacterRecipe("newelixir_shadowfighter", {
    Ingredient("purplegem", 1),
    Ingredient("nightmarefuel", 3),
    Ingredient("ghostflower", 3)
}, TECH.MAGIC_THREE, {
    builder_tag = "elixirbrewer",
    atlas = "images/inventoryimages/newelixir_shadowfighter.xml",
    image = "newelixir_shadowfighter.tex",
})

AddCharacterRecipe("newelixir_lightning", {
    Ingredient("lightninggoathorn", 1),
    Ingredient("nightmarefuel", 3),
    Ingredient("ghostflower", 3)
}, TECH.MAGIC_THREE, {
    builder_tag = "elixirbrewer",
    atlas = "images/inventoryimages/newelixir_lightning.xml",
    image = "newelixir_lightning.tex",
})

AddCharacterRecipe("newelixir_cleanse", {
    Ingredient("ash", 1),
    Ingredient("petals", 1),
    Ingredient("ghostflower", 1)
}, TECH.NONE, {
    builder_tag = "elixirbrewer",
    atlas = "images/inventoryimages/newelixir_cleanse.xml",
    image = "newelixir_cleanse.tex",
})

