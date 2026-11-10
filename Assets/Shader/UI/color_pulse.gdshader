shader_type canvas_item;

uniform vec4 pulse_color : source_color = vec4(1.0, 0.3, 0.3, 1.0);
uniform float speed : hint_range(0.1, 10.0) = 2.0;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    float wave = (sin(TIME * speed) + 1.0) / 2.0;
    vec3 final_rgb = pulse_color.rgb;
    float final_alpha = wave * pulse_color.a * tex_color.a;
    
    COLOR = vec4(final_rgb, final_alpha);
}
