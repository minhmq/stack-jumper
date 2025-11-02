extends Node

## Game state manager singleton
## Manages score, game state machine, and broadcasts signals

signal score_changed(new_score: int)
signal best_changed(new_best: int)
signal state_changed(new_state: String)

enum GameState {
	MENU,
	PLAYING,
	PAUSED,
	GAME_OVER
}

var current_state: GameState = GameState.MENU
var score: int = 0
var best: int = 0

func _ready() -> void:
	best = Save.get_best()
	best_changed.emit(best)

func new_run() -> void:
	score = 0
	current_state = GameState.PLAYING
	score_changed.emit(score)
	state_changed.emit("playing")

func add_score(points: int) -> void:
	score += points
	score_changed.emit(score)

func pause_game() -> void:
	if current_state == GameState.PLAYING:
		current_state = GameState.PAUSED
		get_tree().paused = true
		state_changed.emit("paused")

func resume_game() -> void:
	if current_state == GameState.PAUSED:
		current_state = GameState.PLAYING
		get_tree().paused = false
		state_changed.emit("playing")

func end_run() -> void:
	current_state = GameState.GAME_OVER
	get_tree().paused = false
	state_changed.emit("game_over")
	
	if score > best:
		best = score
		Save.save_best(best)
		best_changed.emit(best)

func go_to_menu() -> void:
	current_state = GameState.MENU
	get_tree().paused = false
	state_changed.emit("menu")

func is_playing() -> bool:
	return current_state == GameState.PLAYING

func is_paused() -> bool:
	return current_state == GameState.PAUSED

