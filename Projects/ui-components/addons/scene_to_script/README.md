# Scene To Script Converter (Godot 4.6)

This addon adds an editor dock that converts a `.tscn` scene into a generated `.gd` script with:

```gdscript
static func build() -> Node
```

The generated `build()` function reconstructs the scene tree and applies as much configuration as is realistically reproducible in script.

## Folder structure

```
res://addons/scene_to_script/
├── plugin.cfg
├── plugin.gd
├── scene_to_script_dock.gd
└── README.md
```

## Install

1. Copy `addons/scene_to_script` into your Godot project.
2. Open the project in Godot 4.6.
3. Go to **Project > Project Settings > Plugins**.
4. Enable **Scene To Script Converter**.
5. Open the new dock tab **Scene→Script**.

## Usage

1. Choose **Scene input (.tscn)**.
2. Choose **Output script path** (default is `..._generated.gd` next to the scene).
3. Configure options:
   - Include exported properties
   - Include non-default properties only
   - Include node groups
   - Include signals (connections) when possible
   - Include resources
   - Include children order and owner where applicable
4. Choose **Instantiation style**:
   - `PackedScene.instantiate()`
   - `Manual Node.new()`
5. Press **Convert**.
6. Review the log output in the dock.

## What is reproduced

- Node tree hierarchy
- Child order
- Node names
- Most stored properties (optionally diffed against class defaults)
- Script exported variables (optional)
- Node groups (optional)
- Signal connections for node-to-node callables where method/target are resolvable (optional)
- Resource properties:
  - External resources via `load("res://...")`
  - Embedded resources via generated inline construction (best effort)

## Limitations / non-reproducible cases

- Runtime-only state (dynamic data only available while running)
- Internal engine handles (`RID`, low-level internals)
- `Callable`, `Signal`, and object references that cannot be expressed safely as literals
- Tool/editor metadata that is not storable or not script-safe
- Some custom script classes if they are not globally named or cannot be instantiated directly
- Signal connections that target non-node objects or unresolved methods/targets
- Complex resources with unsupported nested object payloads

The converter logs skipped properties/signals/resources so you can manually patch the generated script where needed.
