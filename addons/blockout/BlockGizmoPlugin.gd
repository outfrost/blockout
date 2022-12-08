extends EditorSpatialGizmoPlugin

const Block: = preload("res://addons/blockout/Block.gd")

func _init() -> void:
	create_handle_material("handle")

func get_name() -> String:
	return "bruh"

func has_gizmo(spatial: Spatial) -> bool:
	return spatial is Block

func can_be_hidden() -> bool:
	return true

func redraw(gizmo: EditorSpatialGizmo) -> void:
	gizmo.clear()

	var block = gizmo.get_spatial_node()

	var handles = PoolVector3Array()
	handles.push_back(Vector3.RIGHT * block.size.x)
	handles.push_back(Vector3.UP * block.size.y)
	handles.push_back(Vector3.BACK * block.size.z)

	gizmo.add_handles(handles, get_material("handle", gizmo))

func get_handle_name(gizmo: EditorSpatialGizmo, index: int) -> String:
	match index:
		0: return "X"
		1: return "Y"
		2: return "Z"
		_: return "wtf"

func get_handle_value(gizmo: EditorSpatialGizmo, index: int):
	match index:
		0: return gizmo.get_spatial_node().size.x
		1: return gizmo.get_spatial_node().size.y
		2: return gizmo.get_spatial_node().size.z
		_: return NAN

func set_handle(gizmo: EditorSpatialGizmo, index: int, camera: Camera, point: Vector2) -> void:
	var block: Block = gizmo.get_spatial_node()
	var axis_size: float
	var axis: Vector3
	match index:
		0:
			axis_size = block.size.x
			axis = Vector3.RIGHT
		1:
			axis_size = block.size.y
			axis = Vector3.UP
		2:
			axis_size = block.size.z
			axis = Vector3.BACK
		_:
			push_error("wtf")
			return

	var points: = Geometry.get_closest_points_between_segments(
		block.global_translation,
		block.global_translation + (block.global_transform.xform(axis) * max(axis_size, 1.0) * 100.0),
		camera.project_ray_origin(point),
		camera.project_ray_origin(point) + (camera.project_ray_normal(point) * camera.far))
	var point_local: Vector3 = block.global_transform.xform_inv(points[0])

	match index:
		0:
			if !is_nan(point_local.x):
				block.size.x = point_local.x
		1:
			if !is_nan(point_local.y):
				block.size.y = point_local.y
		2:
			if !is_nan(point_local.z):
				block.size.z = point_local.z
