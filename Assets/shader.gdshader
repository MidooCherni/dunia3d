shader_type spatial;
render_mode unshaded;

void fragment() {
    vec2 tex_size = vec2(textureSize(texture_albedo, 0));
    vec2 snapped_uv = floor(UV * tex_size) / tex_size;
    ALBEDO = texture(texture_albedo, snapped_uv).rgb;
}