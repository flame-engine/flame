``` {mermaid}
%%{init: { 'theme': 'dark' } }%%
  graph TD  
  
    %% Node Color %%
    classDef default fill:#282828,stroke:#F6BE00,stroke-width:2px;
    classDef yellow fill:#F6BE00,color:#000;
 
    %% Nodes  %%
    
    z(Mixin):::yellow
    x(Normal Class)
```

``` {mermaid}
%%{init: { 'theme': 'dark' } }%%
  
  graph BT  

    %% Node Color %%
    classDef default fill:#282828,stroke:#F6BE00,stroke-width:2px;
    classDef yellow fill:#F6BE00,color:#000;
 
    %% Nodes  %%
    
    A(OxygenGame)
    B(Loadable):::yellow
    C(Game):::yellow
    D(FlameGame)
    E(Component)
    F(Other Components)
    G(GameWidget)

    %% Flow  %%

    A-- With -->B
    A-- With -->C
    G-- Wants -->C
    C-- On -->B
    E-- With -->B

    D-- Extends -->E
    F-- Extends -->E

    D-- With -->C
 ```
