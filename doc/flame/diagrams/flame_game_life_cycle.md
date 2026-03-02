``` {mermaid}
%%{init: { 'theme': 'dark' } }%%

  graph TD

   %% Node Color %%
   classDef default fill:#282828,stroke:#F6BE00,stroke-width:2px;
   classDef lightYellow fill:#523F00,stroke-width:2px;
   classDef yellow fill:#F6BE00,color:#000000;
   classDef green fill:#00523F,stroke:#F6BE00,stroke-width:2px;

   %% Nodes  %%
   x(Runs Each Tick)
   y(Runs On Add & Resize):::lightYellow
   z(Runs Once):::yellow
   w(Runs On Hot Reload):::green

```

``` {mermaid}
%%{init: { 'theme': 'dark' } }%%
  graph LR

   %% Node Color %%
   classDef default fill:#282828,stroke:#F6BE00,stroke-width:2px;
   classDef lightYellow fill:#523F00,stroke-width:2px;
   classDef yellow fill:#F6BE00,color:#000000;
   classDef green fill:#00523F,stroke:#F6BE00,stroke-width:2px;

    %% Nodes %%

    A(onGameResize):::lightYellow
    B(onLoad):::yellow
    C(onMount):::yellow
    D(update)
    E(render)
    F(onRemove):::yellow
    G(onHotReload):::green

    %% Flow %%

    A-->B
    B-->C
    C-->D
    D-->E
    E-->D
    E-. If removed .->F
    F-. If re-parented .->A
    D-. If hot reloaded .->G
    G-.->D

```
