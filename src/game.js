const canvas = document.querySelector("#game");
const ctx = canvas.getContext("2d");
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
const restartButton = document.querySelector("#restartButton");
const restartConfirm = document.querySelector("#restartConfirm");
const cancelRestartButton = document.querySelector("#cancelRestartButton");
const confirmRestartButton = document.querySelector("#confirmRestartButton");
const levelCompleteOverlay = document.querySelector("#levelCompleteOverlay");
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

const TAU = Math.PI * 2;
const keys = new Set();
const pointer = {
  active: false,
  down: false,
  x: 0,
  y: 0,
};

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
    virusPop: {
      src: "./assets/audio/Virus%20pop.wav",
      volume: 0.58,
      poolSize: 6,
    },
  },
};

const audio = {
  context: null,
  master: null,
  assetsReady: false,
  unlocked: false,
  music: {},
  ambience: {},
  sfx: {},
  activeMusicKey: null,
  musicFadeSpeed: 1.8,
  sfxMasterVolume: 0.95,
};

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
  levelComplete: false,
  awaitingUpgrade: false,
  bossSpawned: false,
  bossDefeated: false,
  bossTriggerProgress: 0.85,
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
    hp: 34,
    score: 650,
    color: "#d262e8",
    core: "#ff4f9a",
    damage: 26,
    targetXRatio: 0.73,
    attackInterval: 2.45,
    shadowBlur: 34,
  },
  adenovirusMini: {
    displayName: "Adenovirus Prism",
    spriteGroup: "adenovirusMini",
    radius: 58,
    hp: 18,
    score: 360,
    color: "#b566ff",
    core: "#f8b9ff",
    damage: 20,
    targetXRatio: 0.68,
    attackInterval: 2.1,
    shadowBlur: 28,
  },
  filovirusBoss: {
    displayName: "Filovirus Ribbon",
    spriteGroup: "filovirusBoss",
    radius: 74,
    hp: 38,
    score: 720,
    color: "#4af7d5",
    core: "#8bff5d",
    damage: 24,
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

function rand(min, max) {
  return min + Math.random() * (max - min);
}

function clamp(value, min, max) {
  return Math.max(min, Math.min(max, value));
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
  if (state.awaitingUpgrade || state.levelComplete) return "upgrade";
  if (!state.running || state.ended) return "menu";
  if (state.paused) return audio.activeMusicKey || "combat";
  if (isBossMission() && (state.bossSpawned || getActiveBoss())) return "boss";
  return "combat";
}

function updateAudioScene(dt = 0.016) {
  if (!audio.assetsReady || !audio.unlocked) return;

  const musicKey = getDesiredMusicKey();
  if (!state.paused && musicKey) {
    audio.activeMusicKey = musicKey;
  }
  const pauseScale = state.paused ? 0.34 : 1;
  for (const [key, track] of Object.entries(audio.music)) {
    updateLoopTrack(track, key === musicKey ? track.baseVolume * pauseScale : 0, dt);
  }

  const playAmbience = state.running && !state.ended && !state.awaitingUpgrade && !state.levelComplete;
  const ambienceTrack = audio.ambience.bloodstream;
  if (ambienceTrack) {
    updateLoopTrack(ambienceTrack, playAmbience ? ambienceTrack.baseVolume * pauseScale : 0, dt);
  }
}

function unlockMenuAudio() {
  const menuVisible = !overlay.hidden && !state.running && !state.awaitingUpgrade && !state.levelComplete;
  if (!menuVisible) return;
  ensureAudio();
  updateAudioScene(0);
}

function playAssetSfx(name, fallback) {
  prepareAudioAssets();
  const sfx = audio.sfx[name];
  if (!audio.unlocked || !sfx) {
    fallback?.();
    return;
  }

  const element = sfx.pool[sfx.index];
  sfx.index = (sfx.index + 1) % sfx.pool.length;
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
}

function playTone({ type = "sine", start = 440, end = start, duration = 0.12, gain = 0.08 }) {
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

function playUpgradeSfx() {
  playTone({ type: "triangle", start: 360, end: 920, duration: 0.2, gain: 0.11 });
  playTone({ type: "sine", start: 680, end: 1320, duration: 0.16, gain: 0.07 });
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

function distance(a, b) {
  const dx = a.x - b.x;
  const dy = a.y - b.y;
  return Math.hypot(dx, dy);
}

function resize() {
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
  if (level <= 5) return 1;
  return Math.pow(1.18, level - 5);
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
  pointer.down = false;
  keys.clear();
  resetHeldActionInputs();
  state.viruses = [];
  state.platelets = [];
  state.shots = [];
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
  levelCompleteOverlay.hidden = false;
  upgradeOverlay.hidden = true;
  syncPauseUi();
  showUpgradeButton.focus();
}

function openUpgradeMenu() {
  state.awaitingUpgrade = true;
  state.levelComplete = false;
  state.levelTransitionTimer = 0;
  pointer.down = false;
  keys.clear();
  resetHeldActionInputs();
  state.viruses = [];
  state.platelets = [];
  state.shots = [];
  state.lockTarget = null;
  const nextMission = getMission(state.level + 1);
  upgradeIntroEl.textContent = `Section ${state.level} cleared. Prepare for ${nextMission.name}: ${nextMission.term}.`;
  renderUpgradeCards();
  levelCompleteOverlay.hidden = true;
  upgradeOverlay.hidden = false;
  syncPauseUi();
  upgradePanelEl.focus({ preventScroll: true });
}

function showUpgradeTree() {
  if (!state.levelComplete) return;
  state.levelComplete = false;
  levelCompleteOverlay.hidden = true;
  openUpgradeMenu();
}

function resetHeldActionInputs() {
  state.dashInputHeld = false;
  state.pulseInputHeld = false;
  if (state.player) {
    state.player.horizontalSoundInput = 0;
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
  pauseOverlay.hidden = !state.paused;
  pauseButton.hidden =
    !state.running || state.ended || state.awaitingUpgrade || state.levelComplete;
  pauseButton.classList.toggle("is-active", state.paused);
  pauseButton.setAttribute("aria-pressed", String(state.paused));
  pauseButton.setAttribute("aria-label", state.paused ? "Resume" : "Pause");
  pauseButtonText.textContent = state.paused ? "Resume" : "Pause";
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
    resumeButton.focus();
  } else if (state.running && !state.ended) {
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
}

function confirmRestartRun() {
  setRestartConfirmOpen(false);
  resetGame();
}

function formatRunTime(seconds) {
  const wholeSeconds = Math.max(0, Math.floor(seconds));
  const minutes = Math.floor(wholeSeconds / 60);
  const remainingSeconds = wholeSeconds % 60;
  return `${minutes}:${String(remainingSeconds).padStart(2, "0")}`;
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
  state.influenzaNoticeTimer = 0;
  state.bossSpawned = false;
  state.bossDefeated = false;
  state.bossTriggerProgress = 0.85;
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
  state.shots = [];
  state.viruses = [];
  state.redCells = [];
  state.platelets = [];
  state.particles = [];
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
  overlay.hidden = true;
  gameOverOverlay.hidden = true;
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
  if (boss) {
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
    getLiveInfluenzaViruses().length >= getInfluenzaCap()
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
  const bossHp = Math.ceil(profile.hp * (1 + Math.max(0, difficulty - 1) * 0.68));
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

function updatePoxBoss(boss, dt) {
  const healthRatio = clamp(boss.hp / boss.maxHp, 0, 1);
  const nextPhase = healthRatio > 0.72 ? 0 : healthRatio > 0.48 ? 1 : healthRatio > 0.22 ? 2 : 3;
  if (nextPhase > boss.phase) {
    boss.phase = nextPhase;
    state.shake = Math.max(state.shake, 0.2 + nextPhase * 0.04);
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
  state.viruses = [];
  state.platelets = [];
  state.shots = [];
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

  state.shots.push({
    x: player.x + shotDirection.x * muzzle,
    y: player.y + shotDirection.y * muzzle,
    vx: shotDirection.x * shotSpeed + player.vx * 0.18,
    vy: shotDirection.y * shotSpeed + player.vy * 0.18,
    radius: 4.2,
    hitRadius: 6.8 + rapidRank * 0.4,
    life: Math.max(2.1, screenTravelLife),
    damage: rapidRank >= 3 ? 3 : 2,
    target: aim.target,
    age: 0,
    frameIndex: randomFrameIndex("antibody"),
  });

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
    state.particles.push({
      x,
      y,
      vx: Math.cos(angle) * speed,
      vy: Math.sin(angle) * speed,
      radius: rand(1.4, 4.2),
      life: rand(0.18, 0.6),
      ttl: 0,
      color,
    });
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
  playVirusPopSfx();
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
  playSwimSurgeSfx(dx >= 0 ? 1 : -1);
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

  for (const virus of [...state.viruses]) {
    if (virus.dead) continue;
    const dist = distance(player, virus);
    if (dist > radius + virus.radius) continue;
    virus.hp -= damage;
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
    if (distance(player, platelet) < radius + platelet.radius) {
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
  const horizontalInput =
    (keys.has("ArrowRight") || keys.has("KeyD") ? 1 : 0) -
    (keys.has("ArrowLeft") || keys.has("KeyA") ? 1 : 0);
  const verticalInput =
    (keys.has("ArrowDown") || keys.has("KeyS") ? 1 : 0) -
    (keys.has("ArrowUp") || keys.has("KeyW") ? 1 : 0);

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

  if (horizontalInput !== 0 && (player.horizontalSoundInput ?? 0) !== horizontalInput) {
    playSwimSurgeSfx(horizontalInput);
  }
  player.horizontalSoundInput = horizontalInput;

  const visualAim = getVisualAimPoint();
  const desiredAimAngle = Math.atan2(visualAim.y - player.y, visualAim.x - player.x);
  player.aimAngle = lerpAngle(player.aimAngle, desiredAimAngle, clamp(dt * 5.8, 0, 0.16));

  if (keys.has("Space") || pointer.down) fireShot();
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

  if (bossTriggerReached && !state.bossSpawned) {
    state.viruses = [];
    state.shots = [];
    state.lockTarget = null;
    spawnBoss(mission.bossType);
    state.bossSpawned = true;
    state.nextVirus = 1.6;
    state.nextPlatelet = 5.8;
  }

  if ((!encounterActive || !state.bossSpawned) && state.nextVirus <= 0) {
    spawnVirus();
    state.nextVirus = rand(0.78, 1.35) * levelConfig.spawnScale;
  }

  if (state.nextRedCell <= 0) {
    spawnRedCell();
    state.nextRedCell = rand(0.45, 0.9);
  }

  if (state.nextPlatelet <= 0) {
    spawnPlatelet();
    state.nextPlatelet = rand(4.4, 7.2) * Math.max(0.72, levelConfig.spawnScale);
  }
}

function updateShots(dt) {
  for (const shot of state.shots) {
    if (isLockableVirus(shot.target)) {
      const dx = shot.target.x - shot.x;
      const dy = shot.target.y - shot.y;
      const length = Math.hypot(dx, dy) || 1;
      const speed = Math.min(760, Math.max(620, Math.hypot(shot.vx, shot.vy) + 22));
      const turn = clamp(dt * 9.5, 0, 0.2);
      shot.vx = lerp(shot.vx, (dx / length) * speed, turn);
      shot.vy = lerp(shot.vy, (dy / length) * speed, turn);
    }

    shot.x += shot.vx * dt;
    shot.y += shot.vy * dt;
    shot.life -= dt;
    shot.age += dt;
  }
  state.shots = state.shots.filter(
    (shot) =>
      shot.life > 0 &&
      shot.x < state.width + 100 &&
      shot.x > -100 &&
      shot.y > -100 &&
      shot.y < state.height + 100,
  );
}

function getInfluenzaCap() {
  if (state.level < 4) return 0;
  return Math.min(30, 12 + Math.max(0, state.level - 4) * 3);
}

function getLiveInfluenzaViruses() {
  return state.viruses.filter(
    (virus) => virus.type === "influenza" && !virus.dead && virus.hp > 0,
  );
}

function nudgeInfluenzaTowardNearest(virus, dt) {
  let nearest = null;
  let nearestDist = Infinity;

  for (const other of state.viruses) {
    if (other === virus || other.type !== "influenza" || other.dead || other.hp <= 0) continue;
    const dist = distance(virus, other);
    if (dist < nearestDist && dist < 290) {
      nearest = other;
      nearestDist = dist;
    }
  }

  if (!nearest || nearestDist <= 1) return;

  const spreadResistance = virus.spreadTimer > 0 ? 0.35 : 1;
  const pull = 28 * spreadResistance * dt * (1 - clamp(nearestDist / 290, 0, 1));
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
  const influenza = getLiveInfluenzaViruses();
  const cap = getInfluenzaCap();
  if (influenza.length < 2 || influenza.length + 2 > cap) return;

  for (let i = 0; i < influenza.length - 1; i += 1) {
    const first = influenza[i];
    if (first.replicateCooldown > 0) continue;

    for (let j = i + 1; j < influenza.length; j += 1) {
      const second = influenza[j];
      if (second.replicateCooldown > 0) continue;
      if (distance(first, second) > (first.radius + second.radius) * 1.42) continue;

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
  const influenza = getLiveInfluenzaViruses();
  for (let i = 0; i < influenza.length - 1; i += 1) {
    const first = influenza[i];
    for (let j = i + 1; j < influenza.length; j += 1) {
      const second = influenza[j];
      const minDist = (first.radius + second.radius) * 1.04;
      const dist = distance(first, second);
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

  state.viruses = state.viruses.filter(
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

  state.redCells = state.redCells.filter((cell) => cell.x > -cell.radius * 2);
}

function updatePlatelets(dt, worldSpeed) {
  for (const platelet of state.platelets) {
    platelet.x -= (platelet.speed + worldSpeed * 0.3) * dt;
    platelet.angle += platelet.spin * dt;
  }

  state.platelets = state.platelets.filter((platelet) => platelet.x > -platelet.radius * 3);
}

function updateParticles(dt) {
  for (const particle of state.particles) {
    particle.ttl += dt;
    particle.x += particle.vx * dt;
    particle.y += particle.vy * dt;
    particle.vx *= Math.pow(0.03, dt);
    particle.vy *= Math.pow(0.03, dt);
  }

  state.particles = state.particles.filter((particle) => particle.ttl < particle.life);
}

function getVirusCollisionRadius(virus) {
  if (virus.type === "poxBoss") return virus.radius * 1.62;
  if (virus.type === "filovirusBoss") return virus.radius * 1.9;
  if (virus.type === "adenovirusMini") return virus.radius * 1.3;
  return virus.radius;
}

function applyShotHit(virus, shot) {
  if (virus.type === "adenovirusMini" && !virus.shieldOpen) {
    virus.hit = 0.18;
    shot.life = -1;
    state.shake = Math.max(state.shake, 0.08);
    playAntibodyHitSfx();
    addParticleBurst(shot.x, shot.y, "#9ff8ff", 8, 92);
    return;
  }

  virus.hp -= shot.damage;
  virus.hit = 0.12;
  shot.life = -1;
  addParticleBurst(shot.x, shot.y, palette.cyan, isBossVirus(virus) ? 14 : 9, 95);
  if (virus.hp <= 0) {
    destroyVirus(virus);
  } else {
    playAntibodyHitSfx();
  }
}

function checkCollisions() {
  const player = state.player;

  for (const shot of state.shots) {
    for (const virus of state.viruses) {
      if (virus.dead) continue;
      if (distance(shot, virus) < (shot.hitRadius ?? shot.radius) + getVirusCollisionRadius(virus)) {
        applyShotHit(virus, shot);
        break;
      }
    }
  }

  state.shots = state.shots.filter((shot) => shot.life > 0);

  for (const virus of state.viruses) {
    if (virus.dead) continue;
    if (distance(player, virus) < player.radius * 0.82 + getVirusCollisionRadius(virus) * 0.66) {
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
    if (distance(player, platelet) < player.radius + platelet.radius * 0.86) {
      hurtPlayer(18, platelet.x, platelet.y, palette.platelet);
      platelet.x = -999;
    }
  }
}

function hurtPlayer(amount, x, y, color, soft = false) {
  const player = state.player;
  if (player.invulnerable > 0 && !soft) return;
  if (soft && player.hurtTimer > 0) return;

  const previousHealth = player.health;
  player.health = Math.max(0, player.health - amount);
  state.stats.damageTaken += previousHealth - player.health;
  player.hurtTimer = soft ? 0.35 : 0.7;
  player.invulnerable = soft ? player.invulnerable : 0.55;
  addParticleBurst(x, y, color, soft ? 4 : 16, soft ? 55 : 150);
  if (!soft) playPlayerDamageSfx();

  if (player.health <= 0) {
    endGame();
  }
}

function endGame() {
  state.running = false;
  state.ended = true;
  state.paused = false;
  state.awaitingUpgrade = false;
  state.levelComplete = false;
  overlay.hidden = true;
  gameOverOverlay.hidden = false;
  pauseOverlay.hidden = true;
  levelCompleteOverlay.hidden = true;
  upgradeOverlay.hidden = true;
  renderGameOverSummary();
  syncPauseUi();
  gameOverRestartButton.focus();
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
      ctx.drawImage(image, 0, 0, drawWidth, drawHeight);
      ctx.restore();
    } else {
      ctx.drawImage(image, x, y, drawWidth, drawHeight);
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
    ctx.save();
    ctx.translate(player.x, player.y);
    ctx.rotate(aimAngle);
    ctx.shadowColor = palette.cyan;
    ctx.shadowBlur = 14;
    ctx.strokeStyle = "rgba(170, 255, 255, 0.82)";
    ctx.lineWidth = 2.6;
    ctx.lineCap = "round";
    ctx.beginPath();
    ctx.arc(player.radius * 1.18, 0, 6 + Math.sin(state.time * 8) * 0.9, -0.75, 0.75);
    ctx.stroke();
    ctx.restore();
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

  ctx.strokeStyle = "rgba(96, 239, 255, 0.7)";
  ctx.lineWidth = 3;
  ctx.beginPath();
  ctx.arc(player.radius * 0.9, 0, 10 + Math.sin(state.time * 8) * 1.4, -0.78, 0.78);
  ctx.stroke();

  ctx.restore();
}

function drawShots() {
  for (const shot of state.shots) {
    const angle = Math.atan2(shot.vy, shot.vx);
    const pulse = 1 + Math.sin((shot.age || 0) * 22) * 0.06;
    const scale = pulse * 1.18;

    ctx.save();
    ctx.translate(shot.x, shot.y);
    ctx.rotate(angle);
    ctx.shadowColor = palette.cyan;
    ctx.shadowBlur = 8;
    ctx.globalAlpha = 0.34;
    ctx.strokeStyle = "rgba(96, 239, 255, 0.62)";
    ctx.lineWidth = 2.2;
    ctx.lineCap = "round";
    ctx.beginPath();
    ctx.moveTo(-24, 0);
    ctx.lineTo(-9, 0);
    ctx.stroke();

    ctx.scale(scale, scale);
    ctx.globalAlpha = 0.5;
    ctx.strokeStyle = "rgba(96, 239, 255, 0.88)";
    ctx.lineWidth = 6;
    ctx.beginPath();
    ctx.moveTo(-8, 0);
    ctx.lineTo(2.5, 0);
    ctx.moveTo(2.5, 0);
    ctx.lineTo(12, -6);
    ctx.moveTo(2.5, 0);
    ctx.lineTo(12, 6);
    ctx.stroke();

    ctx.globalAlpha = 0.92;
    ctx.strokeStyle = "rgba(176, 255, 255, 0.96)";
    ctx.lineWidth = 2.8;
    ctx.beginPath();
    ctx.moveTo(-8, 0);
    ctx.lineTo(2.5, 0);
    ctx.moveTo(2.5, 0);
    ctx.lineTo(12, -6);
    ctx.moveTo(2.5, 0);
    ctx.lineTo(12, 6);
    ctx.stroke();

    ctx.globalAlpha = 1;
    ctx.fillStyle = "#dfffff";
    ctx.beginPath();
    ctx.arc(12, -6, 1.5, 0, TAU);
    ctx.arc(12, 6, 1.5, 0, TAU);
    ctx.fill();
    ctx.restore();
  }
}

function drawParticles() {
  for (const particle of state.particles) {
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
  draw();
  requestAnimationFrame(frame);
}

function updatePointer(event) {
  const rect = canvas.getBoundingClientRect();
  pointer.active = true;
  pointer.x = event.clientX - rect.left;
  pointer.y = event.clientY - rect.top;
}

window.addEventListener("resize", resize);
window.addEventListener("pointerdown", unlockMenuAudio, { capture: true });
window.addEventListener("touchstart", unlockMenuAudio, { capture: true, passive: true });

window.addEventListener("keydown", (event) => {
  unlockMenuAudio();
  ensureAudio();

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

  if (state.levelComplete) {
    const target = event.target;
    const isCompleteControl =
      target instanceof HTMLButtonElement && levelCompleteOverlay.contains(target);
    if (!isCompleteControl) event.preventDefault();
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

  if (!state.running && (event.code === "Space" || event.code === "Enter")) {
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
  if (state.paused || state.awaitingUpgrade || state.levelComplete) {
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
  ensureAudio();

  const now = performance.now();
  if (now - state.lastUiStart < 120) return;
  state.lastUiStart = now;
  resetGame();
}

startButton.addEventListener("click", startRunFromUi);
startButton.addEventListener("pointerdown", startRunFromUi);
gameOverRestartButton.addEventListener("click", startRunFromUi);
pauseButton.addEventListener("click", togglePaused);
resumeButton.addEventListener("click", () => setPaused(false));
restartButton.addEventListener("click", requestRestartRun);
cancelRestartButton.addEventListener("click", () => setRestartConfirmOpen(false));
confirmRestartButton.addEventListener("click", confirmRestartRun);
showUpgradeButton.addEventListener("click", showUpgradeTree);
for (const card of upgradeCards) {
  card.addEventListener("click", () => chooseUpgrade(card.dataset.upgrade));
}

resize();
renderUpgradeCards();
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
