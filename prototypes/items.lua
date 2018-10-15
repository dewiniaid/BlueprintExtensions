-- Add keybindings
data:extend({
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
