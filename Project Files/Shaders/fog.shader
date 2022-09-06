shader_type canvas_item;

uniform vec4 color : hint_color = vec4(0.35, 0.48, 0.95, 1.0);
uniform float noise_scale = 20.0;
uniform float alpha_power = .25;
uniform int OCTAVES = 4;

float rand(vec2 coord){
	return fract(sin(dot(coord, vec2(56, 78)) * 1000.0) * 1000.0);
}

float noise(vec2 coord){
	
	vec2 i = floor(coord);
	vec2 fractal = fract(coord);

	float cornera = rand(i);
	float cornerb = rand(i + vec2(1.0, 0.0));
	float cornerc = rand(i + vec2(0.0, 1.0));
	float cornerd = rand(i + vec2(1.0, 1.0));

	vec2 cubic = fractal * fractal * (3.0 - 2.0 * fractal);

	return mix(cornera, cornerb, cubic.x) + (cornerc - cornera) * cubic.y * (1.0 - cubic.x) + (cornerd - cornerb) * cubic.x * cubic.y;
}

float fbm(vec2 coord){
	
	float scale = 0.5;
	float value = 0.0;

	for(int i = 0; i < OCTAVES; i++){
		value += noise(coord) * scale;
		coord *= 2.0;
		scale *= 0.5;
	}
	return value;
}

void fragment() {
	vec2 coord = UV * noise_scale;
	vec2 motion = vec2( fbm(coord + vec2(TIME * 0.5, 0.0)) );
	float final = fbm(coord + motion);
	COLOR = vec4(color.rgb,final*alpha_power);
}