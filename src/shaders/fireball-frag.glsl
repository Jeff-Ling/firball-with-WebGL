#version 300 es

// This is a fragment shader. If you've opened this file first, please
// open and read lambert.vert.glsl before reading on.
// Unlike the vertex shader, the fragment shader actually does compute
// the shading of geometry. For every pixel in your program's output
// screen, the fragment shader is run for every bit of geometry that
// particular pixel overlaps. By implicitly interpolating the position
// data passed into the fragment shader by the vertex shader, the fragment shader
// can compute what color to apply to its pixel based on things like vertex
// position, light position, and vertex color.
precision highp float;

uniform vec4 u_Color; // The color with which to render this instance of geometry.
uniform float u_Time;
uniform vec4 u_Color1;
uniform vec4 u_Color2;

// These are the interpolated values out of the rasterizer, so you can't know
// their specific values without knowing the vertices that contributed to them
in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;
in float fs_Displacement;

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.

void main()
{
    /*
    // Map the displacement to a color
    float red = clamp(fs_Displacement * 0.5 + 0.5, 0.0, 1.0);
    float green = clamp(sin(fs_Displacement), 0.0, 1.0);
    float blue = clamp(cos(fs_Displacement), 0.0, 1.0) * sin(u_Time / 1000.0);

    // Compute final shaded color
    //out_Col = vec4(newColor, 1.0);
    out_Col = vec4(red, green, blue, 1.0);
    */

    vec3 colorA = vec3(u_Color1[0], u_Color1[1], u_Color1[2]);
    vec3 colorB = vec3(u_Color2[0], u_Color2[1], u_Color2[2]);

    // Interpolate between colorA and colorB based on the noise value
    vec3 finalColor = mix(colorA, colorB, fs_Displacement);
    
    out_Col = vec4(finalColor, 1.0);
}