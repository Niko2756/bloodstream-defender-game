extends Node2D

const BASE_SIZE := Vector2(1280.0, 720.0)
const TAU := PI * 2.0
const PLAYER_MAX_HEALTH := 100.0
const PLAYER_SPEED := 270.0
const PLAYER_ACCEL := 4.4
const PLAYER_DRAG := 3.2
const PLAYER_COLLISION_RADIUS := 34.0
const SHOT_SPEED := 780.0
const SHOT_LIFE := 2.4
const SHOT_HIT_RADIUS := 24.0
const SHOT_HOMING_STRENGTH := 7.5
const ENEMY_BASE_SPEED := 88.0
const LEVEL_CLEAR_DELAY := 0.7
const BOSS_WARNING_DURATION := 17.2
const BOSS_PRE_CLEAR_DURATION := 3.2
const MAX_UPGRADE_RANK := 4
const PULSE_BASE_RADIUS := 180.0
const PULSE_RADIUS_PER_RANK := 42.0
const PULSE_EDGE_GRACE := 10.0
const DANGER_MUSIC_TRIGGER_RATIO := 0.35
const DANGER_MUSIC_RESET_RATIO := 0.5
const RED_CELL_MAX_ACTIVE := 16
const PLATELET_MAX_ACTIVE := 5
const TOUCH_DEADZONE := 0.16
const TILT_DEADZONE := 0.08
const TILT_SENSITIVITY := 0.46
const MOBILE_JOYSTICK_CENTER := Vector2(138.0, 558.0)
const MOBILE_JOYSTICK_RADIUS := 76.0
const MOBILE_JOYSTICK_KNOB_RADIUS := 26.0
const MOBILE_JOYSTICK_TOUCH_RADIUS := 152.0
const MOBILE_JOYSTICK_DEADZONE := 0.13
const LOCK_TARGET_RANGE := 640.0
const LOCK_VERTICAL_RANGE := 245.0
const MOBILE_MAX_PARTICLES := 96
const DESKTOP_MAX_PARTICLES := 220
const MOBILE_PARTICLE_SCALE := 0.55
const MOBILE_PULSE_SEGMENT_SCALE := 0.55
const MOBILE_MAX_FPS := 30

const SPRITE_ATLAS := "res://assets/sprites/processed/bloodstream-asset-atlas-transparent-no-despill.png"
const INFLUENZA_SHEET := "res://assets/sprites/processed/influenza-virion-spritesheet.png"
const POX_BOSS_SHEET := "res://assets/sprites/processed/pox-brick-boss-spritesheet.png"
const ADENO_SHEET := "res://assets/sprites/processed/adenovirus-prism-spritesheet.png"
const FILO_SHEET := "res://assets/sprites/processed/filovirus-ribbon-spritesheet.png"
const HUD_GAME_SCORE_FRAME := "res://assets/ui/hud-game-score-frame.png"
const HUD_GAME_HEALTH_FRAME := "res://assets/ui/hud-game-health-frame.png"
const HUD_GAME_PAUSE_FRAME := "res://assets/ui/hud-game-pause-frame.png"
const HUD_GAME_LEVEL_FRAME := "res://assets/ui/hud-game-level-frame.png"
const HUD_ORN_SCORE := "res://assets/ui/hud-orn-score.png"
const HUD_ORN_HEALTH := "res://assets/ui/hud-orn-health.png"
const START_ASSET_SHEET := "res://assets/ui/start-screen-asset-sheet.png"
const PAUSE_COMPLETE_UI_SHEET := "res://assets/ui/pause-complete-ui-sheet.png"
const UPGRADE_TITLE_PLAQUE := "res://assets/ui/upgrade-title-plaque-clean.png"
const UPGRADE_MEDALLION_ANTIBODY := "res://assets/ui/upgrade-medallion-antibody.png"
const UPGRADE_MEDALLION_COMPLEMENT := "res://assets/ui/upgrade-medallion-complement.png"
const UPGRADE_MEDALLION_CHEMOTAXIS := "res://assets/ui/upgrade-medallion-chemotaxis.png"
const GAME_OVER_PANEL_ART := "res://assets/ui/game-over-summary-panel.png"
const COMPLETE_FRAME_REGION := Rect2(0, 28, 1088, 580)
const PAUSE_FRAME_REGION := Rect2(1100, 48, 410, 592)
const UI_BUTTON_FRAME_REGION := Rect2(70, 645, 868, 132)

const PARALLAX := [
	{"path": "res://assets/backgrounds/parallax/source/layer-00-far-vessel-wash.png", "speed": 0.06, "alpha": 1.0},
	{"path": "res://assets/backgrounds/parallax/processed/layer-01-mid-plasma-currents.png", "speed": 0.16, "alpha": 0.88},
	{"path": "res://assets/backgrounds/parallax/processed/layer-02-distant-red-cells-seam-clean.png", "speed": 0.24, "alpha": 0.62},
	{"path": "res://assets/backgrounds/parallax/processed/layer-02b-branch-openings.png", "speed": 0.34, "alpha": 0.64},
	{"path": "res://assets/backgrounds/parallax/processed/layer-03-foreground-vessel-walls.png", "speed": 0.62, "alpha": 1.0},
	{"path": "res://assets/backgrounds/parallax/processed/layer-04-foreground-floaters-seam-clean.png", "speed": 0.78, "alpha": 0.42},
]

const MOBILE_PARALLAX := [
	{"path": "res://assets/backgrounds/parallax/processed/mobile-composite-flat.png", "speed": 0.24, "alpha": 1.0},
]

const FRAMES := {
	"white_cell": [
		Rect2(45, 41, 184, 178),
		Rect2(284, 58, 221, 158),
		Rect2(590, 54, 224, 160),
		Rect2(865, 56, 156, 158),
		Rect2(1068, 64, 185, 150),
		Rect2(1312, 90, 179, 131),
	],
	"green_virus": [
		Rect2(132, 251, 198, 186),
		Rect2(423, 252, 197, 182),
		Rect2(705, 260, 185, 179),
		Rect2(972, 265, 182, 181),
	],
	"purple_virus": [
		Rect2(133, 465, 199, 189),
		Rect2(435, 467, 196, 186),
		Rect2(713, 471, 189, 182),
		Rect2(980, 479, 191, 173),
	],
	"red_cell": [
		Rect2(94, 674, 174, 132),
		Rect2(357, 693, 185, 101),
		Rect2(652, 698, 125, 96),
		Rect2(916, 701, 90, 101),
	],
	"platelet": [
		Rect2(60, 843, 222, 134),
		Rect2(349, 852, 145, 129),
		Rect2(555, 862, 142, 108),
	],
	"antibody": [
		Rect2(774, 892, 107, 62),
		Rect2(947, 892, 123, 62),
		Rect2(1125, 893, 139, 61),
		Rect2(1316, 892, 143, 62),
	],
	"influenza": [
		Rect2(117, 159, 396, 424),
		Rect2(621, 129, 392, 452),
		Rect2(1154, 173, 386, 407),
		Rect2(1653, 180, 395, 395),
	],
	"pox_boss": [
		Rect2(55, 176, 476, 339),
		Rect2(548, 176, 520, 356),
		Rect2(1101, 186, 513, 336),
		Rect2(1631, 143, 495, 409),
	],
	"adenovirus": [
		Rect2(117, 140, 408, 433),
		Rect2(604, 139, 482, 437),
		Rect2(1086, 134, 543, 452),
		Rect2(1629, 111, 427, 483),
	],
	"filovirus": [
		Rect2(53, 246, 490, 238),
		Rect2(543, 150, 510, 421),
		Rect2(1103, 203, 526, 343),
		Rect2(1629, 218, 490, 285),
	],
}

const MISSIONS := [
	{"name": "Innate Patrol", "term": "Innate immunity", "objective": "Neutralize free virions before they spread downstream.", "target": "virions", "goal": 5},
	{"name": "Antigen Sweep", "term": "Antigen", "objective": "Tag viral antigens so the immune response can recognize them.", "target": "antigens", "goal": 7},
	{"name": "Complement Cascade", "term": "Complement system", "objective": "Clear the viral cluster while avoiding platelet clots.", "target": "virions", "goal": 9},
	{"name": "Influenza Bloom", "term": "Viral replication", "objective": "Stop influenza virions before touching pairs make more copies.", "target": "influenza virions", "goal": 11},
]

const ENCOUNTERS := [
	{"name": "Pox-Brick Breach", "term": "Poxvirus", "objective": "Fight through a high-threat vessel section, then strip the pox armor plates and expose the glowing weak core.", "target": "virions", "boss_target": "pox boss", "encounter": "boss", "boss": "pox"},
	{"name": "Adenovirus Prism", "term": "Adenovirus", "objective": "Clear the viral surge, then time antibody shots for the exposed prism face between shield rotations.", "target": "virions", "boss_target": "adenovirus mini-boss", "encounter": "mini-boss", "boss": "adenovirus"},
	{"name": "Filovirus Ribbon", "term": "Filovirus", "objective": "Push through the bloodstream lanes, then dodge sweeping filament arcs and focus fire on the ribbon body.", "target": "virions", "boss_target": "filovirus boss", "encounter": "boss", "boss": "filovirus"},
	{"name": "Adenovirus Prism", "term": "Adenovirus", "objective": "Survive the late-vessel pressure, then crack the rotating prism shield.", "target": "virions", "boss_target": "adenovirus mini-boss", "encounter": "mini-boss", "boss": "adenovirus"},
]

const BOSS_PROFILES := {
	"pox": {"title": "Pox-Brick Boss", "group": "pox_boss", "sheet": POX_BOSS_SHEET, "radius": 86.0, "hp": 120.0, "score": 650, "damage": 28.0, "damage_scale": 0.38, "target_x": 0.73, "attack_interval": 2.2, "scale": 0.52},
	"adenovirus": {"title": "Adenovirus Prism", "group": "adenovirus", "sheet": ADENO_SHEET, "radius": 58.0, "hp": 56.0, "score": 360, "damage": 20.0, "damage_scale": 0.52, "target_x": 0.68, "attack_interval": 2.1, "scale": 0.36},
	"filovirus": {"title": "Filovirus Ribbon", "group": "filovirus", "sheet": FILO_SHEET, "radius": 74.0, "hp": 128.0, "score": 720, "damage": 24.0, "damage_scale": 0.46, "target_x": 0.64, "attack_interval": 2.7, "scale": 0.38},
}

const UPGRADES := {
	"rapid": {
		"term": "IgG antibodies",
		"title": "Rapid Antibody Factory",
		"controls": "Use: Space, click, or tap.",
		"body": "Shortens antibody cooldown. Later ranks release paired and triple Y-shaped antibodies.",
		"ranks": [
			"Rank 1: faster antibody firing",
			"Rank 2: paired antibodies",
			"Rank 3: stronger antibody hits",
			"Rank 4: triple antibody spread",
		],
	},
	"pulse": {
		"term": "Complement proteins",
		"title": "Complement Pulse",
		"controls": "Use: E, Q, or Enter.",
		"body": "Creates a radial complement burst that damages nearby pathogens and breaks platelets.",
		"ranks": [
			"Rank 1: unlock pulse",
			"Rank 2: larger damage ring",
			"Rank 3: shorter cooldown",
			"Rank 4: heavy nearby clear",
		],
	},
	"dash": {
		"term": "Chemotaxis",
		"title": "Chemotaxis Dash",
		"controls": "Use: Shift + movement.",
		"body": "Surges through crowded vessel sections and briefly slips past contact damage.",
		"ranks": [
			"Rank 1: unlock dash",
			"Rank 2: stronger surge",
			"Rank 3: faster recovery",
			"Rank 4: longer invulnerable slip",
		],
	},
}

const AUDIO := {
	"menu": {"path": "res://assets/audio/Menu music.mp3", "bus": "Music", "volume": -5.5},
	"combat": {"path": "res://assets/audio/Normal vessel combat loop.mp3", "bus": "Music", "volume": -7.5},
	"danger": {"path": "res://assets/audio/High-danger combat loop.mp3", "bus": "Music", "volume": -6.5},
	"boss": {"path": "res://assets/audio/Boss loop.mp3", "bus": "Music", "volume": -6.0},
	"upgrade": {"path": "res://assets/audio/Upgrade tree loop.mp3", "bus": "Music", "volume": -7.0},
	"ambience": {"path": "res://assets/audio/Bloodstream ambience.wav", "bus": "Music", "volume": -18.0},
	"shot": {"path": "res://assets/audio/Antibody shot.wav", "bus": "SFX", "volume": -5.5},
	"hit": {"path": "res://assets/audio/Antibody hit.wav", "bus": "SFX", "volume": -4.5},
	"pop": {"path": "res://assets/audio/Virus pop.wav", "bus": "SFX", "volume": -4.8},
	"swim_surge": {"path": "res://assets/audio/Chemotaxis dash.wav", "bus": "SFX", "volume": -7.0},
	"dash": {"path": "res://assets/audio/Chemotaxis dash upgraded.wav", "bus": "SFX", "volume": -3.8},
	"pulse": {"path": "res://assets/audio/Complement pulse.wav", "bus": "SFX", "volume": -3.2},
	"level_complete": {"path": "res://assets/audio/Level Complete Sting.wav", "bus": "SFX", "volume": -3.5},
	"boss_warning": {"path": "res://assets/audio/Boss warning rumble.mp3", "bus": "SFX", "volume": -3.5},
	"boss_hit": {"path": "res://assets/audio/Boss Hit.wav", "bus": "SFX", "volume": -3.6},
	"boss_defeated": {"path": "res://assets/audio/Boss defeated.mp3", "bus": "SFX", "volume": -4.0},
	"boss_phase": {"path": "res://assets/audio/Boss phase change.mp3", "bus": "SFX", "volume": -4.0},
	"budding_split": {"path": "res://assets/audio/Budding virus split.wav", "bus": "SFX", "volume": -4.2},
	"influenza_hit": {"path": "res://assets/audio/Influenza hit.wav", "bus": "SFX", "volume": -3.8},
	"influenza_replicate": {"path": "res://assets/audio/Influenza replication bloom.wav", "bus": "SFX", "volume": -4.2},
	"player_damage": {"path": "res://assets/audio/Player damage.wav", "bus": "SFX", "volume": -4.0},
	"player_death": {"path": "res://assets/audio/Player death.mp3", "bus": "SFX", "volume": -4.2},
	"platelet_hit": {"path": "res://assets/audio/Platelet or clot bump-crack.wav", "bus": "SFX", "volume": -4.6},
	"pause_open": {"path": "res://assets/audio/Pause open.wav", "bus": "SFX", "volume": -5.0},
	"pause_resume": {"path": "res://assets/audio/Pause resume.mp3", "bus": "SFX", "volume": -5.2},
	"restart_confirm": {"path": "res://assets/audio/Restart confirmation open.wav", "bus": "SFX", "volume": -5.0},
	"upgrade_hover": {"path": "res://assets/audio/Upgrade card hover.wav", "bus": "SFX", "volume": -9.5},
	"upgrade_selected": {"path": "res://assets/audio/Upgrade selected.wav", "bus": "SFX", "volume": -4.4},
	"ui_select": {"path": "res://assets/audio/ui_button_select.wav", "bus": "SFX", "volume": -6.5},
}

var textures = {}
var audio_streams = {}
var rng = RandomNumberGenerator.new()

var bg_root: Node2D
var game_stage_root: Node2D
var entity_root: Node2D
var fx_root: Node2D
var ui_layer: CanvasLayer
var ui_stage: Control
var start_panel: Control
var pause_panel: Control
var complete_panel: Control
var upgrade_panel: Control
var game_over_panel: Control
var hud: Control
var mobile_controls: Control
var mobile_fire_button: Button
var mobile_dash_button: Button
var mobile_pulse_button: Button
var mobile_tilt_button: Button
var mobile_calibrate_button: Button
var mobile_joystick_knob: Panel
var pause_restart_button: Button
var music_player: AudioStreamPlayer
var ambience_player: AudioStreamPlayer
var priority_sfx_player: AudioStreamPlayer
var boss_warning_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []

var score_label: Label
var health_bar: ProgressBar
var level_label: Label
var mission_label: Label
var mission_objective_label: Label
var target_label: Label
var progress_bar: ProgressBar
var dash_label: Label
var pulse_label: Label
var banner_label: Label
var upgrade_intro_label: Label
var upgrade_cards: Dictionary = {}
var game_over_values: Dictionary = {}
var game_over_subtitle_label: Label
var game_over_adaptations_label: Label

var running = false
var paused = false
var waiting_for_upgrade = false
var game_over = false
var music_muted = false
var sfx_muted = false
var tilt_enabled = false
var tilt_neutral = Vector2.ZERO
var tilt_has_calibration = false
var mobile_fire_held = false
var mobile_dash_requested = false
var mobile_pulse_requested = false
var mobile_move_pointer_id = -1
var mobile_mouse_move_active = false
var mobile_move_vector = Vector2.ZERO
var restart_confirm_pending = false
var restart_confirm_timer = 0.0
var current_music = ""
var pending_music = ""
var pending_music_timer = 0.0
var danger_music_active = false
var boss_warning_started = false
var boss_spawned = false
var boss_defeated = false
var boss_clear_timer = 0.0
var boss_warning_timer = 0.0
var boss_trigger_progress = 0.85
var level_clear_timer = 0.0
var banner_timer = 0.0
var scroll = 0.0
var level = 1
var level_length = 3200.0
var level_goal = 5
var level_kills = 0
var total_kills = 0
var sections_cleared = 0
var bosses_neutralized = 0
var score = 0
var run_time = 0.0
var active_mission = {}
var mobile_performance_mode = false
var _cached_visible_game_size := Vector2(-1.0, -1.0)

var upgrades = {"rapid": 0, "pulse": 0, "dash": 0}

var player = {
	"pos": Vector2(210, 360),
	"vel": Vector2.ZERO,
	"health": PLAYER_MAX_HEALTH,
	"shoot_cd": 0.0,
	"dash_cd": 0.0,
	"dash_timer": 0.0,
	"pulse_cd": 0.0,
	"pulse_timer": 0.0,
	"invulnerable": 0.0,
	"hurt_timer": 0.0,
	"sprite": null,
}
var player_facing_left = false
var horizontal_sound_input = 0
var dash_input_held = false
var enemies: Array[Dictionary] = []
var shots: Array[Dictionary] = []
var red_cells: Array[Dictionary] = []
var platelets: Array[Dictionary] = []
var particles: Array[Dictionary] = []
var active_pulses: Array[Dictionary] = []
var next_enemy_id = 1

var spawn_enemy_timer = 0.0
var spawn_red_timer = 0.2
var spawn_platelet_timer = 3.5
var shot_sound_timer = 0.0
var player_damage_sound_timer = 0.0
var platelet_hit_sound_timer = 0.0
var ui_hover_sound_timer = 0.0
var dash_trail_timer = 0.0
var lock_target_id = -1

func _ready() -> void:
	rng.randomize()
	mobile_performance_mode = _is_mobile_performance_target()
	if mobile_performance_mode:
		Engine.max_fps = MOBILE_MAX_FPS
	_load_assets()
	_setup_scene()
	_setup_ui()
	_setup_audio()
	_reset_run(false)
	_show_start()
	if _cmdline_has("--autostart-run"):
		_start_run()


func _process(delta: float) -> void:
	if running and not paused and not waiting_for_upgrade and not game_over:
		run_time += delta
		scroll += 185.0 * delta
		_update_level_flow(delta)
		_update_player(delta)
		_update_spawning(delta)
		_update_shots(delta)
		_update_enemies(delta)
		_update_props(delta)
		_update_active_pulses(delta)
		_update_particles(delta)
		_update_collisions()
		_update_lock_target()
	elif running and not paused and waiting_for_upgrade and not game_over and level_clear_timer > 0.0:
		_update_level_complete_pending(delta)
	_update_banner(delta)
	_update_pending_music(delta)
	_refresh_gameplay_music()
	_update_viewport_layout()
	_update_backgrounds()
	_update_hud()
	_update_upgrade_pip_pulse()
	_update_mobile_controls()
	_sync_ambience()
	if restart_confirm_timer > 0.0:
		restart_confirm_timer = maxf(0.0, restart_confirm_timer - delta)
		if restart_confirm_timer == 0.0:
			restart_confirm_pending = false
			if pause_restart_button != null:
				pause_restart_button.text = "Restart Run"
	shot_sound_timer = maxf(0.0, shot_sound_timer - delta)
	player_damage_sound_timer = maxf(0.0, player_damage_sound_timer - delta)
	platelet_hit_sound_timer = maxf(0.0, platelet_hit_sound_timer - delta)
	ui_hover_sound_timer = maxf(0.0, ui_hover_sound_timer - delta)


func _input(event: InputEvent) -> void:
	if (event is InputEventMouseButton or event is InputEventMouseMotion) and _handle_mobile_move_input(event):
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE or event.keycode == KEY_P:
			_toggle_pause()
		if event.keycode == KEY_SPACE and running and not paused and not waiting_for_upgrade and not game_over:
			_fire_antibodies(true)
		if event.keycode in [KEY_Q, KEY_E, KEY_ENTER, KEY_KP_ENTER] and running and not paused and not waiting_for_upgrade and not game_over:
			_trigger_pulse()
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if running and not paused and not waiting_for_upgrade and not game_over and not _point_inside_active_ui(event.position) and not _point_inside_mobile_joystick_area(event.position):
			_fire_antibodies(true)


func _cmdline_has(flag: String) -> bool:
	for arg in OS.get_cmdline_args():
		if arg == flag:
			return true
	for arg in OS.get_cmdline_user_args():
		if arg == flag:
			return true
	return false


func _unhandled_input(event: InputEvent) -> void:
	if _handle_mobile_move_input(event):
		return
	if event is InputEventScreenTouch:
		if not _gameplay_inputs_active():
			mobile_fire_held = false
			return
		if _point_inside_active_ui(event.position) or _point_inside_mobile_joystick_area(event.position):
			return
		mobile_fire_held = event.pressed
		if event.pressed:
			_fire_antibodies(true)


func _load_assets() -> void:
	var paths = [
		SPRITE_ATLAS,
		INFLUENZA_SHEET,
		POX_BOSS_SHEET,
		ADENO_SHEET,
		FILO_SHEET,
		HUD_GAME_SCORE_FRAME,
		HUD_GAME_HEALTH_FRAME,
		HUD_GAME_PAUSE_FRAME,
		HUD_GAME_LEVEL_FRAME,
		HUD_ORN_SCORE,
		HUD_ORN_HEALTH,
		START_ASSET_SHEET,
		PAUSE_COMPLETE_UI_SHEET,
		UPGRADE_TITLE_PLAQUE,
		UPGRADE_MEDALLION_ANTIBODY,
		UPGRADE_MEDALLION_COMPLEMENT,
		UPGRADE_MEDALLION_CHEMOTAXIS,
		GAME_OVER_PANEL_ART,
	]
	for layer in _background_layers():
		paths.append(layer.path)
	for path in paths:
		textures[path] = load(path)
	for key in AUDIO:
		var stream = load(AUDIO[key].path)
		_prepare_audio_stream(stream, key)
		audio_streams[key] = stream


func _prepare_audio_stream(stream: AudioStream, key: String) -> void:
	if stream == null:
		push_warning("Missing Godot audio stream: %s" % AUDIO[key].path)
		return
	if AUDIO[key].bus == "Music":
		if stream is AudioStreamMP3:
			stream.loop = true
		elif stream is AudioStreamWAV:
			stream.loop_mode = AudioStreamWAV.LOOP_FORWARD


func _setup_scene() -> void:
	bg_root = Node2D.new()
	bg_root.name = "ParallaxBackground"
	add_child(bg_root)
	game_stage_root = Node2D.new()
	game_stage_root.name = "GameplayStage"
	add_child(game_stage_root)
	entity_root = Node2D.new()
	entity_root.name = "Entities"
	game_stage_root.add_child(entity_root)
	fx_root = Node2D.new()
	fx_root.name = "Effects"
	game_stage_root.add_child(fx_root)
	var background_layers = _background_layers()
	for i in background_layers.size():
		var layer_data: Dictionary = background_layers[i]
		var holder = Node2D.new()
		holder.name = "Layer%s" % i
		holder.set_meta("speed", layer_data.speed)
		holder.set_meta("texture_width", 1280.0)
		bg_root.add_child(holder)
		for copy in _background_tile_copy_count():
			var sprite = Sprite2D.new()
			sprite.texture = textures[layer_data.path]
			sprite.centered = false
			sprite.modulate.a = layer_data.alpha
			sprite.z_index = i
			holder.add_child(sprite)
	player.sprite = _make_sprite(SPRITE_ATLAS, FRAMES.white_cell[0], player.pos, 0.42)
	player.sprite.z_index = 20
	entity_root.add_child(player.sprite)


func _setup_audio() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.name = "MusicPlayer"
	music_player.bus = "Music"
	add_child(music_player)
	ambience_player = AudioStreamPlayer.new()
	ambience_player.name = "BloodstreamAmbience"
	ambience_player.bus = "Music"
	add_child(ambience_player)
	priority_sfx_player = AudioStreamPlayer.new()
	priority_sfx_player.name = "PrioritySfx"
	priority_sfx_player.bus = "SFX"
	add_child(priority_sfx_player)
	boss_warning_player = AudioStreamPlayer.new()
	boss_warning_player.name = "BossWarningSfx"
	boss_warning_player.bus = "SFX"
	add_child(boss_warning_player)
	for i in 16:
		var p = AudioStreamPlayer.new()
		p.name = "Sfx%s" % i
		p.bus = "SFX"
		add_child(p)
		sfx_players.append(p)


func _setup_ui() -> void:
	ui_layer = CanvasLayer.new()
	ui_layer.name = "UI"
	add_child(ui_layer)
	ui_stage = Control.new()
	ui_stage.name = "UIStage"
	ui_stage.position = Vector2.ZERO
	ui_stage.size = BASE_SIZE
	ui_stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_layer.add_child(ui_stage)
	hud = Control.new()
	hud.name = "HUD"
	hud.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui_stage.add_child(hud)

	var score_box = _hud_box(HUD_GAME_SCORE_FRAME, Vector2(22, 12), Vector2(210, 84))
	hud.add_child(score_box)
	score_box.add_child(_hud_texture(HUD_ORN_SCORE, Vector2(16, 15), Vector2(54, 54)))
	var score_title = _label("SCORE", Vector2(82, 20), 11, Color(0.42, 1.0, 1.0))
	score_title.add_theme_constant_override("outline_size", 2)
	score_title.add_theme_color_override("font_outline_color", Color(0.0, 0.02, 0.04, 0.9))
	score_box.add_child(score_title)
	score_label = _label("0", Vector2(82, 36), 24, Color(1.0, 0.96, 0.78))
	score_label.size = Vector2(92, 30)
	score_label.add_theme_constant_override("outline_size", 3)
	score_label.add_theme_color_override("font_outline_color", Color(0.04, 0.0, 0.03, 0.88))
	score_box.add_child(score_label)

	var health_box = _hud_box(HUD_GAME_HEALTH_FRAME, Vector2(250, 12), Vector2(450, 84))
	hud.add_child(health_box)
	health_box.add_child(_hud_texture(HUD_ORN_HEALTH, Vector2(14, 15), Vector2(54, 54)))
	health_bar = ProgressBar.new()
	health_bar.position = Vector2(94, 31)
	health_bar.size = Vector2(318, 20)
	health_bar.max_value = PLAYER_MAX_HEALTH
	health_bar.show_percentage = false
	_style_progress_bar(health_bar, Color(0.52, 1.0, 1.0), Color(1.0, 0.87, 0.42))
	health_box.add_child(health_bar)

	var level_box = _hud_box(HUD_GAME_LEVEL_FRAME, Vector2(1181, 14), Vector2(78, 76))
	hud.add_child(level_box)
	var level_title = _label("LEVEL", Vector2(0, 18), 10, Color(1.0, 0.86, 0.42))
	level_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_title.size = Vector2(78, 16)
	level_title.add_theme_constant_override("outline_size", 2)
	level_title.add_theme_color_override("font_outline_color", Color(0.08, 0.0, 0.02, 0.9))
	level_box.add_child(level_title)
	level_label = _label("1", Vector2(0, 34), 24, Color(1.0, 0.96, 0.78))
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	level_label.size = Vector2(78, 30)
	level_label.add_theme_constant_override("outline_size", 3)
	level_label.add_theme_color_override("font_outline_color", Color(0.08, 0.0, 0.02, 0.9))
	level_box.add_child(level_label)

	var pause_box = _hud_box(HUD_GAME_PAUSE_FRAME, Vector2(1062, 14), Vector2(106, 58))
	hud.add_child(pause_box)
	var pause_label = _label("Pause", Vector2(0, 5), 15, Color(0.86, 1.0, 1.0))
	pause_label.size = Vector2(106, 48)
	pause_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pause_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	pause_label.add_theme_constant_override("outline_size", 3)
	pause_label.add_theme_color_override("font_outline_color", Color(0.0, 0.02, 0.04, 0.9))
	pause_box.add_child(pause_label)
	var pause_button = Button.new()
	pause_button.text = ""
	pause_button.position = Vector2(1062, 14)
	pause_button.size = Vector2(106, 58)
	_style_hud_overlay_button(pause_button)
	pause_button.pressed.connect(_toggle_pause)
	hud.add_child(pause_button)

	progress_bar = ProgressBar.new()
	progress_bar.position = Vector2(230, 670)
	progress_bar.size = Vector2(820, 14)
	progress_bar.max_value = 100.0
	progress_bar.show_percentage = false
	_style_progress_bar(progress_bar, Color(0.3, 1.0, 1.0), Color(1.0, 0.83, 0.3))
	hud.add_child(progress_bar)
	_update_viewport_layout()

	banner_label = _label("", Vector2(390, 112), 24, Color(1.0, 0.96, 0.88))
	banner_label.size = Vector2(500, 44)
	banner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner_label.visible = false
	hud.add_child(banner_label)

	start_panel = _make_start_panel()
	pause_panel = _make_pause_panel()
	complete_panel = _make_complete_panel()
	upgrade_panel = _make_upgrade_panel()
	game_over_panel = _make_game_over_panel()
	mobile_controls = _make_mobile_controls()
	ui_stage.add_child(start_panel)
	ui_stage.add_child(pause_panel)
	ui_stage.add_child(complete_panel)
	ui_stage.add_child(upgrade_panel)
	ui_stage.add_child(game_over_panel)
	ui_stage.add_child(mobile_controls)


func _hud_texture(path: String, pos: Vector2, size: Vector2) -> Sprite2D:
	return _ui_sprite(path, pos, size)


func _sheet_texture(path: String, region: Rect2, pos: Vector2, size: Vector2, z := 0, alpha := 1.0) -> TextureRect:
	var atlas = AtlasTexture.new()
	atlas.atlas = textures.get(path, null)
	atlas.region = region
	var rect = TextureRect.new()
	rect.texture = atlas
	rect.position = pos
	rect.custom_minimum_size = size
	rect.size = size
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_SCALE
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.z_index = z
	rect.modulate.a = alpha
	return rect


func _ui_sprite(path: String, pos: Vector2, size: Vector2, z := 0, alpha := 1.0) -> Sprite2D:
	var sprite = Sprite2D.new()
	sprite.texture = textures.get(path, null)
	sprite.centered = false
	sprite.position = pos
	sprite.z_index = z
	sprite.modulate.a = alpha
	if sprite.texture != null:
		var tex_size = sprite.texture.get_size()
		if tex_size.x > 0.0 and tex_size.y > 0.0:
			sprite.scale = Vector2(size.x / tex_size.x, size.y / tex_size.y)
	return sprite


func _sheet_sprite(path: String, region: Rect2, pos: Vector2, size: Vector2, z := 0, alpha := 1.0) -> Sprite2D:
	var sprite = Sprite2D.new()
	sprite.texture = textures.get(path, null)
	sprite.region_enabled = true
	sprite.region_rect = region
	sprite.centered = false
	sprite.position = pos
	sprite.z_index = z
	sprite.modulate.a = alpha
	if region.size.x > 0.0 and region.size.y > 0.0:
		sprite.scale = Vector2(size.x / region.size.x, size.y / region.size.y)
	return sprite


func _hud_box(path: String, pos: Vector2, size: Vector2) -> Control:
	var box = Control.new()
	box.position = pos
	box.size = size
	box.custom_minimum_size = Vector2.ZERO
	box.clip_contents = true
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(_hud_texture(path, Vector2.ZERO, size))
	return box


func _hud_panel(pos: Vector2, size: Vector2, icon_path := "", icon_pos := Vector2.ZERO, icon_size := Vector2.ZERO) -> Panel:
	var panel = Panel.new()
	panel.position = pos
	panel.size = size
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.01, 0.04, 0.66)
	style.border_color = Color(0.25, 0.95, 1.0, 0.44)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	panel.add_theme_stylebox_override("panel", style)
	if icon_path != "" and icon_size != Vector2.ZERO:
		panel.add_child(_hud_texture(icon_path, icon_pos, icon_size))
	return panel


func _hud_chip(pos: Vector2, size: Vector2) -> Panel:
	var chip = Panel.new()
	chip.position = pos
	chip.size = size
	chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.02, 0.07, 0.72)
	style.border_color = Color(0.85, 0.72, 0.36, 0.42)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	chip.add_theme_stylebox_override("panel", style)
	return chip


func _hud_medallion(parent: Control, pos: Vector2, size: Vector2, text: String, accent: Color) -> void:
	var badge = Panel.new()
	badge.position = pos
	badge.size = size
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.02, 0.12, 0.15, 0.82)
	style.border_color = accent.lerp(Color(1.0, 0.82, 0.28), 0.22)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	var radius = int(size.x * 0.5)
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	badge.add_theme_stylebox_override("panel", style)
	parent.add_child(badge)
	var label = _label(text, Vector2.ZERO, 13, accent)
	label.size = size
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	badge.add_child(label)


func _panel(pos: Vector2, size: Vector2, color: Color) -> Panel:
	var panel = Panel.new()
	panel.position = pos
	panel.size = size
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = Color(0.1, 0.85, 0.92, 0.55)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	panel.add_theme_stylebox_override("panel", style)
	return panel


func _button_box(bg: Color, border: Color, radius := 8) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style


func _style_button(button: Button, variant := "primary") -> void:
	button.focus_mode = Control.FOCUS_NONE
	var base = Color(0.10, 0.74, 0.82, 0.98)
	var hover = Color(0.26, 0.96, 1.0, 1.0)
	var pressed = Color(0.05, 0.48, 0.62, 1.0)
	var border = Color(0.72, 1.0, 1.0, 0.95)
	var font = Color(0.02, 0.08, 0.1, 1.0)
	if variant == "secondary":
		base = Color(0.06, 0.22, 0.28, 0.94)
		hover = Color(0.1, 0.38, 0.46, 1.0)
		pressed = Color(0.03, 0.16, 0.22, 1.0)
		border = Color(0.34, 0.98, 1.0, 0.75)
		font = Color(0.82, 1.0, 1.0, 1.0)
	elif variant == "danger":
		base = Color(0.20, 0.02, 0.08, 0.94)
		hover = Color(0.38, 0.05, 0.12, 1.0)
		pressed = Color(0.11, 0.01, 0.05, 1.0)
		border = Color(1.0, 0.52, 0.42, 0.72)
		font = Color(1.0, 0.92, 0.82, 1.0)
	button.add_theme_stylebox_override("normal", _button_box(base, border))
	button.add_theme_stylebox_override("hover", _button_box(hover, Color(1.0, 0.9, 0.42, 0.95)))
	button.add_theme_stylebox_override("pressed", _button_box(pressed, border))
	button.add_theme_stylebox_override("disabled", _button_box(Color(0.06, 0.05, 0.06, 0.55), Color(0.4, 0.34, 0.36, 0.48)))
	button.add_theme_color_override("font_color", font)
	button.add_theme_color_override("font_hover_color", Color(1.0, 0.97, 0.78, 1.0) if variant != "primary" else Color(0.02, 0.08, 0.1, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(1.0, 0.96, 0.84, 1.0))
	button.add_theme_color_override("font_disabled_color", Color(0.65, 0.56, 0.6, 0.82))
	button.add_theme_font_size_override("font_size", 16)
	button.mouse_entered.connect(_play_ui_hover)
	button.pressed.connect(func() -> void: _play_sfx("ui_select"))


func _style_hud_overlay_button(button: Button) -> void:
	button.focus_mode = Control.FOCUS_NONE
	var normal = StyleBoxFlat.new()
	normal.bg_color = Color(0.0, 0.0, 0.0, 0.0)
	var hover = StyleBoxFlat.new()
	hover.bg_color = Color(0.18, 0.95, 1.0, 0.12)
	hover.border_color = Color(0.72, 1.0, 1.0, 0.35)
	hover.border_width_left = 1
	hover.border_width_top = 1
	hover.border_width_right = 1
	hover.border_width_bottom = 1
	hover.corner_radius_top_left = 24
	hover.corner_radius_top_right = 24
	hover.corner_radius_bottom_left = 24
	hover.corner_radius_bottom_right = 24
	var pressed = StyleBoxFlat.new()
	pressed.bg_color = Color(0.06, 0.42, 0.52, 0.18)
	pressed.corner_radius_top_left = 24
	pressed.corner_radius_top_right = 24
	pressed.corner_radius_bottom_left = 24
	pressed.corner_radius_bottom_right = 24
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("focus", normal)
	button.add_theme_color_override("font_color", Color.TRANSPARENT)
	button.mouse_entered.connect(_play_ui_hover)
	button.pressed.connect(func() -> void: _play_sfx("ui_select"))


func _style_start_button(button: Button) -> void:
	button.focus_mode = Control.FOCUS_NONE
	var normal = StyleBoxFlat.new()
	normal.bg_color = Color(0.02, 0.08, 0.1, 0.02)
	normal.border_width_left = 0
	normal.border_width_top = 0
	normal.border_width_right = 0
	normal.border_width_bottom = 0
	var hover = StyleBoxFlat.new()
	hover.bg_color = Color(0.16, 0.86, 0.94, 0.18)
	hover.border_color = Color(0.62, 1.0, 1.0, 0.48)
	hover.border_width_left = 2
	hover.border_width_top = 2
	hover.border_width_right = 2
	hover.border_width_bottom = 2
	hover.corner_radius_top_left = 18
	hover.corner_radius_top_right = 18
	hover.corner_radius_bottom_left = 18
	hover.corner_radius_bottom_right = 18
	var pressed = StyleBoxFlat.new()
	pressed.bg_color = Color(0.08, 0.42, 0.52, 0.28)
	pressed.corner_radius_top_left = 18
	pressed.corner_radius_top_right = 18
	pressed.corner_radius_bottom_left = 18
	pressed.corner_radius_bottom_right = 18
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("focus", normal)
	button.add_theme_color_override("font_color", Color(1.0, 0.96, 0.82, 1.0))
	button.add_theme_color_override("font_hover_color", Color(0.82, 1.0, 1.0, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(1.0, 0.9, 0.42, 1.0))
	button.add_theme_font_size_override("font_size", 28)
	button.add_theme_constant_override("outline_size", 5)
	button.add_theme_color_override("font_outline_color", Color(0.02, 0.0, 0.02, 0.94))
	button.mouse_entered.connect(_play_ui_hover)
	button.pressed.connect(func() -> void: _play_sfx("ui_select"))


func _style_art_button(button: Button, font_size := 20) -> void:
	button.focus_mode = Control.FOCUS_NONE
	var normal = StyleBoxFlat.new()
	normal.bg_color = Color(0.02, 0.02, 0.03, 0.03)
	var hover = StyleBoxFlat.new()
	hover.bg_color = Color(0.18, 0.90, 1.0, 0.16)
	hover.border_color = Color(0.72, 1.0, 1.0, 0.48)
	hover.border_width_left = 2
	hover.border_width_top = 2
	hover.border_width_right = 2
	hover.border_width_bottom = 2
	hover.corner_radius_top_left = 18
	hover.corner_radius_top_right = 18
	hover.corner_radius_bottom_left = 18
	hover.corner_radius_bottom_right = 18
	var pressed = StyleBoxFlat.new()
	pressed.bg_color = Color(0.08, 0.42, 0.52, 0.26)
	pressed.corner_radius_top_left = 18
	pressed.corner_radius_top_right = 18
	pressed.corner_radius_bottom_left = 18
	pressed.corner_radius_bottom_right = 18
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("focus", normal)
	button.add_theme_color_override("font_color", Color(1.0, 0.96, 0.82, 1.0))
	button.add_theme_color_override("font_hover_color", Color(0.78, 1.0, 1.0, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(1.0, 0.9, 0.44, 1.0))
	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_constant_override("outline_size", 4)
	button.add_theme_color_override("font_outline_color", Color(0.01, 0.0, 0.02, 0.96))
	button.mouse_entered.connect(_play_ui_hover)
	button.pressed.connect(func() -> void: _play_sfx("ui_select"))


func _add_art_button(parent: Control, text: String, pos: Vector2, size: Vector2, callback: Callable, font_size := 20) -> Button:
	var frame_pad = Vector2(20, 10)
	var frame = _sheet_sprite(PAUSE_COMPLETE_UI_SHEET, UI_BUTTON_FRAME_REGION, pos - frame_pad, size + frame_pad * 2.0, 0, 0.96)
	parent.add_child(frame)
	var button = Button.new()
	button.text = text
	button.position = pos
	button.size = size
	_style_art_button(button, font_size)
	if callback.is_valid():
		button.pressed.connect(callback)
	parent.add_child(button)
	return button


func _style_progress_bar(bar: ProgressBar, start_color: Color, end_color: Color) -> void:
	var bg = StyleBoxFlat.new()
	bg.bg_color = Color(0.04, 0.01, 0.04, 0.74)
	bg.border_color = Color(0.28, 0.95, 1.0, 0.46)
	bg.border_width_left = 1
	bg.border_width_top = 1
	bg.border_width_right = 1
	bg.border_width_bottom = 1
	bg.corner_radius_top_left = 9
	bg.corner_radius_top_right = 9
	bg.corner_radius_bottom_left = 9
	bg.corner_radius_bottom_right = 9
	var fill = StyleBoxFlat.new()
	fill.bg_color = start_color.lerp(end_color, 0.5)
	fill.corner_radius_top_left = 8
	fill.corner_radius_top_right = 8
	fill.corner_radius_bottom_left = 8
	fill.corner_radius_bottom_right = 8
	bar.add_theme_stylebox_override("background", bg)
	bar.add_theme_stylebox_override("fill", fill)


func _label(text: String, pos: Vector2, font_size: int, color := Color(1.0, 0.96, 0.88)) -> Label:
	var label = Label.new()
	label.text = text
	label.position = pos
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label


func _overlay_panel(title: String, body: String, action: String, callback: Callable) -> Control:
	var root = Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	var shade = ColorRect.new()
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.02, 0.0, 0.02, 0.58)
	root.add_child(shade)
	var panel = _panel(Vector2(390, 170), Vector2(500, 340), Color(0.11, 0.01, 0.05, 0.92))
	root.add_child(panel)
	var title_label = _label(title, Vector2(36, 34), 48)
	title_label.name = "Title"
	title_label.size = Vector2(428, 64)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(title_label)
	var body_label = _label(body, Vector2(40, 122), 21, Color(0.82, 1.0, 0.86))
	body_label.name = "Body"
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	body_label.size = Vector2(420, 110)
	panel.add_child(body_label)
	var button = Button.new()
	button.name = "ActionButton"
	button.text = action
	button.position = Vector2(145, 250)
	button.size = Vector2(210, 62)
	_style_button(button, "primary")
	button.pressed.connect(callback)
	panel.add_child(button)
	root.visible = false
	return root


func _make_complete_panel() -> Control:
	var root = Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	var shade = ColorRect.new()
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.02, 0.0, 0.02, 0.56)
	root.add_child(shade)

	var panel = Control.new()
	panel.name = "Panel"
	panel.position = Vector2(250, 134)
	panel.size = Vector2(780, 420)
	root.add_child(panel)

	var frame = _sheet_sprite(PAUSE_COMPLETE_UI_SHEET, COMPLETE_FRAME_REGION, Vector2(0, -20), Vector2(780, 420), 0, 0.98)
	panel.add_child(frame)

	var title_label = _label("Level Complete", Vector2(72, 94), 46)
	title_label.name = "Title"
	title_label.size = Vector2(636, 58)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_constant_override("outline_size", 7)
	title_label.add_theme_color_override("font_outline_color", Color(0.10, 0.01, 0.04, 0.96))
	panel.add_child(title_label)

	var body_label = _label("", Vector2(150, 176), 20, Color(0.88, 1.0, 0.9))
	body_label.name = "Body"
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	body_label.size = Vector2(480, 126)
	body_label.add_theme_constant_override("outline_size", 4)
	body_label.add_theme_color_override("font_outline_color", Color(0.02, 0.0, 0.02, 0.94))
	panel.add_child(body_label)

	var button = _add_art_button(panel, "", Vector2(266, 324), Vector2(248, 48), _open_upgrade_screen, 18)
	button.name = "ActionButton"
	var button_label = _label("Choose Adaptation", button.position + Vector2(7, 0), 18, Color(1.0, 0.96, 0.82))
	button_label.name = "ActionButtonLabel"
	button_label.size = button.size
	button_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	button_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	button_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button_label.add_theme_constant_override("outline_size", 4)
	button_label.add_theme_color_override("font_outline_color", Color(0.01, 0.0, 0.02, 0.96))
	panel.add_child(button_label)

	root.visible = false
	return root


func _make_start_panel() -> Control:
	var root = Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)

	var shade = ColorRect.new()
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.02, 0.0, 0.02, 0.42)
	root.add_child(shade)

	var plaque = _sheet_sprite(START_ASSET_SHEET, Rect2(132, 16, 1268, 372), Vector2(240, 96), Vector2(800, 235), 2, 0.98)
	root.add_child(plaque)

	var title = _label("Bloodstream Defender", Vector2(228, 190), 48, Color(1.0, 0.96, 0.84))
	title.z_index = 5
	title.size = Vector2(824, 80)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_constant_override("outline_size", 6)
	title.add_theme_color_override("font_outline_color", Color(0.22, 0.02, 0.04, 0.96))
	root.add_child(title)

	var start_frame = _sheet_sprite(START_ASSET_SHEET, Rect2(292, 414, 920, 190), Vector2(450, 510), Vector2(380, 78), 2, 0.98)
	root.add_child(start_frame)

	var button = Button.new()
	button.name = "ActionButton"
	button.text = "Run Game"
	button.z_index = 5
	button.position = Vector2(510, 523)
	button.size = Vector2(260, 52)
	_style_start_button(button)
	button.pressed.connect(_start_run)
	root.add_child(button)

	root.visible = false
	return root


func _make_pause_panel() -> Control:
	var root = Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	var shade = ColorRect.new()
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.02, 0.0, 0.02, 0.58)
	root.add_child(shade)

	var panel = Control.new()
	panel.name = "Panel"
	panel.position = Vector2(462, 104)
	panel.size = Vector2(356, 500)
	root.add_child(panel)
	var frame = _sheet_sprite(PAUSE_COMPLETE_UI_SHEET, PAUSE_FRAME_REGION, Vector2(0, -18), Vector2(356, 514), 0, 0.98)
	panel.add_child(frame)

	var title = _label("Paused", Vector2(16, 60), 48)
	title.name = "Title"
	title.size = Vector2(296, 58)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_constant_override("outline_size", 7)
	title.add_theme_color_override("font_outline_color", Color(0.08, 0.0, 0.03, 0.96))
	panel.add_child(title)

	var button_size = Vector2(192, 42)
	var resume_button = _add_art_button(panel, "Resume", Vector2(64, 142), button_size, _toggle_pause, 17)
	resume_button.name = "ActionButton"
	var audio_label = _label("AUDIO", Vector2(104, 202), 13, Color(0.45, 1.0, 1.0))
	audio_label.size = Vector2(120, 20)
	audio_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(audio_label)
	var music_button = _add_art_button(panel, "Music: On", Vector2(62, 228), button_size, Callable(), 15)
	music_button.pressed.connect(func() -> void:
		_set_music_muted(not music_muted)
		music_button.text = "Music: Off" if music_muted else "Music: On"
	)
	var sfx_button = _add_art_button(panel, "Effects: On", Vector2(62, 280), button_size, Callable(), 15)
	sfx_button.pressed.connect(func() -> void:
		_set_sfx_muted(not sfx_muted)
		sfx_button.text = "Effects: Off" if sfx_muted else "Effects: On"
	)
	if _should_show_mobile_controls():
		mobile_tilt_button = _add_art_button(panel, "Tilt: Off", Vector2(45, 332), Vector2(108, 38), _toggle_tilt_mode, 13)
		mobile_calibrate_button = _add_art_button(panel, "Calibrate", Vector2(169, 332), Vector2(108, 38), _calibrate_tilt, 13)
	var restart_button = _add_art_button(panel, "Restart Run", Vector2(64, 398), button_size, Callable(), 15)
	restart_button.pressed.connect(_request_restart_confirmation)
	pause_restart_button = restart_button
	root.visible = false
	return root


func _make_upgrade_panel() -> Control:
	upgrade_cards.clear()
	var root = Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	var shade = ColorRect.new()
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.02, 0.0, 0.02, 0.68)
	root.add_child(shade)

	var panel = Control.new()
	panel.name = "Panel"
	panel.position = Vector2(120, 46)
	panel.size = Vector2(1040, 610)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(panel)

	var plaque = _ui_sprite(UPGRADE_TITLE_PLAQUE, Vector2(142, 18), Vector2(756, 176), 1, 0.95)
	panel.add_child(plaque)
	upgrade_intro_label = _label("", Vector2(200, 154), 15, Color(1.0, 0.94, 0.84))
	upgrade_intro_label.size = Vector2(640, 24)
	upgrade_intro_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(upgrade_intro_label)
	_add_upgrade_connector(panel, [Vector2(520, 178), Vector2(520, 204)])
	_add_upgrade_connector(panel, [Vector2(210, 204), Vector2(830, 204)])
	_add_upgrade_connector(panel, [Vector2(210, 204), Vector2(210, 234)])
	_add_upgrade_connector(panel, [Vector2(520, 204), Vector2(520, 234)])
	_add_upgrade_connector(panel, [Vector2(830, 204), Vector2(830, 234)])
	var x_positions = [70, 385, 700]
	var ids = ["rapid", "pulse", "dash"]
	for i in ids.size():
		var id: String = ids[i]
		var branch_label = _label(["ANTIBODY OUTPUT", "COMPLEMENT DEFENSE", "CELL MOVEMENT"][i], Vector2(x_positions[i] + 8, 222), 13, Color(0.76, 1.0, 1.0))
		branch_label.size = Vector2(260, 28)
		branch_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		panel.add_child(branch_label)
		var card = _panel(Vector2(x_positions[i], 292), Vector2(276, 270), Color(0.04, 0.01, 0.07, 0.88))
		card.set_meta("upgrade_id", id)
		card.mouse_filter = Control.MOUSE_FILTER_STOP
		card.mouse_entered.connect(_play_ui_hover)
		_apply_upgrade_card_style(card, id, false)
		panel.add_child(card)
		var medallion = _ui_sprite(_upgrade_medallion_path(id), Vector2(x_positions[i] + 112, 254), Vector2(52, 52), 8, 0.96)
		panel.add_child(medallion)
		var term_label = _label(UPGRADES[id].term.to_upper(), Vector2(24, 18), 11, _branch_accent(id))
		term_label.size = Vector2(228, 18)
		term_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		term_label.clip_text = true
		card.add_child(term_label)
		var title_label = _label(UPGRADES[id].title, Vector2(20, 42), 20)
		title_label.name = "UpgradeTitle"
		title_label.size = Vector2(236, 48)
		title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		title_label.autowrap_mode = TextServer.AUTOWRAP_WORD
		title_label.clip_text = true
		card.add_child(title_label)
		var control_label = _label(UPGRADES[id].controls, Vector2(26, 96), 12, Color(0.66, 1.0, 1.0))
		control_label.name = "ControlLabel"
		control_label.size = Vector2(224, 32)
		control_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		control_label.autowrap_mode = TextServer.AUTOWRAP_WORD
		control_label.clip_text = true
		card.add_child(control_label)
		var body_label = _label(_compact_upgrade_body(id), Vector2(32, 136), 12, Color(0.88, 0.94, 0.9))
		body_label.name = "BodyLabel"
		body_label.size = Vector2(212, 50)
		body_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		body_label.autowrap_mode = TextServer.AUTOWRAP_WORD
		body_label.clip_text = true
		card.add_child(body_label)
		var rank_label = _label("", Vector2(24, 190), 13, Color(1.0, 0.83, 0.34))
		rank_label.name = "RankLabel"
		rank_label.size = Vector2(228, 36)
		rank_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		rank_label.autowrap_mode = TextServer.AUTOWRAP_WORD
		rank_label.clip_text = true
		card.add_child(rank_label)
		for pip_index in MAX_UPGRADE_RANK:
			var pip = _make_upgrade_pip(id)
			pip.name = "Pip%s" % pip_index
			pip.position = Vector2(86 + pip_index * 26, 226)
			card.add_child(pip)
		var button = Button.new()
		button.name = "ChooseButton"
		button.text = "Choose"
		button.position = Vector2(51, 244)
		button.size = Vector2(174, 30)
		_style_button(button, "primary")
		button.pressed.connect(func() -> void: _select_upgrade(id))
		card.add_child(button)
		upgrade_cards[id] = card
	var tip = _label("Choose one adaptation. Each branch stacks across the run.", Vector2(280, 584), 14, Color(1.0, 0.92, 0.68))
	tip.size = Vector2(480, 24)
	tip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(tip)
	root.visible = false
	return root


func _branch_accent(id: String) -> Color:
	if id == "rapid":
		return Color(0.45, 1.0, 1.0)
	if id == "pulse":
		return Color(0.88, 0.43, 1.0)
	return Color(0.42, 1.0, 0.66)


func _upgrade_medallion_path(id: String) -> String:
	if id == "rapid":
		return UPGRADE_MEDALLION_ANTIBODY
	if id == "pulse":
		return UPGRADE_MEDALLION_COMPLEMENT
	return UPGRADE_MEDALLION_CHEMOTAXIS


func _compact_upgrade_body(id: String) -> String:
	if id == "rapid":
		return "Shortens cooldown.\nAdds paired/triple shots."
	if id == "pulse":
		return "Damages pathogens.\nBreaks platelet hazards."
	return "Quick immune surge.\nSlip through vessel lanes."


func _add_upgrade_connector(parent: Control, points: Array[Vector2]) -> void:
	var connector = Line2D.new()
	connector.width = 4.0
	connector.default_color = Color(0.34, 1.0, 1.0, 0.72)
	connector.z_index = 1
	connector.points = PackedVector2Array(points)
	parent.add_child(connector)


func _apply_upgrade_card_style(card: Panel, id: String, selected: bool) -> void:
	var accent = _branch_accent(id)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.01, 0.06, 0.86).lerp(accent, 0.08 if not selected else 0.16)
	style.border_color = accent.lerp(Color(1.0, 0.86, 0.36), 0.22 if not selected else 0.42)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	card.add_theme_stylebox_override("panel", style)


func _make_upgrade_pip(id: String) -> Panel:
	var pip = Panel.new()
	pip.size = Vector2(15, 15)
	pip.pivot_offset = pip.size * 0.5
	pip.z_index = 12
	pip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_style_upgrade_pip(pip, id, false, 1.0)
	return pip


func _style_upgrade_pip(pip: Panel, id: String, filled: bool, pulse := 1.0) -> void:
	var accent = _branch_accent(id)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.02, 0.05, 0.72)
	style.border_color = accent.lerp(Color(1.0, 0.82, 0.28), 0.36)
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.0)
	style.shadow_size = 0
	pip.scale = Vector2.ONE
	if filled:
		var glow = clampf((pulse - 0.8) / 0.4, 0.0, 1.0)
		style.bg_color = Color(1.0, 0.72, 0.16, 1.0).lerp(Color(1.0, 0.98, 0.62, 1.0), glow)
		style.border_color = Color(1.0, 0.86, 0.28, 1.0).lerp(Color(1.0, 1.0, 0.78, 1.0), glow)
		style.shadow_color = Color(1.0, 0.72, 0.12, 0.44 + glow * 0.34)
		style.shadow_size = roundi(8.0 + glow * 8.0)
		pip.scale = Vector2.ONE * (1.0 + glow * 0.12)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	pip.add_theme_stylebox_override("panel", style)


func _make_game_over_panel() -> Control:
	var root = Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	var shade = ColorRect.new()
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.02, 0.0, 0.02, 0.66)
	root.add_child(shade)

	var frame_size = Vector2(860, 484)
	var panel = Control.new()
	panel.name = "Panel"
	panel.position = (BASE_SIZE - frame_size) * 0.5 + Vector2(0, 4)
	panel.size = frame_size
	root.add_child(panel)

	panel.add_child(_hud_texture(GAME_OVER_PANEL_ART, Vector2.ZERO, frame_size))

	var title_left = frame_size.x * 0.235
	var title_width = frame_size.x * 0.53
	var title = _label("IMMUNE RUN COMPLETE", Vector2(title_left, frame_size.y * 0.195), 26)
	title.name = "Title"
	title.size = Vector2(title_width, 32)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_constant_override("outline_size", 5)
	title.add_theme_color_override("font_outline_color", Color(0.13, 0.03, 0.04, 0.96))
	panel.add_child(title)
	game_over_subtitle_label = _label("", Vector2(title_left, frame_size.y * 0.256), 9, Color(1.0, 0.92, 0.84))
	game_over_subtitle_label.size = Vector2(title_width, 16)
	game_over_subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	game_over_subtitle_label.add_theme_constant_override("outline_size", 2)
	game_over_subtitle_label.add_theme_color_override("font_outline_color", Color(0.02, 0.0, 0.02, 0.94))
	panel.add_child(game_over_subtitle_label)

	var stat_defs = [
		["score", "FINAL SCORE", 0.0],
		["level", "LEVEL REACHED", 5.0],
		["sections", "SECTIONS CLEARED", 8.0],
		["virions", "VIRIONS NEUTRALIZED", 12.0],
	]
	var stats_x = frame_size.x * 0.272
	var stats_y = frame_size.y * 0.358
	var stats_h = frame_size.y * 0.356
	var stat_gap = stats_h * 0.034
	var stat_row_h = (stats_h - stat_gap * 3.0) / 4.0
	for i in stat_defs.size():
		var row_y = stats_y + i * (stat_row_h + stat_gap) + float(stat_defs[i][2])
		var stat_label = _label(stat_defs[i][1], Vector2(stats_x, row_y + 1), 6, Color(0.42, 1.0, 1.0))
		stat_label.size = Vector2(frame_size.x * 0.19, 10)
		stat_label.clip_text = true
		stat_label.add_theme_constant_override("outline_size", 2)
		stat_label.add_theme_color_override("font_outline_color", Color(0.02, 0.0, 0.02, 0.9))
		panel.add_child(stat_label)
		var value = _label("0", Vector2(stats_x, row_y + 12), 18, Color(1.0, 0.96, 0.78))
		value.size = Vector2(frame_size.x * 0.22, 26)
		value.clip_text = true
		value.add_theme_constant_override("outline_size", 3)
		value.add_theme_color_override("font_outline_color", Color(0.02, 0.0, 0.02, 0.92))
		panel.add_child(value)
		game_over_values[stat_defs[i][0]] = value

	var details_x = frame_size.x * (1.0 - 0.23 - 0.208)
	var details_y = frame_size.y * 0.414
	var time_title = _label("SURVIVAL TIME", Vector2(details_x, details_y), 7, Color(0.42, 1.0, 1.0))
	time_title.size = Vector2(frame_size.x * 0.2, 11)
	time_title.clip_text = true
	time_title.add_theme_constant_override("outline_size", 2)
	time_title.add_theme_color_override("font_outline_color", Color(0.02, 0.0, 0.02, 0.9))
	panel.add_child(time_title)
	var time_value = _label("0:00", Vector2(details_x, details_y + 15), 21, Color(1.0, 0.96, 0.78))
	time_value.add_theme_constant_override("outline_size", 3)
	time_value.add_theme_color_override("font_outline_color", Color(0.02, 0.0, 0.02, 0.92))
	panel.add_child(time_value)
	game_over_values["time"] = time_value
	var boss_title = _label("BOSSES NEUTRALIZED", Vector2(details_x, details_y + 55), 7, Color(0.42, 1.0, 1.0))
	boss_title.size = Vector2(frame_size.x * 0.2, 11)
	boss_title.clip_text = true
	boss_title.add_theme_constant_override("outline_size", 2)
	boss_title.add_theme_color_override("font_outline_color", Color(0.02, 0.0, 0.02, 0.9))
	panel.add_child(boss_title)
	var boss_value = _label("0", Vector2(details_x, details_y + 70), 19, Color(1.0, 0.96, 0.78))
	boss_value.add_theme_constant_override("outline_size", 3)
	boss_value.add_theme_color_override("font_outline_color", Color(0.02, 0.0, 0.02, 0.92))
	panel.add_child(boss_value)
	game_over_values["bosses"] = boss_value
	var adapt_title = _label("ADAPTATIONS", Vector2(details_x, details_y + 102), 7, Color(0.42, 1.0, 1.0))
	adapt_title.size = Vector2(frame_size.x * 0.2, 11)
	adapt_title.clip_text = true
	adapt_title.add_theme_constant_override("outline_size", 2)
	adapt_title.add_theme_color_override("font_outline_color", Color(0.02, 0.0, 0.02, 0.9))
	panel.add_child(adapt_title)
	game_over_adaptations_label = _label("No adaptations selected", Vector2(details_x, details_y + 117), 9, Color(1.0, 0.92, 0.84))
	game_over_adaptations_label.size = Vector2(frame_size.x * 0.205, 49)
	game_over_adaptations_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	game_over_adaptations_label.clip_text = true
	game_over_adaptations_label.add_theme_constant_override("outline_size", 2)
	game_over_adaptations_label.add_theme_color_override("font_outline_color", Color(0.02, 0.0, 0.02, 0.9))
	panel.add_child(game_over_adaptations_label)

	var button = Button.new()
	button.name = "ActionButton"
	button.text = ""
	button.position = Vector2(frame_size.x * 0.348, frame_size.y * 0.794)
	button.size = Vector2(frame_size.x * 0.304, frame_size.y * 0.094)
	_style_art_button(button, 18)
	button.pressed.connect(_restart_from_game_over)
	panel.add_child(button)
	var button_label = _label("TRY AGAIN", button.position, 18, Color(1.0, 0.96, 0.82))
	button_label.size = button.size
	button_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	button_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	button_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button_label.add_theme_constant_override("outline_size", 4)
	button_label.add_theme_color_override("font_outline_color", Color(0.01, 0.0, 0.02, 0.96))
	panel.add_child(button_label)
	root.visible = false
	return root


func _make_mobile_controls() -> Control:
	var root = Control.new()
	root.name = "MobileControls"
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.visible = _should_show_mobile_controls()
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_mobile_joystick_control())
	var fire_button = _mobile_action_button("FIRE", Vector2(1090, 548), Vector2(150, 104), "primary")
	mobile_fire_button = fire_button
	fire_button.button_down.connect(func() -> void:
		if _gameplay_inputs_active():
			mobile_fire_held = true
			_fire_antibodies(true)
	)
	fire_button.button_up.connect(func() -> void: mobile_fire_held = false)
	root.add_child(fire_button)
	var dash_button = _mobile_action_button("DASH", Vector2(936, 520), Vector2(130, 54), "secondary")
	mobile_dash_button = dash_button
	dash_button.button_down.connect(func() -> void:
		if _gameplay_inputs_active():
			mobile_dash_requested = true
	)
	root.add_child(dash_button)
	var pulse_button = _mobile_action_button("PULSE", Vector2(936, 588), Vector2(130, 54), "secondary")
	mobile_pulse_button = pulse_button
	pulse_button.button_down.connect(func() -> void:
		if _gameplay_inputs_active():
			mobile_pulse_requested = true
	)
	root.add_child(pulse_button)
	var tilt_hint = _label("Tilt off", Vector2(44, 642), 14, Color(0.74, 1.0, 1.0))
	tilt_hint.name = "TiltHint"
	tilt_hint.size = Vector2(240, 24)
	root.add_child(tilt_hint)
	return root


func _mobile_joystick_control() -> Control:
	var root = Control.new()
	root.name = "MoveJoystick"
	root.position = MOBILE_JOYSTICK_CENTER - Vector2.ONE * MOBILE_JOYSTICK_RADIUS
	root.size = Vector2.ONE * MOBILE_JOYSTICK_RADIUS * 2.0
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var ring = Panel.new()
	ring.name = "Ring"
	ring.position = Vector2.ZERO
	ring.size = root.size
	ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var ring_style = StyleBoxFlat.new()
	ring_style.bg_color = Color(0.01, 0.10, 0.12, 0.30)
	ring_style.border_color = Color(0.38, 1.0, 1.0, 0.62)
	ring_style.border_width_left = 3
	ring_style.border_width_top = 3
	ring_style.border_width_right = 3
	ring_style.border_width_bottom = 3
	ring_style.corner_radius_top_left = int(MOBILE_JOYSTICK_RADIUS)
	ring_style.corner_radius_top_right = int(MOBILE_JOYSTICK_RADIUS)
	ring_style.corner_radius_bottom_left = int(MOBILE_JOYSTICK_RADIUS)
	ring_style.corner_radius_bottom_right = int(MOBILE_JOYSTICK_RADIUS)
	ring.add_theme_stylebox_override("panel", ring_style)
	root.add_child(ring)

	var knob = Panel.new()
	knob.name = "Knob"
	knob.size = Vector2.ONE * MOBILE_JOYSTICK_KNOB_RADIUS * 2.0
	knob.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var knob_style = StyleBoxFlat.new()
	knob_style.bg_color = Color(0.72, 1.0, 0.92, 0.58)
	knob_style.border_color = Color(1.0, 0.84, 0.36, 0.72)
	knob_style.border_width_left = 2
	knob_style.border_width_top = 2
	knob_style.border_width_right = 2
	knob_style.border_width_bottom = 2
	knob_style.corner_radius_top_left = int(MOBILE_JOYSTICK_KNOB_RADIUS)
	knob_style.corner_radius_top_right = int(MOBILE_JOYSTICK_KNOB_RADIUS)
	knob_style.corner_radius_bottom_left = int(MOBILE_JOYSTICK_KNOB_RADIUS)
	knob_style.corner_radius_bottom_right = int(MOBILE_JOYSTICK_KNOB_RADIUS)
	knob.add_theme_stylebox_override("panel", knob_style)
	root.add_child(knob)
	mobile_joystick_knob = knob
	_sync_mobile_joystick_visual()
	return root


func _mobile_action_button(text: String, pos: Vector2, size: Vector2, variant: String) -> Button:
	var button = Button.new()
	button.text = text
	button.position = pos
	button.size = size
	_style_button(button, variant)
	button.add_theme_font_size_override("font_size", 22 if text == "FIRE" else 15)
	return button


func _is_mobile_performance_target() -> bool:
	return OS.has_feature("ios") or OS.has_feature("android") or OS.has_feature("web_ios") or OS.has_feature("web_android")


func _should_show_mobile_controls() -> bool:
	return mobile_performance_mode or _is_mobile_performance_target()


func _background_layers() -> Array:
	return MOBILE_PARALLAX if mobile_performance_mode else PARALLAX


func _background_tile_copy_count() -> int:
	return 3 if mobile_performance_mode else 4


func _stage_origin_for_size(visible_size: Vector2) -> Vector2:
	return Vector2(maxf(0.0, (visible_size.x - BASE_SIZE.x) * 0.5), maxf(0.0, (visible_size.y - BASE_SIZE.y) * 0.5))


func _current_stage_origin() -> Vector2:
	if ui_stage != null:
		return ui_stage.position
	if game_stage_root != null:
		return game_stage_root.position
	return _stage_origin_for_size(_visible_game_size())


func _viewport_to_stage_point(point: Vector2) -> Vector2:
	return point - _current_stage_origin()


func _gameplay_inputs_active() -> bool:
	return running and not paused and not waiting_for_upgrade and not game_over


func _handle_mobile_move_input(event: InputEvent) -> bool:
	if not _should_show_mobile_controls():
		return false
	if event is InputEventScreenTouch:
		if event.pressed:
			if _gameplay_inputs_active() and _point_inside_mobile_joystick_area(event.position):
				mobile_move_pointer_id = event.index
				_set_mobile_move_from_position(event.position)
				return true
		elif event.index == mobile_move_pointer_id:
			_release_mobile_joystick()
			return true
	if event is InputEventScreenDrag and event.index == mobile_move_pointer_id:
		_set_mobile_move_from_position(event.position)
		return true
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if _gameplay_inputs_active() and _point_inside_mobile_joystick_area(event.position):
				mobile_mouse_move_active = true
				_set_mobile_move_from_position(event.position)
				return true
		elif mobile_mouse_move_active:
			_release_mobile_joystick()
			return true
	if event is InputEventMouseMotion and mobile_mouse_move_active:
		if (event.button_mask & MOUSE_BUTTON_MASK_LEFT) != 0:
			_set_mobile_move_from_position(event.position)
			return true
		_release_mobile_joystick()
		return true
	return false


func _point_inside_mobile_joystick_area(point: Vector2) -> bool:
	if mobile_controls == null or not mobile_controls.visible:
		return false
	var stage_point = _viewport_to_stage_point(point)
	return stage_point.distance_to(MOBILE_JOYSTICK_CENTER) <= MOBILE_JOYSTICK_TOUCH_RADIUS


func _set_mobile_move_from_position(point: Vector2) -> void:
	var offset = _viewport_to_stage_point(point) - MOBILE_JOYSTICK_CENTER
	var normalized = offset / MOBILE_JOYSTICK_RADIUS
	if normalized.length() < MOBILE_JOYSTICK_DEADZONE:
		mobile_move_vector = Vector2.ZERO
	else:
		mobile_move_vector = normalized.limit_length(1.0)
	_sync_mobile_joystick_visual()


func _release_mobile_joystick() -> void:
	mobile_move_pointer_id = -1
	mobile_mouse_move_active = false
	mobile_move_vector = Vector2.ZERO
	_sync_mobile_joystick_visual()


func _sync_mobile_joystick_visual() -> void:
	if mobile_joystick_knob == null:
		return
	var travel = (MOBILE_JOYSTICK_RADIUS - MOBILE_JOYSTICK_KNOB_RADIUS - 8.0)
	var local_center = Vector2.ONE * MOBILE_JOYSTICK_RADIUS
	mobile_joystick_knob.position = local_center + mobile_move_vector.limit_length(1.0) * travel - Vector2.ONE * MOBILE_JOYSTICK_KNOB_RADIUS
	mobile_joystick_knob.modulate.a = 0.92 if mobile_move_vector.length() > 0.01 else 0.62


func _reset_held_action_inputs() -> void:
	mobile_fire_held = false
	mobile_dash_requested = false
	mobile_pulse_requested = false
	_release_mobile_joystick()
	dash_input_held = false
	horizontal_sound_input = 0
	if mobile_fire_button != null:
		mobile_fire_button.button_pressed = false
	if mobile_dash_button != null:
		mobile_dash_button.button_pressed = false
	if mobile_pulse_button != null:
		mobile_pulse_button.button_pressed = false


func _update_mobile_controls() -> void:
	if mobile_controls == null:
		return
	var show_controls = _should_show_mobile_controls() and running and not paused and not waiting_for_upgrade and not game_over
	var visibility_changed = mobile_controls.visible != show_controls
	if visibility_changed:
		mobile_controls.visible = show_controls
	if not show_controls and visibility_changed:
		mobile_fire_held = false
		_release_mobile_joystick()
	elif show_controls and visibility_changed:
		_sync_mobile_joystick_visual()
	if mobile_dash_button != null:
		var dash_ready = upgrades.dash > 0 and player.dash_cd <= 0.05 and show_controls
		var dash_disabled = not dash_ready
		if mobile_dash_button.disabled != dash_disabled:
			mobile_dash_button.disabled = dash_disabled
		var dash_text = "DASH" if upgrades.dash > 0 else "DASH\nLOCKED"
		if mobile_dash_button.text != dash_text:
			mobile_dash_button.text = dash_text
	if mobile_pulse_button != null:
		var pulse_ready = upgrades.pulse > 0 and player.pulse_cd <= 0.05 and show_controls
		var pulse_disabled = not pulse_ready
		if mobile_pulse_button.disabled != pulse_disabled:
			mobile_pulse_button.disabled = pulse_disabled
		var pulse_text = "PULSE" if upgrades.pulse > 0 else "PULSE\nLOCKED"
		if mobile_pulse_button.text != pulse_text:
			mobile_pulse_button.text = pulse_text
	if mobile_tilt_button != null:
		var show_mobile_options = _should_show_mobile_controls()
		if mobile_tilt_button.visible != show_mobile_options:
			mobile_tilt_button.visible = show_mobile_options
		var tilt_text = "Tilt: On" if tilt_enabled else "Tilt: Off"
		if mobile_tilt_button.text != tilt_text:
			mobile_tilt_button.text = tilt_text
	if mobile_calibrate_button != null:
		var show_calibrate = _should_show_mobile_controls()
		if mobile_calibrate_button.visible != show_calibrate:
			mobile_calibrate_button.visible = show_calibrate
	if mobile_controls.has_node("TiltHint"):
		var hint = mobile_controls.get_node("TiltHint") as Label
		var hint_text = "Tilt movement active" if tilt_enabled else "Tilt off"
		if hint.text != hint_text:
			hint.text = hint_text


func _toggle_tilt_mode() -> void:
	tilt_enabled = not tilt_enabled
	if tilt_enabled:
		_calibrate_tilt()
		_show_banner("Tilt movement enabled")
	else:
		_show_banner("Tilt movement disabled")


func _calibrate_tilt() -> void:
	var sensor = _raw_tilt_sensor()
	if sensor.length() <= 0.001:
		tilt_has_calibration = false
		_show_banner("Tilt sensor unavailable here")
		return
	tilt_neutral = sensor
	tilt_has_calibration = true
	_show_banner("Tilt center calibrated")


func _raw_tilt_sensor() -> Vector2:
	var sensor = Input.get_gravity()
	if sensor.length() <= 0.001:
		sensor = Input.get_accelerometer()
	if sensor.length() <= 0.001:
		return Vector2.ZERO
	return Vector2(sensor.x, sensor.y)


func _point_inside_active_ui(point: Vector2) -> bool:
	if start_panel != null and start_panel.visible:
		return true
	if pause_panel != null and pause_panel.visible:
		return true
	if complete_panel != null and complete_panel.visible:
		return true
	if upgrade_panel != null and upgrade_panel.visible:
		return true
	if game_over_panel != null and game_over_panel.visible:
		return true
	if mobile_controls != null and mobile_controls.visible and _visible_button_contains_point(mobile_controls, point):
		return true
	return hud != null and hud.visible and _visible_button_contains_point(hud, point)


func _visible_button_contains_point(root: Node, point: Vector2) -> bool:
	for child in root.get_children():
		if child is Control:
			var control = child as Control
			if control.visible and child is Button and control.get_global_rect().has_point(point):
				return true
		if child.get_child_count() > 0 and _visible_button_contains_point(child, point):
			return true
	return false


func _make_sprite(path: String, frame: Rect2, pos: Vector2, scale_amount: float) -> Sprite2D:
	var sprite = Sprite2D.new()
	sprite.texture = textures[path]
	sprite.region_enabled = true
	sprite.region_rect = frame
	sprite.position = pos
	sprite.scale = Vector2.ONE * scale_amount
	sprite.centered = true
	return sprite


func _reset_run(load_first_level := true) -> void:
	running = false
	paused = false
	waiting_for_upgrade = false
	game_over = false
	level = 1
	score = 0
	level_kills = 0
	total_kills = 0
	sections_cleared = 0
	bosses_neutralized = 0
	next_enemy_id = 1
	boss_defeated = false
	run_time = 0.0
	scroll = 0.0
	level_clear_timer = 0.0
	danger_music_active = false
	upgrades = {"rapid": 0, "pulse": 0, "dash": 0}
	player.pos = Vector2(210, 360)
	player.vel = Vector2.ZERO
	player.health = PLAYER_MAX_HEALTH
	player.shoot_cd = 0.0
	player.dash_cd = 0.0
	player.dash_timer = 0.0
	player.pulse_cd = 0.0
	player.pulse_timer = 0.0
	player.invulnerable = 0.0
	player.hurt_timer = 0.0
	mobile_fire_held = false
	mobile_dash_requested = false
	mobile_pulse_requested = false
	dash_input_held = false
	horizontal_sound_input = 0
	dash_trail_timer = 0.0
	lock_target_id = -1
	if load_first_level:
		_load_level(1)
	else:
		active_mission = _mission_for_level(1)
		level_length = 3200.0
		level_goal = 0
		spawn_enemy_timer = 0.15
		spawn_red_timer = 0.25
		spawn_platelet_timer = 3.5
		_clear_entities()


func _clear_entities() -> void:
	for group in [enemies, shots, red_cells, platelets, particles]:
		for item in group:
			if item.has("sprite") and is_instance_valid(item.sprite):
				item.sprite.queue_free()
		group.clear()
	active_pulses.clear()
	boss_spawned = false
	boss_defeated = false
	boss_warning_started = false
	boss_warning_timer = 0.0
	boss_clear_timer = 0.0
	lock_target_id = -1
	_stop_boss_warning_audio()


func _load_level(next_level: int) -> void:
	pending_music = ""
	pending_music_timer = 0.0
	danger_music_active = false
	level_clear_timer = 0.0
	level = next_level
	level_kills = 0
	scroll = 0.0
	active_mission = _mission_for_level(level)
	var encounter_level = _is_encounter_level()
	var difficulty = _difficulty_multiplier(level)
	var base_length = 2200.0 + level * (560.0 if encounter_level else 520.0)
	level_length = roundf(base_length * (1.0 + maxf(0.0, difficulty - 1.0) * 0.18))
	boss_trigger_progress = rng.randf_range(0.8, 0.9) if encounter_level else 0.85
	level_goal = mini(85, ceili((3 + level * 2) * difficulty))
	spawn_enemy_timer = 0.15
	spawn_red_timer = 0.25
	spawn_platelet_timer = rng.randf_range(1.15, 2.1)
	_clear_entities()
	_seed_red_cells()
	_seed_platelets()
	_show_banner("%s: %s" % [active_mission.name, active_mission.term])
	_play_desired_music()


func _mission_for_level(value: int) -> Dictionary:
	if value <= MISSIONS.size():
		return MISSIONS[value - 1].duplicate(true)
	var encounter = ENCOUNTERS[(value - 5) % ENCOUNTERS.size()].duplicate(true)
	encounter.goal = 9 + value * 2
	return encounter


func _show_start() -> void:
	start_panel.visible = true
	pause_panel.visible = false
	complete_panel.visible = false
	upgrade_panel.visible = false
	game_over_panel.visible = false
	hud.visible = false
	if banner_label != null:
		banner_label.visible = false
	_play_music("menu")
	set_process(false)


func _start_run() -> void:
	set_process(true)
	_reset_run()
	running = true
	start_panel.visible = false
	hud.visible = true
	_play_music("combat")


func _confirm_restart() -> void:
	_play_sfx("restart_confirm")
	_reset_run(false)
	start_panel.visible = true
	pause_panel.visible = false
	hud.visible = false
	_play_music("menu")
	set_process(false)


func _request_restart_confirmation() -> void:
	if restart_confirm_pending:
		restart_confirm_pending = false
		restart_confirm_timer = 0.0
		if pause_restart_button != null:
			pause_restart_button.text = "Restart Run"
		_confirm_restart()
		return
	restart_confirm_pending = true
	restart_confirm_timer = 3.0
	if pause_restart_button != null:
		pause_restart_button.text = "Confirm Restart"
	_play_sfx("restart_confirm")


func _restart_from_game_over() -> void:
	game_over_panel.visible = false
	_start_run()


func _toggle_pause() -> void:
	if not running or waiting_for_upgrade or game_over:
		return
	paused = not paused
	pause_panel.visible = paused
	if paused:
		_reset_held_action_inputs()
	restart_confirm_pending = false
	restart_confirm_timer = 0.0
	if pause_restart_button != null:
		pause_restart_button.text = "Restart Run"
	_play_sfx("pause_open" if paused else "pause_resume")
	get_tree().paused = false


func _update_player(delta: float) -> void:
	var move = _movement_input_vector()
	if move.length() > 0.0:
		move = move.normalized()
		player.vel = player.vel.lerp(move * PLAYER_SPEED, clampf(PLAYER_ACCEL * delta, 0.0, 1.0))
	else:
		player.vel = player.vel.lerp(Vector2.ZERO, clampf(PLAYER_DRAG * delta, 0.0, 1.0))
	_update_lateral_swim_sfx(move)
	var keyboard_dash_pressed = Input.is_key_pressed(KEY_SHIFT)
	if (keyboard_dash_pressed and not dash_input_held) or mobile_dash_requested:
		_trigger_dash(move)
	dash_input_held = keyboard_dash_pressed
	mobile_dash_requested = false
	if mobile_pulse_requested:
		_trigger_pulse()
		mobile_pulse_requested = false
	player.pos += player.vel * delta
	player.pos.x = clampf(player.pos.x, 60.0, BASE_SIZE.x - 90.0)
	player.pos.y = clampf(player.pos.y, 90.0, BASE_SIZE.y - 80.0)
	player.sprite.position = player.pos
	player.sprite.rotation = lerp_angle(player.sprite.rotation, clampf(player.vel.y / 650.0, -0.35, 0.35), 6.0 * delta)
	var frame_index = 0
	if move.x > 0.05:
		_set_player_facing_from_direction(Vector2.RIGHT)
		frame_index = 1
	elif move.x < -0.05:
		_set_player_facing_from_direction(Vector2.LEFT)
		frame_index = 1
	player.sprite.region_rect = FRAMES.white_cell[frame_index]
	player.sprite.flip_h = player_facing_left
	player.shoot_cd = maxf(0.0, player.shoot_cd - delta)
	player.dash_cd = maxf(0.0, player.dash_cd - delta)
	player.dash_timer = maxf(0.0, player.dash_timer - delta)
	player.pulse_cd = maxf(0.0, player.pulse_cd - delta)
	player.pulse_timer = maxf(0.0, player.pulse_timer - delta)
	player.invulnerable = maxf(0.0, float(player.invulnerable) - delta)
	player.hurt_timer = maxf(0.0, float(player.hurt_timer) - delta)
	var player_tint = Color(0.72, 1.0, 1.0, 0.88) if player.dash_timer > 0.0 else Color.WHITE
	if player.hurt_timer > 0.0 and int(player.hurt_timer * 22.0) % 2 == 0:
		player_tint = Color(1.0, 0.72, 0.72, 0.9)
	player.sprite.modulate = player_tint
	if player.dash_timer > 0.0:
		dash_trail_timer -= delta
		if dash_trail_timer <= 0.0:
			_spawn_dash_wake()
			dash_trail_timer = 0.045
	if Input.is_key_pressed(KEY_SPACE) or mobile_fire_held:
		_fire_antibodies(false)


func _update_lateral_swim_sfx(move: Vector2) -> void:
	var input_sign = 0
	if move.x > 0.35:
		input_sign = 1
	elif move.x < -0.35:
		input_sign = -1
	if input_sign != 0 and horizontal_sound_input != input_sign:
		_play_sfx("swim_surge")
	horizontal_sound_input = input_sign


func _movement_input_vector() -> Vector2:
	var move = Vector2.ZERO
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		move.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		move.y += 1.0
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		move.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		move.x += 1.0
	if move.length() > 0.0:
		return move
	if mobile_move_vector.length() > 0.0:
		return mobile_move_vector
	if tilt_enabled:
		return _read_tilt_move()
	return Vector2.ZERO


func _read_tilt_move() -> Vector2:
	var sensor = Input.get_gravity()
	if sensor.length() <= 0.001:
		sensor = Input.get_accelerometer()
	if sensor.length() <= 0.001:
		return Vector2.ZERO
	var raw = Vector2(sensor.x, sensor.y)
	if not tilt_has_calibration:
		tilt_neutral = raw
		tilt_has_calibration = true
	var tilt = raw - tilt_neutral
	var move = Vector2(tilt.x, tilt.y) * TILT_SENSITIVITY
	if absf(move.x) < TILT_DEADZONE:
		move.x = 0.0
	if absf(move.y) < TILT_DEADZONE:
		move.y = 0.0
	return move.limit_length(1.0)


func _set_player_facing_from_direction(direction: Vector2) -> void:
	if direction.x > 0.05:
		player_facing_left = false
	elif direction.x < -0.05:
		player_facing_left = true
	if player.get("sprite", null) != null:
		player.sprite.flip_h = player_facing_left


func _trigger_dash(move: Vector2) -> void:
	if upgrades.dash <= 0 or player.dash_cd > 0.0:
		return
	var direction = move.normalized() if move.length() > 0.0 else (Vector2.LEFT if player_facing_left else Vector2.RIGHT)
	player.vel += direction * (520.0 + upgrades.dash * 100.0)
	player.dash_timer = 0.18 + upgrades.dash * 0.035
	player.dash_cd = maxf(0.45, 1.65 - upgrades.dash * 0.22)
	_play_sfx("dash")


func _trigger_pulse() -> void:
	if upgrades.pulse <= 0 or player.pulse_cd > 0.0:
		return
	var rank = int(upgrades.pulse)
	player.pulse_cd = maxf(1.2, 5.5 - rank * 0.75)
	player.pulse_timer = 0.58
	player.invulnerable = maxf(float(player.invulnerable), 0.6)
	var radius = PULSE_BASE_RADIUS + rank * PULSE_RADIUS_PER_RANK
	var pulse := {
		"pos": player.pos,
		"radius": radius,
		"rank": rank,
		"age": 0.0,
		"life": _pulse_life_for_rank(rank),
		"hit_enemy_ids": {},
	}
	_apply_pulse_hits(pulse, radius + PULSE_EDGE_GRACE)
	active_pulses.append(pulse)
	_play_sfx("pulse")
	_spawn_pulse_wave(player.pos, radius, rank)


func _pulse_intersects_body(pulse_pos: Vector2, pulse_radius: float, body_pos: Vector2, body_radius: float) -> bool:
	return body_pos.distance_to(pulse_pos) <= pulse_radius + maxf(0.0, body_radius)


func _update_active_pulses(delta: float) -> void:
	for i in range(active_pulses.size() - 1, -1, -1):
		var pulse: Dictionary = active_pulses[i]
		pulse["age"] = float(pulse.get("age", 0.0)) + delta
		var life = maxf(0.001, float(pulse.get("life", 0.58)))
		var progress = clampf(float(pulse.age) / life, 0.0, 1.0)
		var eased = 1.0 - pow(1.0 - progress, 2.0)
		var current_radius = float(pulse.get("radius", 0.0)) * lerpf(0.06, 1.0, eased)
		_apply_pulse_hits(pulse, current_radius + PULSE_EDGE_GRACE)
		if progress >= 1.0:
			active_pulses.remove_at(i)
		else:
			active_pulses[i] = pulse


func _apply_pulse_hits(pulse: Dictionary, test_radius: float) -> void:
	var pulse_pos: Vector2 = pulse.get("pos", player.pos)
	var rank = int(pulse.get("rank", 1))
	var hit_enemy_ids: Dictionary = pulse.get("hit_enemy_ids", {})
	for i in enemies.size():
		var enemy: Dictionary = enemies[i]
		if enemy.get("dead", false):
			continue
		var enemy_id = int(enemy.get("id", -1))
		if hit_enemy_ids.has(enemy_id):
			continue
		if _pulse_intersects_body(pulse_pos, test_radius, enemy.pos, _pulse_enemy_radius(enemy)):
			var distance = enemy.pos.distance_to(pulse_pos)
			var push_dir = (enemy.pos - pulse_pos).normalized() if distance > 0.01 else Vector2.RIGHT.rotated(rng.randf_range(0.0, TAU))
			enemy.vel += push_dir * (80.0 + rank * 24.0)
			hit_enemy_ids[enemy_id] = true
			enemies[i] = enemy
			_damage_enemy_at(i, _pulse_damage_for_rank(rank))
	for platelet in platelets:
		if platelet.get("dead", false):
			continue
		if _pulse_intersects_body(pulse_pos, test_radius, platelet.pos, _pulse_platelet_radius(platelet)):
			platelet.dead = true
			_spawn_pop(platelet.pos, Color(1.0, 0.82, 0.32))
	pulse["hit_enemy_ids"] = hit_enemy_ids


func _pulse_damage_for_rank(rank: int) -> float:
	return 2.2 + rank * 0.9


func _pulse_enemy_radius(enemy: Dictionary) -> float:
	var radius = float(enemy.get("radius", 0.0))
	return _pulse_visual_radius(enemy, radius, 0.82)


func _pulse_platelet_radius(platelet: Dictionary) -> float:
	var radius = float(platelet.get("radius", 0.0))
	return maxf(radius * 1.25, _pulse_visual_radius(platelet, radius, 0.95))


func _pulse_visual_radius(body: Dictionary, fallback: float, visual_scale: float) -> float:
	var sprite = body.get("sprite", null)
	if is_instance_valid(sprite) and sprite is Sprite2D:
		var sprite_node := sprite as Sprite2D
		var visual_size = sprite_node.region_rect.size
		if visual_size == Vector2.ZERO and sprite_node.texture != null:
			visual_size = sprite_node.texture.get_size()
		var visual_radius = maxf(visual_size.x * absf(sprite_node.scale.x), visual_size.y * absf(sprite_node.scale.y)) * 0.5 * visual_scale
		return maxf(fallback, visual_radius)
	return fallback


func _fire_antibodies(force: bool) -> void:
	var cooldown = maxf(0.12, 0.34 - upgrades.rapid * 0.045)
	if not force and player.shoot_cd > 0.0:
		return
	if force and player.shoot_cd > cooldown * 0.65:
		return
	player.shoot_cd = cooldown
	var target_index: int = _find_lock_target_index()
	var target_id := -1
	if target_index != -1:
		target_id = int(enemies[target_index].get("id", -1))
		lock_target_id = target_id
	var count = 1
	if upgrades.rapid >= 2:
		count = 2
	if upgrades.rapid >= 4:
		count = 3
	var spread_step = 0.18
	var aim_dir = Vector2.RIGHT
	if target_index != -1:
		var aim_target: Dictionary = enemies[target_index]
		var aim_delta: Vector2 = aim_target["pos"] - player.pos
		if aim_delta.length() > 0.01:
			aim_dir = aim_delta.normalized()
	_set_player_facing_from_direction(aim_dir)
	for i in count:
		var offset = (float(i) - float(count - 1) / 2.0) * spread_step
		var dir = aim_dir
		dir = dir.rotated(offset)
		var frame = FRAMES.antibody[min(upgrades.rapid, FRAMES.antibody.size() - 1)]
		var start_pos: Vector2 = player.pos + dir * 46.0
		var sprite = _make_sprite(SPRITE_ATLAS, frame, start_pos, 0.34)
		sprite.rotation = dir.angle()
		sprite.z_index = 16
		entity_root.add_child(sprite)
		shots.append({
			"pos": start_pos,
			"vel": dir * SHOT_SPEED + Vector2(player.vel) * 0.12,
			"life": SHOT_LIFE,
			"damage": 1.0 + upgrades.rapid * 0.28,
			"target_id": target_id,
			"sprite": sprite,
		})
		if i == 0:
			_spawn_muzzle_spark(start_pos, dir)
	if shot_sound_timer <= 0.0:
		_play_sfx("shot")
		shot_sound_timer = 0.035


func _update_spawning(delta: float) -> void:
	var encounter_active = _is_encounter_level()
	var boss_trigger_reached = encounter_active and _level_progress() >= _boss_trigger_progress()
	var boss_approach_clear_active = false
	if boss_trigger_reached and not boss_spawned:
		boss_approach_clear_active = _update_boss_warning(delta)
	var spawn_scale = _level_spawn_scale()
	spawn_enemy_timer -= delta
	spawn_red_timer -= delta
	spawn_platelet_timer -= delta
	var can_spawn_encounter_enemies = not encounter_active or (not boss_spawned and (not boss_warning_started or not boss_approach_clear_active))
	if can_spawn_encounter_enemies and spawn_enemy_timer <= 0.0:
		_spawn_enemy()
		spawn_enemy_timer = rng.randf_range(0.78, 1.35) * spawn_scale
	if spawn_red_timer <= 0.0 and red_cells.size() < RED_CELL_MAX_ACTIVE:
		_spawn_red_cell()
		spawn_red_timer = rng.randf_range(0.42, 0.86)
	if (not boss_warning_started or not boss_approach_clear_active) and spawn_platelet_timer <= 0.0:
		if _active_platelet_count() < _platelet_limit():
			_spawn_platelet()
			spawn_platelet_timer = _next_platelet_spawn_delay(spawn_scale)
		else:
			spawn_platelet_timer = rng.randf_range(0.9, 1.45)


func _update_boss_warning(delta: float) -> bool:
	if boss_spawned:
		return false
	if not boss_warning_started:
		boss_warning_started = true
		boss_warning_timer = BOSS_WARNING_DURATION
		boss_clear_timer = BOSS_PRE_CLEAR_DURATION
		_play_boss_warning_audio()
		_show_banner("Pathogen signal building")
	boss_warning_timer = maxf(0.0, boss_warning_timer - delta)
	var clear_active = boss_warning_timer <= BOSS_PRE_CLEAR_DURATION
	if clear_active and boss_clear_timer > 0.0:
		boss_clear_timer = maxf(0.0, boss_clear_timer - delta)
		if boss_clear_timer == 0.0:
			_soft_clear_board()
			_show_banner("Clear vessel lane")
	if boss_warning_timer == 0.0:
		_spawn_boss()
	return clear_active


func _spawn_enemy(enemy_type: String = "", options: Dictionary = {}) -> Dictionary:
	var chosen_type = enemy_type if enemy_type != "" else _pick_enemy_type()
	var stats = _enemy_stats(chosen_type)
	var visual_group: String = stats.visual_group
	var sheet = INFLUENZA_SHEET if visual_group == "influenza" else SPRITE_ATLAS
	var frame = FRAMES[visual_group][rng.randi_range(0, FRAMES[visual_group].size() - 1)]
	var pos = options.get("pos", Vector2(BASE_SIZE.x + rng.randf_range(50, 220), rng.randf_range(130, BASE_SIZE.y - 115)))
	var speed = float(options.get("speed", stats.speed))
	var vel = options.get("vel", Vector2(-speed, rng.randf_range(-34, 34)))
	var scale = float(options.get("scale", (float(stats.radius) * 2.9) / frame.size.y))
	var sprite = _make_sprite(sheet, frame, pos, scale)
	sprite.z_index = 12
	entity_root.add_child(sprite)
	var enemy = {
		"id": _next_enemy_id(),
		"type": chosen_type,
		"visual_group": visual_group,
		"pos": pos,
		"vel": vel,
		"base_speed": speed,
		"radius": float(stats.radius),
		"hp": float(stats.hp),
		"max_hp": float(stats.hp),
		"score": int(stats.score),
		"damage": float(stats.damage),
		"repro_cd": rng.randf_range(0.25, 0.85) if chosen_type == "influenza" else 0.0,
		"spread_timer": float(options.get("spread_timer", 0.0)),
		"boss_add": bool(options.get("boss_add", false)),
		"sprite": sprite,
		"dead": false,
	}
	enemies.append(enemy)
	return enemy


func _spawn_boss() -> void:
	boss_spawned = true
	var profile: Dictionary = BOSS_PROFILES[active_mission.boss]
	var difficulty = _difficulty_multiplier()
	var hp_scale = 1.0 + maxf(0.0, difficulty - 1.0) * 0.9
	var pos = Vector2(BASE_SIZE.x + 120.0, BASE_SIZE.y * 0.48)
	var frame = FRAMES[profile.group][0]
	var sprite = _make_sprite(profile.sheet, frame, pos, float(profile.scale))
	sprite.z_index = 14
	entity_root.add_child(sprite)
	enemies.append({
		"id": _next_enemy_id(),
		"type": "boss",
		"boss_type": active_mission.boss,
		"title": profile.title,
		"pos": pos,
		"vel": Vector2(-54.0, 0.0),
		"radius": profile.radius,
		"hp": profile.hp * hp_scale,
		"max_hp": profile.hp * hp_scale,
		"score": roundi(profile.score * difficulty),
		"damage": profile.damage,
		"damage_scale": profile.damage_scale,
		"phase": 0,
		"attack_cd": float(profile.attack_interval) * 0.75 / sqrt(difficulty),
		"shield_cycle": rng.randf_range(0.0, 1.2),
		"shield_open": false,
		"sprite": sprite,
		"dead": false,
	})
	_stop_boss_warning_audio()
	_play_music("boss")
	_show_banner(profile.title)


func _seed_red_cells() -> void:
	var count = mini(RED_CELL_MAX_ACTIVE - 2, 6 + level)
	for i in count:
		_spawn_red_cell(true)


func _seed_platelets() -> void:
	var count = 1
	if level >= 4 and rng.randf() < 0.75:
		count += 1
	if level >= 7 and rng.randf() < 0.45:
		count += 1
	count = mini(count, _platelet_limit())
	for i in count:
		_spawn_platelet(true)


func _spawn_red_cell(start_on_screen := false) -> void:
	var frame = FRAMES.red_cell[rng.randi_range(0, FRAMES.red_cell.size() - 1)]
	var depth = rng.randf_range(0.55, 1.14)
	var radius = rng.randf_range(24.0, 46.0) * depth
	var x_min = 95.0 if start_on_screen else BASE_SIZE.x + 20.0
	var x_max = BASE_SIZE.x + 180.0
	var pos = Vector2(rng.randf_range(x_min, x_max), rng.randf_range(100.0 + radius, BASE_SIZE.y - 86.0 - radius))
	if start_on_screen and pos.distance_to(player.pos) < 145.0:
		pos.x = minf(BASE_SIZE.x + 120.0, pos.x + 210.0)
	var sprite = _make_sprite(SPRITE_ATLAS, frame, pos, (radius * 1.86) / frame.size.y)
	sprite.z_index = 17 if depth >= 0.68 else 5
	sprite.modulate.a = rng.randf_range(0.68, 0.84) if depth >= 0.68 else rng.randf_range(0.38, 0.58)
	entity_root.add_child(sprite)
	red_cells.append({
		"pos": pos,
		"radius": radius,
		"depth": depth,
		"speed": rng.randf_range(46.0, 116.0) * depth,
		"drift": rng.randf_range(-14.0, 14.0),
		"rotation": rng.randf_range(0.0, TAU),
		"spin": rng.randf_range(-0.9, 0.9),
		"wobble": rng.randf_range(0.0, TAU),
		"sprite": sprite,
		"dead": false,
	})


func _spawn_platelet(start_on_screen := false) -> void:
	var frame = FRAMES.platelet[rng.randi_range(0, FRAMES.platelet.size() - 1)]
	var radius = rng.randf_range(18.0, 30.0)
	var x_min = BASE_SIZE.x * 0.55 if start_on_screen else BASE_SIZE.x + radius + 60.0
	var x_max = BASE_SIZE.x - 90.0 if start_on_screen else BASE_SIZE.x + radius + 210.0
	var pos = Vector2(x_max, BASE_SIZE.y * 0.5)
	for attempt in 8:
		var candidate = Vector2(rng.randf_range(x_min, x_max), rng.randf_range(120.0 + radius, BASE_SIZE.y - 110.0 - radius))
		var clear = not start_on_screen or candidate.distance_to(player.pos) > 260.0
		for platelet in platelets:
			if not platelet.get("dead", false) and candidate.distance_to(platelet.pos) < radius + float(platelet.radius) + 150.0:
				clear = false
				break
		if clear or attempt == 7:
			pos = candidate
			break
	var sprite = _make_sprite(SPRITE_ATLAS, frame, pos, (radius * 2.55) / frame.size.y)
	sprite.z_index = 18
	entity_root.add_child(sprite)
	platelets.append({
		"pos": pos,
		"vel": Vector2(-rng.randf_range(62.0, 90.0), 0.0),
		"radius": radius,
		"angle": rng.randf_range(0.0, TAU),
		"spin": rng.randf_range(-0.55, 0.55),
		"sprite": sprite,
		"dead": false,
	})


func _update_shots(delta: float) -> void:
	for i in range(shots.size() - 1, -1, -1):
		var shot: Dictionary = shots[i]
		var sprite: Sprite2D = shot.get("sprite", null)
		if shot.get("dead", false):
			_remove_shot_at(i)
			continue
		var previous_pos: Vector2 = shot.get("pos", Vector2.ZERO)
		var pos: Vector2 = previous_pos
		var vel: Vector2 = shot.get("vel", Vector2.RIGHT * SHOT_SPEED)
		var target_id: int = int(shot.get("target_id", -1))
		var target_index := _find_enemy_index_by_id(target_id)
		if target_index != -1:
			var target_enemy: Dictionary = enemies[target_index]
			if not target_enemy.get("dead", false):
				var to_target: Vector2 = target_enemy["pos"] - pos
				if to_target.length() > 0.01:
					var desired: Vector2 = to_target.normalized() * SHOT_SPEED
					vel = vel.lerp(desired, clampf(SHOT_HOMING_STRENGTH * delta, 0.0, 1.0))
		pos += vel * delta
		var life: float = float(shot.get("life", SHOT_LIFE)) - delta
		var hit_index := _find_shot_hit_index(previous_pos, pos)
		if hit_index != -1:
			shot["dead"] = true
			shots[i] = shot
			if is_instance_valid(sprite):
				sprite.position = pos
			_damage_enemy_at(hit_index, float(shot.get("damage", 1.0)))
			_remove_shot_at(i)
			continue
		if is_instance_valid(sprite):
			sprite.position = pos
			sprite.rotation = vel.angle()
		shot["pos"] = pos
		shot["vel"] = vel
		shot["life"] = life
		shot["target_id"] = target_id
		if life <= 0.0 or pos.x > BASE_SIZE.x + 140.0 or pos.y < -90.0 or pos.y > BASE_SIZE.y + 90.0:
			shot["dead"] = true
		shots[i] = shot
		if shot.get("dead", false):
			_remove_shot_at(i)


func _remove_shot_at(index: int) -> void:
	if index < 0 or index >= shots.size():
		return
	var shot: Dictionary = shots[index]
	var sprite = shot.get("sprite", null)
	if is_instance_valid(sprite):
		sprite.queue_free()
	shots.remove_at(index)


func _find_shot_hit_index(from_pos: Vector2, to_pos: Vector2) -> int:
	var best_index := -1
	var best_distance := INF
	for i in enemies.size():
		var enemy: Dictionary = enemies[i]
		if enemy.get("dead", false):
			continue
		if _segment_hits_circle(from_pos, to_pos, enemy["pos"], float(enemy["radius"]) + SHOT_HIT_RADIUS):
			var distance := from_pos.distance_to(enemy["pos"])
			if distance < best_distance:
				best_distance = distance
				best_index = i
	return best_index


func _damage_enemy_at(index: int, amount: float) -> void:
	if index < 0 or index >= enemies.size():
		return
	var enemy: Dictionary = enemies[index]
	if enemy.get("dead", false):
		return
	if enemy.get("type", "") == "boss" and enemy.get("boss_type", "") == "adenovirus" and not bool(enemy.get("shield_open", false)):
		if is_instance_valid(enemy.get("sprite", null)):
			enemy["sprite"].modulate = Color(0.6, 1.0, 1.0, 1.0)
			var shield_tween := create_tween()
			shield_tween.tween_property(enemy["sprite"], "modulate", Color(0.72, 0.96, 1.0, 1.0), 0.1)
		_play_sfx("hit")
		enemies[index] = enemy
		return
	var applied_damage = amount
	if enemy.get("type", "") == "boss":
		applied_damage *= float(enemy.get("damage_scale", 1.0))
	enemy["hp"] = float(enemy.get("hp", 0.0)) - applied_damage
	_spawn_hit_spark(enemy["pos"], Color(0.66, 1.0, 0.9) if enemy.get("type", "") != "boss" else Color(1.0, 0.78, 0.42))
	if is_instance_valid(enemy.get("sprite", null)):
		enemy["sprite"].modulate = Color(1.0, 0.78, 0.78, 1.0)
		var tween := create_tween()
		tween.tween_property(enemy["sprite"], "modulate", Color.WHITE, 0.08)
	var hit_sfx = "boss_hit" if enemy["type"] == "boss" else ("influenza_hit" if enemy["type"] == "influenza" else "hit")
	_play_sfx(hit_sfx)
	if enemy["hp"] <= 0.0:
		enemy["dead"] = true
		score += int(enemy["score"])
		total_kills += 1
		level_kills += 1
		_spawn_pop(enemy["pos"], Color(0.5, 1.0, 0.88))
		if enemy["type"] == "boss":
			boss_defeated = true
			bosses_neutralized += 1
			_play_sfx("boss_defeated")
			_finish_level()
		else:
			_play_sfx("pop")
			if enemy["type"] == "budding":
				_play_sfx("budding_split")
				_spawn_boss_fragment(enemy, -1)
				_spawn_boss_fragment(enemy, 1)
				_show_banner("Budding virion split into fragments")
	enemies[index] = enemy


func _find_shot_hit(from_pos: Vector2, to_pos: Vector2) -> Dictionary:
	var hit_index := _find_shot_hit_index(from_pos, to_pos)
	if hit_index == -1:
		return {}
	return enemies[hit_index]


func _segment_hits_circle(from_pos: Vector2, to_pos: Vector2, center: Vector2, radius: float) -> bool:
	var segment: Vector2 = to_pos - from_pos
	var closest := from_pos
	var segment_length_sq := segment.length_squared()
	if segment_length_sq > 0.001:
		var t := clampf((center - from_pos).dot(segment) / segment_length_sq, 0.0, 1.0)
		closest = from_pos + segment * t
	return closest.distance_to(center) <= radius


func _update_enemies(delta: float) -> void:
	for enemy in enemies:
		if enemy.dead:
			continue
		if enemy.type == "boss":
			_update_boss(enemy, delta)
		else:
			var to_player = (player.pos - enemy.pos).normalized()
			var desired = Vector2(-float(enemy.get("base_speed", ENEMY_BASE_SPEED)), to_player.y * 86.0)
			if float(enemy.get("spread_timer", 0.0)) > 0.0:
				enemy.spread_timer = maxf(0.0, float(enemy.spread_timer) - delta)
				desired += enemy.vel * 0.42
			enemy.vel = enemy.vel.lerp(desired, clampf(delta * 0.8, 0.0, 1.0))
			enemy.pos += enemy.vel * delta
			enemy.repro_cd = maxf(0.0, float(enemy.get("repro_cd", 0.0)) - delta)
			if enemy.type == "influenza":
				_check_influenza_replication(enemy)
		enemy.sprite.position = enemy.pos
		enemy.sprite.rotation += delta * (0.7 if enemy.type != "boss" else 0.18)
		if enemy.pos.x < -130.0:
			enemy.dead = true
	_cleanup_group(enemies)


func _update_boss(enemy: Dictionary, delta: float) -> void:
	var boss_type: String = enemy.get("boss_type", "pox")
	var profile: Dictionary = BOSS_PROFILES[boss_type]
	var desired_x = BASE_SIZE.x * float(profile.target_x)
	var center_y = BASE_SIZE.y * 0.5
	var drift = sin(run_time * (1.15 if boss_type == "filovirus" else 0.95) + float(enemy.id)) * (112.0 if boss_type == "filovirus" else (92.0 if boss_type == "adenovirus" else 78.0))
	enemy.pos.x = lerpf(enemy.pos.x, desired_x, clampf(delta * 1.25, 0.0, 0.08))
	enemy.pos.y = clampf(center_y + drift, 105.0 + float(enemy.radius), BASE_SIZE.y - 95.0 - float(enemy.radius))
	enemy.attack_cd = float(enemy.attack_cd) - delta
	if boss_type == "pox":
		_update_pox_boss(enemy, profile)
	elif boss_type == "adenovirus":
		_update_adenovirus_boss(enemy, profile, delta)
	elif boss_type == "filovirus":
		_update_filovirus_boss(enemy, profile)


func _update_pox_boss(enemy: Dictionary, profile: Dictionary) -> void:
	var health_ratio = clampf(float(enemy.hp) / maxf(1.0, float(enemy.max_hp)), 0.0, 1.0)
	var next_phase = 0
	if health_ratio <= 0.22:
		next_phase = 3
	elif health_ratio <= 0.48:
		next_phase = 2
	elif health_ratio <= 0.72:
		next_phase = 1
	if next_phase > int(enemy.phase):
		enemy.phase = next_phase
		_spawn_boss_fragment(enemy, -1)
		_spawn_boss_fragment(enemy, 1)
		_show_banner("Pox core exposed" if next_phase == 3 else "Pox armor plates broke loose")
		_play_sfx("boss_phase")
	enemy.sprite.region_rect = FRAMES[profile.group][clampi(int(enemy.phase), 0, FRAMES[profile.group].size() - 1)]
	if float(enemy.attack_cd) <= 0.0:
		var difficulty = _difficulty_multiplier()
		enemy.attack_cd = (float(profile.attack_interval) + rng.randf_range(-0.25, 0.45)) / sqrt(difficulty)
		_spawn_boss_add(enemy, "budding", -0.8, rng.randf_range(84.0, 112.0))
		_spawn_boss_add(enemy, "budding", 0.8, rng.randf_range(84.0, 112.0))


func _update_adenovirus_boss(enemy: Dictionary, profile: Dictionary, delta: float) -> void:
	enemy.shield_cycle = fmod(float(enemy.shield_cycle) + delta, 3.4)
	enemy.shield_open = float(enemy.shield_cycle) > 2.12 and float(enemy.shield_cycle) < 3.02
	var frame_index = 2 if enemy.shield_open else (1 if float(enemy.shield_cycle) > 1.2 else 0)
	enemy.sprite.region_rect = FRAMES[profile.group][frame_index]
	enemy.sprite.modulate = Color.WHITE if enemy.shield_open else Color(0.72, 0.96, 1.0, 1.0)
	if float(enemy.attack_cd) <= 0.0:
		var difficulty = _difficulty_multiplier()
		enemy.attack_cd = (float(profile.attack_interval) + rng.randf_range(-0.2, 0.32)) / sqrt(difficulty)
		enemy.sprite.region_rect = FRAMES[profile.group][3]
		for i in 3:
			_spawn_boss_add(enemy, "fast", rng.randf_range(-1.0, 1.0), rng.randf_range(125.0, 168.0))


func _update_filovirus_boss(enemy: Dictionary, profile: Dictionary) -> void:
	var frame_index = int(floor(run_time * 1.35)) % FRAMES[profile.group].size()
	enemy.sprite.region_rect = FRAMES[profile.group][frame_index]
	if float(enemy.attack_cd) <= 0.0:
		var difficulty = _difficulty_multiplier()
		enemy.attack_cd = (float(profile.attack_interval) + rng.randf_range(-0.25, 0.55)) / sqrt(difficulty)
		var lane = 1.0 if sin(run_time * 1.7) > 0.0 else -1.0
		_spawn_boss_add(enemy, "fast", lane * 0.7, rng.randf_range(138.0, 178.0))
		_spawn_boss_add(enemy, "tank", -lane * 0.55, rng.randf_range(70.0, 92.0))


func _spawn_boss_add(boss: Dictionary, enemy_type: String, angle: float, speed: float) -> void:
	var pos = Vector2(float(boss.pos.x) - float(boss.radius) * 0.55, clampf(float(boss.pos.y) + sin(angle) * float(boss.radius) * 0.95, 120.0, BASE_SIZE.y - 110.0))
	var difficulty = _difficulty_multiplier()
	var velocity = Vector2(-speed * (1.0 + maxf(0.0, difficulty - 1.0) * 0.16), sin(angle) * rng.randf_range(34.0, 58.0))
	_spawn_enemy(enemy_type, {"pos": pos, "vel": velocity, "speed": speed, "spread_timer": rng.randf_range(0.45, 0.75), "boss_add": true})


func _spawn_boss_fragment(boss: Dictionary, direction: int) -> void:
	var pos = Vector2(float(boss.pos.x) + rng.randf_range(10.0, 22.0), clampf(float(boss.pos.y) + direction * rng.randf_range(24.0, 46.0), 120.0, BASE_SIZE.y - 110.0))
	var velocity = Vector2(-rng.randf_range(150.0, 205.0), direction * rng.randf_range(36.0, 72.0))
	_spawn_enemy("fragment", {"pos": pos, "vel": velocity, "spread_timer": rng.randf_range(0.35, 0.65), "boss_add": true})


func _update_props(delta: float) -> void:
	for cell in red_cells:
		var cell_pos: Vector2 = cell.pos
		cell_pos.x -= (float(cell.speed) + 185.0 * float(cell.depth) * 0.26) * delta
		cell_pos.y += sin(run_time * 1.2 + float(cell.wobble)) * float(cell.drift) * delta
		cell.pos = cell_pos
		cell.rotation = float(cell.rotation) + float(cell.spin) * delta
		cell.sprite.position = cell_pos
		cell.sprite.rotation = float(cell.rotation)
		if cell_pos.x < -float(cell.radius) * 2.0:
			cell.dead = true
	_cleanup_group(red_cells)
	for platelet in platelets:
		var platelet_pos: Vector2 = platelet.pos
		platelet_pos += platelet.vel * delta
		platelet_pos.x -= 185.0 * 0.3 * delta
		platelet.pos = platelet_pos
		platelet.angle = float(platelet.angle) + float(platelet.spin) * delta
		platelet.sprite.position = platelet_pos
		platelet.sprite.rotation = float(platelet.angle)
		if platelet_pos.x < -float(platelet.radius) * 3.0:
			platelet.dead = true
	_cleanup_group(platelets)


func _update_particles(delta: float) -> void:
	for particle in particles:
		particle.life -= delta
		particle.pos += particle.vel * delta
		particle.sprite.position = particle.pos
		if particle.has("scale_start") or particle.has("scale_end"):
			var progress = 1.0 - clampf(float(particle.life) / float(particle.max_life), 0.0, 1.0)
			var eased = 1.0 - pow(1.0 - progress, 2.0)
			var scale_start = float(particle.get("scale_start", 1.0))
			var scale_end = float(particle.get("scale_end", 1.0))
			var scale_value = lerpf(scale_start, scale_end, eased)
			particle.sprite.scale = Vector2.ONE * scale_value
		var fade = clampf(particle.life / particle.max_life, 0.0, 1.0)
		particle.sprite.modulate.a = pow(fade, float(particle.get("fade_power", 1.0)))
		particle.sprite.rotation += particle.get("spin", 0.0) * delta
		if particle.life <= 0.0:
			particle.dead = true
	_cleanup_group(particles)


func _update_collisions() -> void:
	for enemy in enemies:
		if enemy.dead:
			continue
		if enemy.pos.distance_to(player.pos) <= enemy.radius + PLAYER_COLLISION_RADIUS:
			if player.dash_timer > 0.0:
				enemy.vel += (enemy.pos - player.pos).normalized() * 170.0
			else:
				_hurt_player(float(enemy.damage), enemy.pos, Color(1.0, 0.25, 0.35))
				if enemy.type != "boss":
					enemy.dead = true
					_spawn_pop(enemy.pos, Color(1.0, 0.25, 0.35))
	for cell in red_cells:
		if cell.get("dead", false):
			continue
		var delta_to_player: Vector2 = player.pos - cell.pos
		var distance = delta_to_player.length()
		var collision_radius = PLAYER_COLLISION_RADIUS + float(cell.radius) * 0.72
		if distance < collision_radius and distance > 0.001:
			var normal = delta_to_player / distance
			var push = (collision_radius - distance) * 0.28
			player.pos += normal * push
			player.vel += normal * 42.0
	for platelet in platelets:
		if not platelet.dead and platelet.pos.distance_to(player.pos) <= PLAYER_COLLISION_RADIUS + platelet.radius * 0.86:
			if player.dash_timer > 0.0:
				platelet.dead = true
				_spawn_pop(platelet.pos, Color(1.0, 0.82, 0.32))
				if platelet_hit_sound_timer <= 0.0:
					_play_sfx("platelet_hit")
					platelet_hit_sound_timer = 0.18
				continue
			if platelet_hit_sound_timer <= 0.0:
				_play_sfx("platelet_hit")
				platelet_hit_sound_timer = 0.18
			_hurt_player(18.0, platelet.pos, Color(1.0, 0.82, 0.32), false)
			platelet.dead = true
	player.pos.x = clampf(player.pos.x, 60.0, BASE_SIZE.x - 90.0)
	player.pos.y = clampf(player.pos.y, 90.0, BASE_SIZE.y - 80.0)
	player.sprite.position = player.pos


func _hurt_player(amount: float, pos: Vector2, color: Color, play_damage_sound := true) -> void:
	if player.invulnerable > 0.0:
		return
	var previous_health = float(player.health)
	player.health = maxf(0.0, previous_health - amount)
	player.hurt_timer = 0.7
	player.invulnerable = 0.55
	if player.health > 0.0 and player.health <= PLAYER_MAX_HEALTH * DANGER_MUSIC_TRIGGER_RATIO:
		danger_music_active = true
	_spawn_pop(pos, color)
	if play_damage_sound and player.health > 0.0 and player_damage_sound_timer <= 0.0:
		_play_sfx("player_damage")
		player_damage_sound_timer = 0.18
	if player.health <= 0.0:
		_end_run()


func _damage_enemy(enemy: Dictionary, amount: float) -> void:
	var enemy_id = int(enemy.get("id", -1))
	var index = _find_enemy_index_by_id(enemy_id)
	if index != -1:
		_damage_enemy_at(index, amount)


func _check_influenza_replication(enemy: Dictionary) -> void:
	if enemy.repro_cd > 0.0 or enemies.size() > 46:
		return
	for other in enemies:
		if other == enemy or other.dead or other.type != "influenza":
			continue
		if other.repro_cd <= 0.0 and other.pos.distance_to(enemy.pos) < enemy.radius + other.radius:
			enemy.repro_cd = 1.2
			other.repro_cd = 1.2
			var midpoint = (enemy.pos + other.pos) * 0.5
			for i in 2:
				_spawn_influenza_clone(midpoint, Vector2.RIGHT.rotated(rng.randf_range(0, TAU)) * rng.randf_range(90, 150))
			_play_sfx("influenza_replicate")
			break


func _spawn_influenza_clone(pos: Vector2, push: Vector2) -> void:
	var frame = FRAMES.influenza[rng.randi_range(0, FRAMES.influenza.size() - 1)]
	var sprite = _make_sprite(INFLUENZA_SHEET, frame, pos + push.normalized() * 18.0, 0.16)
	sprite.z_index = 12
	entity_root.add_child(sprite)
	enemies.append({
		"id": _next_enemy_id(),
		"type": "influenza",
		"pos": sprite.position,
		"vel": push + Vector2(-82, rng.randf_range(-20, 20)),
		"radius": 28.0,
		"hp": 2.8,
		"max_hp": 2.8,
		"score": 35,
		"damage": 16.0,
		"repro_cd": 1.1,
		"sprite": sprite,
		"dead": false,
	})


func _finish_level() -> void:
	if waiting_for_upgrade or game_over:
		return
	waiting_for_upgrade = true
	_reset_held_action_inputs()
	sections_cleared += 1
	player.invulnerable = maxf(float(player.invulnerable), 3.0)
	pending_music = ""
	pending_music_timer = 0.0
	music_player.stop()
	current_music = ""
	_play_priority_sfx("level_complete", priority_sfx_player, true)
	level_clear_timer = 1.15 if boss_defeated else LEVEL_CLEAR_DELAY
	complete_panel.visible = false


func _update_level_complete_pending(delta: float) -> void:
	level_clear_timer = maxf(0.0, level_clear_timer - delta)
	_update_particles(delta)
	if level_clear_timer <= 0.0:
		_show_level_complete_panel()


func _show_level_complete_panel() -> void:
	var panel = complete_panel.get_node("Panel") as Control
	var title = panel.get_node("Title") as Label
	var body = panel.get_node("Body") as Label
	var button = panel.get_node("ActionButton") as Button
	var button_label = panel.get_node("ActionButtonLabel") as Label
	var next_mission = _mission_for_level(level + 1)
	var result_text = active_mission.get("boss_target", active_mission.get("target", "virions"))
	if _is_encounter_level():
		result_text = "%s neutralized after %s %s" % [result_text, level_kills, active_mission.get("target", "virions")]
	else:
		result_text = "%s %s neutralized" % [level_kills, active_mission.get("target", "virions")]
	title.text = "Level %s Complete" % level
	body.text = "%s: %s\n%s\nScore %s  |  Health %s%%\nNext: %s (%s)" % [
		active_mission.name,
		active_mission.term,
		result_text,
		score,
		roundi(player.health),
		next_mission.name,
		next_mission.term,
	]
	button.text = ""
	button_label.text = "Continue" if _all_upgrades_complete() else "Choose Adaptation"
	complete_panel.visible = true
	_queue_music("upgrade", 0.55)


func _open_upgrade_screen() -> void:
	complete_panel.visible = false
	_reset_held_action_inputs()
	if _all_upgrades_complete():
		_continue_to_next_level()
		return
	_update_upgrade_panel()
	upgrade_panel.visible = true


func _update_upgrade_panel() -> void:
	var panel = upgrade_panel.get_node("Panel") as Control
	if upgrade_intro_label != null:
		var next_mission = _mission_for_level(level + 1)
		upgrade_intro_label.text = "Section %s cleared. Prepare for %s: %s." % [level, next_mission.name, next_mission.term]
	for card in panel.get_children():
		if card is Panel and card.has_node("RankLabel"):
			var id = str(card.get_meta("upgrade_id", ""))
			if not UPGRADES.has(id):
				continue
			var rank = int(upgrades[id])
			var maxed = rank >= MAX_UPGRADE_RANK
			var label = card.get_node("RankLabel") as Label
			label.text = "Fully adapted" if maxed else "%s\n%s" % ["New adaptation" if rank == 0 else "Current rank %s" % rank, UPGRADES[id].ranks[rank]]
			for i in MAX_UPGRADE_RANK:
				if card.has_node("Pip%s" % i):
					_style_upgrade_pip(card.get_node("Pip%s" % i) as Panel, id, i < rank, 1.0)
			var button = card.get_node("ChooseButton") as Button
			button.disabled = maxed
			button.text = "Maxed" if maxed else "Choose"
			_apply_upgrade_card_style(card, id, rank > 0 and not maxed)


func _update_upgrade_pip_pulse() -> void:
	if upgrade_panel == null or not upgrade_panel.visible:
		return
	var pulse = 1.0 + sin(Time.get_ticks_msec() / 1000.0 * 4.2) * 0.16
	for id in upgrade_cards.keys():
		var card = upgrade_cards[id] as Panel
		var rank = int(upgrades[id])
		for i in MAX_UPGRADE_RANK:
			if card.has_node("Pip%s" % i):
				_style_upgrade_pip(card.get_node("Pip%s" % i) as Panel, id, i < rank, pulse)


func _select_upgrade(id: String) -> void:
	if upgrades[id] < MAX_UPGRADE_RANK:
		upgrades[id] += 1
	_play_sfx("upgrade_selected")
	upgrade_panel.visible = false
	_continue_to_next_level()


func _continue_to_next_level() -> void:
	waiting_for_upgrade = false
	_load_level(level + 1)
	player.health = minf(PLAYER_MAX_HEALTH, float(player.health) + 18.0)
	player.invulnerable = 1.2
	player.hurt_timer = 0.0
	player.pos.x = maxf(110.0, BASE_SIZE.x * 0.22)
	player.pos.y = clampf(player.pos.y, 90.0, BASE_SIZE.y - 80.0)
	player.sprite.position = player.pos
	_spawn_pop(player.pos, Color(0.73, 1.0, 0.9))
	_play_desired_music()


func _end_run() -> void:
	if game_over:
		return
	game_over = true
	running = false
	_reset_held_action_inputs()
	_play_sfx("player_death")
	music_player.stop()
	current_music = ""
	_queue_music("menu", 0.65)
	if banner_label != null:
		banner_label.visible = false
	game_over_panel.visible = true
	if game_over_subtitle_label != null:
		game_over_subtitle_label.text = "Run ended during %s: %s." % [active_mission.get("name", "the bloodstream"), active_mission.get("term", "immune response")]
	if game_over_values.has("score"):
		(game_over_values.score as Label).text = "%s" % score
	if game_over_values.has("level"):
		(game_over_values.level as Label).text = "%s" % level
	if game_over_values.has("sections"):
		(game_over_values.sections as Label).text = "%s" % sections_cleared
	if game_over_values.has("virions"):
		(game_over_values.virions as Label).text = "%s" % total_kills
	if game_over_values.has("bosses"):
		(game_over_values.bosses as Label).text = "%s" % bosses_neutralized
	if game_over_values.has("time"):
		(game_over_values.time as Label).text = _format_time(run_time)
	if game_over_adaptations_label != null:
		game_over_adaptations_label.text = _adaptation_summary()


func _update_level_flow(delta: float) -> void:
	if _is_encounter_level():
		return
	if _level_progress() >= 1.0 and level_kills >= level_goal:
		_finish_level()


func _is_encounter_level() -> bool:
	return active_mission.has("encounter")


func _boss_trigger_progress() -> float:
	return boss_trigger_progress


func _level_progress() -> float:
	return clampf(scroll / level_length, 0.0, 1.0)


func _combined_level_progress() -> float:
	if _is_encounter_level():
		var boss = _active_boss()
		if boss_defeated:
			return 1.0
		var approach_progress = clampf(_level_progress() / maxf(0.05, boss_trigger_progress), 0.0, 1.0) * 0.82
		if boss.size() > 0:
			var boss_progress = 1.0 - clampf(float(boss.hp) / maxf(1.0, float(boss.max_hp)), 0.0, 1.0)
			return 0.82 + boss_progress * 0.18
		return approach_progress
	var kill_progress = clampf(float(level_kills) / maxf(1.0, float(level_goal)), 0.0, 1.0)
	return (_level_progress() + kill_progress) * 0.5


func _difficulty_multiplier(value: int = -1) -> float:
	var measured_level = level if value == -1 else value
	if measured_level <= 4:
		return 1.0
	return pow(1.2, measured_level - 4)


func _level_spawn_scale() -> float:
	var difficulty = _difficulty_multiplier()
	var base_spawn_scale = maxf(0.42, 0.86 - level * 0.035) if _is_encounter_level() else maxf(0.58, 1.0 - level * 0.055)
	return maxf(0.28, base_spawn_scale / sqrt(difficulty))


func _next_platelet_spawn_delay(spawn_scale: float) -> float:
	var intensity = clampf(float(level - 1) / 8.0, 0.0, 1.0)
	var min_delay = lerpf(3.7, 2.25, intensity)
	var max_delay = lerpf(6.25, 4.25, intensity)
	if rng.randf() < lerpf(0.12, 0.28, intensity):
		min_delay *= 0.58
		max_delay *= 0.68
	return rng.randf_range(min_delay, max_delay) * maxf(0.74, spawn_scale)


func _platelet_limit() -> int:
	if _is_encounter_level():
		return mini(PLATELET_MAX_ACTIVE, 2 + int(level >= 5) + int(level >= 9))
	return mini(PLATELET_MAX_ACTIVE, 2 + int(level >= 4) + int(level >= 7) + int(level >= 10))


func _active_platelet_count() -> int:
	var count = 0
	for platelet in platelets:
		if not platelet.get("dead", false):
			count += 1
	return count


func _pick_enemy_type() -> String:
	var roll = rng.randf()
	var is_influenza_bloom = level >= 4 and active_mission.get("name", "") == "Influenza Bloom"
	var chosen = "basic"
	if level >= 4 and (roll > (0.28 if is_influenza_bloom else 0.84)):
		chosen = "influenza"
	elif roll > 0.88 and level > 3:
		chosen = "budding"
	elif roll > 0.76 and level > 2:
		chosen = "tank"
	elif roll > 0.52:
		chosen = "fast"
	if chosen == "influenza" and _count_live_influenza() >= _influenza_cap():
		chosen = "tank" if level > 2 and roll > 0.62 else "fast"
	return chosen


func _enemy_stats(enemy_type: String) -> Dictionary:
	var difficulty = _difficulty_multiplier()
	var level_boost = minf(12.0, level - 1.0) * (1.0 + maxf(0.0, difficulty - 1.0) * 0.45)
	var stats_by_type = {
		"basic": {"visual_group": "green_virus", "radius": rng.randf_range(18.0, 25.0), "hp": 2.0, "speed": rng.randf_range(82.0, 118.0) + level_boost * 8.0, "score": 20, "damage": 14.0},
		"fast": {"visual_group": "purple_virus", "radius": rng.randf_range(14.0, 19.0), "hp": 1.0, "speed": rng.randf_range(135.0, 178.0) + level_boost * 10.0, "score": 30, "damage": 14.0},
		"tank": {"visual_group": "purple_virus", "radius": rng.randf_range(28.0, 36.0), "hp": 4.0, "speed": rng.randf_range(54.0, 82.0) + level_boost * 5.0, "score": 70, "damage": 22.0},
		"budding": {"visual_group": "green_virus", "radius": rng.randf_range(22.0, 29.0), "hp": 3.0, "speed": rng.randf_range(74.0, 104.0) + level_boost * 7.0, "score": 55, "damage": 14.0},
		"influenza": {"visual_group": "influenza", "radius": rng.randf_range(23.0, 31.0), "hp": 3.0, "speed": rng.randf_range(68.0, 96.0) + level_boost * 6.0, "score": 85, "damage": 16.0},
		"fragment": {"visual_group": "purple_virus", "radius": rng.randf_range(10.0, 14.0), "hp": 1.0, "speed": rng.randf_range(150.0, 205.0) + minf(8.0, level - 1.0) * 8.0, "score": 15, "damage": 6.0},
	}
	var stats = stats_by_type.get(enemy_type, stats_by_type.basic).duplicate(true)
	if difficulty > 1.0:
		var hp_bonus_scale = 1.2 if enemy_type == "fast" else (2.8 if enemy_type == "tank" else (2.2 if enemy_type == "influenza" else 1.9))
		var hp_bonus = floori(maxf(0.0, difficulty - 1.0) * hp_bonus_scale)
		stats.hp = float(stats.hp) + hp_bonus
		stats.speed = float(stats.speed) * (1.0 + maxf(0.0, difficulty - 1.0) * 0.22)
		stats.score = int(stats.score) + hp_bonus * 12
	return stats


func _count_live_influenza() -> int:
	var total = 0
	for enemy in enemies:
		if enemy.get("type", "") == "influenza" and not enemy.get("dead", false):
			total += 1
	return total


func _influenza_cap() -> int:
	if level < 4:
		return 0
	return mini(30, 12 + max(0, level - 4) * 3)


func _find_lock_target() -> Dictionary:
	var target_index := _find_lock_target_index()
	if target_index == -1:
		return {}
	return enemies[target_index]


func _find_lock_target_index() -> int:
	var best_index := -1
	var best_score := -INF
	for i in enemies.size():
		var enemy: Dictionary = enemies[i]
		if not _is_lockable_enemy(enemy):
			continue
		var score_value: float = _enemy_lock_score(enemy)
		if score_value <= -1000000.0:
			continue
		if score_value > best_score:
			best_score = score_value
			best_index = i
	return best_index


func _is_lockable_enemy(enemy: Dictionary) -> bool:
	if enemy.get("dead", false) or float(enemy.get("hp", 0.0)) <= 0.0:
		return false
	var pos: Vector2 = enemy.get("pos", Vector2.ZERO)
	return pos.x > -float(enemy.get("radius", 0.0)) - 24.0 and pos.x < BASE_SIZE.x + float(enemy.get("radius", 0.0)) + 120.0


func _enemy_lock_score(enemy: Dictionary) -> float:
	var pos: Vector2 = enemy["pos"]
	var delta_to_enemy: Vector2 = pos - player.pos
	var distance := delta_to_enemy.length()
	var nearly_touching = distance < 170.0
	var in_front = delta_to_enemy.x > -48.0
	var in_lane = absf(delta_to_enemy.y) < LOCK_VERTICAL_RANGE
	if not nearly_touching and (not in_front or (distance > LOCK_TARGET_RANGE and not in_lane)):
		return -1000000.0
	var closeness = 1.0 - clampf(distance / LOCK_TARGET_RANGE, 0.0, 1.0)
	var lane_match = 1.0 - clampf(absf(delta_to_enemy.y) / LOCK_VERTICAL_RANGE, 0.0, 1.0)
	var ahead_bonus = 1.0 if delta_to_enemy.x > 0.0 else 0.28
	var type_bonus = 0.0
	if enemy.get("type", "") == "boss":
		type_bonus = 1.65
	elif enemy.get("type", "") == "influenza":
		type_bonus = 1.1
	elif enemy.get("type", "") == "fast":
		type_bonus = 0.45
	elif enemy.get("type", "") == "tank":
		type_bonus = 0.25
	var stickiness = 1.8 if int(enemy.get("id", -1)) == lock_target_id else 0.0
	var behind_penalty = absf(delta_to_enemy.x) * 0.018 if delta_to_enemy.x < 0.0 else 0.0
	return closeness * 5.0 + lane_match * 3.2 + ahead_bonus + type_bonus + stickiness - behind_penalty


func _next_enemy_id() -> int:
	var enemy_id = next_enemy_id
	next_enemy_id += 1
	return enemy_id


func _find_enemy_index_by_id(enemy_id: int) -> int:
	if enemy_id == -1:
		return -1
	for i in enemies.size():
		var enemy: Dictionary = enemies[i]
		if int(enemy.get("id", -1)) == enemy_id and not enemy.get("dead", false):
			return i
	return -1


func _active_boss() -> Dictionary:
	for enemy in enemies:
		if enemy.get("type", "") == "boss" and not enemy.get("dead", false) and float(enemy.get("hp", 0.0)) > 0.0:
			return enemy
	return {}


func _update_lock_target() -> void:
	var index = _find_lock_target_index()
	lock_target_id = int(enemies[index].get("id", -1)) if index != -1 else -1


func _soft_clear_board() -> void:
	for enemy in enemies:
		if enemy.type != "boss":
			enemy.dead = true
	for item in platelets:
		item.dead = true


func _all_upgrades_complete() -> bool:
	return upgrades.rapid >= MAX_UPGRADE_RANK and upgrades.pulse >= MAX_UPGRADE_RANK and upgrades.dash >= MAX_UPGRADE_RANK


func _particle_budget() -> int:
	return MOBILE_MAX_PARTICLES if mobile_performance_mode else DESKTOP_MAX_PARTICLES


func _particle_spawn_count(count: int) -> int:
	if not mobile_performance_mode:
		return count
	return maxi(1, ceili(float(count) * MOBILE_PARTICLE_SCALE))


func _particle_segment_count(count: int) -> int:
	if not mobile_performance_mode:
		return count
	return maxi(8, ceili(float(count) * MOBILE_PULSE_SEGMENT_SCALE))


func _free_particle(particle: Dictionary) -> void:
	var sprite = particle.get("sprite", null)
	if is_instance_valid(sprite):
		sprite.queue_free()


func _append_particle(particle: Dictionary) -> void:
	var budget = _particle_budget()
	while particles.size() >= budget and particles.size() > 0:
		_free_particle(particles.pop_front())
	if budget <= 0:
		_free_particle(particle)
		return
	particles.append(particle)


func _spawn_pop(pos: Vector2, color: Color) -> void:
	for i in _particle_spawn_count(16):
		var dot := _make_particle_dot(pos, color, rng.randf_range(5.0, 12.0))
		_append_particle({
			"pos": pos,
			"vel": Vector2.RIGHT.rotated(rng.randf_range(0, TAU)) * rng.randf_range(100, 250),
			"life": rng.randf_range(0.45, 0.85),
			"max_life": 0.85,
			"sprite": dot,
			"spin": rng.randf_range(-4.0, 4.0),
			"dead": false,
		})


func _spawn_muzzle_spark(pos: Vector2, direction: Vector2) -> void:
	for i in _particle_spawn_count(7):
		var dot := _make_particle_dot(pos, Color(0.42, 1.0, 1.0, 0.82), rng.randf_range(2.0, 4.0))
		var spread = direction.rotated(rng.randf_range(-0.75, 0.75))
		_append_particle({
			"pos": pos,
			"vel": spread * rng.randf_range(52.0, 130.0),
			"life": rng.randf_range(0.16, 0.32),
			"max_life": 0.32,
			"sprite": dot,
			"spin": rng.randf_range(-3.0, 3.0),
			"dead": false,
		})


func _spawn_hit_spark(pos: Vector2, color: Color) -> void:
	for i in _particle_spawn_count(6):
		var dot := _make_particle_dot(pos, color, rng.randf_range(2.4, 5.0))
		_append_particle({
			"pos": pos,
			"vel": Vector2.RIGHT.rotated(rng.randf_range(0.0, TAU)) * rng.randf_range(46.0, 125.0),
			"life": rng.randf_range(0.18, 0.36),
			"max_life": 0.36,
			"sprite": dot,
			"spin": rng.randf_range(-4.0, 4.0),
			"dead": false,
		})


func _spawn_dash_wake() -> void:
	var facing = -1.0 if player_facing_left else 1.0
	var origin = player.pos + Vector2(-facing * 38.0, rng.randf_range(-18.0, 18.0))
	var dot := _make_particle_dot(origin, Color(0.72, 1.0, 1.0, 0.62), rng.randf_range(3.0, 6.0))
	_append_particle({
		"pos": origin,
		"vel": Vector2(-facing * rng.randf_range(60.0, 145.0), rng.randf_range(-18.0, 18.0)),
		"life": rng.randf_range(0.20, 0.38),
		"max_life": 0.38,
		"sprite": dot,
		"spin": rng.randf_range(-2.0, 2.0),
		"dead": false,
	})


func _spawn_pulse_wave(pos: Vector2, radius: float, rank: int) -> void:
	var rank_boost = _pulse_rank_boost(rank)
	var life = _pulse_life_for_rank(rank)
	var sphere := _make_particle_circle(pos, Color(0.24, 0.96, 1.0, 0.24), radius, _particle_segment_count(64))
	_append_particle({"pos": pos, "vel": Vector2.ZERO, "life": life, "max_life": life, "sprite": sphere, "spin": 0.0, "scale_start": 0.06, "scale_end": 1.0, "fade_power": 0.58, "dead": false})

	if not mobile_performance_mode:
		var inner_glow := _make_particle_circle(pos, Color(0.78, 1.0, 0.92, 0.20), radius * 0.54, 48)
		_append_particle({"pos": pos, "vel": Vector2.ZERO, "life": life * 0.82, "max_life": life * 0.82, "sprite": inner_glow, "spin": 0.0, "scale_start": 0.18, "scale_end": 1.16, "fade_power": 0.62, "dead": false})

	var bright_rim := _make_particle_ring(pos, Color(0.78, 1.0, 1.0, 1.0), radius, 12.0 + rank_boost * 4.0, _particle_segment_count(96))
	_append_particle({"pos": pos, "vel": Vector2.ZERO, "life": life, "max_life": life, "sprite": bright_rim, "spin": 0.0, "scale_start": 0.08, "scale_end": 1.0, "fade_power": 0.52, "dead": false})

	if not mobile_performance_mode:
		var gold_rim := _make_particle_ring(pos, Color(1.0, 0.82, 0.34, 0.86), radius * 0.82, 5.4 + rank_boost * 1.8, 80)
		_append_particle({"pos": pos, "vel": Vector2.ZERO, "life": life * 0.92, "max_life": life * 0.92, "sprite": gold_rim, "spin": 0.0, "scale_start": 0.10, "scale_end": 1.12, "fade_power": 0.58, "dead": false})


func _pulse_rank_boost(rank: int) -> float:
	return clampf(float(rank - 1) / maxf(1.0, float(MAX_UPGRADE_RANK - 1)), 0.0, 1.0)


func _pulse_life_for_rank(rank: int) -> float:
	return 0.58 + _pulse_rank_boost(rank) * 0.12


func _make_particle_circle(pos: Vector2, color: Color, radius: float, segments: int) -> Polygon2D:
	var circle := Polygon2D.new()
	var points: PackedVector2Array = []
	for i in segments:
		points.append(Vector2.RIGHT.rotated(TAU * i / segments) * radius)
	circle.polygon = points
	circle.color = color
	circle.position = pos
	circle.z_index = 38
	fx_root.add_child(circle)
	return circle


func _make_particle_ring(pos: Vector2, color: Color, radius: float, width: float, segments: int) -> Line2D:
	var ring := Line2D.new()
	var points: PackedVector2Array = []
	for i in segments + 1:
		points.append(Vector2.RIGHT.rotated(TAU * i / segments) * radius)
	ring.points = points
	ring.default_color = color
	ring.width = width
	ring.joint_mode = Line2D.LINE_JOINT_ROUND
	ring.begin_cap_mode = Line2D.LINE_CAP_ROUND
	ring.end_cap_mode = Line2D.LINE_CAP_ROUND
	ring.antialiased = true
	ring.position = pos
	ring.z_index = 42
	fx_root.add_child(ring)
	return ring


func _make_particle_dot(pos: Vector2, color: Color, radius: float) -> Polygon2D:
	var dot := Polygon2D.new()
	var points: PackedVector2Array = []
	for i in 8:
		points.append(Vector2.RIGHT.rotated(TAU * i / 8.0) * radius)
	dot.polygon = points
	dot.color = color
	dot.position = pos
	dot.z_index = 40
	fx_root.add_child(dot)
	return dot


func _show_banner(text: String) -> void:
	if banner_label == null:
		print(text)
		return
	banner_label.text = text
	banner_label.visible = true
	banner_label.modulate = Color(1.0, 1.0, 1.0, 1.0)
	banner_timer = 2.35
	print(text)


func _update_banner(delta: float) -> void:
	if banner_label == null or not banner_label.visible:
		return
	banner_timer = maxf(0.0, banner_timer - delta)
	if banner_timer <= 0.0:
		banner_label.visible = false
	elif banner_timer < 0.45:
		banner_label.modulate.a = banner_timer / 0.45


func _set_music_muted(value: bool) -> void:
	music_muted = value
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), music_muted)
	if music_muted:
		if music_player != null and music_player.playing:
			music_player.stop()
		if ambience_player != null and ambience_player.playing:
			ambience_player.stop()
		_stop_boss_warning_audio()
		return
	if _boss_warning_audio_active():
		_play_boss_warning_audio()
	else:
		_play_desired_music()
		_sync_ambience()


func _set_sfx_muted(value: bool) -> void:
	sfx_muted = value
	AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), sfx_muted)
	if sfx_muted:
		_stop_all_sfx()
	elif _boss_warning_audio_active():
		_play_boss_warning_audio()


func _stop_all_sfx() -> void:
	for player_node in sfx_players:
		if player_node.playing:
			player_node.stop()
	if priority_sfx_player != null and priority_sfx_player.playing:
		priority_sfx_player.stop()
	_stop_boss_warning_audio()


func _boss_warning_audio_active() -> bool:
	return boss_warning_started and not boss_spawned and boss_warning_timer > 0.0 and not music_muted and not sfx_muted and audio_streams.has("boss_warning")


func _play_priority_sfx(key: String, player_node: AudioStreamPlayer, restart := true) -> void:
	if sfx_muted or player_node == null or not audio_streams.has(key):
		return
	if restart and player_node.playing:
		player_node.stop()
	player_node.stream = audio_streams[key]
	player_node.volume_db = AUDIO[key].volume
	player_node.play()


func _play_boss_warning_audio() -> void:
	if music_muted or sfx_muted or not audio_streams.has("boss_warning"):
		return
	pending_music = ""
	pending_music_timer = 0.0
	if music_player != null and music_player.playing:
		music_player.stop()
	current_music = ""
	if ambience_player != null and ambience_player.playing:
		ambience_player.stop()
	_play_priority_sfx("boss_warning", boss_warning_player, true)


func _stop_boss_warning_audio() -> void:
	if boss_warning_player != null and boss_warning_player.playing:
		boss_warning_player.stop()


func _play_music(key: String) -> void:
	if music_muted or not audio_streams.has(key):
		return
	if key == current_music and music_player.playing:
		return
	current_music = key
	music_player.stream = audio_streams[key]
	music_player.volume_db = AUDIO[key].volume
	music_player.play()
	_sync_ambience()


func _play_desired_music() -> void:
	var key = _desired_music_key()
	if key != "":
		_play_music(key)


func _refresh_gameplay_music() -> void:
	if music_muted or pending_music != "" or paused or _boss_warning_audio_active():
		return
	if waiting_for_upgrade or upgrade_panel.visible or complete_panel.visible or game_over or start_panel.visible or not running:
		return
	var key = _desired_music_key()
	if key != "" and key != current_music:
		_play_music(key)


func _desired_music_key() -> String:
	if pending_music != "":
		return ""
	if waiting_for_upgrade or upgrade_panel.visible or complete_panel.visible:
		return "upgrade"
	if game_over or start_panel.visible or not running:
		return "menu"
	if paused:
		return current_music if current_music != "" else "combat"
	if _is_encounter_level() and (boss_spawned or _active_boss().size() > 0):
		return "boss"
	if _danger_music_should_play():
		return "danger"
	return "combat"


func _danger_music_should_play() -> bool:
	if player.health >= PLAYER_MAX_HEALTH * DANGER_MUSIC_RESET_RATIO:
		danger_music_active = false
	return danger_music_active


func _queue_music(key: String, delay: float) -> void:
	pending_music = key
	pending_music_timer = maxf(0.0, delay)


func _update_pending_music(delta: float) -> void:
	if pending_music == "":
		return
	pending_music_timer = maxf(0.0, pending_music_timer - delta)
	if pending_music_timer <= 0.0:
		var next_music = pending_music
		pending_music = ""
		_play_music(next_music)


func _sync_ambience() -> void:
	if ambience_player == null or not audio_streams.has("ambience"):
		return
	var should_play = running and not game_over and not start_panel.visible and not music_muted and not _boss_warning_audio_active()
	if should_play:
		if ambience_player.stream != audio_streams["ambience"]:
			ambience_player.stream = audio_streams["ambience"]
			ambience_player.volume_db = AUDIO["ambience"].volume
		if not ambience_player.playing:
			ambience_player.play()
	else:
		if ambience_player.playing:
			ambience_player.stop()


func _play_sfx(key: String) -> void:
	if sfx_muted or not audio_streams.has(key):
		return
	for player_node in sfx_players:
		if not player_node.playing:
			player_node.stream = audio_streams[key]
			var volume_db = AUDIO[key].volume
			if _boss_warning_audio_active():
				volume_db -= 12.0
			player_node.volume_db = volume_db
			player_node.play()
			return


func _play_ui_hover() -> void:
	if ui_hover_sound_timer > 0.0:
		return
	_play_sfx("upgrade_hover")
	ui_hover_sound_timer = 0.08


func _visible_game_size() -> Vector2:
	var viewport_size = get_viewport_rect().size
	return Vector2(maxf(BASE_SIZE.x, viewport_size.x), maxf(BASE_SIZE.y, viewport_size.y))


func _update_viewport_layout() -> void:
	var visible_size = _visible_game_size()
	if visible_size == _cached_visible_game_size:
		return
	_cached_visible_game_size = visible_size
	var stage_origin = _stage_origin_for_size(visible_size)
	if bg_root != null:
		bg_root.position = Vector2.ZERO
		bg_root.scale = Vector2.ONE
	if game_stage_root != null:
		game_stage_root.position = stage_origin
		game_stage_root.scale = Vector2.ONE
	if ui_stage != null:
		ui_stage.position = stage_origin
		ui_stage.scale = Vector2.ONE
		ui_stage.size = BASE_SIZE
	if progress_bar != null:
		progress_bar.position = Vector2((BASE_SIZE.x - progress_bar.size.x) * 0.5, BASE_SIZE.y - 50.0)
	_refresh_background_layout(visible_size)


func _refresh_background_layout(visible_size: Vector2) -> void:
	for holder in bg_root.get_children():
		var texture_size = visible_size
		if holder.get_child_count() > 0:
			var first_sprite = holder.get_child(0) as Sprite2D
			if first_sprite.texture:
				texture_size = first_sprite.texture.get_size()
		var layer_scale = maxf(visible_size.x / texture_size.x, visible_size.y / texture_size.y)
		var draw_width = texture_size.x * layer_scale
		var draw_height = texture_size.y * layer_scale
		holder.set_meta("layer_scale", layer_scale)
		holder.set_meta("draw_width", draw_width)
		holder.set_meta("draw_y", (visible_size.y - draw_height) * 0.5)


func _update_backgrounds() -> void:
	var visible_size = _cached_visible_game_size
	if visible_size.x < 0.0:
		visible_size = _visible_game_size()
		_cached_visible_game_size = visible_size
		_refresh_background_layout(visible_size)
	for holder in bg_root.get_children():
		var speed = float(holder.get_meta("speed", 0.1))
		var layer_scale = float(holder.get_meta("layer_scale", 1.0))
		var draw_width = float(holder.get_meta("draw_width", visible_size.x))
		var y = float(holder.get_meta("draw_y", 0.0))
		var scroll_position = scroll * speed
		var base_index = floori(scroll_position / draw_width)
		var local_offset = -(scroll_position - float(base_index) * draw_width)
		for i in holder.get_child_count():
			var sprite = holder.get_child(i) as Sprite2D
			var tile = i - 1
			var mirrored = int(base_index + tile) % 2 != 0
			var x = local_offset + float(tile) * draw_width
			sprite.position = Vector2(x + (draw_width if mirrored else 0.0), y)
			sprite.scale = Vector2(-layer_scale if mirrored else layer_scale, layer_scale)


func _set_label_text_if_changed(label: Label, text: String) -> void:
	if label != null and label.text != text:
		label.text = text


func _update_hud() -> void:
	_set_label_text_if_changed(score_label, "%s" % score)
	if health_bar != null:
		var health_value = clampf(player.health, 0.0, PLAYER_MAX_HEALTH)
		if absf(float(health_bar.value) - health_value) > 0.05:
			health_bar.value = health_value
	_set_label_text_if_changed(level_label, "%s" % level)
	if mission_label != null:
		_set_label_text_if_changed(mission_label, str(active_mission.get("name", "")))
	if mission_objective_label != null:
		_set_label_text_if_changed(mission_objective_label, str(active_mission.get("objective", "")))
	if target_label != null:
		var remaining = max(0, level_goal - level_kills)
		var target_text = ""
		if _is_encounter_level():
			var boss = _active_boss()
			if boss.size() > 0:
				target_text = "%s integrity left" % ceili(float(boss.hp))
			elif boss_warning_started and not boss_spawned:
				target_text = "Pathogen signal building"
			else:
				target_text = "%s %s left" % [remaining, active_mission.get("target", "virions")]
		else:
			target_text = "%s %s left" % [remaining, active_mission.get("target", "virions")]
		_set_label_text_if_changed(target_label, target_text)
	if progress_bar != null:
		var progress_value = _combined_level_progress() * 100.0
		if absf(float(progress_bar.value) - progress_value) > 0.05:
			progress_bar.value = progress_value
	if dash_label != null:
		_set_label_text_if_changed(dash_label, _ability_status_short("dash"))
	if pulse_label != null:
		_set_label_text_if_changed(pulse_label, _ability_status_short("pulse"))
	var player_visible = running and not game_over
	if is_instance_valid(player.sprite) and player.sprite.visible != player_visible:
		player.sprite.visible = player_visible


func _ability_status(id: String) -> String:
	var rank = int(upgrades[id])
	if rank <= 0:
		return "%s locked" % ("Dash" if id == "dash" else "Pulse")
	var cooldown = float(player.dash_cd if id == "dash" else player.pulse_cd)
	if cooldown > 0.05:
		return "%s %.1fs" % ["Dash" if id == "dash" else "Pulse", cooldown]
	return "%s ready" % ("Dash" if id == "dash" else "Pulse")


func _ability_status_short(id: String) -> String:
	var rank = int(upgrades[id])
	if rank <= 0:
		return "Locked"
	var cooldown = float(player.dash_cd if id == "dash" else player.pulse_cd)
	if cooldown > 0.05:
		return "%.1fs" % cooldown
	return "Ready"


func _cleanup_group(group: Array) -> void:
	for i in range(group.size() - 1, -1, -1):
		if group[i].get("dead", false):
			if group[i].has("sprite") and is_instance_valid(group[i].sprite):
				group[i].sprite.queue_free()
			group.remove_at(i)


func _format_time(seconds: float) -> String:
	var total = int(seconds)
	return "%s:%02d" % [total / 60, total % 60]


func _adaptation_summary() -> String:
	var rows: Array[String] = []
	var short_names := {
		"rapid": "Rapid",
		"pulse": "Pulse",
		"dash": "Dash",
	}
	for id in ["rapid", "pulse", "dash"]:
		var rank = int(upgrades[id])
		if rank > 0:
			rows.append("%s r%s" % [short_names[id], rank])
	if rows.is_empty():
		return "No adaptations selected"
	if rows.size() >= 3:
		return "%s, %s\n%s" % [rows[0], rows[1], rows[2]]
	return ", ".join(rows)
