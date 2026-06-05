# Bloodstream Defender

Bloodstream Defender is a browser-based arcade game about piloting a white blood cell through a stylized bloodstream. You dodge red blood cells and platelet clots, lock onto incoming viruses, fire Y-shaped antibody projectiles, and adapt between levels with immune-system upgrades.

The project started from a simple idea: I have always wanted to make a game about what is happening inside the body. The goal is to keep the science recognizable, with white blood cells, antibodies, platelets, influenza virions, immune terms, and bloodstream motion, while still making the game feel fast, readable, and playful.

## Play The Demo

The easiest way to try the current build is the hosted demo:

[https://humble-marvel-dx2j.here.now/](https://humble-marvel-dx2j.here.now/)

On desktop, open the link and click **Start Run**. On phones, rotate to landscape and tap **Start Run** once so the browser can unlock music and sound effects.

## Project Highlights

- Vanilla HTML, CSS, and JavaScript Canvas game with no framework or build step
- Level-based arcade structure with escalating difficulty and late-stage boss or mini-boss encounters
- Roguelite upgrade tree with practical immune-system abilities between levels
- Educational mission language using terms like innate immunity, antigen, complement system, chemotaxis, phagocytosis, and adaptive immunity
- Threat-based auto lock-on that prioritizes nearby incoming enemies without cluttering the screen with lock-on rings
- Homing Y-shaped antibody projectiles, complement pulse, and upgraded Chemotaxis Dash
- Influenza virions that multiply on contact and push outward, creating target-priority pressure
- Generated bloodstream backgrounds, sprite assets, HUD ornaments, upgrade UI, and game-over report art
- Multi-layer parallax bloodstream environment
- Desktop and landscape mobile controls
- Layered audio with music, ambience, boss warnings, combat effects, upgrade sounds, pause sounds, and separate music/effects mute buttons

## Screenshots

**Title screen**

![Bloodstream Defender title screen](docs/screenshots/title-screen.png)

**HUD, mission panel, and bloodstream playfield**

![Bloodstream Defender HUD and mission panel](docs/screenshots/gameplay-hud.png)

**Antibody projectiles**

![Bloodstream Defender firing a Y-shaped antibody projectile](docs/screenshots/antibody-shot.png)

**Influenza enemy mission**

![Bloodstream Defender influenza enemy in the Influenza Bloom mission](docs/screenshots/influenza-enemy.png)

**Roguelite upgrade tree**

![Bloodstream Defender upgrade tree](docs/screenshots/upgrade-tree.png)

**Pause menu with audio controls**

![Bloodstream Defender pause menu](docs/screenshots/pause-menu.png)

**End-of-run summary**

![Bloodstream Defender immune run summary](docs/screenshots/game-over-summary.png)

## Play Locally

This is a static web game. You do not need to install dependencies or run a build command, but you should serve the folder through a local web server instead of opening `index.html` directly. A local server lets the browser load JavaScript modules, images, and audio files correctly.

### Requirements

- Git
- Python 3, which is included on many systems and is only used here to serve the static files
- A modern browser such as Chrome, Edge, Firefox, or Safari

### Steps

```bash
git clone https://github.com/Niko2756/bloodstream-defender-game.git
cd bloodstream-defender-game
python3 -m http.server 8000
```

Then open this address in your browser:

```text
http://localhost:8000/
```

If port `8000` is already in use, choose another port:

```bash
python3 -m http.server 8080
```

Then open:

```text
http://localhost:8080/
```

On Windows, if `python3` is not available, try:

```bash
py -m http.server 8000
```

## Controls

### Desktop

| Action | Input |
| --- | --- |
| Move | `WASD` or arrow keys |
| Fire antibodies | `Space`, mouse click, or tap |
| Chemotaxis Dash | `Shift` after choosing the Chemotaxis Dash upgrade |
| Complement Pulse | `E`, `Q`, `Enter`, or `Numpad Enter` after choosing the Complement Pulse upgrade |
| Pause or resume | `P`, `Escape`, or the pause button |
| Restart run | Pause menu or end screen |

### Mobile Web

The mobile version is designed for landscape play.

| Action | Input |
| --- | --- |
| Move | Left thumb joystick |
| Fire antibodies | Hold the **Fire** button |
| Chemotaxis Dash | Tap **Dash** after unlocking it |
| Complement Pulse | Tap **Pulse** after unlocking it |
| Pause or resume | Pause button in the top-right HUD |

For the most full-screen iPhone experience, open the live demo in Safari, tap the Share button, and choose **Add to Home Screen**.

## Game Flow

Each level is a vessel section with a mission objective and an immune-system term. After clearing a section, the game shows a level-complete report with score, neutralized targets, remaining health, and the next mission preview.

The player then chooses one adaptation from the upgrade tree:

- **Antibody Output** improves antibody fire rate, projectile count, and antibody damage.
- **Complement Defense** unlocks and improves the radial complement pulse.
- **Cell Movement** unlocks and improves Chemotaxis Dash for quick repositioning.

Once every upgrade branch is fully adapted, the level-complete screen changes from **Choose Adaptation** to **Continue** and sends the player straight into the next level.

## Enemies And Bosses

Early levels focus on readable arcade combat: incoming viruses, platelet hazards, and antibody timing. Later levels add stronger enemy mixes, influenza virions, and end-of-section boss encounters.

- Influenza virions begin appearing in level 4.
- Matching influenza virions multiply when they touch, then push outward so the bloom spreads instead of stacking in one place.
- Boss and mini-boss encounters begin near the end of later levels, after a warning rumble.
- Bosses are meant to act as a surprise escalation, not the entire level.

## Audio

The game uses a layered audio system:

- Menu, vessel combat, high-danger combat, upgrade, boss-warning, and boss-loop music
- Bloodstream ambience under active gameplay
- Level-clear sting before upgrade music begins
- Boss-warning rumble before the boss appears, then boss-loop music during the fight
- Separate sound effects for antibody shots, hits, boss hits, boss phase changes, boss defeat, influenza replication, budding-virus split, platelet impact, player damage, player death, pause/resume, UI selection, and upgraded dash
- Pause-menu toggles for music and effects

## Project Structure

```text
.
├── index.html          # Game canvas, overlays, HUD, and screen markup
├── styles.css          # HUD, menus, mobile layout, overlays, and responsive styling
├── src/game.js         # Game loop, input, combat, spawning, level flow, audio, and drawing
├── assets/             # Runtime art, sprites, audio, UI assets, and backgrounds
└── docs/               # Design notes, reference material, and README screenshots
```

## Development Notes

Bloodstream Defender currently uses vanilla Canvas instead of a game engine so the prototype stays easy to understand, edit, and deploy as a static site. The visual target is a semi-accurate, semi-cartoony bloodstream: readable biology silhouettes, expressive enemies, rich red plasma layers, and arcade-friendly combat clarity.

The design direction is an educational roguelite arcade game. Each cleared vessel section introduces immune-system language, and each upgrade gives the player a practical antibody adaptation that also teaches how to use the new ability.
