# shinytip (development version)

- New `tip_update()` function for changing a tooltip's text, position, width, or theme from the
server. To use it, give the tooltip an `id` when creating it with `tip()`, `tip_icon()`, or
`tip_input()`. The `id` names the tooltip rather than the tag it's attached to, so it can be the
same as the `inputId` of the input it sits on.

# shinytip 0.2.0 (2026-09-15)

Initial release
