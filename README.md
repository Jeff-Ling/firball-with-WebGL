# [Project 1: Noise](https://github.com/CIS-566-Fall-2022/hw01-fireball-base)

# [Live Demo](https://jeff-ling.github.io/firball-with-houdini/)

<p align="center">
  <img width="640" height="360" src="https://github.com/Jeff-Ling/hw01-fireball/blob/master/screenshot/1.png">
  <img width="640" height="360" src="https://github.com/Jeff-Ling/hw01-fireball/blob/master/screenshot/2.png">
  <img width="640" height="360" src="https://github.com/Jeff-Ling/hw01-fireball/blob/master/screenshot/3.png">
</p>

I used perlinNoise3D for the low-frequency, high-amplitude displacement of my firball surface and fbm3D for the higher-frequency, lower-amplitude layer. 
In the vertex shader, I compute a noiseValue for each vertex position. I added time (u_Time) to the position to give a time-evolving effect. This noise value is then used for displacement and is passed to the fragment shader.
In the fragment shader, I have defined two colors (colorA and colorB). Using the GLSL function mix, I interpolate between these two colors based on the noiseValue.

For the background, I tried to create a cloudy background using Worley noise. I Uses multiple scales of Worley noise to create varied cloud structures and blends between a soft bluish-white and a darker cloud shade based on noise values to get the cloud color. Also, I adds a vertical gradient to the background to give the feeling of a sky.

Interactivity:
innerColor: the inner color of the fireball.
exteriorColor: the exterior color of the fireball.
persistence: the persistence of the fbm noise used in the vertex shader of fieball.
perlinNoisePct: the % of perlin noise will contribute to the fireball effect. 
FBMNoisePct: the % of fbm noise will contribute to the fireball effect.
