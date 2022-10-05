``` {mermaid}
%%{init: { 'theme': 'dark' } }%%
  
  graph TD  

   %% Node Color %%
   classDef yellow fill:#F6BE00,stroke:#F6BE00,stroke-width:4px,color:#000 ;
   classDef default fill:#282828,stroke:#F6BE00,stroke-width:2px;

   %% Nodes  %%
   x(Runs every time)
   z(Runs Once):::yellow

```

``` {mermaid}
%%{init: { 'theme': 'dark' } }%%
  graph LR
  
   %% Node Color %%
   classDef yellow fill:#F6BE00,stroke:#F6BE00,stroke-width:4px,color:#000 ;
   classDef default fill:#282828,stroke:#F6BE00,stroke-width:2px;

    %% Nodes %%
    
    A(onGameResize)
    B(onLoad):::yellow
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
    F-- if Added new parent .->A
    
```
