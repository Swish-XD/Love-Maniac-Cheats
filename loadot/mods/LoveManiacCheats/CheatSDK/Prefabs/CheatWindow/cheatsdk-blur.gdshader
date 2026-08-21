shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform bool enable_blur = true;
uniform float blur_amount : hint_range(0.0, 5.0) = 4.0;
uniform bool enable_aberration = true;
uniform float aberration_amount : hint_range(0.0, 0.05) = 0.005;

uniform bool enable_dithering = false;
uniform float dither_color_steps : hint_range(2.0, 64.0) = 16.0;
uniform float dither_size : hint_range(1.0, 10.0) = 2.0;

uniform bool enable_scanlines = false;
uniform float scanline_opacity : hint_range(0.0, 1.0) = 0.15;

uniform bool enable_mouse_effect = true;
uniform vec2 mouse_position = vec2(0.5);
uniform float cursor_effect_radius : hint_range(0.01, 0.5) = 0.08;
uniform float cursor_aberration_boost : hint_range(0.0, 0.1) = 0.02;
uniform float cursor_blur_boost : hint_range(0.0, 5.0) = 1.0;

uniform bool enable_zoom = true;
uniform float base_window_zoom : hint_range(1, 3.0) = 1.1;
uniform float cursor_zoom_boost : hint_range(1, 3.0) = 0.5;

const float bayer_matrix[16] = {
	0.0,    0.5,    0.125,  0.625,
	0.75,   0.25,   0.875,  0.375,
	0.1875, 0.6875, 0.0625, 0.5625,
	0.9375, 0.4375, 0.8125, 0.3125
};

float get_bayer_value(vec2 pixel_coord) {
	int x = int(mod(pixel_coord.x / dither_size, 4.0));
	int y = int(mod(pixel_coord.y / dither_size, 4.0));
	return bayer_matrix[y * 4 + x];
}

void fragment() {
	vec2 base_uv = SCREEN_UV;
	if (base_window_zoom > 1.0 && enable_zoom) {
		base_uv = vec2(0.5) + (SCREEN_UV - vec2(0.5)) / base_window_zoom;
	}
	
	vec2 mouse_to_uv = base_uv - mouse_position;
	float dist_to_mouse = length(mouse_to_uv);
	
	float local_influence;
	if (enable_mouse_effect) {
		local_influence = smoothstep(cursor_effect_radius, 0.0, dist_to_mouse);
	}
	else {
		local_influence = 0.0;
	}
	
	vec2 distorted_uv = base_uv;
	if (dist_to_mouse < cursor_effect_radius && cursor_zoom_boost > 0.0 && enable_zoom) {
		float norm_dist = dist_to_mouse / cursor_effect_radius;
		
		float total_local_zoom = 1.0 + cursor_zoom_boost;
		float power = (sin(norm_dist * PI * 0.5) - 1.0) * (1.0 - (1.0 / total_local_zoom)) * local_influence;
		
		distorted_uv = base_uv + mouse_to_uv * power;
	}
	
	vec2 center_dist = distorted_uv - vec2(0.5);
	vec2 current_shift;
	if (enable_aberration == true) {
		current_shift = center_dist * (aberration_amount + local_influence * cursor_aberration_boost);
	}
	else {
		current_shift = vec2(0, 0);
	}
	
	float current_blur;
	
	if (enable_blur == true) {
		current_blur = clamp(blur_amount + local_influence * cursor_blur_boost, 0.0, 5.0);
	}
	else {
		current_blur = clamp(0, 0.0, 5.0);
	}
	
	vec4 color;
	color.r = textureLod(screen_texture, distorted_uv - current_shift, current_blur).r;
	color.g = textureLod(screen_texture, distorted_uv,                 current_blur).g;
	color.b = textureLod(screen_texture, distorted_uv + current_shift, current_blur).b;
	color.a = textureLod(screen_texture, distorted_uv,                 current_blur).a;
	
	if (enable_scanlines == true) {
		int raw_y = int(FRAGCOORD.y / dither_size);
		if (mod(float(raw_y), 2.0) == 0.0) {
			color.rgb -= color.rgb * scanline_opacity;
		}
	}
	
	if (enable_dithering == true) {
		vec2 pixel_pos = FRAGCOORD.xy;
		float bayer_noise = get_bayer_value(pixel_pos) - 0.5;
		
		float step_size = 1.0 / (dither_color_steps - 1.0);
		vec3 dithered_color = color.rgb + (bayer_noise * step_size);
		
		color.rgb = floor(dithered_color / step_size + 0.5) * step_size;
	}
	
	COLOR = color * COLOR;
}