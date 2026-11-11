extends RefCounted

## Rules and board state for classic Snake.
##
## The board is COLS x ROWS cells. The snake is a list of Vector2i cells where
## body[0] is the head and the last one is the tail. It moves one cell per tick.

const COLS := 20
const ROWS := 20
const CELL := 20

## Ticks per second at the start of a game, and the fastest it ever gets.
const START_STEP_HZ := 6.0
const MAX_STEP_HZ := 16.0
## Speed gained (in steps per second) for every 5 food eaten.
const SPEED_PER_5_FOOD := 1.0
## Food needed for the next speed step.
const FOOD_PER_SPEED_STEP := 5
## Points for one food.
const POINTS_PER_FOOD := 10
## Length the snake starts with.
const START_LENGTH := 3

var body: Array[Vector2i] = []
var direction := Vector2i.RIGHT
## Direction queued for the next tick, so quick turns are not swallowed.
var pending_direction := Vector2i.ZERO
var food := Vector2i.ZERO
var score := 0
var high_score := 0
var food_eaten := 0
var alive := true
var rng := RandomNumberGenerator.new()

func _init() -> void:
	rng.randomize()

func reset() -> void:
	body.clear()
	var start := Vector2i(COLS / 2 - 1, ROWS / 2)
	for i in START_LENGTH:
		body.append(start - Vector2i(i, 0))
	direction = Vector2i.RIGHT
	pending_direction = Vector2i.ZERO
	score = 0
	food_eaten = 0
	alive = true
	_place_food()

## Steps per second the snake moves at right now.
func step_hz() -> float:
	var steps := int(food_eaten / FOOD_PER_SPEED_STEP)
	return minf(START_STEP_HZ + steps * SPEED_PER_5_FOOD, MAX_STEP_HZ)

## Ask to turn. Reversing straight back is refused: that would be suicide.
func turn(new_direction: Vector2i) -> void:
	if new_direction == Vector2i.ZERO:
		return
	if new_direction == -direction:
		return
	pending_direction = new_direction

## Advance the snake one cell. Returns true while the snake is alive.
func step() -> bool:
	if pending_direction != Vector2i.ZERO:
		direction = pending_direction
		pending_direction = Vector2i.ZERO

	var head: Vector2i = body[0] + direction
	if head.x < 0 or head.x >= COLS or head.y < 0 or head.y >= ROWS:
		alive = false
		return false

	# The tail cell is free when the snake is not growing.
	var growing := head == food
	for i in range(body.size() - (0 if growing else 1)):
		if body[i] == head:
			alive = false
			return false

	body.insert(0, head)
	if growing:
		score += POINTS_PER_FOOD
		food_eaten += 1
		if score > high_score:
			high_score = score
		_place_food()
	else:
		body.remove_at(body.size() - 1)
	return true

func head() -> Vector2i:
	return body[0]

func length() -> int:
	return body.size()

func _place_food() -> void:
	var free: Array[Vector2i] = []
	for x in COLS:
		for y in ROWS:
			var cell := Vector2i(x, y)
			if not body.has(cell):
				free.append(cell)
	if free.is_empty():
		food = Vector2i(-1, -1)
		return
	food = free[rng.randi_range(0, free.size() - 1)]
