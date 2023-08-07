shader_type canvas_item;

void fragment(){
	float w = smoothstep(pow(0.5, 1. - UV.x), 0., abs(UV.y - 0.5)*2.0);
	float l = 1. - UV.x;
	COLOR.a *= l*w;
}