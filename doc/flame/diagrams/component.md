``` {mermaid}
%%{init: { 'theme': 'dark' } }%%
graph TD
    %% Config %%
    classDef default fill:#282828,stroke:#F6BE00;
    
    %% Nodes %%
    Component(Component)
    Misc("
        TimerComponent
        ParticleComponent
        SpriteBatchComponent
    ")
    Effects("Effects<br/>(See the effects section)")
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
