shader_type spatial;

uniform sampler2D base_texture : hint_albedo;
uniform sampler2D stairs_side_texture : hint_albedo;
uniform vec3 local_pos_offset = vec3(0.0);
uniform vec3 stairs_size = vec3(1.0);
uniform float stair_height_ratio = 1.0;

/*
local vertex position to uv conversion
			U	V
( 0, 0, 1)	 x	 y
( 0, 0,-1)	-x	 y
( 1, 0, 0)	-z	 y
(-1, 0, 0)	-z	 y
( 0, 1, 0)	 x	-z
( 0,-1, 0)	 x	 z
*/

varying vec2 local_uv;
varying vec3 reference_pos;
varying float local_normal_x;

void vertex() {
	reference_pos = VERTEX + local_pos_offset;
	reference_pos.z *= stairs_size.y / stairs_size.z;
	reference_pos.y /= stair_height_ratio;
	reference_pos.z += (stairs_size.y - reference_pos.z) * (stair_height_ratio - 1.0);

	// using -(size.y - pos.z) instead of pos.z
	local_uv.x =
		reference_pos.x * clamp(NORMAL.z + abs(NORMAL.y), 0.0, 1.0)
		- reference_pos.x * clamp(- NORMAL.z, 0.0, 1.0)
		+ (stairs_size.y - reference_pos.z) * clamp(abs(NORMAL.x), 0.0, 1.0);
	local_uv.y =
		reference_pos.y * clamp(abs(NORMAL.x) + abs(NORMAL.z), 0.0, 1.0)
		+ (stairs_size.y - reference_pos.z) * clamp(NORMAL.y, 0.0, 1.0)
		- (stairs_size.y - reference_pos.z) * clamp(- NORMAL.y, 0.0, 1.0);
	local_uv.y = - local_uv.y;

	local_normal_x = NORMAL.x;
}

void fragment() {
	float measurement = stairs_size.y - reference_pos.z - floor(reference_pos.y);
	float stairs_side_blend = float(local_normal_x != 0.0 && measurement >= 0.0 && measurement <= 1.0);
	ALBEDO = mix(
		texture(base_texture, local_uv).rgb,
		texture(stairs_side_texture, local_uv).rgb,
		stairs_side_blend);
}
