#version 460 core

#define NUM_LIGHTS 8

in vec2 fragTexCoord;
in vec4 fragColor;
in vec3 fragPosition;
smooth in vec3 fragNormal;

out vec4 outColor;

uniform sampler2D albedoTexture;  // Albedo texture

// material info

uniform Material {
  vec3 albedoColor;
  float metallic;
  float roughness;
} material;

// light info

// uniform AmbientLight {
//   vec3 color;
//   float intensity;
// } ambientLight;

// uniform LightsInfo {
//   float numLights;
// } lightsInfo;

// uniform Light {
//   vec3 position;
//   vec3 color;
//   float intensity;
// } lights [NUM_LIGHTS];

// camera info

uniform Camera {
  vec3 position;
} camera;

// Schlick GGX function
float SchlickGGX(float NdotV, float roughness) {
  float k = (roughness * roughness) / 2.0;
  float nom = NdotV;
  float denom = NdotV * (1.0 - k) + k;
  return nom / denom;
}

void main() {
  vec3 viewDir = normalize(camera.position - fragPosition);
  vec3 normal = normalize(fragNormal);

  vec3 baseColor = material.albedoColor;
  baseColor *= texture(albedoTexture, fragTexCoord).rgb;

  vec3 finalColor = baseColor; //  * ambientLight.color * ambientLight.intensity;

  for (uint i = 0; i < 1; ++i) {
    vec3 lightPos = vec3(0); // lights[i].position;
    float lightIntensity = 0.5; // lights[i].intensity;
    vec3 lightColor = vec3(0, 0.5, 0.2); // lights[i].color

    vec3 lightDir = normalize(lightPos - fragPosition);
    float distance = length(lightPos - fragPosition);
    float attenuation = 0 * lightIntensity / (distance * distance);

    vec3 halfwayDir = normalize(viewDir + lightDir);

    float NdotV = max(dot(normal, viewDir), 0.0);
    float fresnel = SchlickGGX(NdotV, material.roughness);

    float NdotL = max(dot(normal, lightDir), 0.0);
    float NdotH = max(dot(normal, halfwayDir), 0.0);
    float specular = SchlickGGX(NdotL, material.roughness).x * SchlickGGX(NdotH, material.roughness).x;

    vec3 diffuse = mix(baseColor, vec3(0.04, 0.04, 0.04), material.metallic);
    vec3 lightContribution = (diffuse + specular * material.metallic) * NdotL * fresnel * lightColor * attenuation;

    finalColor += lightContribution;
  }

  outColor = vec4(finalColor, 1.0);
}