extends Control


var master_bus = AudioServer.get_bus_index("Master")
var music_bus = AudioServer.get_bus_index("Music")


func _ready():
	
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Globals.player_health = Globals.HEALTH_MAX
	$Controls.hide()
	$OptionsMenu.hide()
	$Credits.hide()
	$Menu/VBoxContainer/StartButton.grab_focus()

	# loads settings that were changed from default
	$OptionsMenu/VBoxContainer/HBoxContainer/VolumeSlider.value = Globals.volume_level
	$OptionsMenu/VBoxContainer/MusicToggle.button_pressed = Globals.music_enabled
	$OptionsMenu/VBoxContainer/FullscreenToggle.button_pressed = Globals.fullscreen_enabled
	$OptionsMenu/VBoxContainer/VsyncToggle.button_pressed = Globals.vsync_enabled


func _input(event: InputEvent):
	if(event.is_action_pressed("ui_home")):
		_on_back_button_pressed()


func _on_start_pressed():
	get_tree().change_scene_to_file("res://scenes/levels/game_manager.tscn")


func _on_controls_button_pressed():
	$Menu.hide()
	$Controls.show()
	$Controls/VBoxContainer/VBoxContainer2/BackButton.grab_focus()


func _on_options_pressed():
	$Menu.hide()
	$OptionsMenu.show()
	$OptionsMenu/VBoxContainer/HBoxContainer/VolumeSlider.grab_focus()


func _on_credits_button_pressed():
	$Menu.hide()
	$Credits.show()
	$Credits/VBoxContainer/BackButton.grab_focus()


func _on_quit_pressed():
	get_tree().quit()


func _on_volume_slider_value_changed(_value):
	Globals.volume_level = $OptionsMenu/VBoxContainer/HBoxContainer/VolumeSlider.value
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(Globals.volume_level))


func _on_music_toggle_toggled(button_pressed):
	if button_pressed:
		AudioServer.set_bus_mute(music_bus, false)
		Globals.music_enabled = true
	if not button_pressed:
		AudioServer.set_bus_mute(music_bus, true)
		Globals.music_enabled = false


func _on_fullscreen_toggle_toggled(button_pressed):
	if button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		Globals.fullscreen_enabled = true
	if not button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		Globals.fullscreen_enabled = false


func _on_vsync_toggle_toggled(button_pressed):
	if button_pressed:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
		Globals.vsync_enabled = true
	if not button_pressed:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		Globals.vsync_enabled = false


func _on_back_button_pressed():
	$Controls.hide()
	$OptionsMenu.hide()
	$Credits.hide()
	$Menu.show()
	$Menu/VBoxContainer/StartButton.grab_focus()
