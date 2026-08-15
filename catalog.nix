/**
  The registry of tracked mods/plugins: which Modrinth projects `update.py`
  should keep locked, and for which loaders. This file is hand-maintained —
  add an entry here, then run `./update.py` to populate/refresh
  `mods/<loader>/<name>.json`.

  Schema per entry:
    project: Modrinth project ID or slug (ID is more stable across renames)
    loaders: loaders to lock versions for, e.g. [ "fabric" ] or [ "fabric" "velocity" ]
*/
{
  # server utilities / core
  FabricProxy-Lite = {
    project = "8dI2tmqs";
    loaders = [ "fabric" ];
  };
  fabric-api = {
    project = "P7dR8mSH";
    loaders = [ "fabric" ];
  };
  jline4mcdsrv = {
    project = "9mnPo3ZV";
    loaders = [ "fabric" ];
  };
  spark = {
    project = "l6YH9Als";
    loaders = [ "fabric" ];
  };

  # discord integration
  SDlink = {
    project = "Sh0YauEf";
    loaders = [ "fabric" ];
  };
  craterlib = {
    project = "Nn8Wasaq";
    loaders = [ "fabric" ];
  };

  # optimizations
  lithium = {
    project = "gvQqBUqZ";
    loaders = [ "fabric" ];
  };
  async = {
    project = "vEC2jm6I";
    loaders = [ "fabric" ];
  };
  serverCore = {
    project = "4WWQxlQP";
    loaders = [ "fabric" ];
  };
  ferriteCore = {
    project = "uXXizFIs";
    loaders = [ "fabric" ];
  };
  CCME = {
    project = "VSNURh3q";
    loaders = [ "fabric" ];
  };
  scalableLux = {
    project = "Ps1zyz6x";
    loaders = [ "fabric" ];
  };

  # management mods
  worldedit = {
    project = "1u6JkXh5";
    loaders = [ "fabric" ];
  };
  invSee = {
    project = "jrDKjZP7";
    loaders = [ "fabric" ];
  };
  vanish = {
    project = "UL4bJFDY";
    loaders = [ "fabric" ];
  };

  # anti-cheat
  ledger = {
    project = "LVN9ygNV";
    loaders = [ "fabric" ];
  };
  kotlin = {
    project = "Ha28R6CL";
    loaders = [ "fabric" ];
  };
  antiXray = {
    project = "sml2FMaA";
    loaders = [ "fabric" ];
  };
  grimAC = {
    project = "LJNGWSvH";
    loaders = [ "fabric" ];
  };

  # voice chat mods (ships for both the fabric server and the velocity proxy)
  simple-voice-chat = {
    project = "9eGKb6K1";
    loaders = [
      "fabric"
      "velocity"
    ];
  };
  voice-chat-interactions = {
    project = "qsSP2ZZ0";
    loaders = [ "fabric" ];
  };
  audioPlayer = {
    project = "SRlzjEBS";
    loaders = [ "fabric" ];
  };

  # QOL mods
  PerfectAccuracy = {
    project = "ochFsQSn";
    loaders = [ "fabric" ];
  };
  image2map = {
    project = "13RpG7dA";
    loaders = [ "fabric" ];
  };
  sit = {
    project = "EsYqsGV4";
    loaders = [ "fabric" ];
  };
  otter = {
    project = "zVVpzurY";
    loaders = [ "fabric" ];
  };
  ouch = {
    project = "nbxqFJCy";
    loaders = [ "fabric" ];
  };
  survival-debug-mod = {
    project = "9rVMDWPD";
    loaders = [ "fabric" ];
  };

  # gameplay changes
  mobheads = {
    project = "82uI0waE";
    loaders = [ "fabric" ];
  };

  # --- broader catalog: not currently deployed by any host, tracked so
  # they're available (with full version history) the next time a server
  # config wants them, without a manifest edit + `update.py` round trip. ---

  # permissions / crossplay (also ship velocity builds, useful on the proxy)
  luckperms = {
    project = "Vebnzrzj";
    loaders = [
      "fabric"
      "velocity"
    ];
  };
  geyser = {
    project = "wKkoqHrH";
    loaders = [
      "fabric"
      "velocity"
    ];
  };
  floodgate = {
    project = "bWrNNfkb";
    loaders = [ "fabric" ]; # Modrinth doesn't publish a velocity-loader build of this one
  };

  # performance
  krypton = {
    project = "fQEb0iXm";
    loaders = [ "fabric" ];
  };
  noisium = {
    project = "KuNKN7d2";
    loaders = [ "fabric" ];
  };

  # security / anti-exploit
  badpackets = {
    project = "ftdbN0KK";
    loaders = [ "fabric" ];
  };

  # server utilities
  chunky = {
    project = "fALzjamp";
    loaders = [ "fabric" ];
  };
  tab = {
    project = "9J38edBm";
    loaders = [ "fabric" ];
  };
  waystones = {
    project = "LOpKHB2A";
    loaders = [ "fabric" ];
  };
  fallingtree = {
    project = "Fb4jn8m6";
    loaders = [ "fabric" ];
  };

  # common library dependencies (several gameplay mods require these)
  cardinal-components-api = {
    project = "K01OU20C";
    loaders = [ "fabric" ];
  };
  trinkets = {
    project = "5aaWibi9";
    loaders = [ "fabric" ];
  };

  # `carpet` is intentionally NOT here: it ships from GitHub releases, not
  # Modrinth, so it falls outside this database and stays a plain `fetchurl`
  # in the consuming flake.
}
