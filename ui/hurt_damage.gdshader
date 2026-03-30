shader_type canvas_item;

uniform float intensity : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 col = vec4(1.0, 0.0, 0.0, intensity); // red
	COLOR = col;
}