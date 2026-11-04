shader_type canvas_item;

uniform vec4 pulse_color : source_color = vec4(1.0, 0.3, 0.3, 1.0); // The color it pulses into
uniform float speed : hint_range(0.1, 10.0) = 2.0;                 // Speed of the pulse

void fragment() {
    // 1. Get the underlying shape/alpha of the button texture
    vec4 tex_color = texture(TEXTURE, UV);
    
    // 2. Create the wave that goes from 0.0 (fully transparent) to 1.0 (fully visible)
    float wave = (sin(TIME * speed) + 1.0) / 2.0;
    
    // 3. Force the color to be your exact pulse_color RGB
    vec3 final_rgb = pulse_color.rgb;
    
    // 4. Calculate final alpha: Combine the wave, your color picker's alpha, 
    // and the button's native cutouts (like rounded corners or text shapes)
    float final_alpha = wave * pulse_color.a * tex_color.a;
    
    // 5. Output the result
    COLOR = vec4(final_rgb, final_alpha);
}
