``` {mermaid}
%%{init: { 'theme': 'dark' } }%%
  
  graph TD  

   %% Node Color %%
   classDef default fill:#282828,stroke:#F6BE00,stroke-width:2px;
   classDef yellow fill:#F6BE00,color:#000;

   %% Nodes  %%
   x(Runs every time)
   z(Runs Once):::yellow

```

``` {mermaid}
%%{init: { 'theme': 'dark' } }%%
  graph LR
  
   %% Node Color %%
   classDef default fill:#282828,stroke:#F6BE00,stroke-width:2px;
   classDef yellow fill:#F6BE00,color:#000;

    %% Nodes %%
    
    A(onLoad):::yellow
    B(onGameResize)
    C(onMount)
    D(Update)
    E(Render)
    F(onRemove)

    %% Flow %%
 
    A-->B
    B-->C
    C-->D
    D-->E
    E-->D
    D-->F
    F-. If added to a new parent .->B
    
```
