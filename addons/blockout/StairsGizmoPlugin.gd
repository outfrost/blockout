extends EditorSpatialGizmoPlugin

const Stairs: = preload("res://addons/blockout/Stairs.gd")

func _init() -> void:
	create_handle_material("handle")

func get_name() -> String:
	return "Blockout"

func has_gizmo(spatial: Spatial) -> bool:
	return spatial is Stairs

func can_be_hidden() -> bool:
	return true

func redraw(gizmo: EditorSpatialGizmo) -> void:
	gizmo.clear()

	var stairs = gizmo.get_spatial_node()

	var handles = PoolVector3Array()
	handles.push_back(Vector3.RIGHT * stairs.size.x * 0.5)
	handles.push_back(Vector3.LEFT * stairs.size.x * 0.5)
	handles.push_back(Vector3.UP * stairs.size.y)
	handles.push_back(Vector3.BACK * stairs.size.z)

	gizmo.add_handles(handles, get_material("handle", gizmo))

func get_handle_name(gizmo: EditorSpatialGizmo, index: int) -> String:
	return "Size"

func get_handle_value(gizmo: EditorSpatialGizmo, index: int) -> BlockoutUtil.ResizeState:
	var stairs: Stairs = gizmo.get_spatial_node()
	return BlockoutUtil.ResizeState.new(stairs.size, stairs.global_translation)

func set_handle(gizmo: EditorSpatialGizmo, index: int, camera: Camera, point: Vector2) -> void:
	var stairs: Stairs = gizmo.get_spatial_node()
	var snap: float = BlockoutUtil.SNAP_STEP
	if Input.is_key_pressed(KEY_SHIFT):
		snap *= 0.1
	if Input.is_key_pressed(KEY_CONTROL):
		snap = 0.0
	match index:
		0:
			var prev_extent: float = stairs.size.x * 0.5
			var point_along_semiaxis: = BlockoutUtil.nearest_point_along_semiaxis(
				stairs.global_transform,
				Vector3.RIGHT,
				prev_extent,
				camera,
				point)

			if is_nan(point_along_semiaxis.x):
				return

			var extent_diff: float = stepify(point_along_semiaxis.x - prev_extent, snap)
			stairs.translate_object_local(Vector3.RIGHT * extent_diff * 0.5)
			stairs.size.x += extent_diff
		1:
			var prev_extent: float = stairs.size.x * 0.5
			var point_along_semiaxis: = BlockoutUtil.nearest_point_along_semiaxis(
				stairs.global_transform,
				Vector3.LEFT,
				prev_extent,
				camera,
				point)

			if is_nan(point_along_semiaxis.x):
				return

			var extent_diff: float = stepify(- point_along_semiaxis.x - prev_extent, snap)
			stairs.translate_object_local(Vector3.LEFT * extent_diff * 0.5)
			stairs.size.x += extent_diff
		2:
			var prev_extent: float = stairs.size.y
			var point_along_semiaxis: = BlockoutUtil.nearest_point_along_semiaxis(
				stairs.global_transform,
				Vector3.UP,
				prev_extent,
				camera,
				point)

			if is_nan(point_along_semiaxis.y):
				return

			var extent_diff: float = stepify(point_along_semiaxis.y - prev_extent, snap)
			stairs.size.y += extent_diff
			if prev_extent == 0.0:
				stairs.size.z += extent_diff
			else:
				var change_ratio: float = 1.0 + (extent_diff / prev_extent)
				stairs.size.z *= change_ratio
		3:
			var prev_extent: float = stairs.size.z
			var point_along_semiaxis: = BlockoutUtil.nearest_point_along_semiaxis(
				stairs.global_transform,
				Vector3.BACK,
				prev_extent,
				camera,
				point)

			if is_nan(point_along_semiaxis.z):
				return

			var extent_diff: float = stepify(point_along_semiaxis.z - prev_extent, snap)
			stairs.size.z += extent_diff
		_:
			push_error("wtf")
			return

func commit_handle(
	gizmo: EditorSpatialGizmo,
	index: int,
	restore: BlockoutUtil.ResizeState,
	cancel: bool = false
) -> void:
	var stairs: Stairs = gizmo.get_spatial_node()
	if cancel:
		stairs.size = restore.size
		stairs.global_translation = restore.origin
	else:
		var undo: = BlockoutUtil.plugin.get_undo_redo()
		undo.create_action("Resize Stairs")
		undo.add_do_property(stairs, "global_translation", stairs.global_translation)
		undo.add_do_property(stairs, "size", stairs.size)
		undo.add_undo_property(stairs, "global_translation", restore.origin)
		undo.add_undo_property(stairs, "size", restore.size)
		undo.commit_action()
