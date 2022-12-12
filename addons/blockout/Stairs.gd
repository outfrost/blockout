tool
extends Spatial

const MATERIAL: Material = preload("res://addons/blockout/material/stairs_mat.tres")
const STAIR_HEIGHT: float = 0.125
const BASE_TEXTURE_NAME: String = "03.png"
const STAIRS_SIDE_TEXTURE_NAME: String = "10.png"

export var size: = Vector3.ONE setget set_size
export(String, "dark", "green", "light", "orange", "purple", "red") var color: String = "dark" setget set_color

var ready: bool = false

func _ready() -> void:
	if BlockoutUtil.plugin.get_editor_interface().get_edited_scene_root() == self:
		return

	regen_geometry()

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
		var segment_height: float = (segments - i) * (size.y / segments)
		#min((segments - i) * STAIR_HEIGHT, size.y)
		var pos_offset: = Vector3(0.0, segment_height * 0.5, (float(i) + 0.5) * segment_length)

		var material: = MATERIAL.duplicate(false)
		material.set_shader_param(
			"base_texture",
			load(BlockoutUtil.TEXTURE_ROOT + "/" + color + "/" + BASE_TEXTURE_NAME))
		material.set_shader_param(
			"stairs_side_texture",
			load(BlockoutUtil.TEXTURE_ROOT + "/" + color + "/" + STAIRS_SIDE_TEXTURE_NAME))
		material.set_shader_param("local_pos_offset", pos_offset)
		material.set_shader_param("stairs_size", size)
		material.set_shader_param("stair_height_ratio", (size.y / segments) / STAIR_HEIGHT)
		material.set_shader_param("stair_height", (size.y / segments))

		var mesh: = CubeMesh.new()
		mesh.size = Vector3(size.x, segment_height, segment_length)
		mesh.material = material

		var mesh_inst: = MeshInstance.new()
		mesh_inst.translation = pos_offset
		mesh_inst.mesh = mesh

		add_child(mesh_inst)

func set_size(v: Vector3) -> void:
	size = v
	if ready:
		regen_geometry()
	update_gizmo()
	BlockoutUtil.plugin.get_editor_interface().get_inspector().refresh()

func set_color(v: String) -> void:
	var base_filename: String = BlockoutUtil.TEXTURE_ROOT + "/" + v + "/" + BASE_TEXTURE_NAME
	var stairs_side_filename: String = BlockoutUtil.TEXTURE_ROOT + "/" + color + "/" + STAIRS_SIDE_TEXTURE_NAME
	if !File.new().file_exists(base_filename) || !File.new().file_exists(stairs_side_filename):
		push_error("Stairs texture color \"%s\" doesn't exist" % v)
		return
	color = v

	if !ready:
		return

	for child in get_children():
		if !(child is MeshInstance):
			continue
		(child as MeshInstance).mesh.material.set_shader_param(
			"base_texture",
			load(base_filename))
		(child as MeshInstance).mesh.material.set_shader_param(
			"stairs_side_texture",
			load(stairs_side_filename))
