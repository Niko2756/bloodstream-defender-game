# Bloodstream Defender

Bloodstream Defender is a small browser game about piloting a white blood cell through a stylized blood vessel, locking onto viruses, and firing antibody-shaped projectiles before they crash into you.

The idea started from a simple wish: I have always wanted to make a game about what is happening inside the body. The goal is to keep the science recognizable, with white blood cells, red blood cells, antibodies, platelets, viruses, and bloodstream motion, while still letting the whole thing feel cartoony, fast, and playful.

## Live Demo

Play the current build at [humble-marvel-dx2j.here.now](https://humble-marvel-dx2j.here.now/).

## Mobile Web

The here.now build is playable on phone browsers as a landscape-first web game. Open the live demo link, rotate the phone to landscape, then tap **Start Run** once so iOS/Safari and mobile Chrome can unlock music and sound effects.

Mobile controls:

- Move: left thumb virtual joystick
- Fire antibodies: hold the right-side **Fire** button
- Chemotaxis Dash: tap **Dash** after choosing the Chemotaxis Dash upgrade
- Complement Pulse: tap **Pulse** after choosing the Complement Pulse upgrade
- Pause/resume: use the pause button in the top-right HUD

## Screenshots

![Bloodstream Defender title screen](docs/screenshots/title-screen.png)

![Bloodstream Defender HUD and mission panel](docs/screenshots/gameplay-hud.png)

![Bloodstream Defender firing a Y-shaped antibody projectile](docs/screenshots/antibody-shot.png)

![Bloodstream Defender influenza enemy in the Influenza Bloom mission](docs/screenshots/influenza-enemy.png)

![Bloodstream Defender upgrade tree](docs/screenshots/upgrade-tree.png)

![Bloodstream Defender pause menu](docs/screenshots/pause-menu.png)

![Bloodstream Defender immune run summary](docs/screenshots/game-over-summary.png)

## Play Locally

This is a static HTML/CSS/JavaScript game. There is no build step and no package install.

```bash
git clone https://github.com/Niko2756/bloodstream-defender-game.git
cd bloodstream-defender-game
python3 -m http.server 8000
```

Then open:

```text
http://localhost:8000/
```

## Controls

Desktop controls:

- Move: `WASD` or arrow keys
- Fire antibodies: `Space`, click, or tap
- Chemotaxis Dash: `Shift` after choosing the Chemotaxis Dash upgrade
- Complement Pulse: `E`, `Q`, `Enter`, or `Numpad Enter` after choosing the Complement Pulse upgrade
- Pause/resume: `P`, `Escape`, or the pause button
- Restart: use the pause menu, which asks for confirmation, or the end screen

## Upgrade Flow

Each level is a vessel section with a mission objective and an immune-system term. After clearing the section, the game shows a completion screen with score, neutralized virions, remaining health, and the next mission preview.

The player then chooses one adaptation from a roguelite upgrade tree:

- Antibody Output: improves passive antibody firing with `Space`, click, or tap.
- Complement Defense: unlocks and improves the `E`/`Q` complement pulse.
- Cell Movement: unlocks and improves the `Shift` chemotaxis dash.

Later sections add escalating pressure. Influenza virions arrive in level 4 and can multiply when matching virions touch, while boss and mini-boss encounters begin around the end of later vessel sections.

## Current Features

- Level-based blood vessel sections with progress goals, escalating difficulty, and late-stage boss encounters
- Level-complete summary screens followed by a roguelite upgrade tree
- Upgrade branches that explain both the immune-system idea and the controls: passive antibody firing, `E`/`Q` complement pulse, and `Shift` chemotaxis dash
- Educational arcade missions that weave in immune terms like innate immunity, antigen, complement system, chemotaxis, phagocytosis, and adaptive immunity
- Swim-like movement with inertia and quick left/right surge animation
- Threat-based auto lock-on that prioritizes nearby incoming viruses without visible lock-on rings
- Homing antibody projectiles shaped more like small Y-shaped antibodies
- Influenza virions that multiply on contact and push outward to create urgent target-priority moments
- Budding virions that can split into smaller fragments when neutralized
- Generated white blood cell, virus, platelet, red blood cell, antibody, influenza, and boss sprites
- Multi-layer generated blood-vessel backgrounds with parallax scrolling
- Generated HUD ornament art for the mission panel, health bar, score, level display, pause button, ability status chips, and level progress bar
- Landscape mobile web controls with a left thumb joystick, hold-to-fire antibody button, one-tap Dash and Pulse buttons, and a portrait rotate prompt
- Pause menu with restart confirmation, level-complete screen, ImageGen-guided upgrade tree, and immune-run summary screen
- Layered Suno audio: menu/combat/boss/upgrade music, level-clear sting before upgrade music, boss-warning rumble before boss loop, bloodstream ambience, and combat sound effects for antibodies, hits, dash, complement pulse, player damage, player death, upgrade selection, and virus pops

## Project Structure

- `index.html` contains the game canvas and HUD markup.
- `styles.css` controls the page, HUD, start overlay, pause menu, level-complete screen, upgrade tree, and game-over report styling.
- `src/game.js` contains the game loop, movement, combat, spawning, drawing, audio, and state handling.
- `assets/` contains generated concept art, sprites, audio, and parallax background layers.
- `docs/` contains art direction notes, asset pipeline notes, parallax notes, and README screenshots.

## Development Notes

The prototype currently uses vanilla Canvas instead of a game engine so the early design can stay lightweight and easy to change. The visual target is a semi-accurate, semi-cartoony bloodstream: readable biology silhouettes, expressive enemies with eyes, rich red plasma layers, and arcade-friendly combat clarity.

The design direction is now a roguelite educational arcade game where each cleared vessel section teaches one immune-system idea and rewards the player with a practical antibody adaptation. The upgrade-tree look was guided by ImageGen concept mockups, then recreated in HTML/CSS so the final in-game text stays crisp, accessible, and easy to tune.
