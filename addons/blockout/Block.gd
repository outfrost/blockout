tool
extends Spatial

export var size: = Vector3.ONE setget set_size

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func set_size(v: Vector3) -> void:
	size = v
	update_gizmo()
