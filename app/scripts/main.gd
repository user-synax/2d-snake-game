extends Node2D

## Classic Snake.
##
## The board is a 20 x 20 grid of 20 px cells. The snake moves one cell per tick,
## starting at 5 ticks per second and getting faster as it eats. Arrow keys (or
## WASD) steer it; eating food scores 10 and makes it longer; a wall or its own
## body ends the game.
##
## Command line options Craft Anything uses:
##   --screenshot <file.png>  play, draw ~110 frames, save the picture, exit.
##   --self-test <file.json>  play with scripted input, measure the core loop, exit.

const Snake := preload("res://scripts/snake_game.gd")

const WINDOW_W := 480
const WINDOW_H := 512
const HUD_H := 48
const BOARD_X := 40
const BOARD_Y := 56
const CELL := 20

## Frame the picture is taken on, so the game has been drawn a while.
const SHOT_FRAME := 110
## Frames drawn before the picture, when the game is told to quit early.
const SHOT_FRAME_MIN := 20

const COL_BG := Color(0.0666667, 0.0901961, 0.1137255)
const COL_BOARD := Color(0.0901961, 0.1215686, 0.1411765)
const COL_GRID := Color(0.145098, 0.184314, 0.2078431)
const COL_BODY := Color(0.356863, 0.784314, 0.443137)
const COL_HEAD := Color(0.639216, 0.898039, 0.643137)
const COL_FOOD := Color(0.898039, 0.27451, 0.298039)
const COL_TEXT := Color(0.815686, 0.945098, 0.815686)

var game: Snake
var frame := 0
var step_accum := 0.0
var dead := false
var self_test_mode := false
var shot_path := ""
var test_path := ""
var shot_taken := false
var quit_after := 0

@onready var score_label: Label = $ScoreLabel
@onready var best_label: Label = $BestLabel
@onready var over_title: Label = $OverTitle
@onready var over_score: Label = $OverScore
@onready var over_hint: Label = $OverHint
@onready var over_panel: ColorRect = $OverPanel

func _ready() -> void:
	game = Snake.new()
	game.reset()
	_read_arguments()
	_update_hud()
	if test_path != "":
		self_test_mode = true
		_run_self_test(test_path)

func _process(delta: float) -> void:
	frame += 1
	if not self_test_mode:
		if not dead:
			step_accum += delta
			var interval := 1.0 / game.step_hz()
			while step_accum >= interval:
				step_accum -= interval
				if not game.step():
					_game_over()
					break
		_update_hud()
		queue_redraw()
	if shot_path != "" and not shot_taken and frame >= _shot_frame():
		shot_taken = true
		_save_picture(shot_path)

## The frame the picture is taken on. When the game is told to quit early the
## picture has to be taken before that, so it is still drawn.
func _shot_frame() -> int:
	if quit_after > 0:
		return maxi(SHOT_FRAME_MIN, quit_after - 10)
	return SHOT_FRAME

func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	var key := event as InputEventKey
	if dead:
		if key.keycode in [KEY_SPACE, KEY_ENTER, KEY_KP_ENTER, KEY_R]:
			_restart()
		return
	match key.keycode:
		KEY_UP:
			game.turn(Vector2i.UP)
		KEY_DOWN:
			game.turn(Vector2i.DOWN)
		KEY_LEFT:
			game.turn(Vector2i.LEFT)
		KEY_RIGHT:
			game.turn(Vector2i.RIGHT)
		KEY_W:
			game.turn(Vector2i.UP)
		KEY_S:
			game.turn(Vector2i.DOWN)
		KEY_A:
			game.turn(Vector2i.LEFT)
		KEY_D:
			game.turn(Vector2i.RIGHT)

## Reads the options from both the arguments after "--" and the plain ones, so
## it works however the game is started.
func _read_arguments() -> void:
	var args: Array = []
	args.append_array(OS.get_cmdline_user_args())
	args.append_array(OS.get_cmdline_args())
	for i in range(args.size() - 1):
		match args[i]:
			"--screenshot":
				shot_path = _out_path(str(args[i + 1]))
			"--self-test":
				test_path = _out_path(str(args[i + 1]))
			"--quit-after":
				quit_after = int(args[i + 1])

## Turns a path Craft Anything gave us into an absolute one we can write to.
## A path that starts with "app/" is relative to the folder above the project,
## anything else is relative to the project itself.
func _out_path(path: String) -> String:
	if path.is_absolute_path():
		return path
	var project := ProjectSettings.globalize_path("res://").trim_suffix("/")
	var root := project.get_base_dir()
	if path.begins_with("app/"):
		return root.path_join(path)
	return project.path_join(path)

func _restart() -> void:
	game.reset()
	dead = false
	step_accum = 0.0
	over_panel.visible = false
	over_title.visible = false
	over_score.visible = false
	over_hint.visible = false
	_update_hud()

func _game_over() -> void:
	dead = true
	over_score.text = "SCORE %d" % game.score
	over_panel.visible = true
	over_title.visible = true
	over_score.visible = true
	over_hint.visible = true

func _update_hud() -> void:
	score_label.text = "SCORE %d" % game.score
	best_label.text = "HI %d" % game.high_score

func _draw() -> void:
	draw_rect(Rect2(0, 0, WINDOW_W, WINDOW_H), COL_BG)
	draw_rect(Rect2(BOARD_X, BOARD_Y, CELL * Snake.COLS, CELL * Snake.ROWS), COL_BOARD)
	for x in range(Snake.COLS + 1):
		var gx := BOARD_X + x * CELL
		draw_line(Vector2(gx, BOARD_Y), Vector2(gx, BOARD_Y + CELL * Snake.ROWS), COL_GRID, 1.0)
	for y in range(Snake.ROWS + 1):
		var gy := BOARD_Y + y * CELL
		draw_line(Vector2(BOARD_X, gy), Vector2(BOARD_X + CELL * Snake.COLS, gy), COL_GRID, 1.0)
	if game.food.x >= 0:
		draw_rect(Rect2(BOARD_X + game.food.x * CELL + 4, BOARD_Y + game.food.y * CELL + 4, CELL - 8, CELL - 8), COL_FOOD)
	for i in range(game.body.size() - 1, -1, -1):
		var cell: Vector2i = game.body[i]
		var colour := COL_HEAD if i == 0 else COL_BODY
		draw_rect(Rect2(BOARD_X + cell.x * CELL + 1, BOARD_Y + cell.y * CELL + 1, CELL - 2, CELL - 2), colour)

## Saves the picture of the game. It uses the real window when there is one and
## draws the same picture by hand when the game runs without a screen.
func _save_picture(path: String) -> void:
	var img: Image = null
	if DisplayServer.get_name() != "headless":
		var tex := get_viewport().get_texture()
		if tex != null:
			img = tex.get_image()
	if img == null or img.is_empty():
		img = _draw_picture()
	var dir := path.get_base_dir()
	if dir != "":
		DirAccess.make_dir_recursive_absolute(dir)
	img.save_png(path)
	get_tree().quit()

## Draws the board into an image, for when there is no window to photograph.
func _draw_picture() -> Image:
	var img := Image.create_empty(WINDOW_W, WINDOW_H, false, Image.FORMAT_RGB8)
	img.fill(COL_BG)
	img.fill_rect(Rect2i(0, 0, WINDOW_W, HUD_H), COL_BG)
	var board_w := CELL * Snake.COLS
	var board_h := CELL * Snake.ROWS
	img.fill_rect(Rect2i(BOARD_X, BOARD_Y, board_w, board_h), COL_BOARD)
	for x in range(Snake.COLS + 1):
		img.fill_rect(Rect2i(BOARD_X + x * CELL, BOARD_Y, 1, board_h), COL_GRID)
	for y in range(Snake.ROWS + 1):
		img.fill_rect(Rect2i(BOARD_X, BOARD_Y + y * CELL, board_w, 1), COL_GRID)
	if game.food.x >= 0:
		img.fill_rect(Rect2i(BOARD_X + game.food.x * CELL + 4, BOARD_Y + game.food.y * CELL + 4, CELL - 8, CELL - 8), COL_FOOD)
	for i in range(game.body.size() - 1, -1, -1):
		var cell: Vector2i = game.body[i]
		var colour := COL_HEAD if i == 0 else COL_BODY
		img.fill_rect(Rect2i(BOARD_X + cell.x * CELL + 1, BOARD_Y + cell.y * CELL + 1, CELL - 2, CELL - 2), colour)
	_blit_text(img, "SCORE %d" % game.score, Vector2i(14, 8), 22, COL_TEXT)
	var hi := "HI %d" % game.high_score
	_blit_text(img, hi, Vector2i(466 - _text_width(hi, 22), 8), 22, COL_TEXT)
	return img

## Width of a piece of text in the font Godot ships with.
func _text_width(text: String, font_size: int) -> int:
	var font := ThemeDB.fallback_font
	if font == null:
		return 0
	return int(font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x)

## Writes text into an image with the font Godot ships with.
func _blit_text(img: Image, text: String, at: Vector2i, font_size: int, colour: Color) -> void:
	var font := ThemeDB.fallback_font
	if font == null:
		return
	var rids := font.get_rids()
	if rids.is_empty():
		return
	var ts := TextServerManager.get_primary_interface()
	var rid: RID = rids[0]
	var size := Vector2i(font_size, font_size)

	# Render every glyph first: the atlas only exists once a glyph is in it.
	var glyphs: Array = []
	for i in text.length():
		var code := text.unicode_at(i)
		ts.font_get_glyph_texture_idx(rid, size, code)
		glyphs.append({
			"advance": ts.font_get_glyph_advance(rid, font_size, code),
			"uv": ts.font_get_glyph_uv_rect(rid, size, code),
			"offset": ts.font_get_glyph_offset(rid, size, code),
			"size": ts.font_get_glyph_size(rid, size, code),
		})
	var atlas := ts.font_get_texture_image(rid, size, 0)
	if atlas == null:
		return

	var baseline := at.y + int(font.get_ascent(font_size))
	var pen := at.x
	for glyph in glyphs:
		var uv: Rect2 = glyph["uv"]
		var offset: Vector2 = glyph["offset"]
		var gsize: Vector2 = glyph["size"]
		for gy in range(int(gsize.y)):
			for gx in range(int(gsize.x)):
				var sx := int(uv.position.x) + gx
				var sy := int(uv.position.y) + gy
				if sx < 0 or sy < 0 or sx >= atlas.get_width() or sy >= atlas.get_height():
					continue
				var src := atlas.get_pixel(sx, sy)
				if src.a <= 0.01:
					continue
				var dx := pen + int(offset.x) + gx
				var dy := baseline + int(offset.y) + gy
				if dx < 0 or dy < 0 or dx >= img.get_width() or dy >= img.get_height():
					continue
				img.set_pixel(dx, dy, colour)
		pen += int(glyph["advance"].x)

## Plays the game with scripted input and writes down what worked.
func _run_self_test(path: String) -> void:
	var steps: Array = []

	var start_head := game.head()
	_press(KEY_DOWN)
	game.step()
	var moved_head := game.head()
	var moved_ok := moved_head != start_head and moved_head.y > start_head.y
	steps.append({
		"step": "move",
		"passed": moved_ok,
		"detail": "steered down: head went from %s to %s" % [str(start_head), str(moved_head)],
	})

	var start_score := game.score
	var start_length := game.length()
	var ate := false
	for i in range(400):
		var direction := _path_to_food()
		if direction != Vector2i.ZERO:
			_press_direction(direction)
		game.step()
		if game.score > start_score:
			ate = true
			break
	steps.append({
		"step": "act",
		"passed": ate,
		"detail": "ate food: score %d to %d, length %d to %d" % [start_score, game.score, start_length, game.length()],
	})

	_update_hud()
	var hud_ok := score_label.visible and score_label.text == "SCORE %d" % game.score \
		and best_label.visible and best_label.text == "HI %d" % game.high_score
	steps.append({
		"step": "hud",
		"passed": hud_ok,
		"detail": "score and best score are on screen: '%s' and '%s'" % [score_label.text, best_label.text],
	})

	var dir := path.get_base_dir()
	if dir != "":
		DirAccess.make_dir_recursive_absolute(dir)
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify({"version": 1, "steps": steps}, "  "))
		file.close()
	get_tree().quit()

## Sends a key to the game, the way a player would.
func _press(keycode: Key) -> void:
	var event := InputEventKey.new()
	event.keycode = keycode
	event.physical_keycode = keycode
	event.pressed = true
	Input.parse_input_event(event)
	Input.flush_buffered_events()

func _press_direction(direction: Vector2i) -> void:
	match direction:
		Vector2i.UP:
			_press(KEY_UP)
		Vector2i.DOWN:
			_press(KEY_DOWN)
		Vector2i.LEFT:
			_press(KEY_LEFT)
		Vector2i.RIGHT:
			_press(KEY_RIGHT)

## First step of the shortest path to the food that does not run into the body.
func _path_to_food() -> Vector2i:
	if game.food.x < 0:
		return Vector2i.ZERO
	var start := game.head()
	var goal: Vector2i = game.food
	var blocked := {}
	for cell in game.body:
		blocked[cell] = true
	var came := {start: start}
	var queue: Array[Vector2i] = [start]
	var found := false
	while not queue.is_empty() and not found:
		var current: Vector2i = queue.pop_front()
		if current == goal:
			found = true
			break
		for direction in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
			var next: Vector2i = current + direction
			if next.x < 0 or next.x >= Snake.COLS or next.y < 0 or next.y >= Snake.ROWS:
				continue
			if blocked.has(next) or came.has(next):
				continue
			came[next] = current
			queue.append(next)
	if not came.has(goal):
		return Vector2i.ZERO
	var step := goal
	while came[step] != start:
		step = came[step]
	return step - start
