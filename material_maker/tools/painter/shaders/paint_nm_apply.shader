shader_type canvas_item;
render_mode blend_disabled, unshaded;

uniform bool erase = false;
uniform sampler2D tex;

void fragment() {
	vec4 screen_color = clamp(texture(SCREEN_TEXTURE, UV), vec4(0.0), vec4(1.0));
	vec4 color = clamp(texture(tex, UV), vec4(0.0), vec4(1.0));
	float a = color.a*MODULATE.a;
	if (erase) {
		COLOR = vec4(screen_color.rgb, max(screen_color.a-a, 0.0));
	} else {
		float alpha_sum = min(1.0, a + screen_color.a);
		COLOR = vec4((color.xyz*a+screen_color.xyz*(vec3(alpha_sum)-a))/alpha_sum, alpha_sum);
	}
}
