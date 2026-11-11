# Brief

**Question:** Build a simple snake game in Godot 4.4.1 (GDScript) in app/ that plays like the classic Snake: grid movement, arrow-key steering, food, growth, speed-up, wall/self collision, score.

**Purpose:** The person asked for 'a simple snake game'. No target program was supplied (capture/README.md: 'No target - Build from the request alone.'), so the reference is the classic Snake arcade/Nokia lineage.

**Targets:**
- D:\Snake Game (workspace)
- app/ (new Godot project)

**Constraints:**
- No target to reverse engineer: capture/README.md says 'No target - Build from the request alone.'
- Godot 4.4.1 stable win64, GDScript, config_version=5, run/main_scene set
- Change files only inside app/
- Must support --screenshot <file.png> and --self-test <file.json>
- No dev servers or watchers

**Done when:** Godot imports and runs headless with no SCRIPT ERROR/ERROR lines; --screenshot writes a non-blank PNG; --self-test writes move/act/hud steps that all pass; rebuild_check reports a pass; MECHANICS.md and mechanics.json agree with the code.
