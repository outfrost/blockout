tool
extends Spatial

const MATERIAL: Material = preload("res://addons/blockout/material/block_mat.tres")

export var size: = Vector3.ONE setget set_size

onready var mesh_inst: MeshInstance = $"%MeshInstance"

func _ready() -> void:
	if BlockoutUtil.plugin.get_editor_interface().get_edited_scene_root() == self:
		return

	var mesh: = CubeMesh.new()
	mesh.size = size
	mesh.material = MATERIAL
	mesh_inst.mesh = mesh

func set_size(v: Vector3) -> void:
	size = v
	if mesh_inst.mesh:
		mesh_inst.mesh.size = size
	update_gizmo()
