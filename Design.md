# Untitled FPS game
This is a hitscan FPS action game with a focus on advanced enemy AI and a unique player health system, and otherwise standard systems for the genre.

## Artificial Intelligence
Our goal for the game is to implement Goal-Oriented Action Planning for the enemy AI, and to have them carry out a variety of unique behaviors, such as:

* Moving on patrol routes
* Taking cover from the player
* Flanking the player
* Fleeing for safety
* Coordinating in squads
* Providing covering fire for other enemies

### Goal-Oriented Action Planning (GOAP)
GOAP is a form of algorithmic AI for games that allows AI to appear to create complex plans and smart behavior choices. It was first implemented in FEAR (2005), which is still considered to this day to be an example of a game with unusually good enemy AI. The FEAR implementation of GOAP is described in this paper:

https://alumni.media.mit.edu/~jorkin/gdc2006_orkin_jeff_fear.pdf

### Path-finding
We may choose to either implement more advanced navigation for the AI, or use a navigation addon provided on the Godot asset library. The built-in navigation in Godot 3.x is very limited, notably not re-routing around or on dynamic objects.

## Health system
The experimental health system in the game is intended to achieve two goals:

1. Resolve the problem of realism in single-player hitscan FPS games, where the player can be shot by enemies thousands of times without dying. This problem arises from regenerating health or health items.
2. Create a health system that improves game depth by having more varied state, and giving more actionable information to the player and enemy AI.

### Danger meter
The new health system in the game is tentatively called the "danger meter." It represents the amount of enemy focus the player has attracted. If the danger meter becomes full, one of the enemies' bullets will hit the player and either instantly kill them, or severely wound them, in which case they may have decreased mobility, aim, and so on, with a re-set danger meter, and a guaranteed insta-kill next time the danger meter becomes full. Prior to the danger meter being full, enemies will still fire in the general direction of the player for purposes of aesthetics and providing information to the player, but will be programmed to miss. 

The danger meter system achieves both design goals:

1. It ensures that the player will not survive being hit by thousands of bullets, and will either die or suffer noticeable, sustained detrimental effects when a bullet does hit them, giving a heightened sense of realism in the game.
2. The danger meter can have more varied state, such as rate of depletion and source of danger, and creates a narrative justification for more varied mechanics.

#### Depth of danger meter mechanic
Planned or implemented consequences of the danger meter mechanic include:

* Individual enemies' contribution to the danger meter disappearing if the enemy dies. Thus a player becomes safer by killing enemies (similar to enemies dropping health pickups, as in Doom (2016)), and may choose to prioritize killing enemies that they believe have been aiming at the player for a longer duration. Individual enemies' contribution to the danger meter could be communicated to the player through visual information.
* Danger meter depletes when enemies can't see the player (similar to health regen, such as that found in the Call of Duty franchise), encouraging player use of cover, but...
* Danger meter depletes slowly if the player's cover position is too near to the last player position that was known to an enemy. Information about this is provided to the player, encouraging them to not only take cover, but perform flanking maneuvers and prioritize cover that provides mobility.
* Danger meter increases at a greater or lesser rate depending on enemy proximity and player visibility. This keeps intact the usual FPS game tradeoff of ease of aiming at enemies versus ease of avoiding enemy bullets.
* Danger meter increases at a greater or lesser rate depending on the player's movement (EG, if they stand still, it will increase faster, but if they are sprinting, it will increase more slowly). Many FPS games do not take this into account when setting enemy aim accuracy. This is also a tradeoff for the player, as they will have more difficulty aiming at the enemy when they are moving.
* Danger meter increases at a greater or lesser rate depending on enemy movement (EG, if they are running while firing, blind-firing, or standing still). The player could choose to engage in actions that force the enemy to keep moving.
* Wielding different weapon types will change enemies' effective ranges and danger falloffs. 
* 


#### Design and balance concerns
Asymmetry, multi-player, effective conveyance of information to player, complexity of per-enemy vs for all enemies,


## Design Goals
Tactical, 
#### Inspirations
