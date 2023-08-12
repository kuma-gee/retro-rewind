shader_type canvas_item;

uniform float radius : hint_range(0.0, 1.0);

void fragment() 
{
	COLOR = COLOR;
	
	float dist = 1.0 - distance(UV, vec2(0.5));
	COLOR.a *= ceil(step(1.0 - radius, dist));
}