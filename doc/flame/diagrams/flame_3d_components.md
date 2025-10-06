```{mermaid}
%%{init: { 'theme': 'dark' } }%%

flowchart TB
    classDef default fill:#282828,stroke:#F6BE00;

    %% base flame classes %%
    World["<code>World</code><br /><span>(base Flame)<code>"]
    Component["<code>Component</code>
        <span>(base Flame)<code>"]

    %% flame 3d classes %%
    World3D["<code>World3D</code>"]
    Component3D["<code>Component3D</code>"]
    Object3D["<code>Object3D</code>
        <span>has the renderCamera override for rendering</span>"]
    LightComponent["<code>LightComponent</code>
        <span>exposes a <code>LightSource</code> to the <code>World3D</code></span>"]
    MeshComponent["<code>MeshComponent</code>"]
    Mesh["<code>Mesh</code>"]
    LightSource["<code>LightSource</code>
        <span>light properties<br />(sans <code>transform</code>)</span>"]
    Resource["<code>Resource</code>"]
    Light["<code>Light</code>
        <span><code>source</code> + <code>transform</code></span>"]

    World -.->|has| Component

    World3D -->|is| World
    World3D -.->|has| Component3D

    Component3D -->|is| Component
    Object3D -->|is| Component3D
    LightComponent -->|is| Component3D
    Light -.->|has| LightSource

    MeshComponent -->|is| Object3D
    MeshComponent -.->|has| Mesh
    Mesh -->|is| Resource

    LightComponent -.->|creates| Light
    Light -->|is| Resource

```
