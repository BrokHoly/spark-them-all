shader_type spatial;

uniform float amplitude = 0.06;
uniform float speed = 1.0;
uniform float frequency = 3.0;
uniform float max_displacement = 0.2;
uniform vec3 color = vec3(0.1,0.1,0.6);

float hash(vec3 p) {
    return fract(sin(dot(p, vec3(127.1, 311.7, 74.7))) * 43758.5453);
}

void vertex() {
    vec3 direction = normalize(VERTEX);
    float rnd = hash(VERTEX);
    float wave = sin(TIME * speed + rnd * frequency * 10.0);
    float displacement = wave * amplitude;
    // ✅ Clamp here
    displacement = clamp(displacement, -max_displacement, max_displacement);
    VERTEX += direction * displacement;
}

void fragment() {
	ALBEDO = color;
}