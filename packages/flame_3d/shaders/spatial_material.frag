#version 460 core

in vec2 fragTexCoord;
in vec4 fragColor;
in vec3 fragPosition;
smooth in vec3 fragNormal;

out vec4 outColor;

uniform sampler2D albedoTexture;  // Albedo texture

uniform Material {
  vec3 albedoColor;
  float metallic;
  float metallicSpecular;
  float roughness;
} material;

uniform Light {
  vec3 position;
} light;

uniform Camera {
  vec3 position;
} camera;

// Schlick GGX function
float SchlickGGX(float NdotV, float roughness)
{
    float k = (roughness * roughness) / 2.0;
    float nom = NdotV;
    float denom = NdotV * (1.0 - k) + k;
    return nom / denom;
}

void main() {
    vec3 viewDir = normalize(camera.position - fragPosition);
    vec3 lightDir = normalize(light.position - fragPosition);
    vec3 halfwayDir = normalize(viewDir + lightDir);

    vec3 normal = normalize(fragNormal);
    float NdotV = max(dot(normal, viewDir), 0.0);
    float fresnel = SchlickGGX(NdotV, material.roughness);

    float NdotL = max(dot(normal, lightDir), 0.0);
    float NdotH = max(dot(normal, halfwayDir), 0.0);
    float specular = SchlickGGX(NdotL, material.roughness) * SchlickGGX(NdotH, material.roughness);

    vec3 baseColor = material.albedoColor;
    baseColor *= texture(albedoTexture, fragTexCoord).rgb;

    vec3 diffuse = mix(baseColor, vec3(0.04, 0.04, 0.04), material.metallic);
    vec3 finalColor = (diffuse + specular * material.metallicSpecular) * NdotL * fresnel;

    outColor = vec4(finalColor, 1.0);
}