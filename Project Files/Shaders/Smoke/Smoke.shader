shader_type canvas_item;
uniform int OCTAVES = 3;

float rand(vec2 coord){
	return fract(sin(dot(coord, vec2(12.9898, 78.233)))* 43758.5453123);
}

float noise(vec2 coord){
	vec2 i = floor(coord);
	vec2 f = fract(coord);

	// 4 corners of a rectangle surrounding our point
	float a = rand(i);
	float b = rand(i + vec2(1.0, 0.0));
	float c = rand(i + vec2(0.0, 1.0));
	float d = rand(i + vec2(1.0, 1.0));

	vec2 cubic = f * f * (3.0 - 2.0 * f);

	return mix(a, b, cubic.x) + (c - a) * cubic.y * (1.0 - cubic.x) + (d - b) * cubic.x * cubic.y;
}

float fbm(vec2 coord){
	float value = 0.0;
	float scale = 0.5;

	for(int i = 0; i < OCTAVES; i++){
		value += noise(coord) * scale;
		coord *= 2.0;
		scale *= 0.5;
	}
	return value;
}

void fragment() {
	vec2 scaled_coord = UV * 6.0;
	
	float warp = UV.y;
	float dist_from_center = abs(UV.x - 0.5) * 4.0;
	if (UV.x > 0.5) {
		warp = 1.0 - warp;
	}
	
	vec2 warp_vec = vec2(warp, 0.0);
	float motion_fbm = fbm(scaled_coord + vec2(TIME * 0.4, TIME * 1.3)); // used for distorting the smoke_fbm texture
	float smoke_fbm = fbm(scaled_coord + vec2(0.0, TIME * 1.0) + motion_fbm + warp_vec * dist_from_center);
	
	
	float thres = 0.1;
	smoke_fbm = clamp(smoke_fbm - thres, 0.0, 1.0) / (1.0 - thres);
	if (smoke_fbm < 0.1) {
		smoke_fbm *= smoke_fbm/0.1;
	}
	smoke_fbm = sqrt(smoke_fbm);
	smoke_fbm = clamp(smoke_fbm, 0.0, 1.0);
	
	COLOR = vec4(smoke_fbm);
}