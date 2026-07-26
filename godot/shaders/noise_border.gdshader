shader_type canvas_item;

uniform float spin_speed = 0.0;
uniform float offset1 = 0.0;
uniform sampler2D noise1;
uniform sampler2D noise2;

uniform float inner_radius = 0.0;
uniform float outer_radius = 1.0;

vec2 scale(vec2 uv, vec2 center, vec2 amount) {
    uv -= center;
    uv *= amount;
    uv += center;
    return uv;
}

vec2 rotate(vec2 uv, vec2 center, float angle){
    uv -= center;

    float s = sin(angle);
    float c = cos(angle);

    uv = vec2(
        uv.x * c - uv.y * s,
        uv.x * s + uv.y * c
    );

    uv += center;
    return uv;
}

void fragment() {
	float spin_amount = TIME * spin_speed;
	vec2 scroll_uv = UV + vec2(0.1, 0.0) * TIME;
	vec2 zoom_uv = scale(UV, vec2(0.5), vec2(0.5, 0.5));
	vec2 spin_uv1 = rotate(zoom_uv, vec2(0.5), spin_amount + offset1);
	vec2 spin_uv2 = rotate(zoom_uv, vec2(0.5), -spin_amount);
	float texture_color1 = texture(noise1, spin_uv1).r;
	float texture_color2 = texture(noise2, spin_uv2).r;
	float texture_color3 = texture(TEXTURE, UV).r;
	float energy = texture_color1 * texture_color2 * texture_color3;
	
	// Vignette
	float x = abs(UV.r-.5)*2.0;
	float y = abs(UV.g-.5)*2.0;
	float q = 1.0-(1.0-sqrt(x*x+y*y)/outer_radius)/(1.0-inner_radius);
	
	energy *= q;
	
	COLOR = vec4(energy, energy, energy, 1.0);
	
}
