``` {mermaid}
%%{init: { 'theme': 'dark' } }%%
  graph TD  

    %% Node Color %%
    classDef yellow fill:#F6BE00,stroke:#F6BE00,stroke-width:4px,color:#000 ;
    classDef default fill:#282828,stroke:#F6BE00;
    
    %% Nodes %%

    z(Abstract Class):::yellow
    x(Normal Class)

 ```

```{mermaid}
%%{init: { 'theme': 'dark'  } }%%

graph TD
    %% Node Color %%
    classDef yellow fill:#F6BE00,stroke:#F6BE00,stroke-width:4px,color:#000 ;
    classDef default fill:#282828,stroke:#F6BE00;
    
    %% Nodes %%
       
    Component[Component]
    TimerComponent(TimerComponent <br/>ParticleComponent <br>SpriteBatchComponent)
    Effects("Effects <br/> (See the effects section)"):::yellow
    FlameGame(Flame Game)
    PositionComponent(PositionComponent)
   
    SpriteComponent("SpriteComponent  <br/> SpriteGroupComponent 
    <br/> SpriteAnimationComponent <br/> 
    SpriteAnimationGroupComponent <br/> ParallaxComponent 
    <br/> IsoMetricTileMapComponent")
    
    HudMarginComponent(HudMarginComponent)
    HudButtonComponent(HudButtonComponent  <br/> JoystickComponent)
    
    ButtonComponent("ButtonComponent <br/> CustomPainterComponent 
    <br/> ShapeComponent <br/> SpriteButtonComponent 
    <br/> TextComponent <br/> TextBoxComponent 
    <br/> NineTileBoxComponent")
    
    Loadable("Loadable (Mixin)"):::yellow
    
    %% Flow %%
    Component --> TimerComponent
    Component --> Effects
    Component --> PositionComponent
    Component --> FlameGame
   
    Loadable --> FlameGame
    PositionComponent --> SpriteComponent
    PositionComponent --> HudMarginComponent
    PositionComponent --> ButtonComponent
    HudMarginComponent --> HudButtonComponent
    
```
