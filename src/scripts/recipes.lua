local Ingredient = GLOBAL.Ingredient
local Recipes = GLOBAL.AllRecipes
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

AddCharacterRecipe("newelixir_cleanse", {
    Ingredient("ash", 2),
    Ingredient("petals", 2),
    Ingredient("ghostflower", 2)
}, TECH.NONE, {
    builder_tag = "elixirbrewer",
    atlas = "images/inventoryimages/newelixir_cleanse.xml",
    image = "newelixir_cleanse.tex",
})

AddCharacterRecipe("newelixir_insanitydamage", {
    Ingredient("stinger", 1),
    Ingredient("nightmarefuel", 5),
    Ingredient("ghostflower", 3)
}, TECH.MAGIC_THREE, {
    builder_tag = "elixirbrewer",
    atlas = "images/inventoryimages/newelixir_insanitydamage.xml",
    image = "newelixir_insanitydamage.tex",
})

AddCharacterRecipe("newelixir_shadowfighter", {
    Ingredient("purplegem", 1),
    Ingredient("nightmarefuel", 5),
    Ingredient("ghostflower", 3)
}, TECH.MAGIC_THREE, {
    builder_tag = "elixirbrewer",
    atlas = "images/inventoryimages/newelixir_shadowfighter.xml",
    image = "newelixir_shadowfighter.tex",
})

AddCharacterRecipe("newelixir_lightning", {
    Ingredient("lightninggoathorn", 1),
    Ingredient("nightmarefuel", 5),
    Ingredient("ghostflower", 3)
}, TECH.MAGIC_THREE, {
    builder_tag = "elixirbrewer",
    atlas = "images/inventoryimages/newelixir_lightning.xml",
    image = "newelixir_lightning.tex",
})

AddCharacterRecipe("gravestone", {
    Ingredient("marble", 4),
    Ingredient("boneshard", 1),
    Ingredient("shovel", 1)
}, TECH.NONE, {
    placer = "gravestone_placer",
    builder_tag = "ghostlyfriend",
    atlas = "images/inventoryimages/gravestone.xml",
    image = "gravestone.tex",
})

-- recipe sorting
Recipes.gravestone.sortkey = Recipes.sisturn.sortkey + 0.1