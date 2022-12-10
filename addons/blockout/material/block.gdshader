shader_type spatial;

uniform sampler2D base_texture : hint_albedo;

varying vec2 local_uv;

void vertex() {
	vec3 origin_world_pos = (WORLD_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
	vec3 reference_pos = VERTEX + origin_world_pos;
	local_uv.x =
		reference_pos.x * clamp(NORMAL.z + abs(NORMAL.y), 0.0, 1.0)
		- reference_pos.x * clamp(- NORMAL.z, 0.0, 1.0)
		- reference_pos.z * clamp(NORMAL.x, 0.0, 1.0)
		+ reference_pos.z * clamp(- NORMAL.x, 0.0, 1.0);
	local_uv.y =
		reference_pos.y * clamp(abs(NORMAL.x) + abs(NORMAL.z), 0.0, 1.0)
		- reference_pos.z * clamp(NORMAL.y, 0.0, 1.0)
		+ reference_pos.z * clamp(- NORMAL.y, 0.0, 1.0);
	local_uv.y = - local_uv.y;
}

void fragment() {
	ALBEDO = texture(base_texture, local_uv).rgb;
}

/*

			U	V
( 0, 0, 1)	 x	 y
( 0, 0,-1)	-x	 y
( 1, 0, 0)	-z	 y
(-1, 0, 0)	 z	 y
( 0, 1, 0)	 x	-z
( 0,-1, 0)	 x	 z

*/