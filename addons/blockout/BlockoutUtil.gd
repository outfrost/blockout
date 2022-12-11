tool
extends Node

const SNAP_STEP: float = 1.0
const TEXTURE_ROOT: String = "res://addons/blockout/texture/kenney"

class ResizeState:
	var size: Vector3
	var origin: Vector3

	func _init(size: Vector3, origin: Vector3) -> void:
		self.size = size
		self.origin = origin

	func _to_string() -> String:
		return str(size)

var plugin: EditorPlugin

static func nearest_point_along_semiaxis(
	block_global_transform: Transform,
	direction: Vector3,
	current_extent: float,
	camera: Camera,
	viewport_point: Vector2
) -> Vector3:
	var points: = Geometry.get_closest_points_between_segments(
		block_global_transform.origin,
		block_global_transform.origin + (
			block_global_transform.basis.xform(direction)
			* max(current_extent, 1.0)
			* 100.0
		),
		camera.project_ray_origin(viewport_point),
		camera.project_ray_origin(viewport_point) + (camera.project_ray_normal(viewport_point) * camera.far))

	var point_local: Vector3 = block_global_transform.xform_inv(points[0])
	return point_local
