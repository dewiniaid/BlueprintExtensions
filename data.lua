-- Add keybindings
data:extend({
    {
        type = "custom-input",
        name = "BlueprintExtensions_snap-n",
        key_sequence = "PAD 8",
        order = 'a-a',
    },
    {
        type = "custom-input",
        name = "BlueprintExtensions_snap-e",
        key_sequence = "PAD 6",
        order = 'a-b',
    },
    {
        type = "custom-input",
        name = "BlueprintExtensions_snap-s",
        key_sequence = "PAD 2",
        order = 'a-c',
    },
    {
        type = "custom-input",
        name = "BlueprintExtensions_snap-w",
        key_sequence = "PAD 4",
        order = 'a-d',
    },

        {
        type = "custom-input",
        name = "BlueprintExtensions_snap-nw",
        key_sequence = "PAD 7",
        order = 'b-a',
    },
    {
        type = "custom-input",
        name = "BlueprintExtensions_snap-ne",
        key_sequence = "PAD 9",
        order = 'b-b',
    },
    {
        type = "custom-input",
        name = "BlueprintExtensions_snap-sw",
        key_sequence = "PAD 1",
        order = 'b-c',
    },
    {
        type = "custom-input",
        name = "BlueprintExtensions_snap-se",
        key_sequence = "PAD 3",
        order = 'b-d',
    },
    {
        type = "custom-input",
        name = "BlueprintExtensions_snap-center",
        key_sequence = "PAD 5",
        order = 'c-a',
    },
    {
        type = "custom-input",
        name = "BlueprintExtensions_clone-blueprint",
        key_sequence = "SHIFT + U",
        order = 'd-a',
    },

    {
        type = "selection-tool",
        name = "BlueprintExtensions_cloned-blueprint",
        icon = "__BlueprintExtensions__/graphics/icons/cloned-blueprint.png",
        icon_size = 32,
        flags = { "goes-to-quickbar" },
        subgroup = "tool",
        order = "c[automated-construction]-a[blueprint]",
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

