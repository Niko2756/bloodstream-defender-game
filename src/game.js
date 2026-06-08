const canvas = document.querySelector("#game");
const ctx = canvas.getContext("2d");
const gameShellEl = document.querySelector(".game-shell");
const phaserStageEl = document.querySelector("#phaserStage");
const scoreEl = document.querySelector("#score");
const levelEl = document.querySelector("#level");
const healthBar = document.querySelector("#healthBar");
const hudEl = document.querySelector(".hud");
const levelProgressEl = document.querySelector("#levelProgress");
const levelMeterEl = document.querySelector(".level-meter");
const levelBannerEl = document.querySelector("#levelBanner");
const overlay = document.querySelector("#startOverlay");
const startButton = document.querySelector("#startButton");
const gameOverOverlay = document.querySelector("#gameOverOverlay");
const gameOverFrameEl = document.querySelector(".game-over-frame");
const gameOverSubtitleEl = document.querySelector("#gameOverSubtitle");
const gameOverScoreEl = document.querySelector("#gameOverScore");
const gameOverLevelEl = document.querySelector("#gameOverLevel");
const gameOverSectionsEl = document.querySelector("#gameOverSections");
const gameOverVirionsEl = document.querySelector("#gameOverVirions");
const gameOverTimeEl = document.querySelector("#gameOverTime");
const gameOverBossesEl = document.querySelector("#gameOverBosses");
const gameOverAdaptationsEl = document.querySelector("#gameOverAdaptations");
const gameOverRestartButton = document.querySelector("#gameOverRestartButton");
const pauseButton = document.querySelector("#pauseButton");
const pauseButtonText = document.querySelector("#pauseButtonText");
const pauseOverlay = document.querySelector("#pauseOverlay");
const resumeButton = document.querySelector("#resumeButton");
const musicMuteButton = document.querySelector("#musicMuteButton");
const sfxMuteButton = document.querySelector("#sfxMuteButton");
const restartButton = document.querySelector("#restartButton");
const restartConfirm = document.querySelector("#restartConfirm");
const cancelRestartButton = document.querySelector("#cancelRestartButton");
const confirmRestartButton = document.querySelector("#confirmRestartButton");
const levelCompleteOverlay = document.querySelector("#levelCompleteOverlay");
const levelCompletePanelEl = document.querySelector(".level-complete-panel");
const levelCompleteTitleEl = document.querySelector("#levelCompleteTitle");
const levelCompleteMissionEl = document.querySelector("#levelCompleteMission");
const levelCompleteScoreEl = document.querySelector("#levelCompleteScore");
const levelCompleteKillsEl = document.querySelector("#levelCompleteKills");
const levelCompleteHealthEl = document.querySelector("#levelCompleteHealth");
const nextMissionPreviewEl = document.querySelector("#nextMissionPreview");
const showUpgradeButton = document.querySelector("#showUpgradeButton");
const missionPanelEl = document.querySelector(".mission-panel");
const missionNameEl = document.querySelector("#missionName");
const objectiveTextEl = document.querySelector("#objectiveText");
const virusesLeftEl = document.querySelector("#virusesLeft");
const abilityDashEl = document.querySelector("#abilityDash");
const abilityPulseEl = document.querySelector("#abilityPulse");
const runSummaryEl = document.querySelector("#runSummary");
const upgradeOverlay = document.querySelector("#upgradeOverlay");
const upgradePanelEl = document.querySelector(".upgrade-panel");
const upgradeIntroEl = document.querySelector("#upgradeIntro");
const upgradeCards = Array.from(document.querySelectorAll(".upgrade-node"));
const mobileControlsEl = document.querySelector(".mobile-controls");
const mobileJoystickEl = document.querySelector("#mobileJoystick");
const mobileJoystickKnobEl = document.querySelector("#mobileJoystickKnob");
const mobileFireButton = document.querySelector("#mobileFireButton");
const mobileDashButton = document.querySelector("#mobileDashButton");
const mobilePulseButton = document.querySelector("#mobilePulseButton");
const mobileDashHint = document.querySelector("#mobileDashHint");
const mobilePulseHint = document.querySelector("#mobilePulseHint");

const TAU = Math.PI * 2;
const LEVEL_CLEAR_MUSIC_DELAY = 3.2;
const BOSS_WARNING_DURATION = 17.2;
const BOSS_PRE_SPAWN_CLEAR_DURATION = 3.2;
const MUSIC_MUTE_STORAGE_KEY = "bloodstream-defender-music-muted";
const SFX_MUTE_STORAGE_KEY = "bloodstream-defender-sfx-muted";
const GAME_OVER_INPUT_LOCK_DURATION = 1.15;
const MAX_POOLED_SHOTS = 260;
const MAX_POOLED_PARTICLES = 520;
const SHOT_COLLISION_CELL_SIZE = 150;
const SHOT_COLLISION_MAX_HIT_RADIUS = 14;
const shotPool = [];
const particlePool = [];
const shotCollisionBuckets = new Map();
const shotCollisionCandidates = [];
const renderCache = {
  shotSprite: null,
};
let phaserRenderer = null;
let mobilePerformanceMode = false;
let shotCollisionQueryId = 0;
const keys = new Set();
const pointer = {
  active: false,
  down: false,
  x: 0,
  y: 0,
};
const mobileInput = {
  joystickPointerId: null,
  joystickX: 0,
  joystickY: 0,
  fire: false,
};
let lastTouchEndAt = 0;
let lastBossHitSfxAt = 0;
let lastUpgradeHoverSfxAt = 0;

const audioManifest = {
  music: {
    menu: {
      src: "./assets/audio/Menu%20music.mp3",
      volume: 0.46,
      fadeLoop: 2.6,
    },
    combat: {
      src: "./assets/audio/Normal%20vessel%20combat%20loop.mp3",
      volume: 0.34,
      fadeLoop: 2.8,
    },
    highDanger: {
      src: "./assets/audio/High-danger%20combat%20loop.mp3",
      volume: 0.38,
      fadeLoop: 2.2,
    },
    boss: {
      src: "./assets/audio/Boss%20loop.mp3",
      volume: 0.4,
      fadeLoop: 2.4,
    },
    upgrade: {
      src: "./assets/audio/Upgrade%20tree%20loop.mp3",
      volume: 0.36,
      fadeLoop: 2.2,
    },
  },
  ambience: {
    bloodstream: {
      src: "./assets/audio/Bloodstream%20ambience.wav",
      volume: 0.18,
      fadeLoop: 1.4,
    },
    cellularSparkle: {
      src: "./assets/audio/Cellular%20sparkle.mp3",
      volume: 0.05,
      fadeLoop: 1.2,
    },
    deepVesselPulse: {
      src: "./assets/audio/Deep%20Vessel%20Pulse.mp3",
      volume: 0.06,
      fadeLoop: 1.8,
    },
  },
  sfx: {
    antibodyShot: {
      src: "./assets/audio/Antibody%20shot.wav",
      volume: 0.54,
      poolSize: 6,
    },
    antibodyHit: {
      src: "./assets/audio/Antibody%20hit.wav",
      volume: 0.5,
      poolSize: 5,
    },
    chemotaxisDash: {
      src: "./assets/audio/Chemotaxis%20dash.wav",
      volume: 0.6,
      poolSize: 3,
    },
    chemotaxisDashUpgraded: {
      src: "./assets/audio/Chemotaxis%20dash%20upgraded.wav",
      volume: 0.7,
      poolSize: 3,
      maxDuration: 1.12,
      fadeOut: 0.24,
    },
    complementPulse: {
      src: "./assets/audio/Complement%20pulse.wav",
      volume: 0.68,
      poolSize: 3,
    },
    playerDamage: {
      src: "./assets/audio/Player%20damage.wav",
      volume: 0.66,
      poolSize: 3,
    },
    playerDeath: {
      src: "./assets/audio/Player%20death.mp3",
      volume: 0.72,
      poolSize: 2,
    },
    virusPop: {
      src: "./assets/audio/Virus%20pop.wav",
      volume: 0.58,
      poolSize: 6,
    },
    upgradeSelected: {
      src: "./assets/audio/Upgrade%20selected.wav",
      volume: 0.58,
      poolSize: 3,
    },
    levelComplete: {
      src: "./assets/audio/Level%20Complete%20Sting.wav",
      volume: 0.64,
      poolSize: 2,
    },
    bossWarning: {
      src: "./assets/audio/Boss%20warning%20rumble.mp3",
      volume: 0.58,
      poolSize: 1,
      maxDuration: BOSS_WARNING_DURATION,
      fadeOut: 2,
    },
    bossHit: {
      src: "./assets/audio/Boss%20Hit.wav",
      volume: 0.68,
      poolSize: 3,
      maxDuration: 0.82,
      fadeOut: 0.18,
    },
    bossDefeated: {
      src: "./assets/audio/Boss%20defeated.mp3",
      volume: 0.62,
      poolSize: 1,
      maxDuration: 2.4,
      fadeOut: 0.65,
    },
    bossPhaseChange: {
      src: "./assets/audio/Boss%20phase%20change.mp3",
      volume: 0.54,
      poolSize: 1,
      maxDuration: 2.7,
      fadeOut: 0.65,
    },
    buddingSplit: {
      src: "./assets/audio/Budding%20virus%20split.wav",
      volume: 0.54,
      poolSize: 3,
      maxDuration: 1.15,
      fadeOut: 0.28,
    },
    influenzaHit: {
      src: "./assets/audio/Influenza%20hit.wav",
      volume: 0.46,
      poolSize: 4,
      maxDuration: 0.7,
      fadeOut: 0.18,
    },
    influenzaReplication: {
      src: "./assets/audio/Influenza%20replication%20bloom.wav",
      volume: 0.56,
      poolSize: 3,
      maxDuration: 1.35,
      fadeOut: 0.28,
    },
    pauseOpen: {
      src: "./assets/audio/Pause%20open.wav",
      volume: 0.46,
      poolSize: 2,
      maxDuration: 0.85,
      fadeOut: 0.22,
    },
    pauseResume: {
      src: "./assets/audio/Pause%20resume.mp3",
      volume: 0.42,
      poolSize: 1,
      maxDuration: 1.15,
      fadeOut: 0.36,
    },
    plateletBump: {
      src: "./assets/audio/Platelet%20or%20clot%20bump-crack.wav",
      volume: 0.58,
      poolSize: 3,
      maxDuration: 1.05,
      fadeOut: 0.25,
    },
    restartConfirm: {
      src: "./assets/audio/Restart%20confirmation%20open.wav",
      volume: 0.5,
      poolSize: 2,
      maxDuration: 1.2,
      fadeOut: 0.28,
    },
    upgradeHover: {
      src: "./assets/audio/Upgrade%20card%20hover.wav",
      volume: 0.28,
      poolSize: 2,
      maxDuration: 0.42,
      fadeOut: 0.14,
    },
    uiSelect: {
      src: "./assets/audio/ui_button_select.wav",
      volume: 0.44,
      poolSize: 3,
      maxDuration: 0.55,
      fadeOut: 0.16,
    },
  },
};

const audio = {
  context: null,
  master: null,
  assetsReady: false,
  unlocked: false,
  musicMuted: readMutePreference(MUSIC_MUTE_STORAGE_KEY),
  sfxMuted: readMutePreference(SFX_MUTE_STORAGE_KEY),
  music: {},
  ambience: {},
  sfx: {},
  activeMusicKey: null,
  musicFadeSpeed: 1.8,
  sfxMasterVolume: 0.95,
};

function readMutePreference(key) {
  try {
    return window.localStorage?.getItem(key) === "true";
  } catch (error) {
    return false;
  }
}

function storeMutePreference(key, muted) {
  try {
    window.localStorage?.setItem(key, String(muted));
  } catch (error) {
    // Mute still works for the current session if storage is unavailable.
  }
}

function updateMuteButtons() {
  if (musicMuteButton) {
    musicMuteButton.classList.toggle("is-muted", audio.musicMuted);
    musicMuteButton.setAttribute("aria-pressed", String(audio.musicMuted));
    musicMuteButton.setAttribute(
      "aria-label",
      audio.musicMuted ? "Music is off. Press to turn music on." : "Music is on. Press to mute music.",
    );
    const valueEl = musicMuteButton.querySelector(".menu-action__status");
    if (valueEl) valueEl.textContent = audio.musicMuted ? "Off" : "On";
  }

  if (sfxMuteButton) {
    sfxMuteButton.classList.toggle("is-muted", audio.sfxMuted);
    sfxMuteButton.setAttribute("aria-pressed", String(audio.sfxMuted));
    sfxMuteButton.setAttribute(
      "aria-label",
      audio.sfxMuted ? "Sound effects are off. Press to turn sound effects on." : "Sound effects are on. Press to mute sound effects.",
    );
    const valueEl = sfxMuteButton.querySelector(".menu-action__status");
    if (valueEl) valueEl.textContent = audio.sfxMuted ? "Off" : "On";
  }
}

function silenceLoopTracks(tracks) {
  for (const track of Object.values(tracks)) {
    track.currentVolume = 0;
    track.targetVolume = 0;
    track.element.volume = 0;
    track.element.pause();
  }
}

function stopAllSfx() {
  for (const sfx of Object.values(audio.sfx)) {
    for (const element of sfx.pool) {
      if (element.audioStopTimer) {
        window.clearTimeout(element.audioStopTimer);
        element.audioStopTimer = null;
      }
      if (element.audioFadeFrame) {
        window.cancelAnimationFrame(element.audioFadeFrame);
        element.audioFadeFrame = null;
      }
      element.pause();
      try {
        element.currentTime = 0;
      } catch (error) {
        // The next sound will restart cleanly once the browser allows seeking.
      }
    }
  }
}

function setMusicMuted(muted) {
  audio.musicMuted = muted;
  storeMutePreference(MUSIC_MUTE_STORAGE_KEY, muted);
  if (muted) {
    silenceLoopTracks(audio.music);
    silenceLoopTracks(audio.ambience);
  }
  updateMuteButtons();
  updateAudioScene(0);
}

function setSfxMuted(muted) {
  audio.sfxMuted = muted;
  storeMutePreference(SFX_MUTE_STORAGE_KEY, muted);
  if (muted) stopAllSfx();
  updateMuteButtons();
}

function toggleMusicMuted() {
  setMusicMuted(!audio.musicMuted);
}

function toggleSfxMuted() {
  setSfxMuted(!audio.sfxMuted);
}

const state = {
  width: 1280,
  height: 720,
  dpr: 1,
  running: false,
  ended: false,
  paused: false,
  score: 0,
  level: 1,
  levelStartScroll: 0,
  levelLength: 3200,
  levelKills: 0,
  levelGoal: 5,
  currentMission: null,
  levelBannerTimer: 0,
  influenzaNoticeTimer: 0,
  levelTransitionTimer: 0,
  levelClearMusicDelay: 0,
  bossMusicDelay: 0,
  bossWarningActive: false,
  bossWarningTimer: 0,
  bossWarningCleared: false,
  pendingBossType: null,
  runStartMusicDelay: 0,
  ambienceIntroDelay: 0,
  levelComplete: false,
  awaitingUpgrade: false,
  bossSpawned: false,
  bossDefeated: false,
  bossTriggerProgress: 0.85,
  gameOverInputLockUntil: 0,
  time: 0,
  lastTime: performance.now(),
  scroll: 0,
  nextVirus: 0,
  nextRedCell: 0,
  nextPlatelet: 4,
  player: null,
  shots: [],
  viruses: [],
  redCells: [],
  platelets: [],
  particles: [],
  plasma: [],
  lockTarget: null,
  lastUiStart: 0,
  upgrades: {
    rapid: 0,
    pulse: 0,
    dash: 0,
  },
  stats: {
    virionsNeutralized: 0,
    sectionsCleared: 0,
    bossesNeutralized: 0,
    damageTaken: 0,
    upgradesTaken: [],
  },
  dashCooldown: 0,
  dashTimer: 0,
  pulseCooldown: 0,
  pulseTimer: 0,
  dashInputHeld: false,
  pulseInputHeld: false,
  shake: 0,
};

const palette = {
  plasmaDeep: "#230816",
  plasmaMid: "#651525",
  plasmaHot: "#ba3842",
  vesselDark: "#4e1022",
  vesselMid: "#8d2330",
  vesselLight: "#f27b64",
  whiteCell: "#fff7e8",
  whiteCellShade: "#d8efe8",
  cyan: "#60efff",
  cyanDeep: "#11aeca",
  platelet: "#ffcd58",
};

const missionDeck = [
  {
    name: "Innate Patrol",
    term: "Innate immunity",
    objective: "Neutralize free virions before they spread downstream.",
    target: "virions",
  },
  {
    name: "Antigen Sweep",
    term: "Antigen",
    objective: "Tag viral antigens so the immune response can recognize them.",
    target: "antigens",
  },
  {
    name: "Complement Cascade",
    term: "Complement system",
    objective: "Clear the viral cluster while avoiding platelet clots.",
    target: "virions",
  },
  {
    name: "Influenza Bloom",
    term: "Viral replication",
    objective: "Stop influenza virions before touching pairs make more copies.",
    target: "influenza virions",
  },
];

const encounterMissionDeck = [
  {
    name: "Pox-Brick Breach",
    term: "Poxvirus",
    objective: "Fight through a high-threat vessel section, then strip the pox armor plates and expose the glowing weak core.",
    target: "virions",
    bossTarget: "pox boss",
    encounter: "boss",
    bossType: "poxBoss",
  },
  {
    name: "Adenovirus Prism",
    term: "Adenovirus",
    objective: "Clear the viral surge, then time antibody shots for the exposed prism face between shield rotations.",
    target: "virions",
    bossTarget: "adenovirus mini-boss",
    encounter: "mini-boss",
    bossType: "adenovirusMini",
  },
  {
    name: "Filovirus Ribbon",
    term: "Filovirus",
    objective: "Push through the bloodstream lanes, then dodge sweeping filament arcs and focus fire on the ribbon body.",
    target: "virions",
    bossTarget: "filovirus boss",
    encounter: "boss",
    bossType: "filovirusBoss",
  },
  {
    name: "Adenovirus Prism",
    term: "Adenovirus",
    objective: "Survive the late-vessel pressure, then crack the rotating prism shield.",
    target: "virions",
    bossTarget: "adenovirus mini-boss",
    encounter: "mini-boss",
    bossType: "adenovirusMini",
  },
];

const upgradeOptions = [
  {
    id: "rapid",
    term: "IgG antibodies",
    title: "Rapid Antibody Factory",
    icon: "Y",
    medallion: "./assets/ui/upgrade-medallion-antibody.png",
    controlIntro: "Use",
    controls: ["Space", "Click", "Tap"],
    controlOutro: "to fire",
    body:
      "Shortens the antibody cooldown. At higher ranks, your leukocyte releases paired Y-shaped antibodies.",
    levels: [
      "Rank 1: faster antibody firing",
      "Rank 2: paired antibodies",
      "Rank 3: stronger antibody hits",
      "Rank 4: triple antibody spread",
    ],
  },
  {
    id: "pulse",
    term: "Complement proteins",
    title: "Complement Pulse",
    icon: "C",
    medallion: "./assets/ui/upgrade-medallion-complement.png",
    controlIntro: "Use",
    controls: ["E", "Q", "Enter"],
    controlOutro: "after unlocking",
    body:
      "Unlocks a radial pulse that damages nearby viruses and breaks platelet hazards before they reach you.",
    levels: [
      "Rank 1: unlock pulse",
      "Rank 2: larger damage ring",
      "Rank 3: shorter cooldown",
      "Rank 4: heavy nearby clear",
    ],
  },
  {
    id: "dash",
    term: "Chemotaxis",
    title: "Chemotaxis Dash",
    icon: "→",
    medallion: "./assets/ui/upgrade-medallion-chemotaxis.png",
    controlIntro: "Use",
    controls: ["Shift", "WASD", "Arrows"],
    controlOutro: "to surge",
    body:
      "Unlocks a quick immune-cell surge for slipping through crowded vessel sections and lining up shots.",
    levels: [
      "Rank 1: unlock dash",
      "Rank 2: stronger surge",
      "Rank 3: faster recovery",
      "Rank 4: longer invulnerable slip",
    ],
  },
];

const parallaxLayers = {
  far: loadGameImage("./assets/backgrounds/parallax/source/layer-00-far-vessel-wash.png"),
  currents: loadGameImage("./assets/backgrounds/parallax/processed/layer-01-mid-plasma-currents.png"),
  cells: loadGameImage("./assets/backgrounds/parallax/processed/layer-02-distant-red-cells.png"),
  branches: loadGameImage("./assets/backgrounds/parallax/processed/layer-02b-branch-openings.png"),
  walls: loadGameImage("./assets/backgrounds/parallax/processed/layer-03-foreground-vessel-walls.png"),
  floaters: loadGameImage("./assets/backgrounds/parallax/processed/layer-04-foreground-floaters.png"),
};

const spriteAtlas = loadGameImage(
  "./assets/sprites/processed/bloodstream-asset-atlas-transparent-no-despill.png",
);
const influenzaSpriteSheet = loadGameImage(
  "./assets/sprites/processed/influenza-virion-spritesheet.png",
);
const poxBossSpriteSheet = loadGameImage(
  "./assets/sprites/processed/pox-brick-boss-spritesheet.png",
);
const adenovirusSpriteSheet = loadGameImage(
  "./assets/sprites/processed/adenovirus-prism-spritesheet.png",
);
const filovirusSpriteSheet = loadGameImage(
  "./assets/sprites/processed/filovirus-ribbon-spritesheet.png",
);

const spriteFrames = {
  whiteCell: [
    { x: 45, y: 41, w: 184, h: 178 },
    { x: 284, y: 58, w: 221, h: 158 },
    { x: 590, y: 54, w: 224, h: 160 },
    { x: 865, y: 56, w: 156, h: 158 },
    { x: 1068, y: 64, w: 185, h: 150 },
    { x: 1312, y: 90, w: 179, h: 131 },
  ],
  greenVirus: [
    { x: 132, y: 251, w: 198, h: 186 },
    { x: 423, y: 252, w: 197, h: 182 },
    { x: 705, y: 260, w: 185, h: 179 },
    { x: 972, y: 265, w: 182, h: 181 },
  ],
  purpleVirus: [
    { x: 133, y: 465, w: 199, h: 189 },
    { x: 435, y: 467, w: 196, h: 186 },
    { x: 713, y: 471, w: 189, h: 182 },
    { x: 980, y: 479, w: 191, h: 173 },
  ],
  influenzaVirus: [
    { x: 117, y: 159, w: 396, h: 424 },
    { x: 621, y: 129, w: 392, h: 452 },
    { x: 1154, y: 173, w: 386, h: 407 },
    { x: 1653, y: 180, w: 395, h: 395 },
  ],
  poxBoss: [
    { x: 55, y: 176, w: 476, h: 339 },
    { x: 548, y: 176, w: 520, h: 356 },
    { x: 1101, y: 186, w: 513, h: 336 },
    { x: 1631, y: 143, w: 495, h: 409 },
  ],
  adenovirusMini: [
    { x: 117, y: 140, w: 408, h: 433 },
    { x: 604, y: 139, w: 482, h: 437 },
    { x: 1086, y: 134, w: 543, h: 452 },
    { x: 1629, y: 111, w: 427, h: 483 },
  ],
  filovirusBoss: [
    { x: 53, y: 246, w: 490, h: 238 },
    { x: 543, y: 150, w: 510, h: 421 },
    { x: 1103, y: 203, w: 526, h: 343 },
    { x: 1629, y: 218, w: 490, h: 285 },
  ],
  redCell: [
    { x: 94, y: 674, w: 174, h: 132 },
    { x: 357, y: 693, w: 185, h: 101 },
    { x: 652, y: 698, w: 125, h: 96 },
    { x: 916, y: 701, w: 90, h: 101 },
  ],
  platelet: [
    { x: 60, y: 843, w: 222, h: 134 },
    { x: 349, y: 852, w: 145, h: 129 },
    { x: 555, y: 862, w: 142, h: 108 },
  ],
  antibody: [
    { x: 774, y: 892, w: 107, h: 62 },
    { x: 947, y: 892, w: 123, h: 62 },
    { x: 1125, y: 893, w: 139, h: 61 },
    { x: 1316, y: 892, w: 143, h: 62 },
  ],
};

const bossProfiles = {
  poxBoss: {
    displayName: "Pox-Brick Boss",
    spriteGroup: "poxBoss",
    radius: 86,
    hp: 120,
    score: 650,
    color: "#d262e8",
    core: "#ff4f9a",
    damage: 28,
    damageScale: 0.38,
    targetXRatio: 0.73,
    attackInterval: 2.2,
    shadowBlur: 34,
  },
  adenovirusMini: {
    displayName: "Adenovirus Prism",
    spriteGroup: "adenovirusMini",
    radius: 58,
    hp: 56,
    score: 360,
    color: "#b566ff",
    core: "#f8b9ff",
    damage: 20,
    damageScale: 0.52,
    targetXRatio: 0.68,
    attackInterval: 2.1,
    shadowBlur: 28,
  },
  filovirusBoss: {
    displayName: "Filovirus Ribbon",
    spriteGroup: "filovirusBoss",
    radius: 74,
    hp: 128,
    score: 720,
    color: "#4af7d5",
    core: "#8bff5d",
    damage: 24,
    damageScale: 0.46,
    targetXRatio: 0.64,
    attackInterval: 2.7,
    shadowBlur: 30,
  },
};

function loadGameImage(src) {
  const asset = {
    image: new Image(),
    loaded: false,
    failed: false,
  };
  asset.image.onload = () => {
    asset.loaded = true;
  };
  asset.image.onerror = () => {
    asset.failed = true;
  };
  asset.image.src = src;
  return asset;
}

const phaserTextureBySpriteGroup = {
  whiteCell: "spriteAtlas",
  greenVirus: "spriteAtlas",
  purpleVirus: "spriteAtlas",
  redCell: "spriteAtlas",
  platelet: "spriteAtlas",
  antibody: "spriteAtlas",
  influenzaVirus: "influenzaSpriteSheet",
  poxBoss: "poxBossSpriteSheet",
  adenovirusMini: "adenovirusSpriteSheet",
  filovirusBoss: "filovirusSpriteSheet",
};

function phaserFrameKey(group, index) {
  return `${group}-${index}`;
}

function colorToNumber(color, fallback = 0xffffff) {
  if (typeof color === "string" && color.startsWith("#")) {
    const value = Number.parseInt(color.slice(1), 16);
    return Number.isFinite(value) ? value : fallback;
  }
  return fallback;
}

function shouldUseMobileRenderMode() {
  return mobilePerformanceMode || isTouchDevice();
}

function createPhaserRenderer() {
  const Phaser = window.Phaser;
  if (!Phaser || !phaserStageEl) return null;
  const rendererHolder = { current: null };

  class BloodstreamPhaserScene extends Phaser.Scene {
    constructor() {
      super("BloodstreamPlayfield");
    }

    preload() {
      this.load.image("parallaxFar", "./assets/backgrounds/parallax/source/layer-00-far-vessel-wash.png");
      this.load.image("parallaxCurrents", "./assets/backgrounds/parallax/processed/layer-01-mid-plasma-currents.png");
      this.load.image("parallaxCells", "./assets/backgrounds/parallax/processed/layer-02-distant-red-cells.png");
      this.load.image("parallaxBranches", "./assets/backgrounds/parallax/processed/layer-02b-branch-openings.png");
      this.load.image("parallaxWalls", "./assets/backgrounds/parallax/processed/layer-03-foreground-vessel-walls.png");
      this.load.image("parallaxFloaters", "./assets/backgrounds/parallax/processed/layer-04-foreground-floaters.png");
      this.load.image("spriteAtlas", "./assets/sprites/processed/bloodstream-asset-atlas-transparent-no-despill.png");
      this.load.image("influenzaSpriteSheet", "./assets/sprites/processed/influenza-virion-spritesheet.png");
      this.load.image("poxBossSpriteSheet", "./assets/sprites/processed/pox-brick-boss-spritesheet.png");
      this.load.image("adenovirusSpriteSheet", "./assets/sprites/processed/adenovirus-prism-spritesheet.png");
      this.load.image("filovirusSpriteSheet", "./assets/sprites/processed/filovirus-ribbon-spritesheet.png");
    }

    create() {
      rendererHolder.current?.attachScene(this);
    }
  }

  rendererHolder.current = new BloodstreamPhaserRenderer(Phaser, BloodstreamPhaserScene);
  return rendererHolder.current;
}

class BloodstreamPhaserRenderer {
  constructor(Phaser, SceneClass) {
    this.Phaser = Phaser;
    this.ready = false;
    this.scene = null;
    this.width = state.width;
    this.height = state.height;
    this.syncId = 0;
    this.redCellSprites = new Map();
    this.plateletSprites = new Map();
    this.virusSprites = new Map();
    this.virusGlowSprites = new Map();
    this.shotSprites = new Map();
    this.game = new Phaser.Game({
      type: Phaser.WEBGL,
      parent: phaserStageEl,
      width: this.width,
      height: this.height,
      backgroundColor: "#160612",
      transparent: false,
      audio: { noAudio: true },
      render: {
        antialias: true,
        pixelArt: false,
        roundPixels: false,
        powerPreference: "high-performance",
      },
      scale: {
        mode: Phaser.Scale.NONE,
        width: this.width,
        height: this.height,
      },
      scene: SceneClass,
    });
  }

  attachScene(scene) {
    this.scene = scene;
    this.registerFrames();
    this.createTextures();
    this.createLayers();
    this.ready = true;
    gameShellEl?.classList.add("is-phaser-renderer");
    this.resize(state.width, state.height);
  }

  registerFrames() {
    for (const [group, frames] of Object.entries(spriteFrames)) {
      const textureKey = phaserTextureBySpriteGroup[group];
      const texture = this.scene.textures.get(textureKey);
      if (!texture) continue;
      frames.forEach((frame, index) => {
        const key = phaserFrameKey(group, index);
        if (!texture.has(key)) texture.add(key, 0, frame.x, frame.y, frame.w, frame.h);
      });
    }
  }

  createTextures() {
    const shotGraphics = this.scene.add.graphics({ x: 0, y: 0 });
    shotGraphics.lineStyle(2.2, 0x60efff, 0.34);
    shotGraphics.beginPath();
    shotGraphics.moveTo(6, 19);
    shotGraphics.lineTo(21, 19);
    shotGraphics.strokePath();
    shotGraphics.lineStyle(6, 0x60efff, 0.5);
    shotGraphics.beginPath();
    shotGraphics.moveTo(22, 19);
    shotGraphics.lineTo(32.5, 19);
    shotGraphics.moveTo(32.5, 19);
    shotGraphics.lineTo(42, 13);
    shotGraphics.moveTo(32.5, 19);
    shotGraphics.lineTo(42, 25);
    shotGraphics.strokePath();
    shotGraphics.lineStyle(2.8, 0xb0ffff, 0.92);
    shotGraphics.beginPath();
    shotGraphics.moveTo(22, 19);
    shotGraphics.lineTo(32.5, 19);
    shotGraphics.moveTo(32.5, 19);
    shotGraphics.lineTo(42, 13);
    shotGraphics.moveTo(32.5, 19);
    shotGraphics.lineTo(42, 25);
    shotGraphics.strokePath();
    shotGraphics.fillStyle(0xdfffff, 1);
    shotGraphics.fillCircle(42, 13, 1.5);
    shotGraphics.fillCircle(42, 25, 1.5);
    shotGraphics.generateTexture("antibodyProjectile", 68, 38);
    shotGraphics.destroy();
  }

  createLayers() {
    const { scene } = this;
    scene.cameras.main.setRoundPixels(false);
    this.background = scene.add.graphics().setDepth(0);
    this.parallax = {
      far: this.createParallaxLayer("parallaxFar", 1, 1),
      currents: this.createParallaxLayer("parallaxCurrents", 2, 0.38),
      branches: this.createParallaxLayer("parallaxBranches", 3, 0.24),
      cells: this.createParallaxLayer("parallaxCells", 4, 0.34),
      walls: this.createParallaxLayer("parallaxWalls", 90, 1),
      floaters: this.createParallaxLayer("parallaxFloaters", 94, 0.28),
    };
    this.plasmaGraphics = scene.add.graphics().setDepth(5);
    this.haloGraphics = scene.add.graphics().setDepth(28);
    this.wakeGraphics = scene.add.graphics().setDepth(38);
    this.abilityGraphics = scene.add.graphics().setDepth(39);
    this.aimGraphics = scene.add.graphics().setDepth(47);
    this.shotGraphics = scene.add.graphics().setDepth(74);
    this.particleGraphics = scene.add.graphics().setDepth(82);
    this.veilGraphics = scene.add.graphics().setDepth(95);
    this.playerGlow = scene.add.image(0, 0, "spriteAtlas", phaserFrameKey("whiteCell", 0)).setDepth(40).setBlendMode(this.Phaser.BlendModes.ADD).setAlpha(0.24);
    this.playerSprite = scene.add.image(0, 0, "spriteAtlas", phaserFrameKey("whiteCell", 0)).setDepth(45);
    this.resize(this.width, this.height);
  }

  createParallaxLayer(texture, depth, alpha) {
    return {
      texture,
      depth,
      alpha,
      drawWidth: this.width,
      drawHeight: this.height,
      y: 0,
      sprites: [],
    };
  }

  resize(width, height) {
    if (!this.game || !this.scene) return;
    this.width = Math.max(320, width);
    this.height = Math.max(320, height);
    this.game.scale.resize(this.width, this.height);
    this.scene.cameras.main.setViewport(0, 0, this.width, this.height);
    this.updateParallaxSizes();
    this.drawStaticVeil();
  }

  updateParallaxSizes() {
    if (!this.parallax) return;
    for (const layer of Object.values(this.parallax)) {
      const source = this.scene.textures.get(layer.texture)?.getSourceImage();
      const sourceWidth = source?.width || this.width;
      const sourceHeight = source?.height || this.height;
      const scale = Math.max(this.width / sourceWidth, this.height / sourceHeight);
      const neededSprites = Math.ceil(this.width / Math.max(1, sourceWidth * scale)) + 3;

      layer.drawWidth = sourceWidth * scale;
      layer.drawHeight = sourceHeight * scale;
      layer.y = (this.height - layer.drawHeight) * 0.5;

      while (layer.sprites.length < neededSprites) {
        const sprite = this.scene.add.image(0, 0, layer.texture);
        sprite.setOrigin(0.5, 0);
        sprite.setDepth(layer.depth);
        sprite.setAlpha(layer.alpha);
        layer.sprites.push(sprite);
      }

      for (const sprite of layer.sprites) {
        sprite.setDisplaySize(layer.drawWidth, layer.drawHeight);
        sprite.setDepth(layer.depth);
        sprite.setAlpha(layer.alpha);
      }
    }
  }

  drawStaticVeil() {
    if (!this.veilGraphics) return;
    this.veilGraphics.clear();
    this.veilGraphics.fillStyle(0x14030d, 0.14);
    this.veilGraphics.fillRect(0, 0, this.width, this.height * 0.22);
    this.veilGraphics.fillRect(0, this.height * 0.78, this.width, this.height * 0.22);
    this.veilGraphics.fillStyle(0x09020a, 0.22);
    this.veilGraphics.fillRect(0, 0, this.width, this.height);
  }

  sync() {
    if (!this.ready || !this.scene) return;
    this.syncId += 1;
    this.syncBackground();
    this.syncWorldObjects();
    this.syncPlayer();
    this.syncShots();
    this.syncParticles();
    this.cleanupMaps();
  }

  syncBackground() {
    this.background.clear();
    this.background.fillGradientStyle(0x2a0718, 0x42101f, 0x6f1d27, 0x270716, 1);
    this.background.fillRect(0, 0, this.width, this.height);

    const layerSpeeds = {
      far: 0.12,
      currents: 0.28,
      branches: 0.38,
      cells: 0.52,
      walls: 0.96,
      floaters: 1.22,
    };
    for (const [key, layer] of Object.entries(this.parallax)) {
      this.syncParallaxLayer(layer, layerSpeeds[key] ?? 0.5);
    }

    this.plasmaGraphics.clear();
    for (const dot of state.plasma) {
      this.plasmaGraphics.fillStyle(0xffc39e, dot.alpha);
      this.plasmaGraphics.fillCircle(dot.x, dot.y, dot.radius);
    }
  }

  syncWorldObjects() {
    this.haloGraphics.clear();
    for (const cell of state.redCells) {
      const frame = phaserFrameKey("redCell", (cell.frameIndex ?? 0) % spriteFrames.redCell.length);
      const sprite = this.getImage(this.redCellSprites, cell, "spriteAtlas", frame);
      const distant = cell.depth < 0.68;
      sprite.setDepth(distant ? 18 : 58);
      sprite.setPosition(cell.x, cell.y);
      sprite.setRotation(cell.rotation);
      sprite.setAlpha(distant ? 0.38 : 0.88);
      sprite.setDisplaySize(cell.radius * 1.86 * (spriteFrames.redCell[(cell.frameIndex ?? 0) % spriteFrames.redCell.length].w / spriteFrames.redCell[(cell.frameIndex ?? 0) % spriteFrames.redCell.length].h), cell.radius * 1.86);
      cell._phaserSyncId = this.syncId;
    }

    for (const platelet of state.platelets) {
      const frameIndex = (platelet.frameIndex ?? 0) % spriteFrames.platelet.length;
      const frame = phaserFrameKey("platelet", frameIndex);
      const sprite = this.getImage(this.plateletSprites, platelet, "spriteAtlas", frame);
      const targetHeight = platelet.radius * 2.55 * (1 + Math.sin(state.time * 2.4 + platelet.angle) * 0.025);
      const frameData = spriteFrames.platelet[frameIndex];
      sprite.setDepth(62);
      sprite.setPosition(platelet.x, platelet.y);
      sprite.setRotation(platelet.angle);
      sprite.setAlpha(0.94);
      sprite.setDisplaySize(targetHeight * (frameData.w / frameData.h), targetHeight);
      platelet._phaserSyncId = this.syncId;
    }

    for (const virus of state.viruses) {
      if (virus.dead) continue;
      this.syncVirus(virus);
      virus._phaserSyncId = this.syncId;
    }
  }

  syncVirus(virus) {
    const group = virus.spriteGroup || "greenVirus";
    const frames = spriteFrames[group] || spriteFrames.greenVirus;
    const frameIndex = (virus.frameIndex ?? 0) % frames.length;
    const textureKey = phaserTextureBySpriteGroup[group] || "spriteAtlas";
    const frame = phaserFrameKey(group, frameIndex);
    const frameData = frames[frameIndex];
    const targetHeight = isBossVirus(virus)
      ? virus.radius * (virus.type === "filovirusBoss" ? 2.48 : 2.74)
      : virus.radius * 2.92;
    const hitPulse = virus.hit > 0 ? 1 + Math.sin(state.time * 60) * 0.06 : 1;
    const alpha = virus.hit > 0 ? 0.72 + Math.sin(state.time * 60) * 0.2 : 1;
    const depth = isBossVirus(virus) ? 66 : 60;
    const sprite = this.getImage(this.virusSprites, virus, textureKey, frame);
    const glow = this.getImage(this.virusGlowSprites, virus, textureKey, frame);
    const width = targetHeight * (frameData.w / frameData.h) * hitPulse;
    const height = targetHeight * hitPulse;

    if (virus.type !== "influenza" && !isBossVirus(virus)) {
      const haloRadius = virus.radius * (virus.type === "fragment" ? 1.28 : 1.34);
      this.haloGraphics.fillStyle(0x0e010a, 0.38);
      this.haloGraphics.fillCircle(virus.x, virus.y, haloRadius);
      this.haloGraphics.lineStyle(virus.type === "budding" ? 3 : 2, virus.type === "budding" ? 0xffe27e : 0xfff4ee, virus.type === "budding" ? 0.7 : 0.22);
      this.haloGraphics.strokeCircle(virus.x, virus.y, haloRadius);
    }

    glow.setDepth(depth - 1);
    glow.setPosition(virus.x, virus.y);
    glow.setRotation(virus.angle);
    glow.setAlpha(isBossVirus(virus) ? 0.28 : 0.2);
    glow.setTint(colorToNumber(virus.color, 0x60efff));
    glow.setBlendMode(this.Phaser.BlendModes.ADD);
    glow.setDisplaySize(width * 1.12, height * 1.12);

    sprite.setDepth(depth);
    sprite.setPosition(virus.x, virus.y);
    sprite.setRotation(virus.angle);
    sprite.setAlpha(alpha);
    sprite.clearTint();
    sprite.setDisplaySize(width, height);

    if (virus.type === "adenovirusMini" && !virus.shieldOpen) {
      this.haloGraphics.lineStyle(3, 0x87faff, 0.58 + Math.sin(state.time * 8) * 0.08);
      this.haloGraphics.strokeCircle(virus.x, virus.y, virus.radius * 1.56);
    }
  }

  syncPlayer() {
    const player = state.player;
    if (!player || !this.playerSprite) return;

    const hurtPulse = player.hurtTimer > 0 ? Math.sin(state.time * 50) * 0.12 : 0;
    const speed = Math.hypot(player.vx, player.vy);
    const swimPulseRate = 3.2 + clamp(speed / 170, 0, 1.8);
    const poseStrength = clamp(Math.abs(player.horizontalPose ?? 0), 0, 1);
    const swimFrame = poseStrength > 0.22 ? 1 : (player.spriteFrame ?? 0) % spriteFrames.whiteCell.length;
    const frame = phaserFrameKey("whiteCell", swimFrame);
    const frameData = spriteFrames.whiteCell[swimFrame];
    const bodyAngle =
      Math.sin(state.time * 2.8) * 0.075 +
      player.vy * 0.0008 +
      (player.horizontalPose ?? 0) * 0.055;
    const targetHeight =
      player.radius *
      3.55 *
      (1 + Math.abs(hurtPulse) * 0.42 + Math.sin(state.time * swimPulseRate) * 0.014);
    const targetWidth = targetHeight * (frameData.w / frameData.h) * (1 + poseStrength * 0.12);
    const finalHeight = targetHeight * (1 - poseStrength * 0.035);
    const flip = (player.horizontalPose ?? 0) < -0.16 ? -1 : 1;

    this.drawPlayerEffects(player, poseStrength);

    this.playerGlow.setTexture("spriteAtlas", frame);
    this.playerGlow.setPosition(player.x, player.y);
    this.playerGlow.setRotation(bodyAngle);
    this.playerGlow.setAlpha(player.hurtTimer > 0 ? 0.36 : 0.24);
    this.playerGlow.setTint(player.hurtTimer > 0 ? 0xff7378 : 0x60efff);
    this.playerGlow.setDisplaySize(targetWidth * 1.12, finalHeight * 1.12);
    this.playerGlow.setFlipX(flip < 0);

    this.playerSprite.setTexture("spriteAtlas", frame);
    this.playerSprite.setPosition(player.x, player.y);
    this.playerSprite.setRotation(bodyAngle);
    this.playerSprite.setDisplaySize(targetWidth, finalHeight);
    this.playerSprite.setFlipX(flip < 0);
    this.playerSprite.setAlpha(1);
    this.playerSprite.clearTint();
  }

  drawPlayerEffects(player, poseStrength) {
    this.wakeGraphics.clear();
    this.abilityGraphics.clear();
    this.aimGraphics.clear();

    if (poseStrength > 0.08) {
      const direction = player.horizontalPose < 0 ? -1 : 1;
      const flicker = 0.72 + Math.sin(state.time * 18) * 0.14;
      for (let i = 0; i < 4; i += 1) {
        const y = player.y + (i - 1.5) * player.radius * 0.28 + Math.sin(state.time * 8 + i) * 1.6;
        const start = player.x - direction * player.radius * (1.05 + i * 0.12);
        const end = player.x - direction * player.radius * (1.86 + i * 0.2);
        this.wakeGraphics.lineStyle(2.4 - i * 0.26, i % 2 === 0 ? 0xa6fff8 : 0xfff4ee, poseStrength * flicker * (i % 2 === 0 ? 0.46 : 0.26));
        this.wakeGraphics.beginPath();
        this.wakeGraphics.moveTo(start, y);
        this.wakeGraphics.lineTo(end, player.y + (y - player.y) * 0.72);
        this.wakeGraphics.strokePath();
      }
    }

    if (state.pulseTimer > 0) {
      const progress = 1 - state.pulseTimer / 0.38;
      const radius = 72 + progress * (150 + state.upgrades.pulse * 32);
      this.abilityGraphics.lineStyle(5 - progress * 2.5, 0xc2ffff, 1 - progress);
      this.abilityGraphics.strokeCircle(player.x, player.y, radius);
      this.abilityGraphics.fillStyle(0x66f2ff, (1 - progress) * 0.18);
      this.abilityGraphics.fillCircle(player.x, player.y, radius * 0.62);
    }

    if (state.dashTimer > 0) {
      const alpha = (state.dashTimer / 0.22) * 0.58;
      this.abilityGraphics.lineStyle(3.4, 0xd2fffa, alpha);
      for (let i = 0; i < 5; i += 1) {
        const y = player.y + (i - 2) * player.radius * 0.22;
        this.abilityGraphics.beginPath();
        this.abilityGraphics.moveTo(player.x - player.radius * (1.1 + i * 0.08), y);
        this.abilityGraphics.lineTo(player.x - player.radius * (2.8 + i * 0.14), player.y + (y - player.y) * 0.6);
        this.abilityGraphics.strokePath();
      }
    }

  }

  syncParallaxLayer(layer, speed) {
    const scrollPosition = state.scroll * speed;
    const drawWidth = Math.max(1, layer.drawWidth);
    const baseIndex = Math.floor(scrollPosition / drawWidth);
    const localOffset = -(scrollPosition - baseIndex * drawWidth);
    const tileCount = Math.ceil(this.width / drawWidth) + 3;

    for (let tile = -1; tile < tileCount; tile += 1) {
      const sprite = layer.sprites[tile + 1];
      if (!sprite) continue;
      const x = localOffset + tile * drawWidth;
      sprite.setVisible(true);
      sprite.setPosition(x + drawWidth * 0.5, layer.y);
      sprite.setDisplaySize(layer.drawWidth, layer.drawHeight);
      sprite.setFlipX(Math.abs((baseIndex + tile) % 2) === 1);
    }

    for (let index = tileCount + 1; index < layer.sprites.length; index += 1) {
      layer.sprites[index].setVisible(false);
    }
  }

  syncShots() {
    if (shouldUseMobileRenderMode()) {
      this.syncMobileShots();
      return;
    }

    this.shotGraphics.clear();
    for (const shot of state.shots) {
      const sprite = this.getImage(this.shotSprites, shot, "antibodyProjectile");
      const angle = Math.atan2(shot.vy, shot.vx);
      const pulse = 1 + Math.sin((shot.age || 0) * 22) * 0.06;
      sprite.setDepth(74);
      sprite.setPosition(shot.x, shot.y);
      sprite.setRotation(angle);
      sprite.setScale(pulse * 1.18);
      sprite.setAlpha(1);
      shot._phaserSyncId = this.syncId;
    }
  }

  syncMobileShots() {
    this.shotGraphics.clear();
    if (state.shots.length === 0) return;

    this.shotGraphics.lineStyle(5.2, 0x60efff, 0.24);
    this.shotGraphics.beginPath();
    for (const shot of state.shots) {
      this.traceMobileShot(shot);
    }
    this.shotGraphics.strokePath();

    this.shotGraphics.lineStyle(2.4, 0xdfffff, 0.9);
    this.shotGraphics.beginPath();
    for (const shot of state.shots) {
      this.traceMobileShot(shot);
      shot._phaserSyncId = this.syncId;
    }
    this.shotGraphics.strokePath();
  }

  traceMobileShot(shot) {
    const ux = shot.renderUx || 1;
    const uy = shot.renderUy || 0;
    const px = -uy;
    const py = ux;
    const stemBack = 12;
    const stemForward = 8;
    const branchForward = 20;
    const branchSpread = 5.2;
    const baseX = shot.x - ux * stemBack;
    const baseY = shot.y - uy * stemBack;
    const splitX = shot.x + ux * stemForward;
    const splitY = shot.y + uy * stemForward;
    const tipX = shot.x + ux * branchForward;
    const tipY = shot.y + uy * branchForward;

    this.shotGraphics.moveTo(baseX, baseY);
    this.shotGraphics.lineTo(splitX, splitY);
    this.shotGraphics.moveTo(splitX, splitY);
    this.shotGraphics.lineTo(tipX + px * branchSpread, tipY + py * branchSpread);
    this.shotGraphics.moveTo(splitX, splitY);
    this.shotGraphics.lineTo(tipX - px * branchSpread, tipY - py * branchSpread);
  }

  syncParticles() {
    this.particleGraphics.clear();
    const mobileMode = shouldUseMobileRenderMode();
    const maxVisibleParticles = mobileMode ? 130 : state.particles.length;
    const particleStride =
      state.particles.length > maxVisibleParticles
        ? Math.ceil(state.particles.length / maxVisibleParticles)
        : 1;

    for (let index = 0; index < state.particles.length; index += particleStride) {
      const particle = state.particles[index];
      const progress = particle.ttl / particle.life;
      this.particleGraphics.fillStyle(colorToNumber(particle.color, 0xffffff), 1 - progress);
      this.particleGraphics.fillCircle(
        particle.x,
        particle.y,
        particle.radius * (1 - progress * 0.45),
      );
    }
  }

  getImage(map, key, texture, frame = undefined) {
    let image = map.get(key);
    if (!image) {
      image = this.scene.add.image(0, 0, texture, frame);
      image.setOrigin(0.5);
      map.set(key, image);
    } else if (frame !== undefined) {
      image.setTexture(texture, frame);
    } else {
      image.setTexture(texture);
    }
    image.setVisible(true);
    return image;
  }

  cleanupMaps() {
    this.cleanupMap(this.redCellSprites);
    this.cleanupMap(this.plateletSprites);
    this.cleanupMap(this.virusSprites);
    this.cleanupMap(this.virusGlowSprites);
    this.cleanupMap(this.shotSprites);
  }

  cleanupMap(map) {
    for (const [item, image] of map) {
      if (item._phaserSyncId === this.syncId) continue;
      image.destroy();
      map.delete(item);
    }
  }
}

function rand(min, max) {
  return min + Math.random() * (max - min);
}

function clamp(value, min, max) {
  return Math.max(min, Math.min(max, value));
}

function getViewportSize() {
  const visualViewport = window.visualViewport;
  return {
    width: visualViewport?.width || window.innerWidth,
    height: visualViewport?.height || window.innerHeight,
  };
}

function isTouchDevice() {
  return navigator.maxTouchPoints > 0 || window.matchMedia("(pointer: coarse)").matches;
}

function syncViewportMetrics() {
  const { width, height } = getViewportSize();
  const touchDevice = isTouchDevice();
  const landscape = width >= height;

  document.documentElement.style.setProperty("--app-width", `${width}px`);
  document.documentElement.style.setProperty("--app-height", `${height}px`);
  document.documentElement.classList.toggle("is-touch-device", touchDevice);
  document.documentElement.classList.toggle("is-landscape", touchDevice && landscape);
  document.documentElement.classList.toggle("is-portrait", touchDevice && !landscape);
  document.documentElement.classList.toggle("is-short-landscape", touchDevice && landscape && height <= 430);
  mobilePerformanceMode = touchDevice;
}

async function requestMobileFullscreen() {
  if (!isTouchDevice() || document.fullscreenElement || !gameShellEl?.requestFullscreen) return;

  try {
    await gameShellEl.requestFullscreen({ navigationUI: "hide" });
  } catch (error) {
    // iOS Safari/Chrome do not expose element fullscreen for normal web pages.
  }
}

function lerp(a, b, t) {
  return a + (b - a) * t;
}

function lerpAngle(a, b, t) {
  const delta = Math.atan2(Math.sin(b - a), Math.cos(b - a));
  return a + delta * t;
}

function randomFrameIndex(group) {
  return Math.floor(rand(0, spriteFrames[group].length));
}

function getSpriteAsset(spriteGroup) {
  if (spriteGroup === "influenzaVirus") return influenzaSpriteSheet;
  if (spriteGroup === "poxBoss") return poxBossSpriteSheet;
  if (spriteGroup === "adenovirusMini") return adenovirusSpriteSheet;
  if (spriteGroup === "filovirusBoss") return filovirusSpriteSheet;
  return spriteAtlas;
}

function createLoopTrack(config) {
  const element = new Audio(config.src);
  const track = {
    element,
    baseVolume: config.volume,
    currentVolume: 0,
    targetVolume: 0,
    fadeLoop: config.fadeLoop ?? 0,
    loopFadeIn: config.fadeLoop ?? 0,
    loopMultiplier: 1,
    shouldPlay: false,
  };

  element.preload = "auto";
  element.loop = false;
  element.volume = 0;
  element.addEventListener("ended", () => restartLoopTrack(track));
  return track;
}

function createSfxPool(config) {
  const poolSize = config.poolSize ?? 3;
  return {
    volume: config.volume,
    maxDuration: config.maxDuration ?? 0,
    fadeOut: config.fadeOut ?? 0.25,
    index: 0,
    pool: Array.from({ length: poolSize }, () => {
      const element = new Audio(config.src);
      element.preload = "auto";
      element.volume = config.volume * audio.sfxMasterVolume;
      return element;
    }),
  };
}

function prepareAudioAssets() {
  if (audio.assetsReady) return;

  audio.music = Object.fromEntries(
    Object.entries(audioManifest.music).map(([key, config]) => [key, createLoopTrack(config)]),
  );
  audio.ambience = Object.fromEntries(
    Object.entries(audioManifest.ambience).map(([key, config]) => [
      key,
      createLoopTrack(config),
    ]),
  );
  audio.sfx = Object.fromEntries(
    Object.entries(audioManifest.sfx).map(([key, config]) => [key, createSfxPool(config)]),
  );
  audio.assetsReady = true;
}

function ensureAudio() {
  prepareAudioAssets();
  audio.unlocked = true;

  if (!window.AudioContext && !window.webkitAudioContext) {
    updateAudioScene(0);
    return null;
  }

  if (!audio.context) {
    const AudioContextClass = window.AudioContext || window.webkitAudioContext;
    audio.context = new AudioContextClass();
    audio.master = audio.context.createGain();
    const compressor = audio.context.createDynamicsCompressor();
    compressor.threshold.value = -18;
    compressor.knee.value = 16;
    compressor.ratio.value = 6;
    compressor.attack.value = 0.004;
    compressor.release.value = 0.16;
    audio.master.gain.value = 0.42;
    audio.master.connect(compressor);
    compressor.connect(audio.context.destination);
  }

  if (audio.context.state === "suspended") {
    void audio.context.resume();
  }

  updateAudioScene(0);
  return audio.context;
}

function tryPlayElement(element) {
  const playPromise = element.play();
  if (playPromise) {
    playPromise.catch(() => {});
  }
}

function restartLoopTrack(track) {
  if (!track.shouldPlay) return;

  try {
    track.element.currentTime = 0;
  } catch (error) {
    return;
  }
  track.loopFadeIn = track.fadeLoop;
  track.loopMultiplier = track.fadeLoop > 0 ? 0 : 1;
  tryPlayElement(track.element);
}

function updateLoopEnvelope(track, dt) {
  const { element, fadeLoop } = track;
  if (fadeLoop <= 0 || !Number.isFinite(element.duration) || element.duration <= fadeLoop + 0.35) {
    track.loopMultiplier = 1;
    return;
  }

  if (element.paused || !track.shouldPlay) {
    track.loopMultiplier = 1;
    return;
  }

  const remaining = element.duration - element.currentTime;
  if (remaining <= 0.08) {
    restartLoopTrack(track);
    return;
  }

  if (remaining <= fadeLoop) {
    track.loopMultiplier = clamp(remaining / fadeLoop, 0, 1);
    return;
  }

  if (track.loopFadeIn > 0) {
    track.loopFadeIn = Math.max(0, track.loopFadeIn - dt);
    track.loopMultiplier = clamp(1 - track.loopFadeIn / fadeLoop, 0, 1);
    return;
  }

  track.loopMultiplier = 1;
}

function updateLoopTrack(track, targetVolume, dt) {
  track.shouldPlay = targetVolume > 0.001;
  track.targetVolume = targetVolume;

  if (track.shouldPlay && track.element.paused) {
    tryPlayElement(track.element);
  }

  const fadeAmount = clamp(dt * audio.musicFadeSpeed, 0, 1);
  track.currentVolume = lerp(track.currentVolume, track.targetVolume, fadeAmount);
  updateLoopEnvelope(track, dt);
  track.element.volume = clamp(track.currentVolume * track.loopMultiplier, 0, 1);

  if (!track.shouldPlay && track.currentVolume < 0.003 && !track.element.paused) {
    track.element.pause();
    track.loopFadeIn = track.fadeLoop;
    track.loopMultiplier = track.fadeLoop > 0 ? 0 : 1;
    try {
      track.element.currentTime = 0;
    } catch (error) {
      // Some browsers disallow seeking before metadata loads.
    }
  }
}

function getDesiredMusicKey() {
  if (state.levelClearMusicDelay > 0 || state.bossMusicDelay > 0 || state.runStartMusicDelay > 0) {
    return null;
  }
  if (state.awaitingUpgrade || state.levelComplete) return "upgrade";
  if (!state.running || state.ended) return "menu";
  if (state.paused) return audio.activeMusicKey || "combat";
  if (isBossMission() && (state.bossSpawned || getActiveBoss())) return "boss";
  if (state.player && (state.player.health <= 35 || (state.level >= 6 && getDistanceProgress() >= 0.62))) {
    return "highDanger";
  }
  return "combat";
}

function updateAudioScene(dt = 0.016) {
  if (!audio.assetsReady || !audio.unlocked) return;

  state.levelClearMusicDelay = Math.max(0, state.levelClearMusicDelay - dt);
  state.bossMusicDelay = Math.max(0, state.bossMusicDelay - dt);
  state.runStartMusicDelay = Math.max(0, state.runStartMusicDelay - dt);
  state.ambienceIntroDelay = Math.max(0, state.ambienceIntroDelay - dt);
  const musicKey = getDesiredMusicKey();
  if (!state.paused && musicKey) {
    audio.activeMusicKey = musicKey;
  }
  const pauseScale = state.paused ? 0.34 : 1;
  const musicScale = audio.musicMuted ? 0 : 1;
  for (const [key, track] of Object.entries(audio.music)) {
    updateLoopTrack(track, key === musicKey ? track.baseVolume * pauseScale * musicScale : 0, dt);
  }

  const ambienceHeld = state.bossMusicDelay > 0 || state.runStartMusicDelay > 0 || state.ambienceIntroDelay > 0;
  const playAmbience =
    state.running && !state.ended && !state.awaitingUpgrade && !state.levelComplete && !ambienceHeld;
  const ambientIntensity = playAmbience && !audio.musicMuted ? (state.paused ? 0.34 : 1) : 0;
  const ambienceScales = {
    bloodstream: 1,
    cellularSparkle: state.level >= 3 ? 0.55 : 0,
    deepVesselPulse:
      state.level >= 6 || isBossMission() || (state.player && state.player.health <= 45) ? 0.75 : 0,
  };
  for (const [key, track] of Object.entries(audio.ambience)) {
    updateLoopTrack(track, track.baseVolume * ambientIntensity * (ambienceScales[key] ?? 1), dt);
  }
}

function unlockMenuAudio() {
  const menuVisible = !overlay.hidden && !state.running && !state.awaitingUpgrade && !state.levelComplete;
  if (!menuVisible) return;
  ensureAudio();
  updateAudioScene(0);
}

function playAssetSfx(name, fallback) {
  if (audio.sfxMuted) return;
  prepareAudioAssets();
  const sfx = audio.sfx[name];
  if (!audio.unlocked || !sfx) {
    fallback?.();
    return;
  }

  const element = sfx.pool[sfx.index];
  sfx.index = (sfx.index + 1) % sfx.pool.length;
  if (element.audioStopTimer) {
    window.clearTimeout(element.audioStopTimer);
    element.audioStopTimer = null;
  }
  if (element.audioFadeFrame) {
    window.cancelAnimationFrame(element.audioFadeFrame);
    element.audioFadeFrame = null;
  }
  element.pause();
  try {
    element.currentTime = 0;
  } catch (error) {
    // The next play still works; the browser just was not ready to seek yet.
  }
  element.volume = clamp(sfx.volume * audio.sfxMasterVolume, 0, 1);
  const playPromise = element.play();
  if (playPromise) {
    playPromise.catch(() => fallback?.());
  }

  if (sfx.maxDuration > 0) {
    const maxDurationMs = sfx.maxDuration * 1000;
    const fadeDurationMs = Math.min(sfx.fadeOut * 1000, maxDurationMs);
    const holdDurationMs = Math.max(0, maxDurationMs - fadeDurationMs);
    element.audioStopTimer = window.setTimeout(() => {
      const startVolume = element.volume;
      const fadeStart = performance.now();
      const fadeStep = (now) => {
        const progress = clamp((now - fadeStart) / Math.max(1, fadeDurationMs), 0, 1);
        element.volume = startVolume * (1 - progress);
        if (progress < 1 && !element.paused) {
          element.audioFadeFrame = window.requestAnimationFrame(fadeStep);
          return;
        }
        element.pause();
        try {
          element.currentTime = 0;
        } catch (error) {
          // The next play will restart cleanly once the browser allows seeking.
        }
        element.volume = clamp(sfx.volume * audio.sfxMasterVolume, 0, 1);
        element.audioFadeFrame = null;
        element.audioStopTimer = null;
      };
      element.audioFadeFrame = window.requestAnimationFrame(fadeStep);
    }, holdDurationMs);
  }
}

function playTone({ type = "sine", start = 440, end = start, duration = 0.12, gain = 0.08 }) {
  if (audio.sfxMuted) return;
  const context = ensureAudio();
  if (!context || !audio.master) return;

  const now = context.currentTime;
  const oscillator = context.createOscillator();
  const output = context.createGain();

  oscillator.type = type;
  oscillator.frequency.setValueAtTime(start, now);
  oscillator.frequency.exponentialRampToValueAtTime(Math.max(20, end), now + duration);
  output.gain.setValueAtTime(0.0001, now);
  output.gain.exponentialRampToValueAtTime(gain, now + 0.012);
  output.gain.exponentialRampToValueAtTime(0.0001, now + duration);

  oscillator.connect(output);
  output.connect(audio.master);
  oscillator.start(now);
  oscillator.stop(now + duration + 0.02);
}

function playNoise({ duration = 0.16, gain = 0.06, frequency = 900 }) {
  if (audio.sfxMuted) return;
  const context = ensureAudio();
  if (!context || !audio.master) return;

  const sampleCount = Math.max(1, Math.floor(context.sampleRate * duration));
  const buffer = context.createBuffer(1, sampleCount, context.sampleRate);
  const data = buffer.getChannelData(0);
  for (let i = 0; i < sampleCount; i += 1) {
    data[i] = (Math.random() * 2 - 1) * (1 - i / sampleCount);
  }

  const source = context.createBufferSource();
  const filter = context.createBiquadFilter();
  const output = context.createGain();
  const now = context.currentTime;

  filter.type = "bandpass";
  filter.frequency.value = frequency;
  filter.Q.value = 1.8;
  output.gain.setValueAtTime(gain, now);
  output.gain.exponentialRampToValueAtTime(0.0001, now + duration);

  source.buffer = buffer;
  source.connect(filter);
  filter.connect(output);
  output.connect(audio.master);
  source.start(now);
}

function playShootSfx() {
  playAssetSfx("antibodyShot", () => {
    playTone({ type: "triangle", start: 980, end: 520, duration: 0.1, gain: 0.12 });
    playTone({ type: "sine", start: 1520, end: 880, duration: 0.055, gain: 0.06 });
  });
}

function playSwimSurgeSfx(direction) {
  playAssetSfx("chemotaxisDash", () => {
    playNoise({ duration: 0.18, gain: 0.11, frequency: direction > 0 ? 720 : 520 });
    playTone({
      type: "sine",
      start: direction > 0 ? 180 : 150,
      end: direction > 0 ? 260 : 95,
      duration: 0.16,
      gain: 0.064,
    });
  });
}

function playChemotaxisDashSfx(direction) {
  playAssetSfx("chemotaxisDashUpgraded", () => {
    playNoise({ duration: 0.2, gain: 0.15, frequency: direction > 0 ? 860 : 640 });
    playTone({
      type: "triangle",
      start: direction > 0 ? 260 : 210,
      end: direction > 0 ? 680 : 140,
      duration: 0.2,
      gain: 0.09,
    });
  });
}

function playVirusPopSfx() {
  playAssetSfx("virusPop", () => {
    playNoise({ duration: 0.22, gain: 0.18, frequency: 640 });
    playTone({ type: "sawtooth", start: 180, end: 58, duration: 0.18, gain: 0.12 });
  });
}

function playAntibodyHitSfx() {
  playAssetSfx("antibodyHit", () => {
    playTone({ type: "triangle", start: 440, end: 720, duration: 0.09, gain: 0.08 });
  });
}

function playBossHitSfx() {
  const now = performance.now();
  if (now - lastBossHitSfxAt < 150) return;
  lastBossHitSfxAt = now;
  playAssetSfx("bossHit", () => {
    playNoise({ duration: 0.12, gain: 0.14, frequency: 180 });
    playTone({ type: "sawtooth", start: 240, end: 120, duration: 0.12, gain: 0.08 });
  });
}

function playBossDefeatedSfx() {
  playAssetSfx("bossDefeated", () => {
    playNoise({ duration: 0.32, gain: 0.18, frequency: 110 });
    playTone({ type: "triangle", start: 180, end: 520, duration: 0.34, gain: 0.1 });
  });
}

function playBossPhaseChangeSfx() {
  playAssetSfx("bossPhaseChange", () => {
    playNoise({ duration: 0.24, gain: 0.16, frequency: 240 });
    playTone({ type: "sawtooth", start: 160, end: 360, duration: 0.22, gain: 0.08 });
  });
}

function playBuddingSplitSfx() {
  playAssetSfx("buddingSplit", () => {
    playNoise({ duration: 0.18, gain: 0.16, frequency: 520 });
    playTone({ type: "triangle", start: 360, end: 180, duration: 0.14, gain: 0.08 });
  });
}

function playInfluenzaHitSfx() {
  playAssetSfx("influenzaHit", () => {
    playTone({ type: "triangle", start: 320, end: 560, duration: 0.1, gain: 0.08 });
  });
}

function playInfluenzaReplicationSfx() {
  playAssetSfx("influenzaReplication", () => {
    playNoise({ duration: 0.2, gain: 0.14, frequency: 460 });
    playTone({ type: "sine", start: 220, end: 680, duration: 0.18, gain: 0.08 });
  });
}

function playPlateletBumpSfx() {
  playAssetSfx("plateletBump", () => {
    playNoise({ duration: 0.16, gain: 0.15, frequency: 300 });
    playTone({ type: "sawtooth", start: 190, end: 92, duration: 0.14, gain: 0.08 });
  });
}

function playPauseOpenSfx() {
  playAssetSfx("pauseOpen", () => {
    playTone({ type: "triangle", start: 520, end: 320, duration: 0.14, gain: 0.08 });
  });
}

function playPauseResumeSfx() {
  playAssetSfx("pauseResume", () => {
    playTone({ type: "triangle", start: 320, end: 560, duration: 0.14, gain: 0.08 });
  });
}

function playRestartConfirmSfx() {
  playAssetSfx("restartConfirm", () => {
    playTone({ type: "sawtooth", start: 240, end: 180, duration: 0.18, gain: 0.08 });
  });
}

function playUpgradeHoverSfx() {
  const now = performance.now();
  if (now - lastUpgradeHoverSfxAt < 130) return;
  lastUpgradeHoverSfxAt = now;
  playAssetSfx("upgradeHover", () => {
    playTone({ type: "sine", start: 680, end: 920, duration: 0.09, gain: 0.05 });
  });
}

function playUiSelectSfx() {
  playAssetSfx("uiSelect", () => {
    playTone({ type: "triangle", start: 520, end: 760, duration: 0.08, gain: 0.07 });
  });
}

function playVirusHitSfx(virus) {
  if (isBossVirus(virus)) {
    playBossHitSfx();
  } else if (virus.type === "influenza") {
    playInfluenzaHitSfx();
  } else {
    playAntibodyHitSfx();
  }
}

function playUpgradeSfx() {
  playAssetSfx("upgradeSelected", () => {
    playTone({ type: "triangle", start: 360, end: 920, duration: 0.2, gain: 0.11 });
    playTone({ type: "sine", start: 680, end: 1320, duration: 0.16, gain: 0.07 });
  });
}

function playPulseSfx() {
  playAssetSfx("complementPulse", () => {
    playNoise({ duration: 0.28, gain: 0.16, frequency: 420 });
    playTone({ type: "sine", start: 240, end: 760, duration: 0.22, gain: 0.12 });
  });
}

function playPlayerDamageSfx() {
  playAssetSfx("playerDamage", () => {
    playNoise({ duration: 0.18, gain: 0.16, frequency: 260 });
    playTone({ type: "sawtooth", start: 160, end: 82, duration: 0.15, gain: 0.1 });
  });
}

function playPlayerDeathSfx() {
  playAssetSfx("playerDeath", () => {
    playNoise({ duration: 0.32, gain: 0.2, frequency: 180 });
    playTone({ type: "sawtooth", start: 180, end: 46, duration: 0.34, gain: 0.13 });
  });
}

function playLevelCompleteSfx() {
  playAssetSfx("levelComplete", () => {
    playTone({ type: "triangle", start: 520, end: 980, duration: 0.16, gain: 0.1 });
    playTone({ type: "sine", start: 780, end: 1320, duration: 0.26, gain: 0.075 });
  });
}

function playBossWarningSfx() {
  playAssetSfx("bossWarning", () => {
    playNoise({ duration: 0.44, gain: 0.2, frequency: 120 });
    playTone({ type: "sawtooth", start: 84, end: 42, duration: 0.5, gain: 0.16 });
  });
}

function drawImageFrame(asset, frame, x, y, targetHeight, options = {}) {
  if (!asset.loaded || !frame) return false;

  const {
    rotation = 0,
    alpha = 1,
    shadowColor = "rgba(255, 255, 255, 0)",
    shadowBlur = 0,
    pulse = 1,
    offsetX = 0,
    offsetY = 0,
    flipX = false,
    scaleX = 1,
    scaleY = 1,
  } = options;
  const drawHeight = targetHeight * pulse * scaleY;
  const drawWidth = drawHeight * (frame.w / frame.h) * scaleX;

  ctx.save();
  ctx.translate(x, y);
  ctx.rotate(rotation);
  if (flipX) ctx.scale(-1, 1);
  ctx.globalAlpha *= alpha;
  ctx.shadowColor = shadowColor;
  ctx.shadowBlur = shadowBlur;
  ctx.drawImage(
    asset.image,
    frame.x,
    frame.y,
    frame.w,
    frame.h,
    -drawWidth / 2 + offsetX,
    -drawHeight / 2 + offsetY,
    drawWidth,
    drawHeight,
  );
  ctx.restore();
  return true;
}

function drawAtlasFrame(frame, x, y, targetHeight, options = {}) {
  return drawImageFrame(spriteAtlas, frame, x, y, targetHeight, options);
}

function createCachedShotSprite() {
  const pixelRatio = Math.min(state.dpr || 1, 2);
  const logicalWidth = 68;
  const logicalHeight = 38;
  const originX = 30;
  const originY = logicalHeight * 0.5;
  const spriteCanvas = document.createElement("canvas");
  spriteCanvas.width = Math.ceil(logicalWidth * pixelRatio);
  spriteCanvas.height = Math.ceil(logicalHeight * pixelRatio);
  const spriteCtx = spriteCanvas.getContext("2d");
  spriteCtx.setTransform(pixelRatio, 0, 0, pixelRatio, 0, 0);
  spriteCtx.imageSmoothingEnabled = true;
  spriteCtx.imageSmoothingQuality = "high";
  spriteCtx.translate(originX, originY);
  spriteCtx.shadowColor = palette.cyan;
  spriteCtx.shadowBlur = 8;
  spriteCtx.globalAlpha = 0.34;
  spriteCtx.strokeStyle = "rgba(96, 239, 255, 0.62)";
  spriteCtx.lineWidth = 2.2;
  spriteCtx.lineCap = "round";
  spriteCtx.beginPath();
  spriteCtx.moveTo(-24, 0);
  spriteCtx.lineTo(-9, 0);
  spriteCtx.stroke();

  spriteCtx.globalAlpha = 0.5;
  spriteCtx.strokeStyle = "rgba(96, 239, 255, 0.88)";
  spriteCtx.lineWidth = 6;
  spriteCtx.beginPath();
  spriteCtx.moveTo(-8, 0);
  spriteCtx.lineTo(2.5, 0);
  spriteCtx.moveTo(2.5, 0);
  spriteCtx.lineTo(12, -6);
  spriteCtx.moveTo(2.5, 0);
  spriteCtx.lineTo(12, 6);
  spriteCtx.stroke();

  spriteCtx.globalAlpha = 0.92;
  spriteCtx.strokeStyle = "rgba(176, 255, 255, 0.96)";
  spriteCtx.lineWidth = 2.8;
  spriteCtx.beginPath();
  spriteCtx.moveTo(-8, 0);
  spriteCtx.lineTo(2.5, 0);
  spriteCtx.moveTo(2.5, 0);
  spriteCtx.lineTo(12, -6);
  spriteCtx.moveTo(2.5, 0);
  spriteCtx.lineTo(12, 6);
  spriteCtx.stroke();

  spriteCtx.globalAlpha = 1;
  spriteCtx.fillStyle = "#dfffff";
  spriteCtx.beginPath();
  spriteCtx.arc(12, -6, 1.5, 0, TAU);
  spriteCtx.arc(12, 6, 1.5, 0, TAU);
  spriteCtx.fill();

  renderCache.shotSprite = {
    canvas: spriteCanvas,
    key: `shot-${pixelRatio}`,
    logicalWidth,
    logicalHeight,
    originX,
    originY,
  };
}

function getCachedShotSprite() {
  const key = `shot-${Math.min(state.dpr || 1, 2)}`;
  if (!renderCache.shotSprite || renderCache.shotSprite.key !== key) {
    createCachedShotSprite();
  }
  return renderCache.shotSprite;
}

function getScaledParallaxLayer(asset, drawWidth, drawHeight) {
  if (!asset.loaded) return null;

  const pixelRatio = Math.min(state.dpr || 1, 2);
  const logicalWidth = Math.max(1, Math.ceil(drawWidth));
  const logicalHeight = Math.max(1, Math.ceil(drawHeight));
  const key = `${logicalWidth}x${logicalHeight}@${pixelRatio}`;
  if (asset.scaledLayer?.key === key) return asset.scaledLayer;

  const layerCanvas = document.createElement("canvas");
  layerCanvas.width = Math.ceil(logicalWidth * pixelRatio);
  layerCanvas.height = Math.ceil(logicalHeight * pixelRatio);
  const layerCtx = layerCanvas.getContext("2d");
  layerCtx.setTransform(pixelRatio, 0, 0, pixelRatio, 0, 0);
  layerCtx.imageSmoothingEnabled = true;
  layerCtx.imageSmoothingQuality = "high";
  layerCtx.drawImage(asset.image, 0, 0, logicalWidth, logicalHeight);
  asset.scaledLayer = {
    canvas: layerCanvas,
    key,
    logicalWidth,
    logicalHeight,
  };
  return asset.scaledLayer;
}

function distance(a, b) {
  const dx = a.x - b.x;
  const dy = a.y - b.y;
  return Math.hypot(dx, dy);
}

function distanceSquared(a, b) {
  const dx = a.x - b.x;
  const dy = a.y - b.y;
  return dx * dx + dy * dy;
}

function isWithinDistance(a, b, radius) {
  return distanceSquared(a, b) < radius * radius;
}

function compactArray(array, shouldKeep, releaseItem) {
  let writeIndex = 0;
  for (let readIndex = 0; readIndex < array.length; readIndex += 1) {
    const item = array[readIndex];
    if (shouldKeep(item)) {
      if (writeIndex !== readIndex) array[writeIndex] = item;
      writeIndex += 1;
    } else if (releaseItem) {
      releaseItem(item);
    }
  }
  array.length = writeIndex;
}

function clearRuntimeArray(array, releaseItem) {
  if (releaseItem) {
    for (const item of array) releaseItem(item);
  }
  array.length = 0;
}

function recycleShot(shot) {
  shot.target = null;
  if (shotPool.length < MAX_POOLED_SHOTS) shotPool.push(shot);
}

function recycleParticle(particle) {
  if (particlePool.length < MAX_POOLED_PARTICLES) particlePool.push(particle);
}

function clearShots() {
  clearRuntimeArray(state.shots, recycleShot);
  state.lockTarget = null;
}

function clearParticles() {
  clearRuntimeArray(state.particles, recycleParticle);
}

function resize() {
  syncViewportMetrics();
  const rect = canvas.getBoundingClientRect();
  state.width = Math.max(320, rect.width);
  state.height = Math.max(320, rect.height);
  state.dpr = Math.min(window.devicePixelRatio || 1, 2);
  canvas.width = Math.floor(state.width * state.dpr);
  canvas.height = Math.floor(state.height * state.dpr);
  ctx.setTransform(state.dpr, 0, 0, state.dpr, 0, 0);
  ctx.imageSmoothingEnabled = true;
  ctx.imageSmoothingQuality = "high";

  if (state.player) {
    state.player.x = clamp(state.player.x, 72, state.width * 0.72);
    state.player.y = clampToVessel(state.player.x, state.player.y, state.player.radius);
  }

  seedPlasma();
  phaserRenderer?.resize(state.width, state.height);
}

function seedPlasma() {
  const count = Math.round((state.width * state.height) / 16000);
  state.plasma = Array.from({ length: count }, (_, i) => ({
    x: rand(0, state.width),
    y: rand(0, state.height),
    radius: rand(0.7, 2.4),
    speed: rand(8, 30),
    alpha: rand(0.12, 0.34),
    layer: i % 3,
  }));
}

function topWallAt(x, t = state.time) {
  const w = state.width;
  const h = state.height;
  const n = (x + state.scroll * 0.55) / Math.max(1, w);
  return (
    h * 0.15 +
    Math.sin(n * 6.2 + t * 0.42) * h * 0.026 +
    Math.sin(n * 15.3 - t * 0.28) * h * 0.015
  );
}

function bottomWallAt(x, t = state.time) {
  const w = state.width;
  const h = state.height;
  const n = (x + state.scroll * 0.46) / Math.max(1, w);
  return (
    h * 0.86 +
    Math.sin(n * 5.4 + 1.7 - t * 0.36) * h * 0.028 +
    Math.sin(n * 12.8 + t * 0.24) * h * 0.014
  );
}

function clampToVessel(x, y, radius) {
  const top = topWallAt(x) + radius + 8;
  const bottom = bottomWallAt(x) - radius - 8;
  return clamp(y, top, bottom);
}

function getMission(level) {
  if (level <= missionDeck.length) {
    return missionDeck[level - 1];
  }

  return encounterMissionDeck[(level - missionDeck.length - 1) % encounterMissionDeck.length];
}

function isBossMission(mission = state.currentMission) {
  return Boolean(mission?.bossType);
}

function isBossVirus(virus) {
  return Boolean(virus?.isBoss);
}

function getDistanceProgress() {
  return clamp((state.scroll - state.levelStartScroll) / state.levelLength, 0, 1);
}

function getLevelDifficultyMultiplier(level = state.level) {
  if (level <= 4) return 1;
  return Math.pow(1.2, level - 4);
}

function getLevelConfig(level) {
  const mission = getMission(level);
  const encounterLevel = isBossMission(mission);
  const difficulty = getLevelDifficultyMultiplier(level);
  const baseLength = 2200 + level * (encounterLevel ? 560 : 520);
  const baseKills = 3 + level * 2;
  const baseSpawnScale = encounterLevel
    ? Math.max(0.42, 0.86 - level * 0.035)
    : Math.max(0.58, 1 - level * 0.055);

  return {
    length: Math.round(baseLength * (1 + Math.max(0, difficulty - 1) * 0.18)),
    kills: Math.min(85, Math.ceil(baseKills * difficulty)),
    spawnScale: Math.max(0.28, baseSpawnScale / Math.sqrt(difficulty)),
    mission,
  };
}

function getActiveBoss() {
  return state.viruses.find((virus) => isBossVirus(virus) && !virus.dead && virus.hp > 0) || null;
}

function getLevelProgress() {
  const boss = isBossMission() ? getActiveBoss() : null;
  const distanceProgress = getDistanceProgress();
  const killProgress = clamp(state.levelKills / state.levelGoal, 0, 1);
  if (isBossMission()) {
    if (state.bossDefeated) {
      return {
        distance: 1,
        kills: 1,
        combined: 1,
        complete: true,
      };
    }

    const triggerProgress = state.bossTriggerProgress || 0.86;
    const approachProgress = clamp(distanceProgress / triggerProgress, 0, 1) * 0.82;
    const bossProgress = boss ? 1 - clamp(boss.hp / boss.maxHp, 0, 1) : 0;
    const combined = boss ? 0.82 + bossProgress * 0.18 : approachProgress;
    return {
      distance: combined,
      kills: killProgress,
      combined,
      complete: false,
    };
  }

  return {
    distance: distanceProgress,
    kills: killProgress,
    combined: (distanceProgress + killProgress) * 0.5,
    complete: distanceProgress >= 1 && killProgress >= 1,
  };
}

function showLevelBanner(text, duration = 2.1) {
  levelBannerEl.textContent = text;
  levelBannerEl.classList.add("is-visible");
  state.levelBannerTimer = duration;
}

function configureLevel(level) {
  const config = getLevelConfig(level);
  state.level = level;
  state.currentMission = config.mission;
  state.levelStartScroll = state.scroll;
  state.levelLength = config.length;
  state.levelGoal = config.kills;
  state.levelKills = 0;
  state.levelTransitionTimer = 0;
  state.levelClearMusicDelay = 0;
  state.bossMusicDelay = 0;
  state.bossWarningActive = false;
  state.bossWarningTimer = 0;
  state.bossWarningCleared = false;
  state.pendingBossType = null;
  state.runStartMusicDelay = 0;
  state.ambienceIntroDelay = 1.4;
  state.influenzaNoticeTimer = 0;
  state.bossSpawned = false;
  state.bossDefeated = false;
  state.bossTriggerProgress = isBossMission(config.mission) ? rand(0.8, 0.9) : 0.85;
  state.nextVirus = 1.05;
  state.nextPlatelet = 4.4;
  showLevelBanner(`${config.mission.name}: ${config.mission.term}`, 2.35);
}

function getUpgradeById(id) {
  return upgradeOptions.find((upgrade) => upgrade.id === id);
}

function getUpgradeRankLabel(id) {
  const rank = state.upgrades[id] || 0;
  return rank === 0 ? "New adaptation" : `Current rank ${rank}`;
}

function isUpgradeMaxed(upgrade) {
  return (state.upgrades[upgrade.id] || 0) >= upgrade.levels.length;
}

function areAllUpgradesMaxed() {
  return upgradeOptions.every((upgrade) => isUpgradeMaxed(upgrade));
}

function getUpgradeNextText(upgrade) {
  const rank = state.upgrades[upgrade.id] || 0;
  if (rank >= upgrade.levels.length) return "Fully adapted";
  return upgrade.levels[rank];
}

function renderUpgradePips(upgrade) {
  const rank = state.upgrades[upgrade.id] || 0;
  return upgrade.levels
    .map(
      (_, index) =>
        `<span class="upgrade-node__pip${index < rank ? " is-filled" : ""}"></span>`,
    )
    .join("");
}

function renderControlChips(upgrade) {
  return upgrade.controls
    .map((control) => `<span class="upgrade-node__key">${control}</span>`)
    .join("");
}

function renderUpgradeCards() {
  for (const card of upgradeCards) {
    const upgrade = getUpgradeById(card.dataset.upgrade);
    if (!upgrade) continue;
    const maxed = isUpgradeMaxed(upgrade);

    card.innerHTML = `
      <span class="upgrade-node__medallion" aria-hidden="true">
        <img src="${upgrade.medallion}" alt="">
      </span>
      <span class="upgrade-node__term">${upgrade.term}</span>
      <span class="upgrade-node__title">${upgrade.title}</span>
      <span class="upgrade-node__use">
        <span>${upgrade.controlIntro}</span>
        <span class="upgrade-node__keys">${renderControlChips(upgrade)}</span>
        <span>${upgrade.controlOutro}</span>
      </span>
      <span class="upgrade-node__body">${upgrade.body}</span>
      <span class="upgrade-node__divider" aria-hidden="true"></span>
      <span class="upgrade-node__next-label">Next Rank</span>
      <span class="upgrade-node__next">${getUpgradeNextText(upgrade)}</span>
      <span class="upgrade-node__rank">${getUpgradeRankLabel(upgrade.id)}</span>
      <span class="upgrade-node__pips" aria-hidden="true">${renderUpgradePips(upgrade)}</span>
    `;
    card.disabled = maxed;
    card.classList.toggle("is-maxed", maxed);
  }
}

function openLevelCompleteScreen() {
  state.levelComplete = true;
  state.levelTransitionTimer = 0;
  state.levelClearMusicDelay = LEVEL_CLEAR_MUSIC_DELAY;
  pointer.down = false;
  keys.clear();
  resetHeldActionInputs();
  state.viruses.length = 0;
  state.platelets.length = 0;
  clearShots();
  state.lockTarget = null;

  const mission = state.currentMission || getMission(state.level);
  const nextMission = getMission(state.level + 1);
  const health = state.player ? Math.round(state.player.health) : 0;
  levelCompleteTitleEl.textContent = `Level ${state.level} Complete`;
  levelCompleteMissionEl.textContent = `${mission.name}: ${mission.term}`;
  levelCompleteScoreEl.textContent = `Score ${state.score}`;
  levelCompleteKillsEl.textContent = isBossMission(mission)
    ? `${mission.bossTarget || mission.encounter} neutralized after ${state.levelKills} ${mission.target}`
    : `${state.levelKills} ${mission.target} neutralized`;
  levelCompleteHealthEl.textContent = `Health ${health}%`;
  nextMissionPreviewEl.textContent = `Next section: ${nextMission.name} (${nextMission.term})`;
  showUpgradeButton.textContent = areAllUpgradesMaxed() ? "Continue" : "Choose Adaptation";
  levelCompleteOverlay.hidden = false;
  upgradeOverlay.hidden = true;
  playLevelCompleteSfx();
  syncPauseUi();
  levelCompletePanelEl.focus({ preventScroll: true });
}

function openUpgradeMenu() {
  state.awaitingUpgrade = true;
  state.levelComplete = false;
  state.levelTransitionTimer = 0;
  pointer.down = false;
  keys.clear();
  resetHeldActionInputs();
  state.viruses.length = 0;
  state.platelets.length = 0;
  clearShots();
  state.lockTarget = null;
  const nextMission = getMission(state.level + 1);
  upgradeIntroEl.textContent = `Section ${state.level} cleared. Prepare for ${nextMission.name}: ${nextMission.term}.`;
  renderUpgradeCards();
  levelCompleteOverlay.hidden = true;
  upgradeOverlay.hidden = false;
  syncPauseUi();
  upgradePanelEl.focus({ preventScroll: true });
}

function showUpgradeTree(event) {
  if (!isOnScreenButtonActivation(event)) return;
  if (!state.levelComplete) return;
  playUiSelectSfx();

  if (areAllUpgradesMaxed()) {
    state.levelComplete = false;
    levelCompleteOverlay.hidden = true;
    startNextLevel();
    return;
  }

  state.levelComplete = false;
  levelCompleteOverlay.hidden = true;
  openUpgradeMenu();
}

function resetHeldActionInputs() {
  state.dashInputHeld = false;
  state.pulseInputHeld = false;
  mobileInput.fire = false;
  resetMobileJoystick();
  setMobileButtonPressed(mobileFireButton, false);
  setMobileButtonPressed(mobileDashButton, false);
  setMobileButtonPressed(mobilePulseButton, false);
  if (state.player) {
    state.player.horizontalSoundInput = 0;
  }
}

function getKeyboardMovementInput() {
  return {
    horizontal:
      (keys.has("ArrowRight") || keys.has("KeyD") ? 1 : 0) -
      (keys.has("ArrowLeft") || keys.has("KeyA") ? 1 : 0),
    vertical:
      (keys.has("ArrowDown") || keys.has("KeyS") ? 1 : 0) -
      (keys.has("ArrowUp") || keys.has("KeyW") ? 1 : 0),
  };
}

function getMovementInput() {
  const keyboard = getKeyboardMovementInput();
  let horizontal = keyboard.horizontal || mobileInput.joystickX;
  let vertical = keyboard.vertical || mobileInput.joystickY;
  const magnitude = Math.hypot(horizontal, vertical);

  if (magnitude < 0.08) {
    return { horizontal: 0, vertical: 0 };
  }

  if (magnitude > 1) {
    horizontal /= magnitude;
    vertical /= magnitude;
  }

  return { horizontal, vertical };
}

function setMobileButtonPressed(button, pressed) {
  if (!button) return;
  button.classList.toggle("is-pressed", pressed);
  button.setAttribute("aria-pressed", String(pressed));
}

function resetMobileJoystick() {
  mobileInput.joystickPointerId = null;
  mobileInput.joystickX = 0;
  mobileInput.joystickY = 0;
  mobileJoystickEl?.classList.remove("is-active");
  if (mobileJoystickKnobEl) {
    mobileJoystickKnobEl.style.transform = "translate(-50%, -50%)";
  }
}

function updateMobileJoystick(event) {
  if (!mobileJoystickEl || !mobileJoystickKnobEl) return;

  const rect = mobileJoystickEl.getBoundingClientRect();
  const centerX = rect.left + rect.width / 2;
  const centerY = rect.top + rect.height / 2;
  const maxRadius = Math.max(24, Math.min(rect.width, rect.height) * 0.36);
  let dx = event.clientX - centerX;
  let dy = event.clientY - centerY;
  const distanceFromCenter = Math.hypot(dx, dy);

  if (distanceFromCenter > maxRadius) {
    dx = (dx / distanceFromCenter) * maxRadius;
    dy = (dy / distanceFromCenter) * maxRadius;
  }

  const normalizedX = dx / maxRadius;
  const normalizedY = dy / maxRadius;
  const deadzone = Math.hypot(normalizedX, normalizedY) < 0.08;
  mobileInput.joystickX = deadzone ? 0 : normalizedX;
  mobileInput.joystickY = deadzone ? 0 : normalizedY;
  mobileJoystickKnobEl.style.transform =
    `translate(calc(-50% + ${dx}px), calc(-50% + ${dy}px))`;
}

function stopMobileControlEvent(event) {
  if (event.cancelable) event.preventDefault();
  event.stopPropagation();
}

function blockMobileControlGesture(event) {
  if (!isTouchDevice()) return;
  stopMobileControlEvent(event);
}

function isGameplayTouchReady() {
  return state.running && !state.paused && !state.ended && !state.awaitingUpgrade && !state.levelComplete;
}

function bindMobileControls() {
  if (mobileControlsEl) {
    for (const eventName of ["touchend", "touchcancel", "click", "dblclick", "contextmenu"]) {
      mobileControlsEl.addEventListener(eventName, blockMobileControlGesture, {
        capture: true,
        passive: false,
      });
    }
  }

  if (mobileJoystickEl) {
    mobileJoystickEl.addEventListener("pointerdown", (event) => {
      stopMobileControlEvent(event);
      ensureAudio();
      mobileInput.joystickPointerId = event.pointerId;
      mobileJoystickEl.setPointerCapture(event.pointerId);
      mobileJoystickEl.classList.add("is-active");
      updateMobileJoystick(event);
    });

    mobileJoystickEl.addEventListener("pointermove", (event) => {
      if (event.pointerId !== mobileInput.joystickPointerId) return;
      stopMobileControlEvent(event);
      updateMobileJoystick(event);
    });

    const endJoystick = (event) => {
      if (event.pointerId !== mobileInput.joystickPointerId) return;
      stopMobileControlEvent(event);
      if (mobileJoystickEl.hasPointerCapture(event.pointerId)) {
        mobileJoystickEl.releasePointerCapture(event.pointerId);
      }
      resetMobileJoystick();
    };

    mobileJoystickEl.addEventListener("pointerup", endJoystick);
    mobileJoystickEl.addEventListener("pointercancel", endJoystick);
    mobileJoystickEl.addEventListener("lostpointercapture", () => resetMobileJoystick());
  }

  if (mobileFireButton) {
    mobileFireButton.addEventListener("pointerdown", (event) => {
      stopMobileControlEvent(event);
      ensureAudio();
      if (!isGameplayTouchReady()) return;
      mobileFireButton.setPointerCapture(event.pointerId);
      mobileInput.fire = true;
      setMobileButtonPressed(mobileFireButton, true);
      fireShot();
    });

    const endFire = (event) => {
      stopMobileControlEvent(event);
      mobileInput.fire = false;
      setMobileButtonPressed(mobileFireButton, false);
      if (mobileFireButton.hasPointerCapture(event.pointerId)) {
        mobileFireButton.releasePointerCapture(event.pointerId);
      }
    };

    mobileFireButton.addEventListener("pointerup", endFire);
    mobileFireButton.addEventListener("pointercancel", endFire);
    mobileFireButton.addEventListener("lostpointercapture", () => {
      mobileInput.fire = false;
      setMobileButtonPressed(mobileFireButton, false);
    });
  }

  if (mobileDashButton) {
    mobileDashButton.addEventListener("pointerdown", (event) => {
      stopMobileControlEvent(event);
      ensureAudio();
      if (!isGameplayTouchReady()) return;
      const input = getMovementInput();
      triggerDash(input.horizontal, input.vertical);
      setMobileButtonPressed(mobileDashButton, true);
      window.setTimeout(() => setMobileButtonPressed(mobileDashButton, false), 120);
    });
    mobileDashButton.addEventListener("pointerup", (event) => {
      stopMobileControlEvent(event);
      setMobileButtonPressed(mobileDashButton, false);
    });
    mobileDashButton.addEventListener("pointercancel", (event) => {
      stopMobileControlEvent(event);
      setMobileButtonPressed(mobileDashButton, false);
    });
  }

  if (mobilePulseButton) {
    mobilePulseButton.addEventListener("pointerdown", (event) => {
      stopMobileControlEvent(event);
      ensureAudio();
      if (!isGameplayTouchReady()) return;
      triggerComplementPulse();
      setMobileButtonPressed(mobilePulseButton, true);
      window.setTimeout(() => setMobileButtonPressed(mobilePulseButton, false), 120);
    });
    mobilePulseButton.addEventListener("pointerup", (event) => {
      stopMobileControlEvent(event);
      setMobileButtonPressed(mobilePulseButton, false);
    });
    mobilePulseButton.addEventListener("pointercancel", (event) => {
      stopMobileControlEvent(event);
      setMobileButtonPressed(mobilePulseButton, false);
    });
  }
}

function chooseUpgrade(id) {
  const upgrade = getUpgradeById(id);
  if (!upgrade || !state.awaitingUpgrade) return;
  if (isUpgradeMaxed(upgrade)) return;

  state.upgrades[id] += 1;
  state.stats.upgradesTaken.push(`${upgrade.title} rank ${state.upgrades[id]}`);
  state.awaitingUpgrade = false;
  upgradeOverlay.hidden = true;
  playUpgradeSfx();
  startNextLevel();
}

function syncPauseUi() {
  const showGameplayUi =
    state.running && !state.ended && !state.awaitingUpgrade && !state.levelComplete;
  hudEl.hidden = !showGameplayUi;
  missionPanelEl.hidden = !showGameplayUi;
  levelMeterEl.hidden = !showGameplayUi;
  levelBannerEl.hidden = !showGameplayUi;
  if (mobileControlsEl) {
    mobileControlsEl.hidden = !showGameplayUi;
  }
  pauseOverlay.hidden = !state.paused;
  pauseButton.hidden =
    !state.running || state.ended || state.awaitingUpgrade || state.levelComplete;
  pauseButton.classList.toggle("is-active", state.paused);
  pauseButton.setAttribute("aria-pressed", String(state.paused));
  pauseButton.setAttribute("aria-label", state.paused ? "Resume" : "Pause");
  pauseButtonText.textContent = state.paused ? "Resume" : "Pause";

  if (!showGameplayUi) {
    mobileInput.fire = false;
    resetMobileJoystick();
    setMobileButtonPressed(mobileFireButton, false);
    setMobileButtonPressed(mobileDashButton, false);
    setMobileButtonPressed(mobilePulseButton, false);
  }
}

function setPaused(paused) {
  if (!state.running || state.ended || state.awaitingUpgrade || state.levelComplete) return;

  state.paused = paused;
  if (paused) {
    pointer.down = false;
    keys.clear();
    resetHeldActionInputs();
  } else {
    setRestartConfirmOpen(false);
  }
  state.lastTime = performance.now();
  syncPauseUi();

  if (paused) {
    playPauseOpenSfx();
    resumeButton.focus();
  } else if (state.running && !state.ended) {
    playPauseResumeSfx();
    pauseButton.focus();
  }
}

function togglePaused() {
  setPaused(!state.paused);
}

function setRestartConfirmOpen(open) {
  restartConfirm.hidden = !open;
  restartButton.setAttribute("aria-expanded", String(open));
  if (open) {
    cancelRestartButton.focus();
  }
}

function requestRestartRun() {
  setRestartConfirmOpen(true);
  playRestartConfirmSfx();
}

function cancelRestartRun() {
  setRestartConfirmOpen(false);
  playUiSelectSfx();
}

function confirmRestartRun() {
  playUiSelectSfx();
  setRestartConfirmOpen(false);
  resetGame();
}

function formatRunTime(seconds) {
  const wholeSeconds = Math.max(0, Math.floor(seconds));
  const minutes = Math.floor(wholeSeconds / 60);
  const remainingSeconds = wholeSeconds % 60;
  return `${minutes}:${String(remainingSeconds).padStart(2, "0")}`;
}

function isGameOverInputLocked() {
  return state.ended && performance.now() < state.gameOverInputLockUntil;
}

function blockOverlayKeyboard(event) {
  event.preventDefault();
  event.stopPropagation();
}

function armOnScreenButton(event) {
  event.currentTarget.dataset.pointerArmedAt = String(performance.now());
}

function isOnScreenButtonActivation(event) {
  const button = event?.currentTarget;
  if (!(button instanceof HTMLButtonElement)) return false;

  const armedAt = Number(button.dataset.pointerArmedAt || 0);
  button.dataset.pointerArmedAt = "";

  const hasFreshPointerDown = armedAt > 0 && performance.now() - armedAt < 1200;
  if (hasFreshPointerDown) return true;

  event.preventDefault();
  event.stopPropagation();
  return false;
}

function setGameOverRestartReady(ready) {
  gameOverRestartButton.disabled = !ready;
  gameOverRestartButton.setAttribute("aria-disabled", String(!ready));
}

function renderGameOverSummary() {
  const mission = state.currentMission || getMission(state.level);
  gameOverSubtitleEl.textContent = `Run ended during ${mission.name}: ${mission.term}.`;
  gameOverScoreEl.textContent = state.score.toLocaleString("en-US");
  gameOverLevelEl.textContent = String(state.level);
  gameOverSectionsEl.textContent = String(state.stats.sectionsCleared);
  gameOverVirionsEl.textContent = state.stats.virionsNeutralized.toLocaleString("en-US");
  gameOverTimeEl.textContent = formatRunTime(state.time);
  gameOverBossesEl.textContent = String(state.stats.bossesNeutralized);

  gameOverAdaptationsEl.replaceChildren();
  const upgrades =
    state.stats.upgradesTaken.length > 0
      ? state.stats.upgradesTaken.slice(-5)
      : ["No adaptations selected"];
  for (const upgrade of upgrades) {
    const item = document.createElement("li");
    item.textContent = upgrade;
    gameOverAdaptationsEl.append(item);
  }
}

function resetGame() {
  state.running = true;
  state.ended = false;
  state.paused = false;
  state.awaitingUpgrade = false;
  state.levelComplete = false;
  state.score = 0;
  state.level = 1;
  state.levelStartScroll = 0;
  state.levelKills = 0;
  state.currentMission = getMission(1);
  state.levelTransitionTimer = 0;
  state.levelClearMusicDelay = 0;
  state.bossMusicDelay = 0;
  state.bossWarningActive = false;
  state.bossWarningTimer = 0;
  state.bossWarningCleared = false;
  state.pendingBossType = null;
  state.runStartMusicDelay = 0;
  state.ambienceIntroDelay = 0;
  state.influenzaNoticeTimer = 0;
  state.bossSpawned = false;
  state.bossDefeated = false;
  state.bossTriggerProgress = 0.85;
  state.gameOverInputLockUntil = 0;
  state.time = 0;
  state.scroll = 0;
  state.nextVirus = 1.25;
  state.nextRedCell = 0.1;
  state.nextPlatelet = 3.2;
  state.lastTime = performance.now();
  state.player = {
    x: Math.max(120, state.width * 0.24),
    y: state.height * 0.5,
    vx: 0,
    vy: 0,
    radius: 24,
    health: 100,
    cooldown: 0,
    hurtTimer: 0,
    invulnerable: 1.35,
    blink: 0,
    aimAngle: 0,
    spriteFrame: 0,
    horizontalPose: 0,
    horizontalSoundInput: 0,
  };
  clearShots();
  state.viruses.length = 0;
  state.redCells.length = 0;
  state.platelets.length = 0;
  clearParticles();
  state.lockTarget = null;
  state.upgrades = {
    rapid: 0,
    pulse: 0,
    dash: 0,
  };
  state.stats = {
    virionsNeutralized: 0,
    sectionsCleared: 0,
    bossesNeutralized: 0,
    damageTaken: 0,
    upgradesTaken: [],
  };
  state.dashCooldown = 0;
  state.dashTimer = 0;
  state.pulseCooldown = 0;
  state.pulseTimer = 0;
  state.dashInputHeld = false;
  state.pulseInputHeld = false;
  state.shake = 0;
  overlay.querySelector("h1").textContent = "Bloodstream Defender";
  runSummaryEl.hidden = true;
  runSummaryEl.textContent = "";
  startButton.textContent = "Start Run";
  setRestartConfirmOpen(false);
  configureLevel(1);
  state.runStartMusicDelay = 0.75;
  state.ambienceIntroDelay = 2.25;
  overlay.hidden = true;
  gameOverOverlay.hidden = true;
  setGameOverRestartReady(true);
  levelCompleteOverlay.hidden = true;
  upgradeOverlay.hidden = true;
  syncPauseUi();
  updateHud();
}

function updateHud() {
  scoreEl.textContent = String(state.score);
  levelEl.textContent = String(state.level);
  const health = state.player ? state.player.health : 100;
  const mission = state.currentMission || getMission(state.level);
  const virusesLeft = Math.max(0, state.levelGoal - state.levelKills);
  const boss = isBossMission(mission) ? getActiveBoss() : null;
  healthBar.style.transform = `scaleX(${clamp(health / 100, 0, 1)})`;
  levelProgressEl.style.transform = `scaleX(${getLevelProgress().combined})`;
  missionNameEl.textContent = mission.name;
  objectiveTextEl.textContent = mission.objective;
  if (state.bossWarningActive) {
    virusesLeftEl.textContent = "Pathogen signal rising";
  } else if (boss) {
    virusesLeftEl.textContent = `${Math.ceil(boss.hp)} integrity left`;
  } else if (isBossMission(mission) && !state.bossDefeated) {
    virusesLeftEl.textContent = `${virusesLeft} ${mission.target} left`;
  } else {
    virusesLeftEl.textContent = `${virusesLeft} ${mission.target} left`;
  }

  const dashUnlocked = state.upgrades.dash > 0;
  const pulseUnlocked = state.upgrades.pulse > 0;
  const dashStatus = dashUnlocked
    ? state.dashCooldown <= 0
      ? "Ready"
      : `${Math.ceil(state.dashCooldown)}s`
    : "Locked";
  const pulseStatus = pulseUnlocked
    ? state.pulseCooldown <= 0
      ? "Ready"
      : `${Math.ceil(state.pulseCooldown)}s`
    : "Locked";
  abilityDashEl.textContent = dashStatus;
  abilityPulseEl.textContent = pulseStatus;
  abilityDashEl.setAttribute("aria-label", `Dash ${dashStatus}`);
  abilityPulseEl.setAttribute("aria-label", `Pulse ${pulseStatus}`);
  abilityDashEl.classList.toggle("is-ready", dashUnlocked && state.dashCooldown <= 0);
  abilityPulseEl.classList.toggle("is-ready", pulseUnlocked && state.pulseCooldown <= 0);
  abilityDashEl.classList.toggle("is-locked", !dashUnlocked);
  abilityPulseEl.classList.toggle("is-locked", !pulseUnlocked);

  const gameplayReady = state.running && !state.paused && !state.ended && !state.awaitingUpgrade && !state.levelComplete;
  if (mobileFireButton) {
    mobileFireButton.disabled = !gameplayReady;
  }
  if (mobileDashButton && mobileDashHint) {
    const dashReady = dashUnlocked && state.dashCooldown <= 0 && gameplayReady;
    mobileDashButton.disabled = !dashReady;
    mobileDashButton.classList.toggle("is-ready", dashReady);
    mobileDashButton.classList.toggle("is-locked", !dashUnlocked);
    mobileDashHint.textContent = dashUnlocked ? dashStatus : "Locked";
  }
  if (mobilePulseButton && mobilePulseHint) {
    const pulseReady = pulseUnlocked && state.pulseCooldown <= 0 && gameplayReady;
    mobilePulseButton.disabled = !pulseReady;
    mobilePulseButton.classList.toggle("is-ready", pulseReady);
    mobilePulseButton.classList.toggle("is-locked", !pulseUnlocked);
    mobilePulseHint.textContent = pulseUnlocked ? pulseStatus : "Locked";
  }
}

function spawnRedCell(depth = rand(0.42, 1.12), x = state.width + rand(20, 180)) {
  const radius = rand(24, 46) * depth;
  state.redCells.push({
    x,
    y: rand(topWallAt(x) + radius + 20, bottomWallAt(x) - radius - 20),
    radius,
    depth,
    speed: rand(46, 116) * depth,
    drift: rand(-14, 14),
    rotation: rand(0, TAU),
    spin: rand(-0.9, 0.9),
    wobble: rand(0, TAU),
    frameIndex: randomFrameIndex("redCell"),
  });
}

function spawnVirus(typeOverride = null, options = {}) {
  const difficulty = getLevelDifficultyMultiplier();
  const levelBoost = Math.min(12, state.level - 1) * (1 + Math.max(0, difficulty - 1) * 0.45);
  const roll = Math.random();
  const mission = state.currentMission || getMission(state.level);
  const isInfluenzaBloom = state.level >= 4 && mission.name === "Influenza Bloom";
  let type = typeOverride || "basic";
  if (!typeOverride) {
    if (state.level >= 4 && (isInfluenzaBloom ? roll > 0.28 : roll > 0.84)) {
      type = "influenza";
    } else if (roll > 0.88 && state.level > 3) {
      type = "budding";
    } else if (roll > 0.76 && state.level > 2) {
      type = "tank";
    } else if (roll > 0.52) {
      type = "fast";
    }
  }
  if (
    type === "influenza" &&
    !typeOverride &&
    countLiveInfluenzaViruses() >= getInfluenzaCap()
  ) {
    type = state.level > 2 && roll > 0.62 ? "tank" : "fast";
  }

  const statsByType = {
    basic: {
      radius: rand(18, 25),
      hp: 2,
      speed: rand(82, 118) + levelBoost * 8,
      color: "#7ced6f",
      core: "#357c37",
      score: 20,
      spikes: 10,
    },
    fast: {
      radius: rand(14, 19),
      hp: 1,
      speed: rand(135, 178) + levelBoost * 10,
      color: "#ff6d9d",
      core: "#8d2145",
      score: 30,
      spikes: 8,
    },
    tank: {
      radius: rand(28, 36),
      hp: 4,
      speed: rand(54, 82) + levelBoost * 5,
      color: "#9b85ff",
      core: "#45317c",
      score: 70,
      spikes: 13,
    },
    budding: {
      radius: rand(22, 29),
      hp: 3,
      speed: rand(74, 104) + levelBoost * 7,
      color: "#ffd15d",
      core: "#8d501f",
      score: 55,
      spikes: 11,
    },
    influenza: {
      radius: rand(23, 31),
      hp: 3,
      speed: rand(68, 96) + levelBoost * 6,
      color: "#ff8b2a",
      core: "#a944d4",
      score: 85,
      spikes: 14,
    },
  };
  const stats = { ...statsByType[type] };
  if (difficulty > 1) {
    const hpBonusScale =
      type === "fast" ? 1.2 : type === "tank" ? 2.8 : type === "influenza" ? 2.2 : 1.9;
    const hpBonus = Math.floor(Math.max(0, difficulty - 1) * hpBonusScale);
    stats.hp += hpBonus;
    stats.speed *= 1 + Math.max(0, difficulty - 1) * 0.22;
    stats.score += hpBonus * 12;
  }

  const x = options.x ?? state.width + stats.radius + rand(15, 110);
  const spriteGroup =
    type === "influenza"
      ? "influenzaVirus"
      : type === "basic" || type === "budding"
        ? "greenVirus"
        : "purpleVirus";
  const virus = {
    ...stats,
    type,
    spriteGroup,
    frameIndex: randomFrameIndex(spriteGroup),
    x,
    y:
      options.y ??
      rand(topWallAt(x) + stats.radius + 22, bottomWallAt(x) - stats.radius - 22),
    speed: options.speed ?? stats.speed,
    wobble: rand(0, TAU),
    wobbleSpeed: type === "influenza" ? rand(1.0, 1.9) : rand(1.4, 2.5),
    replicateCooldown:
      type === "influenza" ? options.replicateCooldown ?? rand(0.25, 0.65) : 0,
    spreadVx: options.spreadVx ?? 0,
    spreadVy: options.spreadVy ?? 0,
    spreadTimer: options.spreadTimer ?? 0,
    hit: 0,
    angle: rand(0, TAU),
    spin: rand(-1.4, 1.4),
  };
  state.viruses.push(virus);
  return virus;
}

function spawnVirusFragment(parent, direction) {
  const levelBoost = Math.min(8, state.level - 1);
  const radius = rand(10, 14);
  const y = clampToVessel(parent.x, parent.y + direction * rand(24, 46), radius);
  state.viruses.push({
    type: "fragment",
    spriteGroup: "purpleVirus",
    frameIndex: randomFrameIndex("purpleVirus"),
    x: parent.x + rand(10, 22),
    y,
    radius,
    hp: 1,
    speed: rand(150, 205) + levelBoost * 8,
    color: "#ff9b45",
    core: "#7d301d",
    score: 15,
    spikes: 6,
    wobble: rand(0, TAU),
    wobbleSpeed: rand(2.2, 3.3),
    hit: 0,
    angle: rand(0, TAU),
    spin: rand(-2.4, 2.4),
  });
}

function spawnPlatelet() {
  const radius = rand(20, 34);
  const x = state.width + radius + rand(60, 210);
  state.platelets.push({
    x,
    y: rand(topWallAt(x) + radius + 34, bottomWallAt(x) - radius - 34),
    radius,
    speed: rand(72, 98),
    angle: rand(0, TAU),
    spin: rand(-0.55, 0.55),
    frameIndex: randomFrameIndex("platelet"),
    bubbles: Array.from({ length: 13 }, () => ({
      angle: rand(0, TAU),
      distance: rand(0, radius * 0.66),
      radius: rand(radius * 0.22, radius * 0.4),
      alpha: rand(0.72, 0.96),
    })),
    points: Array.from({ length: 9 }, (_, i) => ({
      angle: (i / 9) * TAU,
      radius: rand(0.72, 1.14),
    })),
  });
}

function spawnBoss(type) {
  const profile = bossProfiles[type];
  if (!profile) return null;

  const difficulty = getLevelDifficultyMultiplier();
  const radius = profile.radius;
  const x = state.width + radius + 150;
  const y = clampToVessel(x, state.height * 0.5, radius);
  const bossHp = Math.ceil(profile.hp * (1 + Math.max(0, difficulty - 1) * 0.9));
  const boss = {
    type,
    isBoss: true,
    displayName: profile.displayName,
    spriteGroup: profile.spriteGroup,
    frameIndex: 0,
    x,
    y,
    baseY: y,
    targetXRatio: profile.targetXRatio,
    radius,
    hp: bossHp,
    maxHp: bossHp,
    speed: 0,
    color: profile.color,
    core: profile.core,
    score: Math.round(profile.score * difficulty),
    damage: profile.damage,
    spikes: 0,
    wobble: rand(0, TAU),
    wobbleSpeed: rand(0.75, 1.25),
    hit: 0,
    angle: 0,
    spin: type === "adenovirusMini" ? rand(-0.42, 0.42) : 0,
    attackTimer: (profile.attackInterval * 0.75) / Math.sqrt(difficulty),
    phase: 0,
    shieldCycle: rand(0, 1.2),
    shieldOpen: false,
  };
  state.viruses.push(boss);
  showLevelBanner(`${profile.displayName}: ${state.currentMission?.term || "Boss"}`, 2.25);
  return boss;
}

function spawnBossAdd(boss, type, angle, speed = rand(90, 130)) {
  const difficulty = getLevelDifficultyMultiplier();
  const x = boss.x - boss.radius * 0.55;
  const y = clampToVessel(x, boss.y + Math.sin(angle) * boss.radius * 0.95, 24);
  const add = spawnVirus(type, {
    x,
    y,
    speed: speed * (1 + Math.max(0, difficulty - 1) * 0.16),
    replicateCooldown: rand(0.8, 1.25),
    spreadVx: Math.cos(angle) * rand(24, 48),
    spreadVy: Math.sin(angle) * rand(34, 58),
    spreadTimer: rand(0.45, 0.75),
  });
  add.bossAdd = true;
  return add;
}

function clearBossApproachHazards() {
  compactArray(state.viruses, (virus) => isBossVirus(virus));
  state.platelets.length = 0;
  clearShots();
  state.lockTarget = null;
}

function updatePoxBoss(boss, dt) {
  const healthRatio = clamp(boss.hp / boss.maxHp, 0, 1);
  const nextPhase = healthRatio > 0.72 ? 0 : healthRatio > 0.48 ? 1 : healthRatio > 0.22 ? 2 : 3;
  if (nextPhase > boss.phase) {
    boss.phase = nextPhase;
    state.shake = Math.max(state.shake, 0.2 + nextPhase * 0.04);
    playBossPhaseChangeSfx();
    addParticleBurst(boss.x, boss.y, boss.color, 18 + nextPhase * 4, 150);
    spawnVirusFragment(boss, -1);
    spawnVirusFragment(boss, 1);
    showLevelBanner(nextPhase === 3 ? "Pox core exposed" : "Pox armor plates broke loose", 1.35);
  }
  boss.frameIndex = boss.phase;

  boss.attackTimer -= dt;
  if (boss.attackTimer <= 0) {
    const difficulty = getLevelDifficultyMultiplier();
    boss.attackTimer = (bossProfiles.poxBoss.attackInterval + rand(-0.25, 0.45)) / Math.sqrt(difficulty);
    spawnBossAdd(boss, "budding", -0.8, rand(84, 112));
    spawnBossAdd(boss, "budding", 0.8, rand(84, 112));
    addParticleBurst(boss.x - boss.radius * 0.55, boss.y, "#ff7cca", 12, 110);
  }
}

function updateAdenovirusMiniBoss(boss, dt) {
  boss.shieldCycle = (boss.shieldCycle + dt) % 3.4;
  boss.shieldOpen = boss.shieldCycle > 2.12 && boss.shieldCycle < 3.02;
  boss.frameIndex = boss.shieldOpen ? 2 : boss.shieldCycle > 1.2 ? 1 : 0;

  boss.attackTimer -= dt;
  if (boss.attackTimer <= 0) {
    const difficulty = getLevelDifficultyMultiplier();
    boss.attackTimer =
      (bossProfiles.adenovirusMini.attackInterval + rand(-0.2, 0.32)) / Math.sqrt(difficulty);
    boss.frameIndex = 3;
    for (let i = 0; i < 3; i += 1) {
      spawnBossAdd(boss, "fast", rand(-1.0, 1.0), rand(125, 168));
    }
    addParticleBurst(boss.x, boss.y, "#c86cff", 10, 125);
  }
}

function updateFilovirusBoss(boss, dt) {
  boss.frameIndex = Math.floor(state.time * 1.35) % spriteFrames.filovirusBoss.length;
  boss.attackTimer -= dt;
  if (boss.attackTimer <= 0) {
    const difficulty = getLevelDifficultyMultiplier();
    boss.attackTimer =
      (bossProfiles.filovirusBoss.attackInterval + rand(-0.25, 0.55)) / Math.sqrt(difficulty);
    const lane = Math.sin(state.time * 1.7) > 0 ? 1 : -1;
    spawnBossAdd(boss, "fast", lane * 0.7, rand(138, 178));
    spawnBossAdd(boss, "tank", -lane * 0.55, rand(70, 92));
    addParticleBurst(boss.x - boss.radius, boss.y, "#5ffff0", 14, 135);
  }
}

function updateBossVirus(boss, dt) {
  const profile = bossProfiles[boss.type];
  if (!profile) return;

  const targetX = state.width * profile.targetXRatio;
  const centerY = state.height * 0.5;
  const driftY =
    boss.type === "poxBoss"
      ? Math.sin(state.time * 0.85 + boss.wobble) * 78
      : boss.type === "filovirusBoss"
        ? Math.sin(state.time * 1.15 + boss.wobble) * 112
        : Math.sin(state.time * 1.05 + boss.wobble) * 92;

  boss.x = lerp(boss.x, targetX, clamp(dt * 1.25, 0, 0.08));
  boss.y = clampToVessel(boss.x, centerY + driftY, boss.radius);
  boss.angle += boss.spin * dt;
  boss.hit = Math.max(0, boss.hit - dt);

  if (boss.type === "poxBoss") updatePoxBoss(boss, dt);
  if (boss.type === "adenovirusMini") updateAdenovirusMiniBoss(boss, dt);
  if (boss.type === "filovirusBoss") updateFilovirusBoss(boss, dt);
}

function updateLevelTimers(dt) {
  if (state.levelBannerTimer > 0) {
    state.levelBannerTimer = Math.max(0, state.levelBannerTimer - dt);
    if (state.levelBannerTimer === 0) {
      levelBannerEl.classList.remove("is-visible");
    }
  }

  state.influenzaNoticeTimer = Math.max(0, state.influenzaNoticeTimer - dt);

  if (state.levelTransitionTimer > 0) {
    state.levelTransitionTimer = Math.max(0, state.levelTransitionTimer - dt);
    if (state.levelTransitionTimer === 0) {
      openLevelCompleteScreen();
    }
  }
}

function completeLevel() {
  if (state.levelTransitionTimer > 0) return;

  state.levelTransitionTimer = 1.55;
  state.stats.sectionsCleared += 1;
  state.viruses.length = 0;
  state.platelets.length = 0;
  clearShots();
  state.lockTarget = null;
  showLevelBanner(`${state.currentMission?.name || "Section"} Cleared`, 1.45);

  if (state.player) {
    addParticleBurst(state.player.x, state.player.y, palette.cyan, 26, 190);
  }
}

function startNextLevel() {
  const player = state.player;
  configureLevel(state.level + 1);

  if (player) {
    player.health = Math.min(100, player.health + 18);
    player.invulnerable = 1.2;
    player.x = Math.max(110, state.width * 0.22);
    player.y = clampToVessel(player.x, player.y, player.radius);
    addParticleBurst(player.x, player.y, "#b9ffe5", 18, 130);
  }

  syncPauseUi();
}

function updateLevelCompletion() {
  if (state.levelTransitionTimer > 0) return;
  if (isBossMission()) {
    if (state.bossDefeated) {
      completeLevel();
    }
    return;
  }

  if (getLevelProgress().complete) {
    completeLevel();
  }
}

function isLockableVirus(virus) {
  return (
    virus &&
    !virus.dead &&
    virus.hp > 0 &&
    virus.x > -virus.radius - 24 &&
    virus.x < state.width + virus.radius + 120
  );
}

function chooseLockTarget() {
  const player = state.player;
  if (!player || state.viruses.length === 0) return null;

  const lockRange = Math.min(640, state.width * 0.86);
  const verticalRange = Math.max(150, state.height * 0.34);
  let best = null;
  let bestScore = -Infinity;

  for (const virus of state.viruses) {
    if (!isLockableVirus(virus)) continue;

    const dx = virus.x - player.x;
    const dy = virus.y - player.y;
    const dist = Math.hypot(dx, dy);
    const isNearlyTouching = dist < 170;
    const isInFront = dx > -48;
    const isInLane = Math.abs(dy) < verticalRange;

    if (!isNearlyTouching && (!isInFront || (dist > lockRange && !isInLane))) {
      continue;
    }

    const closeness = 1 - clamp(dist / lockRange, 0, 1);
    const laneMatch = 1 - clamp(Math.abs(dy) / verticalRange, 0, 1);
    const aheadBonus = dx > 0 ? 1 : 0.28;
    const typeBonus =
      isBossVirus(virus)
        ? 1.65
        : virus.type === "influenza"
        ? 1.1
        : virus.type === "fast"
          ? 0.45
          : virus.type === "tank"
            ? 0.25
            : 0;
    const stickiness = state.lockTarget === virus ? 1.8 : 0;
    const behindPenalty = dx < 0 ? Math.abs(dx) * 0.018 : 0;
    const score = closeness * 5 + laneMatch * 3.2 + aheadBonus + typeBonus + stickiness - behindPenalty;

    if (score > bestScore) {
      bestScore = score;
      best = virus;
    }
  }

  return best;
}

function updateLockTarget() {
  state.lockTarget = chooseLockTarget();
}

function getAimPoint() {
  const player = state.player;
  const target = isLockableVirus(state.lockTarget) ? state.lockTarget : chooseLockTarget();

  if (target) {
    state.lockTarget = target;
    return { target, x: target.x, y: target.y };
  }

  if (pointer.down && pointer.active) {
    return { target: null, x: pointer.x, y: pointer.y };
  }

  return { target: null, x: player.x + 320, y: player.y };
}

function getVisualAimPoint() {
  const player = state.player;
  const target = isLockableVirus(state.lockTarget) ? state.lockTarget : null;

  if (target) {
    return { x: target.x, y: target.y };
  }

  if (pointer.down && pointer.active) {
    return { x: pointer.x, y: pointer.y };
  }

  return { x: player.x + 220, y: player.y };
}

function rotateVector(x, y, angle) {
  const cos = Math.cos(angle);
  const sin = Math.sin(angle);
  return {
    x: x * cos - y * sin,
    y: x * sin + y * cos,
  };
}

function addAntibodyShot(player, aim, dx, dy, angleOffset = 0) {
  const rapidRank = state.upgrades.rapid;
  const shotDirection = rotateVector(dx, dy, angleOffset);
  const muzzle = player.radius + 10;
  const shotSpeed = 620 + rapidRank * 42;
  const screenTravelLife = (Math.hypot(state.width, state.height) + 260) / shotSpeed;
  const shot = shotPool.pop() || {};

  shot.x = player.x + shotDirection.x * muzzle;
  shot.y = player.y + shotDirection.y * muzzle;
  shot.vx = shotDirection.x * shotSpeed + player.vx * 0.18;
  shot.vy = shotDirection.y * shotSpeed + player.vy * 0.18;
  shot.speed = Math.hypot(shot.vx, shot.vy);
  shot.radius = 4.2;
  shot.hitRadius = 6.8 + rapidRank * 0.4;
  shot.life = Math.max(2.1, screenTravelLife);
  shot.damage = rapidRank >= 3 ? 3 : 2;
  shot.target = aim.target;
  shot.age = 0;
  shot.renderUx = shot.vx / Math.max(1, shot.speed);
  shot.renderUy = shot.vy / Math.max(1, shot.speed);
  shot.frameIndex = randomFrameIndex("antibody");
  state.shots.push(shot);

  return shotDirection;
}

function fireShot() {
  const player = state.player;
  if (!state.running || !player || player.cooldown > 0) return;

  const aim = getAimPoint();
  const targetX = aim.x;
  const targetY = aim.y;
  let dx = targetX - player.x;
  let dy = targetY - player.y;
  const length = Math.hypot(dx, dy) || 1;
  dx /= length;
  dy /= length;

  const rapidRank = state.upgrades.rapid;
  const spread = rapidRank >= 4 ? [-0.11, 0, 0.11] : rapidRank >= 2 ? [-0.075, 0.075] : [0];
  let mainDirection = { x: dx, y: dy };
  for (const angleOffset of spread) {
    mainDirection = addAntibodyShot(player, aim, dx, dy, angleOffset);
  }
  player.cooldown = Math.max(0.055, 0.13 * Math.pow(0.78, rapidRank));

  playShootSfx();
  addParticleBurst(
    player.x + mainDirection.x * (player.radius + 10),
    player.y + mainDirection.y * (player.radius + 10),
    palette.cyan,
    5 + rapidRank,
    46,
  );
}

function addParticleBurst(x, y, color, count = 12, power = 110) {
  for (let i = 0; i < count; i += 1) {
    const angle = rand(0, TAU);
    const speed = rand(power * 0.25, power);
    const particle = particlePool.pop() || {};
    particle.x = x;
    particle.y = y;
    particle.vx = Math.cos(angle) * speed;
    particle.vy = Math.sin(angle) * speed;
    particle.radius = rand(1.4, 4.2);
    particle.life = rand(0.18, 0.6);
    particle.ttl = 0;
    particle.color = color;
    state.particles.push(particle);
  }
}

function destroyVirus(virus, source = "shot") {
  if (!virus || virus.dead) return;

  virus.dead = true;
  virus.hp = 0;
  state.score += virus.score;
  if (isBossMission()) {
    if (isBossVirus(virus)) {
      state.bossDefeated = true;
      state.stats.bossesNeutralized += 1;
    } else {
      state.levelKills = Math.min(state.levelGoal, state.levelKills + 1);
    }
  } else {
    state.levelKills += 1;
  }
  state.stats.virionsNeutralized += 1;
  state.shake = Math.max(state.shake, isBossVirus(virus) ? 0.46 : source === "pulse" ? 0.34 : 0.18);
  if (isBossVirus(virus)) {
    playBossDefeatedSfx();
  } else if (virus.type === "budding") {
    playBuddingSplitSfx();
  } else {
    playVirusPopSfx();
  }
  addParticleBurst(virus.x, virus.y, virus.color, isBossVirus(virus) ? 44 : virus.type === "tank" ? 26 : 18, isBossVirus(virus) ? 220 : 145);

  if (virus.type === "budding") {
    spawnVirusFragment(virus, -1);
    spawnVirusFragment(virus, 1);
    showLevelBanner("Budding virion split into fragments", 1.25);
  } else if (isBossVirus(virus)) {
    showLevelBanner(`${virus.displayName || "Boss"} neutralized`, 1.45);
  }
}

function updateAbilities(dt) {
  state.dashCooldown = Math.max(0, state.dashCooldown - dt);
  state.dashTimer = Math.max(0, state.dashTimer - dt);
  state.pulseCooldown = Math.max(0, state.pulseCooldown - dt);
  state.pulseTimer = Math.max(0, state.pulseTimer - dt);
  state.shake = Math.max(0, state.shake - dt * 2.8);
}

function triggerDash(horizontalInput, verticalInput) {
  if (state.upgrades.dash <= 0 || state.dashCooldown > 0) return false;

  const player = state.player;
  let dx = horizontalInput;
  let dy = verticalInput;
  if (!dx && !dy) dx = 1;
  const length = Math.hypot(dx, dy) || 1;
  dx /= length;
  dy /= length;

  const dashRank = state.upgrades.dash;
  const impulse = 430 + dashRank * 58;
  player.vx += dx * impulse;
  player.vy += dy * impulse;
  player.invulnerable = Math.max(player.invulnerable, 0.34 + dashRank * 0.05);
  state.dashTimer = 0.22;
  state.dashCooldown = Math.max(1.4, 3.2 - dashRank * 0.42);
  state.shake = Math.max(state.shake, 0.18);
  playChemotaxisDashSfx(dx >= 0 ? 1 : -1);
  addParticleBurst(player.x - dx * player.radius, player.y - dy * player.radius, palette.cyan, 12, 155);
  return true;
}

function triggerComplementPulse() {
  if (state.upgrades.pulse <= 0 || state.pulseCooldown > 0) return false;

  const player = state.player;
  const pulseRank = state.upgrades.pulse;
  const radius = 150 + pulseRank * 32;
  const damage = 1 + pulseRank;
  state.pulseTimer = 0.38;
  state.pulseCooldown = Math.max(3.2, 7.2 - pulseRank * 0.9);
  state.shake = Math.max(state.shake, 0.28);
  player.invulnerable = Math.max(player.invulnerable, 0.72);
  playPulseSfx();
  addParticleBurst(player.x, player.y, "#d9ffff", 30, 210);

  const virusCount = state.viruses.length;
  for (let i = 0; i < virusCount; i += 1) {
    const virus = state.viruses[i];
    if (virus.dead) continue;
    const maxDistance = radius + virus.radius;
    const distSq = distanceSquared(player, virus);
    if (distSq > maxDistance * maxDistance) continue;
    const dist = Math.sqrt(distSq);
    virus.hp -= damage * getVirusDamageScale(virus);
    virus.hit = 0.2;
    if (virus.hp <= 0) destroyVirus(virus, "pulse");
    else {
      const push = (1 - clamp(dist / radius, 0, 1)) * 95;
      const dx = (virus.x - player.x) / Math.max(1, dist);
      const dy = (virus.y - player.y) / Math.max(1, dist);
      virus.x += dx * push;
      virus.y += dy * push;
    }
  }

  for (const platelet of state.platelets) {
    if (isWithinDistance(player, platelet, radius + platelet.radius)) {
      const burstX = platelet.x;
      const burstY = platelet.y;
      platelet.x = -999;
      addParticleBurst(burstX, burstY, palette.platelet, 8, 80);
    }
  }

  return true;
}

function update(dt) {
  if (!state.running) return;

  state.time += dt;
  updateAbilities(dt);
  updateLevelTimers(dt);
  if (state.awaitingUpgrade) {
    updateHud();
    return;
  }
  const difficulty = getLevelDifficultyMultiplier();
  const worldSpeed =
    (92 + state.level * 8 + (state.levelTransitionTimer > 0 ? 42 : 0)) *
    (1 + Math.max(0, difficulty - 1) * 0.16);
  state.scroll += worldSpeed * dt;

  updateSpawns(dt);
  updateViruses(dt, worldSpeed);
  updateRedCells(dt, worldSpeed);
  updatePlatelets(dt, worldSpeed);
  updateLockTarget();
  updatePlayer(dt);
  updateShots(dt);
  updateParticles(dt);
  checkCollisions();
  updateLevelCompletion();
  updateLockTarget();
  updateHud();
}

function updatePlayer(dt) {
  const player = state.player;
  const accel = 960;
  const swimKick = 44;
  let ax = 0;
  let ay = 0;
  const { horizontal: horizontalInput, vertical: verticalInput } = getMovementInput();

  if (horizontalInput < 0) ax -= accel;
  if (horizontalInput > 0) ax += accel;
  if (verticalInput < 0) ay -= accel;
  if (verticalInput > 0) ay += accel;

  const dashPressed = keys.has("ShiftLeft") || keys.has("ShiftRight");
  if (dashPressed && !state.dashInputHeld) {
    triggerDash(horizontalInput, verticalInput);
  }
  state.dashInputHeld = dashPressed;

  const pulsePressed =
    keys.has("KeyE") || keys.has("KeyQ") || keys.has("Enter") || keys.has("NumpadEnter");
  if (pulsePressed && !state.pulseInputHeld) {
    triggerComplementPulse();
  }
  state.pulseInputHeld = pulsePressed;

  const maxSpeed = 350 + state.upgrades.dash * 18 + (state.dashTimer > 0 ? 320 : 0);

  if (ax || ay) {
    const length = Math.hypot(ax, ay);
    ax = (ax / length) * accel;
    ay = (ay / length) * accel;
  } else {
    ay += Math.sin(state.time * 3.4) * swimKick;
  }

  player.vx += ax * dt;
  player.vy += ay * dt;
  player.vx *= Math.pow(0.036, dt);
  player.vy *= Math.pow(0.036, dt);
  const speed = Math.hypot(player.vx, player.vy);
  if (speed > maxSpeed) {
    player.vx = (player.vx / speed) * maxSpeed;
    player.vy = (player.vy / speed) * maxSpeed;
  }
  player.x += player.vx * dt;
  player.y += player.vy * dt;

  const left = 58;
  const right = Math.max(left + 120, state.width * 0.72);
  player.x = clamp(player.x, left, right);
  player.y = clampToVessel(player.x, player.y, player.radius);

  player.cooldown = Math.max(0, player.cooldown - dt);
  player.hurtTimer = Math.max(0, player.hurtTimer - dt);
  player.invulnerable = Math.max(0, player.invulnerable - dt);
  player.blink += dt;
  player.horizontalPose = lerp(player.horizontalPose ?? 0, horizontalInput, clamp(dt * 8.5, 0, 1));

  const horizontalSoundInput = Math.abs(horizontalInput) > 0.35 ? Math.sign(horizontalInput) : 0;
  if (horizontalSoundInput !== 0 && (player.horizontalSoundInput ?? 0) !== horizontalSoundInput) {
    playSwimSurgeSfx(horizontalSoundInput);
  }
  player.horizontalSoundInput = horizontalSoundInput;

  const visualAim = getVisualAimPoint();
  const desiredAimAngle = Math.atan2(visualAim.y - player.y, visualAim.x - player.x);
  player.aimAngle = lerpAngle(player.aimAngle, desiredAimAngle, clamp(dt * 5.8, 0, 0.16));

  if (keys.has("Space") || pointer.down || mobileInput.fire) fireShot();
}

function updateSpawns(dt) {
  if (state.levelTransitionTimer > 0) return;

  state.nextVirus -= dt;
  state.nextRedCell -= dt;
  state.nextPlatelet -= dt;
  const levelConfig = getLevelConfig(state.level);
  const mission = state.currentMission || levelConfig.mission;
  const encounterActive = isBossMission(mission);
  const bossTriggerReached =
    encounterActive && getDistanceProgress() >= (state.bossTriggerProgress || 0.86);
  let bossApproachClearActive = false;

  if (state.bossWarningActive) {
    state.bossWarningTimer = Math.max(0, state.bossWarningTimer - dt);
    bossApproachClearActive = state.bossWarningTimer <= BOSS_PRE_SPAWN_CLEAR_DURATION;
    if (bossApproachClearActive && !state.bossWarningCleared) {
      clearBossApproachHazards();
      state.bossWarningCleared = true;
      state.nextVirus = 1.4;
      state.nextPlatelet = 4.8;
      showLevelBanner("Clear vessel lane", 1.65);
    }

    if (state.bossWarningTimer === 0 && !state.bossSpawned) {
      spawnBoss(state.pendingBossType || mission.bossType);
      state.bossSpawned = true;
      state.bossWarningActive = false;
      state.bossWarningCleared = false;
      state.pendingBossType = null;
      state.bossMusicDelay = 0;
      state.nextVirus = 1.6;
      state.nextPlatelet = 5.8;
    }
  } else if (bossTriggerReached && !state.bossSpawned) {
    state.bossWarningActive = true;
    state.bossWarningTimer = BOSS_WARNING_DURATION;
    state.bossWarningCleared = false;
    state.pendingBossType = mission.bossType;
    state.bossMusicDelay = BOSS_WARNING_DURATION;
    state.nextVirus = Math.min(state.nextVirus, 0.45);
    state.nextPlatelet = Math.min(state.nextPlatelet, 1.8);
    showLevelBanner("Pathogen signal building", 2.35);
    playBossWarningSfx();
  }

  const encounterCanSpawn =
    !encounterActive || (!state.bossSpawned && (!state.bossWarningActive || !bossApproachClearActive));
  if (encounterCanSpawn && state.nextVirus <= 0) {
    spawnVirus();
    state.nextVirus = rand(0.78, 1.35) * levelConfig.spawnScale;
  }

  if (state.nextRedCell <= 0) {
    spawnRedCell();
    state.nextRedCell = rand(0.45, 0.9);
  }

  if ((!state.bossWarningActive || !bossApproachClearActive) && state.nextPlatelet <= 0) {
    spawnPlatelet();
    state.nextPlatelet = rand(4.4, 7.2) * Math.max(0.72, levelConfig.spawnScale);
  }
}

function updateShots(dt) {
  for (const shot of state.shots) {
    if (isLockableVirus(shot.target)) {
      const dx = shot.target.x - shot.x;
      const dy = shot.target.y - shot.y;
      const length = Math.sqrt(dx * dx + dy * dy) || 1;
      shot.speed = Math.min(760, Math.max(620, (shot.speed ?? 620) + 22));
      const turn = clamp(dt * 9.5, 0, 0.2);
      shot.vx = lerp(shot.vx, (dx / length) * shot.speed, turn);
      shot.vy = lerp(shot.vy, (dy / length) * shot.speed, turn);
    }

    shot.x += shot.vx * dt;
    shot.y += shot.vy * dt;
    shot.life -= dt;
    shot.age += dt;
    const speedSq = shot.vx * shot.vx + shot.vy * shot.vy;
    if (speedSq > 0.0001) {
      const invSpeed = 1 / Math.sqrt(speedSq);
      shot.renderUx = shot.vx * invSpeed;
      shot.renderUy = shot.vy * invSpeed;
    }
  }
  compactArray(
    state.shots,
    (shot) =>
      shot.life > 0 &&
      shot.x < state.width + 100 &&
      shot.x > -100 &&
      shot.y > -100 &&
      shot.y < state.height + 100,
    recycleShot,
  );
}

function getInfluenzaCap() {
  if (state.level < 4) return 0;
  return Math.min(30, 12 + Math.max(0, state.level - 4) * 3);
}

function isLiveInfluenzaVirus(virus) {
  return virus.type === "influenza" && !virus.dead && virus.hp > 0;
}

function countLiveInfluenzaViruses() {
  let count = 0;
  for (const virus of state.viruses) {
    if (isLiveInfluenzaVirus(virus)) count += 1;
  }
  return count;
}

function nudgeInfluenzaTowardNearest(virus, dt) {
  let nearest = null;
  let nearestDistSq = Infinity;
  const maxDist = 290;
  const maxDistSq = maxDist * maxDist;

  for (const other of state.viruses) {
    if (other === virus || !isLiveInfluenzaVirus(other)) continue;
    const distSq = distanceSquared(virus, other);
    if (distSq < nearestDistSq && distSq < maxDistSq) {
      nearest = other;
      nearestDistSq = distSq;
    }
  }

  const nearestDist = Math.sqrt(nearestDistSq);
  if (!nearest || nearestDist <= 1) return;

  const spreadResistance = virus.spreadTimer > 0 ? 0.35 : 1;
  const pull = 28 * spreadResistance * dt * (1 - clamp(nearestDist / maxDist, 0, 1));
  virus.x += ((nearest.x - virus.x) / nearestDist) * pull;
  virus.y += ((nearest.y - virus.y) / nearestDist) * pull;
}

function addInfluenzaSpread(virus, angle, speed, duration) {
  virus.spreadVx = clamp((virus.spreadVx ?? 0) + Math.cos(angle) * speed, -170, 170);
  virus.spreadVy = clamp((virus.spreadVy ?? 0) + Math.sin(angle) * speed, -150, 150);
  virus.spreadTimer = Math.max(virus.spreadTimer ?? 0, duration);
}

function updateInfluenzaSpread(virus, dt) {
  if ((virus.spreadTimer ?? 0) <= 0) return;

  const fade = clamp(virus.spreadTimer / 1.25, 0, 1);
  virus.x += (virus.spreadVx ?? 0) * fade * dt;
  virus.y += (virus.spreadVy ?? 0) * fade * dt;
  virus.spreadTimer = Math.max(0, virus.spreadTimer - dt);

  const damping = Math.pow(0.3, dt);
  virus.spreadVx *= damping;
  virus.spreadVy *= damping;
  if (virus.spreadTimer === 0) {
    virus.spreadVx = 0;
    virus.spreadVy = 0;
  }
}

function spawnInfluenzaCopy(parent, partner, angleOffset) {
  const midX = (parent.x + partner.x) * 0.5;
  const midY = (parent.y + partner.y) * 0.5;
  const angle = Math.atan2(partner.y - parent.y, partner.x - parent.x) + angleOffset;
  const radius = 27;
  const x = clamp(midX + Math.cos(angle) * 54, 74, state.width + 110);
  const y = clampToVessel(x, midY + Math.sin(angle) * 54, radius);
  const spreadSpeed = rand(86, 124);
  return spawnVirus("influenza", {
    x,
    y,
    replicateCooldown: rand(0.85, 1.25),
    spreadVx: Math.cos(angle) * spreadSpeed,
    spreadVy: Math.sin(angle) * spreadSpeed,
    spreadTimer: rand(1.05, 1.45),
  });
}

function replicateInfluenzaViruses() {
  const cap = getInfluenzaCap();
  const influenzaCount = countLiveInfluenzaViruses();
  if (influenzaCount < 2 || influenzaCount + 2 > cap) return;

  for (let i = 0; i < state.viruses.length - 1; i += 1) {
    const first = state.viruses[i];
    if (!isLiveInfluenzaVirus(first)) continue;
    if (first.replicateCooldown > 0) continue;

    for (let j = i + 1; j < state.viruses.length; j += 1) {
      const second = state.viruses[j];
      if (!isLiveInfluenzaVirus(second)) continue;
      if (second.replicateCooldown > 0) continue;
      const replicateRadius = (first.radius + second.radius) * 1.42;
      if (!isWithinDistance(first, second, replicateRadius)) continue;

      first.replicateCooldown = rand(1.45, 2.15);
      second.replicateCooldown = rand(1.45, 2.15);
      const pairAngle = Math.atan2(second.y - first.y, second.x - first.x);
      addInfluenzaSpread(first, pairAngle + Math.PI, rand(42, 66), rand(0.8, 1.05));
      addInfluenzaSpread(second, pairAngle, rand(42, 66), rand(0.8, 1.05));
      spawnInfluenzaCopy(first, second, Math.PI * 0.5);
      spawnInfluenzaCopy(first, second, -Math.PI * 0.5);

      const burstX = (first.x + second.x) * 0.5;
      const burstY = (first.y + second.y) * 0.5;
      state.shake = Math.max(state.shake, 0.16);
      playInfluenzaReplicationSfx();
      addParticleBurst(burstX, burstY, "#ff9b2f", 16, 120);

      if (state.influenzaNoticeTimer === 0) {
        showLevelBanner("Influenza virions replicated", 1.35);
        state.influenzaNoticeTimer = 3.8;
      }

      return;
    }
  }
}

function separateInfluenzaViruses(dt) {
  for (let i = 0; i < state.viruses.length - 1; i += 1) {
    const first = state.viruses[i];
    if (!isLiveInfluenzaVirus(first)) continue;
    for (let j = i + 1; j < state.viruses.length; j += 1) {
      const second = state.viruses[j];
      if (!isLiveInfluenzaVirus(second)) continue;
      const minDist = (first.radius + second.radius) * 1.04;
      const distSq = distanceSquared(first, second);
      if (distSq >= minDist * minDist) continue;
      const dist = Math.sqrt(distSq);
      if (dist <= 1 || dist >= minDist) continue;

      const push = (1 - dist / minDist) * 72 * dt;
      const dx = (second.x - first.x) / dist;
      const dy = (second.y - first.y) / dist;
      first.x -= dx * push;
      first.y = clampToVessel(first.x, first.y - dy * push, first.radius);
      second.x += dx * push;
      second.y = clampToVessel(second.x, second.y + dy * push, second.radius);
    }
  }
}

function updateViruses(dt, worldSpeed) {
  for (const virus of state.viruses) {
    if (virus.dead) continue;
    if (isBossVirus(virus)) {
      updateBossVirus(virus, dt);
    } else {
      virus.x -= (virus.speed + worldSpeed * 0.45) * dt;
      virus.y += Math.sin(state.time * virus.wobbleSpeed + virus.wobble) * 26 * dt;
      if (virus.type === "influenza") {
        virus.replicateCooldown = Math.max(0, (virus.replicateCooldown ?? 0) - dt);
        updateInfluenzaSpread(virus, dt);
        nudgeInfluenzaTowardNearest(virus, dt);
      }
      virus.y = clampToVessel(virus.x, virus.y, virus.radius);
      virus.angle += virus.spin * dt;
      virus.hit = Math.max(0, virus.hit - dt);
    }
  }

  compactArray(
    state.viruses,
    (virus) => !virus.dead && virus.x > -virus.radius - 80 && virus.hp > 0,
  );
  separateInfluenzaViruses(dt);
  replicateInfluenzaViruses();
}

function updateRedCells(dt, worldSpeed) {
  for (const cell of state.redCells) {
    cell.x -= (cell.speed + worldSpeed * cell.depth * 0.26) * dt;
    cell.y += Math.sin(state.time * 1.2 + cell.wobble) * cell.drift * dt;
    cell.rotation += cell.spin * dt;
  }

  compactArray(state.redCells, (cell) => cell.x > -cell.radius * 2);
}

function updatePlatelets(dt, worldSpeed) {
  for (const platelet of state.platelets) {
    platelet.x -= (platelet.speed + worldSpeed * 0.3) * dt;
    platelet.angle += platelet.spin * dt;
  }

  compactArray(state.platelets, (platelet) => platelet.x > -platelet.radius * 3);
}

function updateParticles(dt) {
  for (const particle of state.particles) {
    particle.ttl += dt;
    particle.x += particle.vx * dt;
    particle.y += particle.vy * dt;
    particle.vx *= Math.pow(0.03, dt);
    particle.vy *= Math.pow(0.03, dt);
  }

  compactArray(state.particles, (particle) => particle.ttl < particle.life, recycleParticle);
}

function getVirusCollisionRadius(virus) {
  if (virus.type === "poxBoss") return virus.radius * 1.62;
  if (virus.type === "filovirusBoss") return virus.radius * 1.9;
  if (virus.type === "adenovirusMini") return virus.radius * 1.3;
  return virus.radius;
}

function getVirusDamageScale(virus) {
  if (!isBossVirus(virus)) return 1;
  return bossProfiles[virus.type]?.damageScale ?? 1;
}

function applyShotHit(virus, shot) {
  if (virus.type === "adenovirusMini" && !virus.shieldOpen) {
    virus.hit = 0.18;
    shot.life = -1;
    state.shake = Math.max(state.shake, 0.08);
    playVirusHitSfx(virus);
    addParticleBurst(shot.x, shot.y, "#9ff8ff", 8, 92);
    return;
  }

  virus.hp -= shot.damage * getVirusDamageScale(virus);
  virus.hit = 0.12;
  shot.life = -1;
  addParticleBurst(shot.x, shot.y, palette.cyan, isBossVirus(virus) ? 14 : 9, 95);
  if (virus.hp <= 0) {
    destroyVirus(virus);
  } else {
    playVirusHitSfx(virus);
  }
}

function getShotCollisionCellKey(cellX, cellY) {
  return `${cellX}:${cellY}`;
}

function addVirusToShotCollisionBucket(cellX, cellY, virus) {
  const key = getShotCollisionCellKey(cellX, cellY);
  let bucket = shotCollisionBuckets.get(key);
  if (!bucket) {
    bucket = [];
    shotCollisionBuckets.set(key, bucket);
  }
  bucket.push(virus);
}

function buildShotCollisionBuckets() {
  shotCollisionBuckets.clear();
  const cellSize = SHOT_COLLISION_CELL_SIZE;
  for (const virus of state.viruses) {
    if (virus.dead) continue;
    const radius = getVirusCollisionRadius(virus) + SHOT_COLLISION_MAX_HIT_RADIUS;
    const minCellX = Math.floor((virus.x - radius) / cellSize);
    const maxCellX = Math.floor((virus.x + radius) / cellSize);
    const minCellY = Math.floor((virus.y - radius) / cellSize);
    const maxCellY = Math.floor((virus.y + radius) / cellSize);

    for (let cellY = minCellY; cellY <= maxCellY; cellY += 1) {
      for (let cellX = minCellX; cellX <= maxCellX; cellX += 1) {
        addVirusToShotCollisionBucket(cellX, cellY, virus);
      }
    }
  }
}

function getShotCollisionCandidates(shot) {
  shotCollisionCandidates.length = 0;
  shotCollisionQueryId += 1;

  const cellSize = SHOT_COLLISION_CELL_SIZE;
  const cellX = Math.floor(shot.x / cellSize);
  const cellY = Math.floor(shot.y / cellSize);

  for (let y = cellY - 1; y <= cellY + 1; y += 1) {
    for (let x = cellX - 1; x <= cellX + 1; x += 1) {
      const bucket = shotCollisionBuckets.get(getShotCollisionCellKey(x, y));
      if (!bucket) continue;
      for (const virus of bucket) {
        if (virus._shotCollisionQueryId === shotCollisionQueryId) continue;
        virus._shotCollisionQueryId = shotCollisionQueryId;
        shotCollisionCandidates.push(virus);
      }
    }
  }

  return shotCollisionCandidates;
}

function tryShotVirusCollision(shot, virus) {
  if (!virus || virus.dead || shot.life <= 0) return false;
  const collisionRadius = (shot.hitRadius ?? shot.radius) + getVirusCollisionRadius(virus);
  const dx = shot.x - virus.x;
  if (Math.abs(dx) > collisionRadius) return false;
  const dy = shot.y - virus.y;
  if (Math.abs(dy) > collisionRadius) return false;
  if (dx * dx + dy * dy > collisionRadius * collisionRadius) return false;
  applyShotHit(virus, shot);
  return true;
}

function checkShotCollisions() {
  if (state.shots.length === 0 || state.viruses.length === 0) return;
  buildShotCollisionBuckets();
  for (const shot of state.shots) {
    if (shot.life <= 0) continue;
    if (isLockableVirus(shot.target) && tryShotVirusCollision(shot, shot.target)) continue;

    const candidates = getShotCollisionCandidates(shot);
    for (const virus of candidates) {
      if (virus === shot.target) continue;
      if (tryShotVirusCollision(shot, virus)) break;
    }
  }

  compactArray(state.shots, (shot) => shot.life > 0, recycleShot);
}

function checkCollisions() {
  const player = state.player;

  checkShotCollisions();

  for (const virus of state.viruses) {
    if (virus.dead) continue;
    const collisionRadius = player.radius * 0.82 + getVirusCollisionRadius(virus) * 0.66;
    if (isWithinDistance(player, virus, collisionRadius)) {
      hurtPlayer(
        isBossVirus(virus)
          ? virus.damage
          : virus.type === "tank"
            ? 22
            : virus.type === "influenza"
              ? 16
              : 14,
        virus.x,
        virus.y,
        virus.color,
      );
      if (!isBossVirus(virus)) {
        virus.hp = 0;
        virus.dead = true;
      }
    }
  }

  for (const cell of state.redCells) {
    const dx = player.x - cell.x;
    const dy = player.y - cell.y;
    const collisionRadius = player.radius + cell.radius * 0.72;
    const d = Math.hypot(dx, dy);
    if (d < collisionRadius && d > 0) {
      const push = (collisionRadius - d) * 0.28;
      player.x += (dx / d) * push;
      player.y += (dy / d) * push;
      player.vx += (dx / d) * 42;
      player.vy += (dy / d) * 42;
    }
  }

  for (const platelet of state.platelets) {
    if (isWithinDistance(player, platelet, player.radius + platelet.radius * 0.86)) {
      playPlateletBumpSfx();
      hurtPlayer(18, platelet.x, platelet.y, palette.platelet, false, false);
      platelet.x = -999;
    }
  }
}

function hurtPlayer(amount, x, y, color, soft = false, playDamageSound = true) {
  const player = state.player;
  if (player.invulnerable > 0 && !soft) return;
  if (soft && player.hurtTimer > 0) return;

  const previousHealth = player.health;
  player.health = Math.max(0, player.health - amount);
  state.stats.damageTaken += previousHealth - player.health;
  player.hurtTimer = soft ? 0.35 : 0.7;
  player.invulnerable = soft ? player.invulnerable : 0.55;
  addParticleBurst(x, y, color, soft ? 4 : 16, soft ? 55 : 150);
  if (!soft && playDamageSound) {
    if (player.health <= 0) playPlayerDeathSfx();
    else playPlayerDamageSfx();
  }

  if (player.health <= 0) {
    endGame();
  }
}

function endGame() {
  if (state.ended) return;
  state.running = false;
  state.ended = true;
  state.paused = false;
  state.awaitingUpgrade = false;
  state.levelComplete = false;
  state.gameOverInputLockUntil = performance.now() + GAME_OVER_INPUT_LOCK_DURATION * 1000;
  pointer.down = false;
  pointer.active = false;
  keys.clear();
  resetHeldActionInputs();
  resetMobileJoystick();
  mobileInput.fire = false;
  setMobileButtonPressed(mobileFireButton, false);
  setMobileButtonPressed(mobileDashButton, false);
  setMobileButtonPressed(mobilePulseButton, false);
  overlay.hidden = true;
  gameOverOverlay.hidden = false;
  setGameOverRestartReady(false);
  pauseOverlay.hidden = true;
  levelCompleteOverlay.hidden = true;
  upgradeOverlay.hidden = true;
  renderGameOverSummary();
  syncPauseUi();
  gameOverFrameEl.focus({ preventScroll: true });
  window.setTimeout(() => {
    if (!state.ended || gameOverOverlay.hidden) return;
    setGameOverRestartReady(true);
    gameOverFrameEl.focus({ preventScroll: true });
  }, GAME_OVER_INPUT_LOCK_DURATION * 1000);
}

function renderPlayfield() {
  if (phaserRenderer?.ready) {
    phaserRenderer.sync();
    return;
  }

  draw();
}

function draw() {
  ctx.save();
  if (state.shake > 0) {
    const amount = state.shake * 7;
    ctx.translate(rand(-amount, amount), rand(-amount, amount));
  }
  drawBackground();
  drawWorldObjects(false);
  drawPlayer();
  drawWorldObjects(true);
  drawShots();
  drawParticles();
  drawVesselForeground();
  ctx.restore();
}

function drawBackground() {
  const { width, height } = state;
  const background = ctx.createLinearGradient(0, 0, width, height);
  background.addColorStop(0, "#2a0718");
  background.addColorStop(0.28, "#42101f");
  background.addColorStop(0.62, "#6f1d27");
  background.addColorStop(1, "#270716");
  ctx.fillStyle = background;
  ctx.fillRect(0, 0, width, height);

  const generatedBackgroundReady = drawParallaxLayer(parallaxLayers.far, 0.12, 1);

  if (!generatedBackgroundReady) {
    drawProceduralPlasmaBands();
  }

  drawParallaxLayer(parallaxLayers.currents, 0.28, 0.38);
  drawParallaxLayer(parallaxLayers.branches, 0.38, 0.24);
  drawParallaxLayer(parallaxLayers.cells, 0.52, 0.34);
  for (const dot of state.plasma) {
    dot.x -= dot.speed * (1 / 60) * (0.5 + dot.layer * 0.3);
    if (dot.x < -8) {
      dot.x = state.width + 8;
      dot.y = rand(0, state.height);
    }
    ctx.beginPath();
    ctx.fillStyle = `rgba(255, 195, 158, ${dot.alpha})`;
    ctx.arc(dot.x, dot.y, dot.radius, 0, TAU);
    ctx.fill();
  }

  drawGameplayFocusVeil();
}

function drawGameplayFocusVeil() {
  const { width, height } = state;
  const lane = ctx.createLinearGradient(0, 0, 0, height);
  lane.addColorStop(0, "rgba(20, 2, 13, 0.08)");
  lane.addColorStop(0.22, "rgba(28, 4, 16, 0.16)");
  lane.addColorStop(0.5, "rgba(50, 8, 20, 0.1)");
  lane.addColorStop(0.78, "rgba(28, 4, 16, 0.16)");
  lane.addColorStop(1, "rgba(20, 2, 13, 0.1)");
  ctx.fillStyle = lane;
  ctx.fillRect(0, 0, width, height);
}

function drawProceduralPlasmaBands() {
  const { width, height } = state;

  for (let band = 0; band < 7; band += 1) {
    const y = height * (0.19 + band * 0.11);
    ctx.beginPath();
    for (let x = -40; x <= width + 40; x += 36) {
      const n = (x + state.scroll * (0.12 + band * 0.045)) * 0.012;
      const wave = Math.sin(n + band * 1.9) * 18 + Math.sin(n * 0.43) * 11;
      if (x === -40) ctx.moveTo(x, y + wave);
      else ctx.lineTo(x, y + wave);
    }
    ctx.lineWidth = 14 + band * 3.5;
    ctx.strokeStyle = `rgba(${185 + band * 8}, ${52 + band * 10}, ${50 + band * 8}, ${0.06 + band * 0.014})`;
    ctx.stroke();
  }

  for (let ribbon = 0; ribbon < 4; ribbon += 1) {
    const y = height * (0.28 + ribbon * 0.13);
    ctx.beginPath();
    for (let x = -60; x <= width + 60; x += 28) {
      const n = (x + state.scroll * (0.2 + ribbon * 0.035)) * 0.008;
      const wave = Math.sin(n + ribbon * 0.8) * 24 + Math.cos(n * 1.7) * 7;
      if (x === -60) ctx.moveTo(x, y + wave);
      else ctx.lineTo(x, y + wave);
    }
    ctx.lineWidth = 2.5 + ribbon * 0.8;
    ctx.strokeStyle = `rgba(255, ${118 + ribbon * 18}, ${74 + ribbon * 12}, 0.12)`;
    ctx.stroke();
  }
}

function drawParallaxLayer(asset, speed, alpha = 1) {
  if (!asset.loaded) return false;

  const { width, height } = state;
  const image = asset.image;
  const scale = Math.max(width / image.width, height / image.height);
  const drawWidth = image.width * scale;
  const drawHeight = image.height * scale;
  const scaledLayer = getScaledParallaxLayer(asset, drawWidth, drawHeight);
  const layerSource = scaledLayer?.canvas || image;
  const y = (height - drawHeight) * 0.5;
  const scrollPosition = state.scroll * speed;
  const baseIndex = Math.floor(scrollPosition / drawWidth);
  const localOffset = -(scrollPosition - baseIndex * drawWidth);
  const tileCount = Math.ceil(width / drawWidth) + 3;

  ctx.save();
  ctx.globalAlpha = alpha;
  for (let tile = -1; tile < tileCount; tile += 1) {
    const x = localOffset + tile * drawWidth;
    const mirrored = (baseIndex + tile) % 2 !== 0;

    if (mirrored) {
      ctx.save();
      ctx.translate(x + drawWidth, y);
      ctx.scale(-1, 1);
      ctx.drawImage(layerSource, 0, 0, drawWidth, drawHeight);
      ctx.restore();
    } else {
      ctx.drawImage(layerSource, x, y, drawWidth, drawHeight);
    }
  }
  ctx.restore();
  return true;
}

function drawBranchHint() {
  const { width, height } = state;
  const branchX = width * 0.88 - (state.scroll * 0.11) % (width * 1.18);
  const branchY = height * 0.27 + Math.sin(state.time * 0.4) * 12;
  const branchW = width * 0.3;
  const branchH = height * 0.22;
  ctx.save();
  ctx.globalAlpha = 0.72;
  ctx.translate(branchX, branchY);
  ctx.rotate(-0.28);

  const rim = ctx.createRadialGradient(0, 0, branchW * 0.12, 0, 0, branchW * 0.56);
  rim.addColorStop(0, "rgba(31, 4, 17, 0.96)");
  rim.addColorStop(0.46, "rgba(35, 5, 18, 0.92)");
  rim.addColorStop(0.52, "rgba(168, 48, 55, 0.72)");
  rim.addColorStop(0.68, "rgba(116, 29, 42, 0.45)");
  rim.addColorStop(1, "rgba(116, 29, 42, 0)");
  ctx.fillStyle = rim;
  ctx.beginPath();
  ctx.ellipse(0, 0, branchW * 0.52, branchH * 0.47, 0, 0, TAU);
  ctx.fill();

  const grad = ctx.createRadialGradient(-branchW * 0.12, -branchH * 0.05, 6, 0, 0, branchW * 0.34);
  grad.addColorStop(0, "rgba(9, 3, 11, 0.96)");
  grad.addColorStop(1, "rgba(21, 4, 14, 0.78)");
  ctx.fillStyle = grad;
  ctx.beginPath();
  ctx.ellipse(-branchW * 0.03, 0, branchW * 0.32, branchH * 0.32, 0, 0, TAU);
  ctx.fill();
  ctx.restore();
}

function drawWorldObjects(foreground) {
  for (const platelet of state.platelets) {
    if (foreground) drawPlatelet(platelet);
  }

  for (const cell of state.redCells) {
    if ((cell.depth >= 0.68) === foreground) drawRedCell(cell, !foreground);
  }

  for (const virus of state.viruses) {
    if (virus.dead) continue;
    if (foreground) drawVirus(virus);
  }
}

function drawVesselForeground() {
  const { width, height } = state;
  const generatedWallsReady = drawParallaxLayer(parallaxLayers.walls, 0.96, 1);

  if (!generatedWallsReady) {
    drawWall("top");
    drawWall("bottom");
  }

  drawParallaxLayer(parallaxLayers.floaters, 1.22, 0.28);

  const vignette = ctx.createRadialGradient(width * 0.48, height * 0.5, height * 0.15, width * 0.5, height * 0.5, width * 0.74);
  vignette.addColorStop(0, "rgba(0, 0, 0, 0)");
  vignette.addColorStop(1, "rgba(18, 1, 13, 0.36)");
  ctx.fillStyle = vignette;
  ctx.fillRect(0, 0, width, height);
}

function drawWall(position) {
  const { width, height } = state;
  const isTop = position === "top";
  ctx.beginPath();

  if (isTop) {
    ctx.moveTo(0, 0);
    for (let x = 0; x <= width + 20; x += 24) ctx.lineTo(x, topWallAt(x));
    ctx.lineTo(width, 0);
    ctx.closePath();
  } else {
    ctx.moveTo(0, height);
    for (let x = 0; x <= width + 20; x += 24) ctx.lineTo(x, bottomWallAt(x));
    ctx.lineTo(width, height);
    ctx.closePath();
  }

  const grad = ctx.createLinearGradient(0, isTop ? 0 : height, 0, isTop ? height * 0.23 : height * 0.74);
  grad.addColorStop(0, palette.vesselDark);
  grad.addColorStop(0.58, palette.vesselMid);
  grad.addColorStop(1, "rgba(232, 83, 72, 0.86)");
  ctx.fillStyle = grad;
  ctx.fill();

  drawWallSpots(isTop);

  ctx.beginPath();
  for (let x = -20; x <= width + 20; x += 24) {
    const y = isTop ? topWallAt(x) : bottomWallAt(x);
    if (x === -20) ctx.moveTo(x, y);
    else ctx.lineTo(x, y);
  }
  ctx.lineWidth = 5;
  ctx.strokeStyle = isTop ? "rgba(255, 161, 128, 0.42)" : "rgba(255, 183, 137, 0.36)";
  ctx.stroke();

  ctx.lineWidth = 2;
  ctx.strokeStyle = "rgba(255, 218, 180, 0.52)";
  ctx.stroke();
}

function drawWallSpots(isTop) {
  const { width } = state;
  ctx.save();
  ctx.globalAlpha = 0.28;
  for (let i = 0; i < 22; i += 1) {
    const seed = Math.sin(i * 91.7 + state.level * 4.4) * 10000;
    const f = seed - Math.floor(seed);
    const x = ((i * 87 - state.scroll * 0.36) % (width + 160)) - 80;
    const wall = isTop ? topWallAt(x) : bottomWallAt(x);
    const offset = 18 + f * 46;
    const y = isTop ? wall - offset : wall + offset;
    const r = 5 + f * 16;
    ctx.translate(x, y);
    ctx.rotate(f * TAU);
    ctx.scale(1.6, 0.62);
    ctx.fillStyle = f > 0.5 ? "rgba(255, 119, 94, 0.34)" : "rgba(88, 15, 31, 0.38)";
    ctx.beginPath();
    ctx.arc(0, 0, r, 0, TAU);
    ctx.fill();
    ctx.setTransform(state.dpr, 0, 0, state.dpr, 0, 0);
  }
  ctx.restore();
}

function drawRedCell(cell, distant = false) {
  const frame = spriteFrames.redCell[(cell.frameIndex ?? 0) % spriteFrames.redCell.length];
  const spriteDrawn = drawAtlasFrame(frame, cell.x, cell.y, cell.radius * 1.86, {
    rotation: cell.rotation,
    alpha: distant ? 0.38 : 0.88,
    shadowColor: distant ? "rgba(0, 0, 0, 0)" : "rgba(255, 107, 92, 0.24)",
    shadowBlur: distant ? 0 : 8,
  });
  if (spriteDrawn) return;

  ctx.save();
  ctx.translate(cell.x, cell.y);
  ctx.rotate(cell.rotation);
  ctx.scale(1.32, 0.66);
  ctx.globalAlpha = distant ? 0.42 : 0.82;

  const grad = ctx.createRadialGradient(-cell.radius * 0.28, -cell.radius * 0.24, cell.radius * 0.16, 0, 0, cell.radius);
  grad.addColorStop(0, "#ffad92");
  grad.addColorStop(0.5, "#d54a48");
  grad.addColorStop(1, "#8f1e32");
  ctx.fillStyle = grad;
  ctx.beginPath();
  ctx.ellipse(0, 0, cell.radius, cell.radius, 0, 0, TAU);
  ctx.fill();

  ctx.globalAlpha *= 0.8;
  ctx.fillStyle = "rgba(83, 12, 30, 0.36)";
  ctx.beginPath();
  ctx.ellipse(0, 0, cell.radius * 0.42, cell.radius * 0.4, 0, 0, TAU);
  ctx.fill();

  ctx.restore();
}

function drawPlatelet(platelet) {
  const frame = spriteFrames.platelet[(platelet.frameIndex ?? 0) % spriteFrames.platelet.length];
  const spriteDrawn = drawAtlasFrame(frame, platelet.x, platelet.y, platelet.radius * 2.55, {
    rotation: platelet.angle,
    alpha: 0.94,
    shadowColor: "rgba(255, 207, 86, 0.34)",
    shadowBlur: 13,
    pulse: 1 + Math.sin(state.time * 2.4 + platelet.angle) * 0.025,
  });
  if (spriteDrawn) return;

  ctx.save();
  ctx.translate(platelet.x, platelet.y);
  ctx.rotate(platelet.angle);
  ctx.shadowColor = "rgba(255, 207, 86, 0.34)";
  ctx.shadowBlur = 12;

  for (const bubble of platelet.bubbles) {
    const x = Math.cos(bubble.angle) * bubble.distance;
    const y = Math.sin(bubble.angle) * bubble.distance * 0.82;
    const grad = ctx.createRadialGradient(
      x - bubble.radius * 0.25,
      y - bubble.radius * 0.25,
      bubble.radius * 0.12,
      x,
      y,
      bubble.radius,
    );
    grad.addColorStop(0, `rgba(255, 238, 145, ${bubble.alpha})`);
    grad.addColorStop(0.58, `rgba(229, 171, 48, ${bubble.alpha})`);
    grad.addColorStop(1, `rgba(160, 102, 22, ${bubble.alpha})`);
    ctx.fillStyle = grad;
    ctx.beginPath();
    ctx.arc(x, y, bubble.radius, 0, TAU);
    ctx.fill();
  }

  ctx.lineWidth = 2;
  ctx.strokeStyle = "rgba(255, 220, 120, 0.48)";
  ctx.beginPath();
  ctx.arc(0, 0, platelet.radius * 0.95, 0, TAU);
  ctx.stroke();
  ctx.restore();
}

function drawVirusReadabilityHalo(virus) {
  ctx.save();
  ctx.translate(virus.x, virus.y);
  const radius = virus.radius * (virus.type === "fragment" ? 1.28 : 1.34);
  ctx.fillStyle = "rgba(14, 1, 10, 0.38)";
  ctx.beginPath();
  ctx.arc(0, 0, radius, 0, TAU);
  ctx.fill();
  ctx.lineWidth = virus.type === "budding" ? 3 : 2;
  ctx.strokeStyle =
    virus.type === "budding"
      ? "rgba(255, 226, 126, 0.7)"
      : virus.type === "fragment"
        ? "rgba(255, 164, 90, 0.62)"
        : "rgba(255, 244, 238, 0.22)";
  ctx.stroke();
  ctx.restore();
}

function drawVirusTypeOverlay(virus) {
  if (virus.type !== "budding" && virus.type !== "fragment") return;

  ctx.save();
  ctx.translate(virus.x, virus.y);
  ctx.rotate(-virus.angle * 0.45);
  ctx.globalAlpha = virus.type === "fragment" ? 0.5 : 0.72;
  ctx.strokeStyle = virus.type === "fragment" ? "rgba(255, 184, 108, 0.78)" : "rgba(255, 237, 136, 0.86)";
  ctx.lineWidth = virus.type === "fragment" ? 1.8 : 2.4;
  ctx.setLineDash(virus.type === "fragment" ? [4, 5] : [7, 5]);
  ctx.beginPath();
  ctx.arc(0, 0, virus.radius * 1.22, 0, TAU);
  ctx.stroke();
  ctx.setLineDash([]);
  ctx.restore();
}

function drawAdenovirusShield(virus) {
  if (virus.type !== "adenovirusMini" || virus.shieldOpen) return;

  ctx.save();
  ctx.translate(virus.x, virus.y);
  ctx.rotate(state.time * 0.8);
  ctx.globalAlpha = 0.48 + Math.sin(state.time * 8) * 0.08;
  ctx.strokeStyle = "rgba(135, 250, 255, 0.74)";
  ctx.lineWidth = 3;
  ctx.setLineDash([12, 10]);
  ctx.beginPath();
  ctx.arc(0, 0, virus.radius * 1.56, 0, TAU);
  ctx.stroke();
  ctx.setLineDash([]);
  ctx.restore();
}

function drawVirus(virus) {
  const frames = spriteFrames[virus.spriteGroup] || spriteFrames.greenVirus;
  const frame = frames[(virus.frameIndex ?? 0) % frames.length];
  const spriteAsset = getSpriteAsset(virus.spriteGroup);
  const hitPulse = virus.hit > 0 ? 1 + Math.sin(state.time * 60) * 0.06 : 1;
  if (virus.type !== "influenza" && !isBossVirus(virus)) {
    drawVirusReadabilityHalo(virus);
  }
  const targetHeight = isBossVirus(virus)
    ? virus.radius * (virus.type === "filovirusBoss" ? 2.48 : 2.74)
    : virus.radius * 2.92;
  const spriteDrawn = drawImageFrame(spriteAsset, frame, virus.x, virus.y, targetHeight, {
    rotation: virus.angle,
    alpha: virus.hit > 0 ? 0.72 + Math.sin(state.time * 60) * 0.2 : 1,
    shadowColor: virus.color,
    shadowBlur:
      bossProfiles[virus.type]?.shadowBlur ??
      (virus.type === "influenza" || virus.type === "tank" || virus.type === "budding" ? 18 : 11),
    pulse: hitPulse,
  });
  if (spriteDrawn) {
    drawAdenovirusShield(virus);
    if (virus.type !== "influenza" && !isBossVirus(virus)) {
      drawVirusTypeOverlay(virus);
    }
    return;
  }
  if (virus.type === "influenza") return;

  ctx.save();
  ctx.translate(virus.x, virus.y);
  ctx.rotate(virus.angle);
  ctx.globalAlpha = virus.hit > 0 ? 0.7 + Math.sin(state.time * 60) * 0.22 : 1;
  ctx.shadowColor = virus.color;
  ctx.shadowBlur = virus.type === "tank" ? 18 : 10;

  for (let i = 0; i < virus.spikes; i += 1) {
    const angle = (i / virus.spikes) * TAU;
    const inner = virus.radius * 0.82;
    const outer = virus.radius * 1.24;
    ctx.beginPath();
    ctx.moveTo(Math.cos(angle) * inner, Math.sin(angle) * inner);
    ctx.lineTo(Math.cos(angle - 0.08) * outer, Math.sin(angle - 0.08) * outer);
    ctx.lineTo(Math.cos(angle + 0.08) * outer, Math.sin(angle + 0.08) * outer);
    ctx.closePath();
    ctx.fillStyle = virus.color;
    ctx.fill();
  }

  const grad = ctx.createRadialGradient(-virus.radius * 0.28, -virus.radius * 0.28, 2, 0, 0, virus.radius);
  grad.addColorStop(0, "#fff0b8");
  grad.addColorStop(0.2, virus.color);
  grad.addColorStop(1, virus.core);
  ctx.beginPath();
  ctx.arc(0, 0, virus.radius, 0, TAU);
  ctx.fillStyle = grad;
  ctx.fill();

  ctx.globalAlpha *= 0.45;
  ctx.fillStyle = "#fff7cc";
  ctx.beginPath();
  ctx.arc(-virus.radius * 0.25, -virus.radius * 0.32, virus.radius * 0.18, 0, TAU);
  ctx.fill();
  ctx.restore();
  drawVirusTypeOverlay(virus);
}

function drawPlayerSwimWake(player, strength) {
  if (strength < 0.08) return;

  const direction = player.horizontalPose < 0 ? -1 : 1;
  const flicker = 0.72 + Math.sin(state.time * 18) * 0.14;

  ctx.save();
  ctx.translate(player.x, player.y);
  ctx.scale(direction, 1);
  ctx.globalAlpha = strength * flicker;
  ctx.lineCap = "round";

  for (let i = 0; i < 4; i += 1) {
    const y = (i - 1.5) * player.radius * 0.28 + Math.sin(state.time * 8 + i) * 1.6;
    const start = -player.radius * (1.05 + i * 0.12);
    const end = -player.radius * (1.86 + i * 0.2);
    ctx.strokeStyle = i % 2 === 0 ? "rgba(166, 255, 248, 0.46)" : "rgba(255, 244, 238, 0.26)";
    ctx.lineWidth = 2.4 - i * 0.26;
    ctx.beginPath();
    ctx.moveTo(start, y);
    ctx.lineTo(end, y * 0.72);
    ctx.stroke();
  }

  ctx.globalAlpha = strength * 0.36;
  ctx.fillStyle = "rgba(194, 255, 246, 0.58)";
  for (let i = 0; i < 3; i += 1) {
    const x = -player.radius * (1.35 + i * 0.38);
    const y = Math.sin(state.time * 7 + i) * player.radius * 0.34;
    ctx.beginPath();
    ctx.arc(x, y, 2.2 - i * 0.32, 0, TAU);
    ctx.fill();
  }

  ctx.restore();
}

function drawPlayerAbilityEffects(player) {
  if (state.pulseTimer > 0) {
    const progress = 1 - state.pulseTimer / 0.38;
    const radius = 72 + progress * (150 + state.upgrades.pulse * 32);
    ctx.save();
    ctx.translate(player.x, player.y);
    ctx.globalAlpha = 1 - progress;
    ctx.strokeStyle = "rgba(194, 255, 255, 0.72)";
    ctx.lineWidth = 5 - progress * 2.5;
    ctx.shadowColor = palette.cyan;
    ctx.shadowBlur = 20;
    ctx.beginPath();
    ctx.arc(0, 0, radius, 0, TAU);
    ctx.stroke();
    ctx.globalAlpha *= 0.36;
    ctx.fillStyle = "rgba(102, 242, 255, 0.18)";
    ctx.beginPath();
    ctx.arc(0, 0, radius * 0.62, 0, TAU);
    ctx.fill();
    ctx.restore();
  }

  if (state.dashTimer > 0) {
    const alpha = state.dashTimer / 0.22;
    ctx.save();
    ctx.translate(player.x, player.y);
    ctx.globalAlpha = alpha * 0.58;
    ctx.strokeStyle = "rgba(210, 255, 250, 0.8)";
    ctx.lineWidth = 3.4;
    ctx.lineCap = "round";
    for (let i = 0; i < 5; i += 1) {
      const y = (i - 2) * player.radius * 0.22;
      ctx.beginPath();
      ctx.moveTo(-player.radius * (1.1 + i * 0.08), y);
      ctx.lineTo(-player.radius * (2.8 + i * 0.14), y * 0.6);
      ctx.stroke();
    }
    ctx.restore();
  }
}

function drawPlayer() {
  const player = state.player;
  if (!player) return;

  const hurtPulse = player.hurtTimer > 0 ? Math.sin(state.time * 50) * 0.12 : 0;
  const aimAngle = player.aimAngle;
  const speed = Math.hypot(player.vx, player.vy);
  const swimPulseRate = 3.2 + clamp(speed / 170, 0, 1.8);
  const poseStrength = clamp(Math.abs(player.horizontalPose ?? 0), 0, 1);
  const swimFrame = poseStrength > 0.22 ? 1 : (player.spriteFrame ?? 0) % spriteFrames.whiteCell.length;
  const spriteAlpha = 1;
  const bodyAngle =
    Math.sin(state.time * 2.8) * 0.075 +
    player.vy * 0.0008 +
    (player.horizontalPose ?? 0) * 0.055;

  drawPlayerAbilityEffects(player);
  drawPlayerSwimWake(player, poseStrength);

  const spriteDrawn = drawAtlasFrame(
    spriteFrames.whiteCell[swimFrame],
    player.x,
    player.y,
    player.radius * 3.55,
    {
      rotation: bodyAngle,
      alpha: spriteAlpha,
      shadowColor:
        player.hurtTimer > 0 ? "rgba(255, 115, 120, 0.42)" : "rgba(96, 239, 255, 0.28)",
      shadowBlur: player.hurtTimer > 0 ? 22 : 18,
      pulse:
        1 +
        Math.abs(hurtPulse) * 0.42 +
        Math.sin(state.time * swimPulseRate) * 0.014,
      flipX: (player.horizontalPose ?? 0) < -0.16,
      scaleX: 1 + poseStrength * 0.12,
      scaleY: 1 - poseStrength * 0.035,
    },
  );

  if (spriteDrawn) {
    return;
  }

  ctx.save();
  ctx.translate(player.x, player.y);
  ctx.rotate(Math.sin(state.time * 2.8) * 0.08 + player.vy * 0.0008);
  ctx.scale(
    1 + Math.abs(player.vx) * 0.00025 + poseStrength * 0.12,
    1 - Math.abs(player.vx) * 0.00008 - poseStrength * 0.035,
  );
  ctx.shadowColor = "rgba(96, 239, 255, 0.28)";
  ctx.shadowBlur = 18;

  const blob = [
    [-0.95, -0.04],
    [-0.65, -0.52],
    [-0.15, -0.92],
    [0.48, -0.8],
    [0.94, -0.28],
    [0.82, 0.28],
    [0.38, 0.78],
    [-0.18, 0.92],
    [-0.72, 0.6],
  ];

  ctx.beginPath();
  for (let i = 0; i < blob.length; i += 1) {
    const point = blob[i];
    const next = blob[(i + 1) % blob.length];
    const wobble = 1 + Math.sin(state.time * 4 + i) * 0.05;
    const x = point[0] * player.radius * wobble;
    const y = point[1] * player.radius * wobble;
    const cx = ((point[0] + next[0]) / 2) * player.radius;
    const cy = ((point[1] + next[1]) / 2) * player.radius;
    if (i === 0) ctx.moveTo(x, y);
    ctx.quadraticCurveTo(x, y, cx, cy);
  }
  ctx.closePath();
  const grad = ctx.createRadialGradient(-9, -11, 4, 0, 0, player.radius * 1.12);
  grad.addColorStop(0, "#ffffff");
  grad.addColorStop(0.58, palette.whiteCell);
  grad.addColorStop(1, player.hurtTimer > 0 ? "#ffd3d3" : palette.whiteCellShade);
  ctx.fillStyle = grad;
  ctx.fill();
  ctx.lineWidth = 3;
  ctx.strokeStyle = `rgba(104, 238, 255, ${0.44 + hurtPulse})`;
  ctx.stroke();

  for (let i = 0; i < 8; i += 1) {
    const angle = i * 0.78 + Math.sin(state.time * 1.4 + i) * 0.08;
    const lobeX = Math.cos(angle) * player.radius * 0.58;
    const lobeY = Math.sin(angle) * player.radius * 0.58;
    const lobeRadius = player.radius * (0.18 + (i % 3) * 0.025);
    ctx.fillStyle = i % 2 === 0 ? "rgba(210, 236, 255, 0.36)" : "rgba(201, 218, 255, 0.28)";
    ctx.beginPath();
    ctx.arc(lobeX, lobeY, lobeRadius, 0, TAU);
    ctx.fill();
  }

  ctx.rotate(aimAngle);
  ctx.fillStyle = "#233449";
  ctx.beginPath();
  ctx.ellipse(8, -8, 4.2, 5.4, 0, 0, TAU);
  ctx.ellipse(8, 8, 4.2, 5.4, 0, 0, TAU);
  ctx.fill();
  ctx.fillStyle = "#ffffff";
  ctx.beginPath();
  ctx.arc(9.5, -9.2, 1.2, 0, TAU);
  ctx.arc(9.5, 6.8, 1.2, 0, TAU);
  ctx.fill();

  ctx.restore();
}

function drawShots() {
  if (shouldUseMobileRenderMode()) {
    drawMobileShots();
    return;
  }

  const sprite = getCachedShotSprite();
  for (const shot of state.shots) {
    const angle = Math.atan2(shot.vy, shot.vx);
    const pulse = 1 + Math.sin((shot.age || 0) * 22) * 0.06;
    const scale = pulse * 1.18;

    ctx.save();
    ctx.translate(shot.x, shot.y);
    ctx.rotate(angle);
    ctx.scale(scale, scale);
    ctx.drawImage(
      sprite.canvas,
      -sprite.originX,
      -sprite.originY,
      sprite.logicalWidth,
      sprite.logicalHeight,
    );
    ctx.restore();
  }
}

function drawMobileShots() {
  ctx.save();
  ctx.lineCap = "round";
  ctx.lineJoin = "round";

  ctx.strokeStyle = "rgba(96, 239, 255, 0.24)";
  ctx.lineWidth = 5.2;
  ctx.beginPath();
  for (const shot of state.shots) {
    traceCanvasMobileShot(shot);
  }
  ctx.stroke();

  ctx.strokeStyle = "rgba(223, 255, 255, 0.9)";
  ctx.lineWidth = 2.4;
  ctx.beginPath();
  for (const shot of state.shots) {
    traceCanvasMobileShot(shot);
  }
  ctx.stroke();

  ctx.restore();
}

function traceCanvasMobileShot(shot) {
  const ux = shot.renderUx || 1;
  const uy = shot.renderUy || 0;
  const px = -uy;
  const py = ux;
  const baseX = shot.x - ux * 12;
  const baseY = shot.y - uy * 12;
  const splitX = shot.x + ux * 8;
  const splitY = shot.y + uy * 8;
  const tipX = shot.x + ux * 20;
  const tipY = shot.y + uy * 20;
  const spread = 5.2;

  ctx.moveTo(baseX, baseY);
  ctx.lineTo(splitX, splitY);
  ctx.moveTo(splitX, splitY);
  ctx.lineTo(tipX + px * spread, tipY + py * spread);
  ctx.moveTo(splitX, splitY);
  ctx.lineTo(tipX - px * spread, tipY - py * spread);
}

function drawParticles() {
  const mobileMode = shouldUseMobileRenderMode();
  const maxVisibleParticles = mobileMode ? 130 : state.particles.length;
  const particleStride =
    state.particles.length > maxVisibleParticles
      ? Math.ceil(state.particles.length / maxVisibleParticles)
      : 1;

  for (let index = 0; index < state.particles.length; index += particleStride) {
    const particle = state.particles[index];
    const progress = particle.ttl / particle.life;
    ctx.globalAlpha = 1 - progress;
    ctx.fillStyle = particle.color;
    ctx.beginPath();
    ctx.arc(particle.x, particle.y, particle.radius * (1 - progress * 0.45), 0, TAU);
    ctx.fill();
  }
  ctx.globalAlpha = 1;
}

function frame(now) {
  const dt = Math.min(0.033, (now - state.lastTime) / 1000 || 0);
  state.lastTime = now;
  if (!state.paused && !state.awaitingUpgrade && !state.levelComplete) {
    update(dt);
  }
  updateAudioScene(dt);
  renderPlayfield();
  requestAnimationFrame(frame);
}

function updatePointer(event) {
  const rect = canvas.getBoundingClientRect();
  pointer.active = true;
  pointer.x = event.clientX - rect.left;
  pointer.y = event.clientY - rect.top;
}

window.addEventListener("resize", resize);
window.addEventListener("orientationchange", () => window.setTimeout(resize, 80));
window.visualViewport?.addEventListener("resize", resize);
window.visualViewport?.addEventListener("scroll", resize);
window.addEventListener("pointerdown", unlockMenuAudio, { capture: true });
window.addEventListener("touchstart", unlockMenuAudio, { capture: true, passive: true });
document.addEventListener(
  "touchmove",
  (event) => {
    if (event.scale && event.scale !== 1) event.preventDefault();
  },
  { passive: false },
);
document.addEventListener(
  "touchend",
  (event) => {
    const now = Date.now();
    if (now - lastTouchEndAt < 350) event.preventDefault();
    lastTouchEndAt = now;
  },
  { passive: false },
);
for (const gestureEvent of ["gesturestart", "gesturechange", "gestureend"]) {
  document.addEventListener(gestureEvent, (event) => event.preventDefault(), { passive: false });
}

window.addEventListener("keydown", (event) => {
  unlockMenuAudio();
  ensureAudio();

  if (state.levelComplete || state.ended) {
    blockOverlayKeyboard(event);
    return;
  }

  if (event.code === "Escape" || event.code === "KeyP") {
    if (state.running && !state.ended) {
      event.preventDefault();
      togglePaused();
    }
    return;
  }

  if (state.awaitingUpgrade) {
    const target = event.target;
    const isUpgradeControl =
      target instanceof HTMLButtonElement && upgradeOverlay.contains(target);
    if (!isUpgradeControl) event.preventDefault();
    return;
  }

  if (state.paused) {
    const target = event.target;
    const isPauseControl = target === pauseButton || pauseOverlay.contains(target);
    if (!isPauseControl) event.preventDefault();
    return;
  }

  if (
    event.code.startsWith("Arrow") ||
    event.code === "Space" ||
    event.code === "ShiftLeft" ||
    event.code === "ShiftRight" ||
    event.code === "KeyE" ||
    event.code === "KeyQ" ||
    event.code === "Enter" ||
    event.code === "NumpadEnter" ||
    event.code === "KeyW" ||
    event.code === "KeyA" ||
    event.code === "KeyS" ||
    event.code === "KeyD"
  ) {
    event.preventDefault();
    keys.add(event.code);
  }

  if (!state.running && !state.ended && (event.code === "Space" || event.code === "Enter")) {
    resetGame();
  }
});

window.addEventListener("keyup", (event) => {
  keys.delete(event.code);
});

window.addEventListener("blur", () => {
  keys.clear();
  pointer.down = false;
  resetHeldActionInputs();
});

canvas.addEventListener("pointermove", updatePointer);
canvas.addEventListener("pointerdown", (event) => {
  ensureAudio();
  updatePointer(event);
  if (state.ended || state.paused || state.awaitingUpgrade || state.levelComplete) {
    pointer.down = false;
    return;
  }
  pointer.down = true;
  canvas.setPointerCapture(event.pointerId);
  if (!state.running) resetGame();
  fireShot();
});

canvas.addEventListener("pointerup", (event) => {
  pointer.down = false;
  if (canvas.hasPointerCapture(event.pointerId)) {
    canvas.releasePointerCapture(event.pointerId);
  }
});

canvas.addEventListener("pointerleave", () => {
  pointer.down = false;
});

function startRunFromUi(event) {
  event?.preventDefault();
  event?.stopPropagation();
  if (event?.currentTarget === gameOverRestartButton) {
    if (isGameOverInputLocked() || !isOnScreenButtonActivation(event)) return;
  }
  ensureAudio();
  requestMobileFullscreen();

  const now = performance.now();
  if (now - state.lastUiStart < 120) return;
  state.lastUiStart = now;
  resetGame();
}

startButton.addEventListener("click", startRunFromUi);
startButton.addEventListener("pointerdown", startRunFromUi);
gameOverRestartButton.addEventListener("pointerdown", armOnScreenButton);
gameOverRestartButton.addEventListener("click", startRunFromUi);
pauseButton.addEventListener("click", togglePaused);
resumeButton.addEventListener("click", () => setPaused(false));
musicMuteButton?.addEventListener("click", toggleMusicMuted);
sfxMuteButton?.addEventListener("click", toggleSfxMuted);
restartButton.addEventListener("click", requestRestartRun);
cancelRestartButton.addEventListener("click", cancelRestartRun);
confirmRestartButton.addEventListener("click", confirmRestartRun);
showUpgradeButton.addEventListener("pointerdown", armOnScreenButton);
showUpgradeButton.addEventListener("click", showUpgradeTree);
for (const card of upgradeCards) {
  card.addEventListener("pointerenter", () => {
    if (!card.disabled) playUpgradeHoverSfx();
  });
  card.addEventListener("focus", () => {
    if (!card.disabled) playUpgradeHoverSfx();
  });
  card.addEventListener("click", () => chooseUpgrade(card.dataset.upgrade));
}
bindMobileControls();

phaserRenderer = createPhaserRenderer();
resize();
renderUpgradeCards();
updateMuteButtons();
resetGame();
state.running = false;
state.paused = false;
state.awaitingUpgrade = false;
state.levelComplete = false;
overlay.hidden = false;
levelCompleteOverlay.hidden = true;
upgradeOverlay.hidden = true;
syncPauseUi();
requestAnimationFrame(frame);
