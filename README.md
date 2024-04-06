# What Lies Beneath
<!-- Fiverr.com Order number: #FO81898B1B882 -->


<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/ConnorBS/What-Lies-Beneath">
    <img src="Project Management/0. File Collection/0. Initial/Screenshot.png" alt="Logo" height=200% width=200%>
  </a>

<h3 align="center">What Lies Beneath</h3>

  <p align="center">
    A side-scroller horror game
    <br />
    <a href="https://github.com/ConnorBS/What-Lies-Beneath/tree/main/Project%20Management"><strong>Explore the Project Documents »</strong></a>
    <!-- Comment out for now
    <br />
    <br />
    <a href="https://github.com/github_username/repo_name">View Demo</a>
    ·
    <a href="https://github.com/github_username/repo_name/issues">Report Bug</a>
    ·
    <a href="https://github.com/github_username/repo_name/issues">Request Feature</a>
    --->
  </p>
</div>



<!-- Milestone Table -->
<details>
  <summary><a href="#milestone-table">Milestone Table</a></summary>
  <ol>
    <li>
      <a href="#player-movement-milestone">Player Movement Milestone</a>
      <ul>
        <li><a href="#general-movement">General Movement</a></li>
        <li><a href="#interactions">Interactions</a></li>
        <li><a href="#basic-combat">Basic Combat</a></li>
        <li><a href="#game-camera">Game Camera</a></li>
      </ul>
    </li>
    <li>
      <a href="#menu-system-milestone">Menu System Milestone</a>
      <ul>
        <li><a href="#silent-hill-style-inventory">Silent Hill Style Inventory</a></li>
        <li><a href="#map-placeholder">Map option - Placeholder Screen</a></li>
        <li><a href="#memo---journal-pages">Memo - Journal Pages</a></li>
        <li><a href="#important-objects">Important Objects</a></li>
        <li><a href="#options">Options</a></li>
        <li><a href="#global-player-state">Global Player State</a></li>
      </ul>
    </li>
    <li><a href="#dialogue-milestone">Dialogue Milestone</a>
      <ul>
        <li><a href="#dialog-with-branching-options">Dialog with Branching Options</a></li>
        <li><a href="#interact-able-objects-with-dialog-boxes">Interact-able Objects With Dialog Boxes</a></li>
        <li><a href="#interact-able-objects-with-text-above-player">Interact-able Objects With Text Above Player</a></li>
        <li><a href="#save-dialog-choice">Save Dialog Choice</a></li>
      </ul>
    </li>
    <li><a href="#map-system-milestone">Map System Milestone</a>
      <ul>
        <li><a href="#collecting-map-fragments">Collecting Map Fragments</a></li>
        <li><a href="#metroid-style-map">Metroid Style Map</a></li>
      </ul>
    </li>
    <li><a href="#combat-milestone">Combat Milestone</a>
      <ul>
        <li><a href="#player-combat">Player Combat</a></li>
        <li><a href="#player-inventory">Player Inventory</a></li>
      </ul>
    </li>
    <li><a href="#enemies-milestone--save-point-milestone">Enemies Milestone / Save Point Milestone</a>
      <ul>
        <li><a href="#enemy-ai-types">Enemy AI Types</a></li>
        <li><a href="#enemy-interactions">Enemy Interactions</a></li>
        <li><a href="#save-objects">Save Objects</a></li>
        <li><a href="#start-menu">Start Menu</a></li>
        <li><a href="#player-death-load-save">Player Death, Load Save</a></li>
      </ul>
    </li>
  </ol>
</details>

### Design Documentation per Component

<h4>
  <a href = "https://sites.google.com/offthegroundgames.com/what-lies-beneath"> https://sites.google.com/offthegroundgames.com/what-lies-beneath </a>
</h4>



### Built With
<h2>
<a href="https://godotengine.org/download/archive/3.5.1-stable/"> <img src="https://godotengine.org/assets/logo.svg" width=20% height=%20>

  Version 3.5
</a>
</h2>



<!-- GETTING STARTED -->
## Getting Started

Game Build is stored within the [Project File](https://github.com/ConnorBS/What-Lies-Beneath/tree/main/Project%20Files), while Documents pertaining to the project management of this endeavour are stored in the [Project Management](https://github.com/ConnorBS/What-Lies-Beneath/tree/main/Project%20Management)

### Prerequisites

Download Version 3.5 from Godot Download files [Here](https://godotengine.org/download)

<!--
### Installation
-->


## Milestone Table

### Player Movement Milestone
[GIF Library](https://imgur.com/a/XAhMfN8)
#### General Movement
- [x] Walking 
- [x] Running (Hold-Shift)
- [x] Hidden Stamina Bar
- [x] Climb Ladder
- [x] Fall/Drop
#### Interactions
- [x] Push/Pull Box/Climb Box
- [x] Kneeling (Looting/Interacting) 
- [x] Interactable Object (Shimmer)
#### Basic Combat
- [x] Aiming (across the walkable axis)
- [x] While Aiming you can only Walking
- [x] Button to pull out gun 
#### Game Camera
- [x] Dynamic Camera Primarily on Character
<p align="right">(<a href="#what-lies-beneath">back to top</a>)</p>

### Menu System Milestone
#### Silent Hill Style Inventory
<a href="http://www.youtube.com/watch?feature=player_embedded&v=lP6XaMMV9pU
" target="_blank"><img src="http://img.youtube.com/vi/lP6XaMMV9pU/0.jpg" 
alt="IMAGE ALT TEXT HERE" width="240" height="180" border="10" /></a>
- [x] Options to: Use, Reload, Equip, Remove
- [x] Gun Equipment Slot
- [x] Still Screenshot of the Game in the top left with colour overlay indicating health
#### Map Placeholder
#### Memo - Journal Pages
- [x] Left right over Journal Objects
#### Important Objects
- [x] Shows Keys
- [x] Shows Map Fragments
#### Options
- [x] Music and Sound Controls
#### Global Player State
- [x] Health
- [x] Equipped Item
- [x] Inventory
- [x] Important Inventory Items
- [x] Map Fragments
- [x] Location
<p align="right">(<a href="#what-lies-beneath">back to top</a>)</p>

### Dialogue Milestone
- [x] Dialog with Branching Options 
- [x] Interact-able Objects With Dialog Boxes
- [x] Interact-able Objects With Text Above Player
- [x] Save Dialog Choice
<p align="right">(<a href="#what-lies-beneath">back to top</a>)</p>

### Map System Milestone 
#### Collecting Map Fragments
#### Metroid Style Map
- [x] Track if you have been in the space
- [x] Track if the door is locked (show by X)
<p align="right">(<a href="#what-lies-beneath">back to top</a>)</p>

### Combat Milestone
#### Player Combat
- [x] Shooting Gun While Aiming
- [x] Melee Animation
- [x] Check on Hit/Provide Damage
- [x] Taking damage 
- [x] HP Recovery (Syringe)
- [x] Game Restart 
#### Player Inventory
- [x] Check Equipped Item (Gun)
- [x] Provide Damage on Check
<p align="right">(<a href="#what-lies-beneath">back to top</a>)</p>

### Enemies Milestone / Save Point Milestone
#### Enemy AI Types
- [x] CuddleBuddy – The remnants of a person. Doesn't focus on the player and shuffles on its own, until it sees the player and goes straight to the player. Takes 2-3 hits
- [x] Enemy Interactions
- [x] On Player Touch, Damages Player
- [x] Attack Animations
- [x] Attack hitboxes
- [x] Critical hitbox damage
- [x] On Kill Logic
- [x] Enemy is destroyed and corpse on ground
- [x] Corpse is lootable
- [x] On Entry, Enemy States are stored and loaded back
- [x] Option for Level to Ignore saving the enemy to reset enemy placement

#### Object in world where the character can save
- [x] Start Menu
- [x] New Game
- [x] Load Game
- [x] Quit
- [x] On Death, Load Last Save
#### Item Usage Enhancements
- [x] Use Items on World Objects
- [x] Combine Items in Inventory
#### Lighting Enhancements
- [x] Flashlight for Ethan
- [x] Flashlight Button
- [x] Dark Option for Level
#### Clean-Up
##### Connect the new audio files for the following actions: 
- [x] Dry Fire
- [x] Shooting
- [x] Reloading
- [x] Walking on wood/Concrete
- [x] Area2D to inform which file to play
- [x] Add Crowbar Animation Walking Animation
- [x] Update Crowbar Attacking Animation
- [x] Remove the text on the interaction

<p align="right">(<a href="#what-lies-beneath">back to top</a>)</p>



<!-- CONTRIBUTING 
## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<p align="right">(<a href="#readme-top">back to top</a>)</p>


-->

<!-- CONTACT -->
## Contact

Connor Sutherland-Stewart - [@Connor_BS](https://twitter.com/Connor_BS) - connorbs@offthegroundgames.com

<p align="right">(<a href="#what-lies-beneath">back to top</a>)</p>



<!-- ACKNOWLEDGMENTS
## Acknowledgments

* []()
* []()
* []()

<p align="right">(<a href="#readme-top">back to top</a>)</p>

 -->

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[godot-logo]: https://godotengine.org/themes/godotengine/assets/logo.svg
