extends EditorSpatialGizmoPlugin

const Block: = preload("res://addons/blockout/Block.gd")

const SNAP_STEP: float = 1.0

class HandleValue:
	var size: Vector3
	var origin: Vector3

	func _init(size: Vector3, origin: Vector3) -> void:
		self.size = size
		self.origin = origin

	func _to_string() -> String:
		return str(size)

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
	handles.push_back(Vector3.RIGHT * block.size.x * 0.5)
	handles.push_back(Vector3.LEFT * block.size.x * 0.5)
	handles.push_back(Vector3.UP * block.size.y * 0.5)
	handles.push_back(Vector3.DOWN * block.size.y * 0.5)
	handles.push_back(Vector3.BACK * block.size.z * 0.5)
	handles.push_back(Vector3.FORWARD * block.size.z * 0.5)

	gizmo.add_handles(handles, get_material("handle", gizmo))

func get_handle_name(gizmo: EditorSpatialGizmo, index: int) -> String:
	return "Size"

func get_handle_value(gizmo: EditorSpatialGizmo, index: int) -> HandleValue:
	var block: Block = gizmo.get_spatial_node()
	return HandleValue.new(block.size, block.global_translation)

func set_handle(gizmo: EditorSpatialGizmo, index: int, camera: Camera, point: Vector2) -> void:
	var block: Block = gizmo.get_spatial_node()
	var snap: float = SNAP_STEP
	if Input.is_key_pressed(KEY_SHIFT):
		snap *= 0.1
	if Input.is_key_pressed(KEY_CONTROL):
		snap = 0.0
	match index:
		0:
			var prev_extent: float = block.size.x * 0.5
			var point_along_semiaxis: = nearest_point_along_semiaxis(
				block.global_transform,
				Vector3.RIGHT,
				prev_extent,
				camera,
				point)

			if is_nan(point_along_semiaxis.x):
				return

			var extent_diff: float = stepify(point_along_semiaxis.x - prev_extent, snap)
			block.translate_object_local(Vector3.RIGHT * extent_diff * 0.5)
			block.size.x += extent_diff
		1:
			var prev_extent: float = block.size.x * 0.5
			var point_along_semiaxis: = nearest_point_along_semiaxis(
				block.global_transform,
				Vector3.LEFT,
				prev_extent,
				camera,
				point)

			if is_nan(point_along_semiaxis.x):
				return

			var extent_diff: float = stepify(- point_along_semiaxis.x - prev_extent, snap)
			block.translate_object_local(Vector3.LEFT * extent_diff * 0.5)
			block.size.x += extent_diff
		2:
			var prev_extent: float = block.size.y * 0.5
			var point_along_semiaxis: = nearest_point_along_semiaxis(
				block.global_transform,
				Vector3.UP,
				prev_extent,
				camera,
				point)

			if is_nan(point_along_semiaxis.y):
				return

			var extent_diff: float = stepify(point_along_semiaxis.y - prev_extent, snap)
			block.translate_object_local(Vector3.UP * extent_diff * 0.5)
			block.size.y += extent_diff
		3:
			var prev_extent: float = block.size.y * 0.5
			var point_along_semiaxis: = nearest_point_along_semiaxis(
				block.global_transform,
				Vector3.DOWN,
				prev_extent,
				camera,
				point)

			if is_nan(point_along_semiaxis.y):
				return

			var extent_diff: float = stepify(- point_along_semiaxis.y - prev_extent, snap)
			block.translate_object_local(Vector3.DOWN * extent_diff * 0.5)
			block.size.y += extent_diff
		4:
			var prev_extent: float = block.size.z * 0.5
			var point_along_semiaxis: = nearest_point_along_semiaxis(
				block.global_transform,
				Vector3.BACK,
				prev_extent,
				camera,
				point)

			if is_nan(point_along_semiaxis.z):
				return

			var extent_diff: float = stepify(point_along_semiaxis.z - prev_extent, snap)
			block.translate_object_local(Vector3.BACK * extent_diff * 0.5)
			block.size.z += extent_diff
		5:
			var prev_extent: float = block.size.z * 0.5
			var point_along_semiaxis: = nearest_point_along_semiaxis(
				block.global_transform,
				Vector3.FORWARD,
				prev_extent,
				camera,
				point)

			if is_nan(point_along_semiaxis.z):
				return

			var extent_diff: float = stepify(- point_along_semiaxis.z - prev_extent, snap)
			block.translate_object_local(Vector3.FORWARD * extent_diff * 0.5)
			block.size.z += extent_diff
		_:
			push_error("wtf")
			return

func commit_handle(gizmo: EditorSpatialGizmo, index: int, restore: HandleValue, cancel: bool = false) -> void:
	var block: Block = gizmo.get_spatial_node()
	if cancel:
		block.size = restore.size
		block.global_translation = restore.origin
	else:
		var undo: = BlockoutUtil.plugin.get_undo_redo()
		undo.create_action("Resize Block")
		undo.add_do_property(block, "global_translation", block.global_translation)
		undo.add_do_property(block, "size", block.size)
		undo.add_undo_property(block, "global_translation", restore.origin)
		undo.add_undo_property(block, "size", restore.size)
		undo.commit_action()

static func nearest_point_along_semiaxis(
	block_global_transform: Transform,
	direction: Vector3,
	current_extent: float,
	camera: Camera,
	viewport_point: Vector2
) -> Vector3:
	var points: = Geometry.get_closest_points_between_segments(
		block_global_transform.origin,
		block_global_transform.origin + (block_global_transform.basis.xform(direction) * max(current_extent, 1.0) * 100.0),
		camera.project_ray_origin(viewport_point),
		camera.project_ray_origin(viewport_point) + (camera.project_ray_normal(viewport_point) * camera.far))
	var point_local: Vector3 = block_global_transform.xform_inv(points[0])
	return point_local
