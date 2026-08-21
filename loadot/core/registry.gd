# Loadot Registry, for accessing mod details and other information

var mods : Array[ModResource] = []
var patches : Array[Patch] = []

class ModResource extends Resource:
    var id : String
    var name : String
    var version : String

    func _init(_id : String, _name := _id, _version := "1.0.0") -> void:
        id = _id
        name = _name
        version = _version

class Patch extends Resource:
    var script_path : String
    var priority : int
    var node : Node = null

    func _init(_script_path : String, _priority := 1, _node : Node = null):
        script_path = _script_path
        priority = _priority
        node = _node

## Register mod details for other mods to read and parse
func register_mod(id : String, name : String, version : String):
    var mod = ModResource.new(id, name, version)
    mods.append(mod)


## Conviencence function that registers multiple patches at once.
## To have unique priorities for individual patches, use the `register_patch` function to register that specific patch.
func register_patches(_patches, priority := 0) -> void:
    if _patches is Array[Patch]:
        patches.append_array(_patches)
    elif _patches is Array[Script]:
        for script in _patches:
            register_patch(script, priority)
    else:
        push_error("Patches %s not Array[Patch] or Array[Script]! Rejecting!"% patches)


## Registers a patch to be loaded later based on priority
func register_patch(patch, priority := 0) -> void:
    if patch is Patch:
        patches.append(patch)
    elif patch is String:
        var new_patch = Patch.new(patch, priority)
        patches.append(new_patch)
    else:
        push_error("Patch %s is not Patch class or String! Rejecting!" % patch)

func register_autoload(patch, node : Node, priority := 0):
    if patch is Patch:
        patches.append(patch)
    elif patch is String:
        var new_patch = Patch.new(patch, priority, node)
        patches.append(new_patch)
    else:
        push_error("Autoload patch %s is not Patch class or String! Rejecting!" % patch)

## Function to start patching all registered patches respecting priority
func load_patches():
    # Sort all patches in priority order
    patches.sort_custom(func (a : Patch, b : Patch): return a.priority < b.priority)

    for patch in patches:
        var patch_script = load(patch.script_path)
        Loadot.Injector.inject_script(patch_script)

        if patch.node:
            Loadot.Injector.inject_autoload(patch_script, patch.node)