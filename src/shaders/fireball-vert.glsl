#version 300 es

//This is a vertex shader. While it is called a "shader" due to outdated conventions, this file
//is used to apply matrix transformations to the arrays of vertex data passed to it.
//Since this code is run on your GPU, each vertex is transformed simultaneously.
//If it were run on your CPU, each vertex would have to be processed in a FOR loop, one at a time.
//This simultaneous transformation allows your program to run much faster, especially when rendering
//geometry with millions of vertices.

uniform mat4 u_Model;       // The matrix that defines the transformation of the
                            // object we're rendering. In this assignment,
                            // this will be the result of traversing your scene graph.

uniform mat4 u_ModelInvTr;  // The inverse transpose of the model matrix.
                            // This allows us to transform the object's normals properly
                            // if the object has been non-uniformly scaled.

uniform mat4 u_ViewProj;    // The matrix that defines the camera's transformation.
                            // We've written a static matrix for you to use for HW2,
                            // but in HW3 you'll have to generate one yourself

uniform float u_Time;
uniform float u_Persistence;
uniform float u_PerlinPct;
uniform float u_FBMPct;

in vec4 vs_Pos;             // The array of vertex positions passed to the shader

in vec4 vs_Nor;             // The array of vertex normals passed to the shader

in vec4 vs_Col;             // The array of vertex colors passed to the shader.

out vec4 fs_Pos;
out vec4 fs_Nor;            // The array of normals that has been transformed by u_ModelInvTr. This is implicitly passed to the fragment shader.
out vec4 fs_LightVec;       // The direction in which our virtual light lies, relative to each vertex. This is implicitly passed to the fragment shader.
out vec4 fs_Col;            // The color of each vertex. This is implicitly passed to the fragment shader.

const vec4 lightPos = vec4(5, 5, 3, 1); //The position of our virtual light, which is used to compute the shading of
                                        //the geometry in the fragment shader.
out float fs_Displacement;

const float PI = 3.14159265359;

vec3 powVec3(vec3 v, float p)
{
    for (int i = 0; i < int(p); i++)
    {
        v *= v;
    }
    return v;
}

vec3 random3(vec3 p)
{
    float x = fract(sin(dot(p, vec3(127.1, 311.7, 275.2))) * 43758.5453);
    float y = fract(sin(dot(p, vec3(269.5, 183.3, 167.7))) * 43758.5453);
    float z = fract(sin(dot(p, vec3(420.6, 631.2, 728.1))) * 43758.5453);
    return vec3(x, y, z);
}


float surflet(vec3 p, vec3 gridPoint)
{
    float distX = abs(p.x - gridPoint.x);
    float distY = abs(p.y - gridPoint.y);
    float distZ = abs(p.z - gridPoint.z);
    float tX = 1.0 - 6.0 * pow(distX, 5.0) + 15.0 * pow(distX, 4.0) - 10.0 * pow(distX, 3.0);
    float tY = 1.0 - 6.0 * pow(distY, 5.0) + 15.0 * pow(distY, 4.0) - 10.0 * pow(distY, 3.0);
    float tZ = 1.0 - 6.0 * pow(distZ, 5.0) + 15.0 * pow(distZ, 4.0) - 10.0 * pow(distZ, 3.0);

    vec3 gradient = random3(gridPoint);
    vec3 diff = p - gridPoint;
    float height = dot(diff, gradient);
    return height * tX * tY * tZ;
}

float perlinNoise3D(vec3 p)
{
    float surfletSum = 0.f;
    for(int dx = 0; dx <= 1; ++dx) {
        for(int dy = 0; dy <= 1; ++dy) {
            for(int dz = 0; dz <= 1; ++dz) {
                surfletSum += surflet(p, floor(p) + vec3(dx, dy, dz));
            }
        }
    }
    return surfletSum;
}

float noise3D(vec3 p) 
{
    return fract(sin(dot(p, vec3(127.1, 311.7, 183.3))) * 43758.5453);
}

float cosineInterpolate(float a, float b, float t) 
{
    float cos_t = (1.0 - cos(t * PI)) * 0.5f;
    return mix(a, b, cos_t);
}

float interpNoise3D(float x, float y, float z) 
{
    int intX = int(floor(x));
    float fractX = fract(x);
    int intY = int(floor(y));
    float fractY = fract(y);
    int intZ = int(floor(z));
    float fractZ = fract(z);

    float v1 = noise3D(vec3(intX, intY, intZ));
    float v2 = noise3D(vec3(intX + 1, intY, intZ));
    float v3 = noise3D(vec3(intX, intY + 1, intZ));
    float v4 = noise3D(vec3(intX + 1, intY + 1, intZ));
    float v5 = noise3D(vec3(intX, intY, intZ + 1));
    float v6 = noise3D(vec3(intX + 1, intY, intZ + 1));
    float v7 = noise3D(vec3(intX, intY + 1, intZ + 1));
    float v8 = noise3D(vec3(intX + 1, intY + 1, intZ + 1));

    float i1 = cosineInterpolate(v1, v2, fractX);
    float i2 = cosineInterpolate(v3, v4, fractX);
    float i3 = cosineInterpolate(v5, v6, fractX);
    float i4 = cosineInterpolate(v7, v8, fractX);

    float mix1 = cosineInterpolate(i1, i2, fractY);
    float mix2 = cosineInterpolate(i3, i4, fractY);

    return cosineInterpolate(mix1, mix2, fractZ);
}

float fbm3D(vec3 point, float persistence, int octaves)
{
    float total = 0.f;
    float frequency = 3.f;
    float amplitude = .7f;

    for(int i = 1; i <= octaves; i++) 
    {
        total += interpNoise3D(point.x * frequency, point.y * frequency, point.z * frequency) * amplitude;
        frequency *= 2.f;
        amplitude *= persistence;
    }
    return total;
}

void main()
{
    mat3 invTranspose = mat3(u_ModelInvTr);
    fs_Nor = vec4(invTranspose * vec3(vs_Nor), 0);          // Pass the vertex normals to the fragment shader for interpolation.
                                                            // Transform the geometry's normals by the inverse transpose of the
                                                            // model matrix. This is necessary to ensure the normals remain
                                                            // perpendicular to the surface after the surface is transformed by
                                                            // the model matrix.

    float displacementLFHA = u_PerlinPct * perlinNoise3D(sin(vs_Pos.xyz * u_Time / 1000.0));         // low-frequency, high-amplitude displacement combine with sinusoidal functions
    float displacementHFLA =  u_FBMPct * fbm3D(sin(vs_Pos.xyz + u_Time / 2000.0), u_Persistence, 10);       // higher-frequency, lower-amplitude layer of fractal Brownian motion
    float displacement = displacementLFHA + displacementHFLA;
    fs_Displacement = displacement;

    vec4 newPos = vs_Pos + (displacement * vs_Nor * 2.0);

    vec4 modelposition = u_Model * newPos;

    fs_Pos = modelposition;

    fs_LightVec = lightPos - modelposition;  // Compute the direction in which the light source lies

    gl_Position = u_ViewProj * modelposition;// gl_Position is a built-in variable of OpenGL which is
                                             // used to render the final positions of the geometry's vertices
}
