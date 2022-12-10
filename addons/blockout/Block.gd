tool
extends Spatial

const MATERIAL: Material = preload("res://addons/blockout/material/block_mat.tres")

const TEXTURE_ROOT: String = "res://addons/blockout/texture/kenney"
const TEXTURE_NAMES: Array = [
	"00.png",
	"01.png",
	"02.png",
	"03.png",
	"04.png",
	"05.png",
	"06.png",
	"07.png",
	"08.png",
	"09.png",
]

export var size: = Vector3.ONE setget set_size
export(String, "dark", "green", "light", "orange", "purple", "red") var color: String = "dark" setget set_color
export(int, 0, 9) var texture_variant: int = 0 setget set_texture_variant

onready var mesh_inst: MeshInstance = $"%MeshInstance"
onready var material: Material = MATERIAL.duplicate(false)

func _ready() -> void:
	if BlockoutUtil.plugin.get_editor_interface().get_edited_scene_root() == self:
		return

	material.set_shader_param(
		"base_texture",
		load(TEXTURE_ROOT + "/" + color + "/" + TEXTURE_NAMES[texture_variant]))

	var mesh: = CubeMesh.new()
	mesh.size = size
	mesh.material = material
	mesh_inst.mesh = mesh

func set_size(v: Vector3) -> void:
	size = v
	if mesh_inst && mesh_inst.mesh:
		mesh_inst.mesh.size = size
	update_gizmo()
	BlockoutUtil.plugin.get_editor_interface().get_inspector().refresh()

func set_color(v: String) -> void:
	var filename: String = TEXTURE_ROOT + "/" + v + "/" + TEXTURE_NAMES[texture_variant]
	if !File.new().file_exists(filename):
		push_error("Block texture color \"%s\" doesn't exist" % v)
		return
	color = v
	if mesh_inst && mesh_inst.mesh:
		material.set_shader_param("base_texture", load(filename))

func set_texture_variant(v: int) -> void:
	var filename: String = TEXTURE_ROOT + "/" + color + "/" + TEXTURE_NAMES[v]
	if !File.new().file_exists(filename):
		push_error("Block texture variant %d doesn't exist" % v)
		return
	texture_variant = v
	if mesh_inst && mesh_inst.mesh:
		material.set_shader_param("base_texture", load(filename))
