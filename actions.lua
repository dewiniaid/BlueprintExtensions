--- Actions for shortcut bar/etc.
local actions = {
    ["BlueprintExtensions_flip-h"] = {
        icon = 0,
        key_sequence = "SHIFT + X",
        order = 'a-a',
        visibility_setting = 'BlueprintExtensions_show-mirror',
        data = 'h',
        shortcut_style = 'blue',
    },
    ["BlueprintExtensions_flip-v"] = {
        icon = 1,
        key_sequence = "SHIFT + V",
        order = 'a-b',
        visibility_setting = 'BlueprintExtensions_show-mirror',
        data = 'v',
        shortcut_style = 'blue',
    },
    ["BlueprintExtensions_rotate-clockwise"] = {
        icon = 2,
        key_sequence = "CONTROL + ALT + R",
        order = 'a-c',
        visibility_setting = 'BlueprintExtensions_show-rotate',
        data = false,
        shortcut_style = 'blue',
    },
    ["BlueprintExtensions_clone-blueprint"] = {
        icon = 3,
        key_sequence = "SHIFT + U",
        order = 'c-a',
        visibility_setting = 'BlueprintExtensions_show-clone',
        shortcut_style = 'green',
    },
    ["BlueprintExtensions_wireswap"] = {
        icon = 4,
        key_sequence = "CONTROL + ALT + W",
        order = 'c-b',
        visibility_setting = 'BlueprintExtensions_show-wireswap',
        shortcut_style = 'blue',
    },
    ["BlueprintExtensions_landfill"] = {
        icon = 5,
        key_sequence = "CONTROL + ALT + L",
        order = 'c-c',
        visibility_setting = 'BlueprintExtensions_show-landfill',
        shortcut_style = 'blue',
    },
    ["BlueprintExtensions_snap-center"] = {
        key_sequence = "PAD 5",
        order = 'f-a',
        data = 'center',
        shortcut_style = 'blue',
    }
}

for ix, t in pairs({
    { "n", "8" },
    { "e", "6" },
    { "s", "2" },
    { "w", "4" },
    { "nw", "7" },
    { "ne", "9" },
    { "sw", "1" },
    { "se", "3" }
}) do
    local d = t[1]
    local key = t[2]

    actions["BlueprintExtensions_snap-" .. d] = {
        key_sequence = "PAD " .. key,
        order = 'd-' .. ix,
        data = d,
    }

    actions["BlueprintExtensions_nudge-" .. d] = {
        key_sequence = "CONTROL + PAD " .. key,
        order = 'e-' .. ix,
        data = d,
    }
end

actions["BlueprintExtensions_snap-center"] = {
    key_sequence = "PAD 5",
    order = 'f-a',
    data = 'center',
}

for name, action in pairs(actions) do action.name = name end

return actions
