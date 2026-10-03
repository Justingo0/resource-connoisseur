shader_type canvas_item;

// Controls the progress (0.0 = fully visible, 1.0 = completely dissolved)
uniform float dissolve_progress : hint_range(0.0, 1.0) = 0.0;
// Roughness of the dissolve edges (assign a FastNoiseLite texture in Inspector)
uniform sampler2D noise_texture : repeat_enable;
// The glow color of the breaking edges
uniform vec4 edge_color : source_color = vec4(1.0, 0.4, 0.0, 1.0);
// Thickness of the burning edge line
uniform float edge_thickness : hint_range(0.0, 0.5) = 0.1;

void fragment() {
    vec4 main_tex = texture(TEXTURE, UV);
    
    // 1. Calculate distance from the center
    float distance_from_center = distance(UV, vec2(0.5));
    distance_from_center *= 1.414; // Normalize corners
    
    // 2. Sample the noise texture
    float noise_val = texture(noise_texture, UV).r;
    
    // --- FIX: Remap dissolve_progress so 0.0 starts perfectly intact ---
    // This offsets the progress value so it covers the entire range from center to corner
    float adjusted_progress = (dissolve_progress * 1.35);
    
    // 3. Combine using the adjusted progress instead
    float mask_base = distance_from_center + (noise_val * 0.4) - adjusted_progress;
    
    // 4. Hard threshold steps
    float alpha_mask = step(0.0, mask_base);
    float edge_mask = step(0.0, mask_base + edge_thickness);
    float burn_line = edge_mask - alpha_mask;
    
    // 5. Build final output
    vec3 mixed_color = mix(main_tex.rgb, edge_color.rgb, burn_line);
    COLOR = vec4(mixed_color, main_tex.a * edge_mask);
}
