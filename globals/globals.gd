extends Node


# universal signal to GameManager to tell it to update the UI
signal stat_change

# game settings
const HEALTH_MAX: int = 10
const BOSS_HEALTH_MAX: int = 3
var music_enabled: bool = true
var volume_level: float = 1
var vsync_enabled: bool = true
var fullscreen_enabled: bool = false

# player status
var player_control: bool = false
var player_health: int = 10:
	set(value):
		player_health = value
		stat_change.emit()
var player_pos: Vector2

# boss status
var boss_health: int = 3:
	set(value):
		boss_health = value
		stat_change.emit()
