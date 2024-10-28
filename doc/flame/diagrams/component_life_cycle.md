``` {mermaid}
%%{init: { 'theme': 'dark' } }%%

  graph TD

   %% Node Color %%
   classDef default fill:#282828,stroke:#F6BE00,stroke-width:2px;
   classDef lightYellow fill:#523F00,stroke-width:2px;
   classDef yellow fill:#F6BE00,color:#000000;

   %% Nodes  %%
   x(Runs Each Tick)
   y(Runs On Add & Resize):::lightYellow
   z(Runs Once):::yellow

```

``` {mermaid}
%%{init: { 'theme': 'dark' } }%%
  graph LR

   %% Node Color %%
   classDef default fill:#282828,stroke:#F6BE00,stroke-width:2px;
   classDef lightYellow fill:#523F00,stroke-width:2px;
   classDef yellow fill:#F6BE00,color:#000000;

    %% Nodes %%

    A(onLoad):::yellow
    B(onGameResize):::lightYellow
    C(onMount):::lightYellow
    D(update)
    E(render)
    F(onRemove):::lightYellow

    %% Flow %%

    A-->B
    B-->C
    C-->D
    D-->E
    E-->D
    E-. If removed .->F
    F-. If re-parented .->A

```
