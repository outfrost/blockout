tool
extends EditorPlugin

const BlockGizmoPlugin: = preload("res://addons/blockout/BlockGizmoPlugin.gd")
const Blockout: = preload("res://addons/blockout/Blockout.gd")

var block_gizmo_plugin: = BlockGizmoPlugin.new()

func _enter_tree() -> void:
	add_autoload_singleton("BlockoutUtil", "res://addons/blockout/BlockoutUtil.gd")
	BlockoutUtil.plugin = self

	add_spatial_gizmo_plugin(block_gizmo_plugin)
	add_custom_type("Blockout", "Spatial", Blockout, null)

func _exit_tree() -> void:
	remove_spatial_gizmo_plugin(block_gizmo_plugin)
	remove_custom_type("Blockout")

	BlockoutUtil.plugin = null
	remove_autoload_singleton("BlockoutUtil")
