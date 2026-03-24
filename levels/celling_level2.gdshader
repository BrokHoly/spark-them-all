shader_type spatial;

uniform sampler2D heightmap;
uniform float height_ratio;

void vertex() {
	// Called for every vertex the material is visible on.
	float height = texture(heightmap, UV).r;
	if(height > 0.89 ){
		height = 50.0;
	}
	VERTEX.y -= height * height_ratio ;
}

void fragment() {
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
