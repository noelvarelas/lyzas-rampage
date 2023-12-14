extends Node


# goes to PauseMenu to toggle the UI
signal toggle_game_paused(is_paused: bool)

var current_intro_screen: int = 1
var is_playing_boss_music: bool = false

# auto-changes the pause state then signals PauseMenu the pause state
var game_paused: bool = false:
	set(value):
		game_paused = value
		get_tree().paused = game_paused
		if game_paused:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			$Music.stream_paused = true
			$MusicBoss.stream_paused = true
		if not game_paused:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			$Music.stream_paused = false
			$MusicBoss.stream_paused = false
		emit_signal("toggle_game_paused", game_paused)


func _ready():
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# receives a signal from Globals when a UI element needs to update
	Globals.connect("stat_change", update_stat_text)
	Globals.player_health = Globals.HEALTH_MAX
	Globals.boss_health = Globals.BOSS_HEALTH_MAX
	game_paused = false
	$CanvasLayer/Control/Go.visible = false
	$CanvasLayer/Control/HealthBar/HealthHi.visible = true
	$CanvasLayer/Control/HealthBar/HealthLo.visible = false
	$CanvasLayer/Control/BossName.visible = false
	$CanvasLayer/Control/BossHealthBar.visible = false
	
	# set up intro screens
	Globals.player_control = false
	$CanvasLayer/Intro/Intro2.modulate = Color(1,1,1,1)
	$CanvasLayer/Intro/Intro1.visible = true
	$CanvasLayer/Intro/Intro2.visible = false
	$CanvasLayer/Intro/Intro1/HBoxContainer/Button.grab_focus()

	# get camera into position quickly
	$Level/Player/Camera2D.position_smoothing_speed = 100


func _physics_process(_delta):

	if Globals.player_health <= 0:
		get_tree().change_scene_to_file("res://scenes/user_interface/death_screen.tscn")
	
	if Globals.boss_health <= 0:
		$MusicBoss.stop()


func _input(event: InputEvent):
	# toggles the pause state upon button press
	if(event.is_action_pressed("ui_cancel")) and Globals.player_control:
		game_paused = !game_paused
	
	# cycle through intro screens
	if((Input.is_action_just_pressed("primary")) or (Input.is_action_just_pressed("ui_accept"))) and current_intro_screen == 1:
		$CanvasLayer/Intro/Intro2.visible = true
		$CanvasLayer/Intro/Intro2/HBoxContainer/Button.grab_focus()
		$AnimationPlayer.play("intro_next")
		await $AnimationPlayer.animation_finished
		current_intro_screen = 2
	elif((Input.is_action_just_pressed("primary")) or (Input.is_action_just_pressed("ui_accept"))) and current_intro_screen == 2:
		$AnimationPlayer.play("intro_fade")
		await $AnimationPlayer.animation_finished
		current_intro_screen = 0
		$Level/Player/Camera2D.position_smoothing_speed = 1
		Globals.player_control = true


# list of functions to run that all update the UI
func update_stat_text():
	update_health_text()
	update_boss_health_text()


func update_health_text():
	$CanvasLayer/Control/HealthBar/ProgressBar.value = Globals.player_health
	if Globals.player_health >= (Globals.HEALTH_MAX / 2):
		$CanvasLayer/Control/HealthBar/HealthHi.visible = true
		$CanvasLayer/Control/HealthBar/HealthLo.visible = false
		$CanvasLayer/Control/HealTip.visible = false
	elif Globals.player_health < (Globals.HEALTH_MAX / 2):
		$CanvasLayer/Control/HealthBar/HealthHi.visible = false
		$CanvasLayer/Control/HealthBar/HealthLo.visible = true
		$CanvasLayer/Control/HealTip.visible = true


func update_boss_health_text():
	$CanvasLayer/Control/BossHealthBar.value = Globals.boss_health


# signal coming from level scene
func _on_level_screen_just_cleared():
	$GoBlink/AnimationPlayer.play("go_blink")


# signal coming from boss scene
func _on_boss_boss_fight_started():
	if not is_playing_boss_music:
		$CanvasLayer/Control/BossName.visible = true
		$CanvasLayer/Control/BossHealthBar.visible = true
		is_playing_boss_music = true
		$Music.stop()
		$MusicBoss.play()
