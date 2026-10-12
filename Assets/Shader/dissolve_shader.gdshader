shader_type canvas_item;

// --- Dissolve Parameters ---
uniform float dissolve_progress : hint_range(0.0, 1.0) = 0.0;
uniform sampler2D noise_texture : repeat_enable;
uniform vec4 edge_color : source_color = vec4(1.0, 0.4, 0.0, 1.0);
uniform float edge_thickness : hint_range(0.0, 0.5) = 0.1;

// --- Square Outline Parameters ---
uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float outline_width : hint_range(0.0, 20.0) = 2.0;

void fragment() {
    vec4 main_tex = texture(TEXTURE, UV);
    
    // --- 1. Determine Base Color (Sprite vs. Square Outline) ---
    vec2 thickness = TEXTURE_PIXEL_SIZE * outline_width;
    
    bvec4 in_border = bvec4(
        UV.x < thickness.x,                  // Left border
        UV.x > (1.0 - thickness.x),          // Right border
        UV.y < thickness.y,                  // Top border
        UV.y > (1.0 - thickness.y)           // Bottom border
    );
    
    vec4 base_color;
    if (any(in_border)) {
        base_color = outline_color;          // Use outline color on the outer box edges
    } else {
        base_color = main_tex;               // Use normal sprite color inside the box
    }
    
    // --- 2. Core Dissolve Logic (Applied to the entire composite) ---
    float dist = distance(UV, vec2(0.5)) * 1.414;
    float noise_val = texture(noise_texture, UV).r;
    float adjusted_progress = dissolve_progress * 1.35;
    
    float mask_base = dist + (noise_val * 0.4) - adjusted_progress;
    
    float alpha_mask = step(0.0, mask_base);
    float edge_mask = step(0.0, mask_base + edge_thickness);
    float burn_line = edge_mask - alpha_mask;
    
    // --- 3. Final Output ---
    // Apply the burning fire effect to whatever is underneath (sprite or outline)
    vec3 final_rgb = mix(base_color.rgb, edge_color.rgb, burn_line);
    // Erase the pixels perfectly based on the edge mask
    float final_alpha = base_color.a * edge_mask;
    
    COLOR = vec4(final_rgb, final_alpha);
}
