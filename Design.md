# Untitled FPS game
This is a hitscan FPS action game with a focus on advanced enemy AI and a unique player health system, and otherwise standard systems for the genre.

# Table of contents
1. [Artificial Intelligence](#artificial-intelligence)
3. [Design Goals](#design-goals)
## Artificial Intelligence <a name="#artificial-intelligence"></a>
Our goal for the game is to implement Goal-Oriented Action Planning for the enemy AI, and to have them carry out a variety of unique behaviors, such as:

* Moving on patrol routes when not engaging in combat
* Taking cover from the player
* Flanking the player
* Fleeing for safety
* Coordinating in squads
* Providing covering fire for other enemies
* Assisting other enemies who are injured

### Goal-Oriented Action Planning (GOAP)
GOAP is a form of algorithmic AI for games that allows AI to appear to make complex plans and smart behavior choices. It was first implemented in FEAR (2005), which is still considered to this day to be an example of a game with unusually good enemy AI. The FEAR implementation of GOAP is described in this paper:

https://alumni.media.mit.edu/~jorkin/gdc2006_orkin_jeff_fear.pdf

### Path-finding
We may choose to either implement more advanced navigation for the AI, or use a navigation addon provided on the Godot asset library. The built-in navigation in Godot 3.x is very limited, notably not re-routing around or on dynamic objects. We may also want to have enemy navigation that adds weight to nodes the player can see, so that enemies will prefer to flank behind cover. Already existing navigation servers for Godot include:

https://github.com/TheSHEEEP/godotdetour

https://github.com/MilosLukic/Godot-Navigation-Lite

## Health system
The experimental health system in the game is intended to achieve two goals:

1. Resolve the problem of realism in single-player hitscan FPS games, where the player can be shot by enemies thousands of times without dying. This problem arises from regenerating health or health pickup items.
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
* Danger meter depletes more slowly if the player's cover position is too near to the last player position that was known to an enemy. Information about this is provided to the player, encouraging them to not only take cover, but also perform flanking maneuvers and prioritize cover that provides mobility.
* Danger meter increases at a greater or lesser rate depending on enemy proximity and player visibility. This keeps intact the usual FPS game tradeoff of ease of aiming at enemies versus ease of avoiding enemy bullets from afar.
* Danger meter increases at a greater or lesser rate depending on the player's movement (EG, if they stand still, it will increase faster, but if they are sprinting, it will increase more slowly). Many FPS games do not take this into account when setting enemy aim accuracy. This is also a tradeoff for the player, as they will have more difficulty aiming at the enemy when they are moving.
* Danger meter increases at a greater or lesser rate depending on enemy movement (EG, if they are running while firing, blind-firing, or standing still). The player could choose to engage in actions that force the enemy to keep moving.
* Wielding different weapon types will change enemies' effective ranges and danger falloffs. 
* Visibility effects such as bushes or smoke grenades may not make the player entirely safe, but only reduce the rate of increase of the danger meter, as enemies could be blind-firing at the player's hidden location.

From these examples, it is apparent that the danger meter can contain deep game state, deeper than a normal health bar or regenerating health. However, it is not clear to what extent this depth carries over into gameplay depth. It is possible that the player would not notice the difference in depth, and the danger meter would, in practice, be no different from normal regenerating health, aside from narrative concerns. This is likely the worst-case scenario for the mechanic, which would make it a low-risk mechanic to include in the game as it couldn't be worse than what is already commonly implemented. 

#### Design and balance concerns
The complexity of the danger meter mechanic could vary widely depending on implementation, and player reception of said complexity will depend heavily on the extent that they understand how it works. Therefore, in evaluating implementation details of the danger meter, mechanics that convey information to the player poorly should be discarded, and mechanics that convey information well should be preferred.

An example of state that could be difficult to communicate to the player would be seperate depletion rates for enemies' contributions to the danger bar. In the present prototype, the player has to be hidden from all enemies in order to have their danger level diminish. This could be explained to the player as the enemies communicating with each other about the player's position. However, it is possible to have each individual enemies' danger bars deplete whenever that specific enemy can't see the player. This could lead to a more complex game state, but would lead to a situation where there could be two enemies with depleting meters and one enemy with an increasing meter, looking overall to the player as if the meter was simply decreasing, not informing them that they were still in an enemy's sight. Conveying information about these separate enemy states (seeing player, knowing where the player is hiding, and not knowing the player's location) might be achievable through a multi-colored, color-coded danger bar, but this could come at significant cost to player understanding. Play-testing could help determine which scheme is better.

The danger meter mechanic simulates the process of enemies aiming at the player. The player actually experiences the process of aiming at enemies and either missing or hitting. Therefore, the danger meter mechanic tends towards an asymmetrical game design, in which the player and the enemies have different health systems (the enemies having a more traditional health points system, or having more distinct hitboxes). The game is balanced through enemy placement, grouping, and variation, as well as the player having imperfect aim (likely with added screen-shake that varies with player movement). Making the player fill up an enemies' own danger meter before being able to shoot them would place a hard, low skill cap on the game, which may be desirable if the game's focus is not aiming skill, but instead tactics or movement, but is otherwise undesirable. Some games do have such a player mechanic, such as missile lock-on systems in fighter jet simulators. However, such a mechanic is also harder to justify in the game's narrative if it is a realistic hit-scan FPS. 

Asymmetry in game design is well-suited to single-player games, but not to multi-player games, which demand a level playing field. There is a trend in big-studio FPS game design to include a multi-player mode even though most of these multi-player modes never become popular or quickly lose their player base. The multi-player FPS market is dominated by major titles like Counter-Strike, Call of Duty, and Fortnite, many of which are released as stand-alone multiplayer modes. The danger meter mechanic makes this game more comparable to a game in the action-stealth genre, which is also highly asymmetrical and does not translate well into multi-player. The exclusion of multi-player considerations from this game design is not a major loss due to the low likelihood that any new multi-player game would be widely adopted, and due to the benefits of exploring a new single-player game design space.

## Design goals <a name="design-goals"></a>
The rest of the game's design should play to the strengths of its GOAP AI and the danger bar mechanic. These two aspects of the game could be sufficient in a variety of design styles. For example, they likely would not prevent a fast-paced, arcade-style shooter from being fun. However, the player would not get a chance to see much of the AI planning and behaviors if the enemies were short-lived, so in order to show off the depth of the AI to the player, the danger meter, enemy placements and groupings, level design, enemy health, and player aim (screen shake, weapon recoil) should be tuned so that the enemies live long enough to exhibit a variety of behaviors. Likewise, the danger bar mechanic exhibits depth when the player is frequently moving to and from cover, engaging enemies at a variety of distances, and moving at different speeds, so the game should also be balanced to require an average player to engage in these behaviors. Notably, balancing for medium to long-lived enemies (they are more dangerous) naturally balances for the desired player behaviors. GOAP AI and good level design can have synergy with the danger meter mechanic that pushes the game design towards a tactical style, either fast-paced or slow-paced.

A tactical style of gameplay emphasizes positioning, player movement, and player choice between tradeoffs. It deemphasizes some aspects common in the FPS genre that are associated with power fantasy. The player should not feel invulnerable or overpowered, and the enemies should not appear to be stupid or incapable.

### Inspirations
Well-known examples of tactical-feeling single-player FPS games include FEAR, STALKER, Half-life 1, and Crysis.
FEAR, STALKER, Half-life, Devil Daggers, MGSV, Crysis, 

## Other game mechanics
