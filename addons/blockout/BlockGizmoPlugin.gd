extends EditorSpatialGizmoPlugin

const Block: = preload("res://addons/blockout/Block.gd")

const SNAP: Vector3 = Vector3.ONE

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
	return "Size"

func get_handle_value(gizmo: EditorSpatialGizmo, index: int):
	var block: Block = gizmo.get_spatial_node()
	return block.size

func set_handle(gizmo: EditorSpatialGizmo, index: int, camera: Camera, point: Vector2) -> void:
	var block: Block = gizmo.get_spatial_node()
	match index:
		0:
			var point_along_axis: = nearest_point_along_axis(
				block.global_transform,
				Vector3.RIGHT,
				block.size.x,
				camera,
				point)

			if !is_nan(point_along_axis.x):
				block.size.x = point_along_axis.x
		1:
			var point_along_axis: = nearest_point_along_axis(
				block.global_transform,
				Vector3.UP,
				block.size.y,
				camera,
				point)

			if !is_nan(point_along_axis.y):
				block.size.y = point_along_axis.y
		2:
			var point_along_axis: = nearest_point_along_axis(
				block.global_transform,
				Vector3.BACK,
				block.size.z,
				camera,
				point)

			if !is_nan(point_along_axis.z):
				block.size.z = point_along_axis.z
		_:
			push_error("wtf")
			return

func nearest_point_along_axis(
	block_global_transform: Transform,
	axis_direction: Vector3,
	current_extent: float,
	camera: Camera,
	viewport_point: Vector2
) -> Vector3:
	var points: = Geometry.get_closest_points_between_segments(
		block_global_transform.origin,
		block_global_transform.origin + (block_global_transform.basis.xform(axis_direction) * max(current_extent, 1.0) * 100.0),
		camera.project_ray_origin(viewport_point),
		camera.project_ray_origin(viewport_point) + (camera.project_ray_normal(viewport_point) * camera.far))
	print(points[0])
	var point_local: Vector3 = block_global_transform.xform_inv(points[0])
	return point_local

func commit_handle(gizmo: EditorSpatialGizmo, index: int, restore, cancel: bool = false) -> void:
	if !cancel:
		return

	var block: Block = gizmo.get_spatial_node()
	block.size = restore
