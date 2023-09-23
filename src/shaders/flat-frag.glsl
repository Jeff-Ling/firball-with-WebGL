#version 300 es
precision highp float;

uniform vec3 u_Eye, u_Ref, u_Up;
uniform vec2 u_Dimensions;
uniform float u_Time;

in vec2 fs_Pos;
out vec4 out_Col;

vec2 random2(vec2 p)
{
    float x = fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
    float z = fract(sin(dot(p, vec2(269.5,183.3))) * 43758.5453);
    return vec2(x, z);
}

float worleyNoise(float x, float z)
{
    int intX = int(floor(x));
    float fractX = fract(x);
    int intZ = int(floor(z));
    float fractZ = fract(z);

    float minDist = 1.0; // Minimum distance initialized to max.
    for(int y = -1; y <= 1; ++y) {
        for(int x = -1; x <= 1; ++x) {
            vec2 neighbor = vec2(float(x), float(y)); // Direction in which neighbor cell lies
            vec2 point = random2(vec2(intX, intZ) + neighbor); // Get the Voronoi centerpoint for the neighboring cell
            vec2 diff = neighbor + point - vec2(fractX, fractZ); // Distance between fragment coord and neighbor’s Voronoi point
            float dist = length(diff);
            if (dist < minDist)
            {
                minDist = dist;
            }

            // minDist = min(minDist, dist);
        }
    }
    return minDist;
}

void main() {
  vec2 uv = (gl_FragCoord.xy/u_Dimensions.xy) * 2.0f - vec2(1.0f);

  uv.x += u_Time * 0.0001; 

  // Get multiple scales of Worley noise
  float n1 = worleyNoise(uv.x * 2.0, uv.y * 2.0);    // larger structures
  float n2 = worleyNoise(uv.x * 5.0, uv.y * 5.0);    // medium structures
  float n3 = worleyNoise(uv.x * 10.0, uv.y * 10.0);  // finer structures

  // Combine the noise values to get a more varied look
  float n = n1 * 0.5 + n2 * 0.3 + n3 * 0.2;

  // Define rich cloud colors
  vec3 lightColor = vec3(0.9, 0.9, 1.0);  // Soft bluish-white
  vec3 darkColor = vec3(0.4, 0.4, 0.5);   // Darker cloud shade

  // Use the noise value to blend between these colors
  vec3 cloudColor = mix(darkColor, lightColor, n);

  // If you want to add more richness, consider using a gradient based on UV.y (vertical position)
  vec3 skyGradient = mix(vec3(0.6, 0.7, 0.9), vec3(1.0, 0.8, 0.6), uv.y);
  cloudColor *= skyGradient; // Blend the cloud color with the sky gradient

  // Set the final color
  out_Col = vec4(cloudColor, 1.0);
  //out_Col = vec4(0.5 * (fs_Pos + vec2(1.0)), 0.5 * (sin(u_Time * 3.14159 * 0.01) + 1.0), 1.0);
}
