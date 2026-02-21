# Custom Modular UI Components for Godot 4

This folder gives you a practical starter-kit for desktop-style applications (Windows-first) that can still adapt cleanly to mobile layouts.

## Design goals
- **Self-building UI**: each component builds its own child tree in script.
- **Composable**: components are standalone and can be dropped into any scene.
- **Adaptive behavior**: every component extends one base class (`AdaptiveUIComponent`) so desktop/mobile tweaks stay centralized.

## Files

### `scripts/adaptive_ui_component.gd`
**Purpose:** shared base class for responsive logic.
- Detects whether viewport width is below a configurable mobile breakpoint.
- Exposes `get_adaptive_padding()` for desktop/mobile spacing.
- Calls `_build_ui()` once and `_refresh_layout()` when viewport size changes.

### `scripts/date_time_picker.gd`
**Purpose:** date + time input in a single control.
- Combines calendar date selection with month/year/hour/minute controls.
- Supports 12h or 24h behavior.
- Emits `date_time_changed(selected_dict)` whenever selection updates.
- Useful for appointment scheduling, reminders, logs, filter ranges, etc.

### `scripts/toast_stack.gd`
**Purpose:** non-blocking toast notifications.
- Provides `push_toast(message, duration)`.
- Manages stacking and auto-fade lifecycle.
- Limits visible toasts via `max_toasts`.
- Ideal for save confirmations, warning nudges, and background-task status.

### `scripts/adaptive_alert.gd`
**Purpose:** modal confirmation/alert with desktop/mobile-friendly sizing.
- Backdrop + centered panel.
- Configurable labels and optional cancel button.
- Emits `confirmed` and `cancelled` signals.
- Use for delete confirmations, destructive actions, and legal acknowledgements.

### `scripts/dockable_window.gd`
**Purpose:** draggable floating window container.
- Header with title + close button.
- Drag handle to reposition within your app UI.
- `set_content(control)` method to inject any custom panel.
- Great for inspector tools, property panels, plugin-like mini windows, and advanced desktop UX.

### `scripts/bottom_sheet.gd`
**Purpose:** mobile-first bottom sheet that still works in desktop apps.
- Tap/click sheet to toggle collapsed/expanded states.
- Animated transitions.
- `set_content(control)` to plug in any UI.
- Perfect for quick actions, contextual details, or mobile secondary navigation.

### `scripts/command_palette.gd`
**Purpose:** productivity command launcher (VSCode-style palette).
- Accepts command dictionaries via `set_commands([{id,name}, ...])`.
- Filters commands live from search text.
- Emits `command_chosen(command_id)` on activation.
- Useful for power-user shortcuts in admin apps and internal tooling.

## Quick setup
1. Copy this `ui_components` folder into your project.
2. Attach a component script to an empty `Control` node (or instantiate by code).
3. For overlays/modals (`ToastStack`, `AdaptiveAlert`, `BottomSheet`, `CommandPalette`), add to a top-level `CanvasLayer` or root UI node.
4. Connect component signals to your app controller.

## Example bootstrap snippet
```gdscript
# In a root UI script
var toast := ToastStack.new()
add_child(toast)
toast.push_toast("Settings saved")

var alert := AdaptiveAlert.new()
add_child(alert)
alert.confirmed.connect(func(): print("Confirmed"))
alert.show_alert("Delete item", "This action cannot be undone.", "Delete")

var palette := CommandPalette.new()
add_child(palette)
palette.set_commands([
	{"id": "open_settings", "name": "Open Settings"},
	{"id": "sync_now", "name": "Sync Now"}
])
palette.command_chosen.connect(func(command_id): print(command_id))
```

## Extending the library
To add a new component, inherit from `AdaptiveUIComponent` and implement:
- `_build_ui()` to create children programmatically.
- `_refresh_layout()` for breakpoint-specific spacing/sizing.

That pattern keeps each node self-contained while preserving consistent responsive behavior.
