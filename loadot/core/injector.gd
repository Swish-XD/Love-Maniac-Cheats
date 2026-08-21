extends Node

# Based on script extension from Delta V and GodotModding
static func inject_script(script : Script):

    script.set_meta("injected_script_path", script.resource_path)
    script.new()

    var parent_script : Script = script.get_base_script()
    var parent_script_path = parent_script.resource_path

    # Here we want to store the fact that we're injecting so we can do an inheritance chain?

    script.take_over_path(parent_script_path)

# Replace the running script on an autoload with our custom script
func inject_autoload(script : Script, autoload_node : Node) -> Script:

    autoload_node.set_script(script)

    return script