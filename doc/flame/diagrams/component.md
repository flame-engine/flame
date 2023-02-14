``` {mermaid}
%%{init: { 'theme': 'dark' } }%%
  graph TD  

    %% Node Color %%
    classDef yellow fill:#F6BE00,stroke:#F6BE00,stroke-width:4px,color:#AAA ;
    classDef default fill:#282828,stroke:#F6BE00;
    
    %% Nodes %%

    z(Abstract Class):::yellow
    x(Normal Class)

 ```

```{mermaid}
%%{init: { 'theme': 'dark'  } }%%
graph TD
    %% Node Color %%
    classDef yellow fill:#F6BE00,stroke:#F6BE00,stroke-width:4px,color:#AAA;
    classDef default fill:#282828,stroke:#F6BE00;
    
    %% Nodes %%
       
    Component(Component)
    Misc("
        TimerComponent
        ParticleComponent
        SpriteBatchComponent
    ")
    Effects("Effects<br/>(See the effects section)"):::yellow
    Game(Game)
    FlameGame(FlameGame)
    PositionComponent(PositionComponent)
   
    Sprites("
        SpriteComponent
        SpriteGroupComponent 
        SpriteAnimationComponent
        SpriteAnimationGroupComponent
        ParallaxComponent 
        IsoMetricTileMapComponent
    ")
    
    HudMarginComponent(HudMarginComponent)
    HudComponents("
        HudButtonComponent
        JoystickComponent
    ")
    
    OtherPositionComponents("
        ButtonComponent
        CustomPainterComponent
        ShapeComponent
        SpriteButtonComponent
        TextComponent
        TextBoxComponent
        NineTileBoxComponent
    ")
        
    %% Flow %%
    Component --> Misc
    Component --> Effects
    Component --> PositionComponent
    Component --> FlameGame
   
    Game --> FlameGame
    PositionComponent --> Sprites
    PositionComponent --> HudMarginComponent
    PositionComponent --> OtherPositionComponents
    HudMarginComponent --> HudComponents    
```
