tool 
extends EditorPlugin

const MainPanel = preload("res://addons/helpers/ObjStateTools.tscn")

var main_panel_instance
var selection

func _enter_tree():
	main_panel_instance = MainPanel.instance()

	add_control_to_bottom_panel(main_panel_instance, "CharStateEditor")

	selection = get_editor_interface().get_selection()
	selection.connect("selection_changed", self, "_on_editor_selection_changed")
	pass

func _on_editor_selection_changed():
	var selected_nodes = selection.get_selected_nodes()
	for node in selected_nodes:
		if node is BaseObj:
			main_panel_instance.load_node(node)

			break

func _exit_tree():
	remove_control_from_bottom_panel(main_panel_instance)
	if main_panel_instance:
		main_panel_instance.queue_free()
	pass

func has_main_screen():
	return true
	
func make_visible(visible):
	if main_panel_instance:
		main_panel_instance.visible = visible
	pass

func get_plugin_name():
	return "1738 ayy im like hey whats up hello"

func get_plugin_icon():
	return get_editor_interface().get_base_control().get_icon("Node", "EditorIcons")
