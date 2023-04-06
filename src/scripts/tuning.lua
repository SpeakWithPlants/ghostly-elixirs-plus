-- tuning values for this mod here
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
    ALL_ELIXIRS = {
        DURATION = TUNING.TOTAL_DAY_TIME,
    },
    ALL_NIGHTMARE_ELIXIRS = {
        DURATION = TUNING.TOTAL_DAY_TIME / 2,
        SANITYAURA = -TUNING.SANITYAURA_LARGE,
        DRIP_FX_PERIOD = 10 * GLOBAL.FRAMES,
        DARK_SWORD_VEX_MULT = 1.2,
    },
    SANITYAURA = {
        DURATION = TUNING.TOTAL_DAY_TIME * 2,
        AURA = TUNING.SANITYAURA_MED,
    },
    LIGHTAURA = {
        DURATION = TUNING.TOTAL_DAY_TIME * 2,
        INTENSITY = 0.5,
        RADIUS = 5,
        FALLOFF = 0.9,
        TEMPERATURE = 85,
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
        DURATION = 0.1,
        HEALTH_GAIN = 0.3,
        SANITY_GAIN = TUNING.SANITY_LARGE
    },

    -- continued tuning options for existing elixirs below
    SPEED = {
        MIN_FOLLOW_DIST = 0.5,
        MED_FOLLOW_DIST = 0.6,
        MAX_FOLLOW_DIST = 0.7,
    },
    SLOWREGEN = {
        BOND_TIME_MULT = 3,
    },
}