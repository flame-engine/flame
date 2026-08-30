``` {mermaid}
%%{init: { 'theme': 'dark' } }%%
  graph TD  
  
    %% Node Color %%
    classDef default fill:#282828,stroke:#F6BE00,stroke-width:2px;
    classDef yellow fill:#F6BE00,color:#000;
 
    %% Nodes  %%
    
    z(Abstract Class):::yellow
    x(Normal Class)
```

``` {mermaid}
%%{init: { 'theme': 'dark' } }%%
  
  graph BT  

    %% Node Color %%
    classDef default fill:#282828,stroke:#F6BE00,stroke-width:2px;
    classDef yellow fill:#F6BE00,color:#000;
 
    %% Nodes  %%
    
    B(Game):::yellow
    C(FlameGame)
    D(Component)
    E(Other Components)
    F(GameWidget)

    %% Flow  %%

    F-- Wants -->B

    C-- Extends -->D
    E-- Extends -->D

    C-- With -->B
 ```
