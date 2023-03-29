-- tuning values for this mod here
TUNING.ELIXIRS_PLUS = {
    MAX_SACRIFICE = 9,
    COMPLETE_RITUAL_BONUS_FLOWERS = 3,
    SANITYAURA = {
        AURA = TUNING.SANITYAURA_MED
    },
    LIGHTAURA = {
        LIGHT_RADIUS = 5,
        TEMPERATURE = 85
    },
    HEALTHDAMAGE = {
        LOW_DAMAGE_MULT = 1.4,
        MED_DAMAGE_MULT = 1.6,
        HIGH_DAMAGE_MULT = 1.9,
        CRIT_DAMAGE_MULT = 2.4,

        HIGH_HEALTH = 0.65,
        MED_HEALTH = 0.4,
        LOW_HEALTH = 0.2
    },
    CLEANSE = {
        HEAL_MULT = 0.3,
        SANITY_GAIN = TUNING.SANITY_LARGE
    },
    LIGHTNING = {
        SMITE_CHANCE = 0.1
    }
}

TUNING.NEW_ELIXIRS = {
    MOONDIAL = {
        RITUAL_STARTED_FLOWERS = -1, -- number of flowers each trinket is worth before completing the ritual
        RITUAL_COMPLETE_TRINKETS = 3, -- number of trinkets required to complete the ritual
        RITUAL_COMPLETE_BONUS_FLOWERS = 5, -- one-time bonus flowers for completing the ritual
        RITUAL_COMPLETE_FLOWERS = 1, -- number of flowers each trinket is worth after completing the ritual
        RITUAL_STARTED_SANITY_AURA = TUNING.SANITYAURA_SMALL, -- moon dial sanity aura after starting the ritual, but before completing it
        RITUAL_COMPLETE_SANITY_AURA = TUNING.SANITYAURA_LARGE, -- moon dial sanity aura after completing the ritual
    },

    -- continued tuning options for new elixirs below
    ALL_NIGHTMARE_ELIXIRS = {
        SANITYAURA = -TUNING.SANITYAURA_LARGE
    },
    SANITYAURA = {
        AURA = TUNING.SANITYAURA_MED
    },
    LIGHTAURA = {
        LIGHT_RADIUS = 7,
        TEMPERATURE = 85
    },
    HEALTHDAMAGE = {
        HIGH_HEALTH = 1.0,
        LOW_HEALTH = 0.2,
        ABIGAIL = {
            MIN_DAMAGE_MULT = 1.0,
            MAX_DAMAGE_MULT = 1.5,
            BONUS_DAMAGE_MULT = 1.5,
        },
        WENDY_VEX = {
            MIN_DAMAGE_MULT = 1.4,
            MAX_DAMAGE_MULT = 2.4,
            BONUS_DAMAGE_MULT = 2.8,
        },
    },
    INSANITYDAMAGE = {
        HIGH_SANITY = 1.0,
        LOW_SANITY = 0.2,
        ABIGAIL = {
            MIN_DAMAGE_MULT = 1.0,
            MAX_DAMAGE_MULT = 1.5,
            BONUS_DAMAGE_MULT = 1.5,
        },
        WENDY_VEX = {
            MIN_DAMAGE_MULT = 1.4,
            MAX_DAMAGE_MULT = 2.0,
            BONUS_DAMAGE_MULT = 2.5,
        },
    },
    SHADOWFIGHTER = {
        WENDY_VEX = {
            DAMAGE_MULT = 2.0,
        },
    },
    LIGHTNING = {
        SMITE_CHANCE = 0.1
    },
    CLEANSE = {
        HEALTH_GAIN = 0.3,
        SANITY_GAIN = TUNING.SANITY_LARGE
    },

    -- continued tuning options for existing elixirs below
    SPEED = {
        MIN_FOLLOW_DIST = 0.5,
        MED_FOLLOW_DIST = 0.8,
        MAX_FOLLOW_DIST = 1.0,
    },
    SLOWREGEN = {
        BOND_TIME_MULT = 3,
    },
}

-- TODO remove debug options
TUNING.GHOST_GRAVESTONE_CHANCE = 1.0
TUNING.UNIQUE_SMALLGHOST_DISTANCE = 0.1