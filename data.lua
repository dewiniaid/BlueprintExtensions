-- Add keybindings
data:extend({
    {
        type = "custom-input",
        name = "BlueprintExtensions_flip-h",
        key_sequence = "SHIFT + x",
        order = 'a-a'
    },
    {
        type = "custom-input",
        name = "BlueprintExtensions_flip-v",
        key_sequence = "SHIFT + v",
        order = 'a-b'
    },
    {
        type = "custom-input",
        name = "BlueprintExtensions_snap-n",
        key_sequence = "PAD 8",
        order = 'd-a',
    },
    {
        type = "custom-input",
        name = "BlueprintExtensions_snap-e",
        key_sequence = "PAD 6",
        order = 'd-b',
    },
    {
        type = "custom-input",
        name = "BlueprintExtensions_snap-s",
        key_sequence = "PAD 2",
        order = 'd-c',
    },
    {
        type = "custom-input",
        name = "BlueprintExtensions_snap-w",
        key_sequence = "PAD 4",
        order = 'd-d',
    },

    {
        type = "custom-input",
        name = "BlueprintExtensions_snap-nw",
        key_sequence = "PAD 7",
        order = 'e-a',
    },
    {
        type = "custom-input",
        name = "BlueprintExtensions_snap-ne",
        key_sequence = "PAD 9",
        order = 'e-b',
    },
    {
        type = "custom-input",
        name = "BlueprintExtensions_snap-sw",
        key_sequence = "PAD 1",
        order = 'e-c',
    },
    {
        type = "custom-input",
        name = "BlueprintExtensions_snap-se",
        key_sequence = "PAD 3",
        order = 'e-d',
    },
    {
        type = "custom-input",
        name = "BlueprintExtensions_snap-center",
        key_sequence = "PAD 5",
        order = 'f-a',
    },
    {
        type = "custom-input",
        name = "BlueprintExtensions_clone-blueprint",
        key_sequence = "SHIFT + U",
        order = 'g-a',
    },

    {
        type = "selection-tool",
        name = "BlueprintExtensions_cloned-blueprint",
        icon = "__BlueprintExtensions__/graphics/icons/cloned-blueprint.png",
        icon_size = 32,
        flags = { "goes-to-quickbar" },
        subgroup = "tool",
        order = "c[automated-construction]-a[blueprint]-no-picker",
        stack_size = 1,
        stackable = false,
        selection_color = { r = 0, g = 1, b = 0 },
        alt_selection_color = { r = 0, g = 1, b = 0 },
        selection_mode = { "blueprint" },
        alt_selection_mode = { "blueprint" },
        selection_cursor_box_type = "copy",
        alt_selection_cursor_box_type = "copy",
        show_in_library = false
    },
})

require("style")
