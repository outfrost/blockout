tool
extends Spatial

const STAIR_HEIGHT: float = 0.125

export var size: = Vector3.ONE setget set_size

var ready: bool = false

func _ready() -> void:
	if BlockoutUtil.plugin.get_editor_interface().get_edited_scene_root() == self:
		return

	regen_geometry()

#	material.set_shader_param(
#		"base_texture",
#		load(TEXTURE_ROOT + "/" + color + "/" + TEXTURE_NAMES[texture_variant]))

#	var mesh: = CubeMesh.new()
#	mesh.size = size
#	mesh.material = material
#	mesh_inst.mesh = mesh
#
#	var shape: = BoxShape.new()
#	shape.extents = size * 0.5
#	collision_shape.shape = shape

	ready = true

func regen_geometry() -> void:
	for child in get_children():
		if child.owner == null:
			remove_child(child)
			child.queue_free()

	var segments: int = ceil(size.y / STAIR_HEIGHT)
	if segments == 0:
		segments = 1
	var segment_length: float = size.z / float(segments)

	for i in range(segments):
		var segment_height: float = min((segments - i) * STAIR_HEIGHT, size.y)
		var mesh: = CubeMesh.new()
		mesh.size = Vector3(size.x, segment_height, segment_length)
		var mesh_inst: = MeshInstance.new()
		mesh_inst.translation = Vector3(0.0, segment_height * 0.5, (float(i) + 0.5) * segment_length)
		mesh_inst.mesh = mesh
		add_child(mesh_inst)

func set_size(v: Vector3) -> void:
	size = v
	if ready:
		regen_geometry()
	update_gizmo()
	BlockoutUtil.plugin.get_editor_interface().get_inspector().refresh()
