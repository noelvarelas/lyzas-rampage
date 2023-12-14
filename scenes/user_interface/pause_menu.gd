extends Control

# connects to GameManager's signal which triggers the provided function 
func _ready():
	hide()
	$"../..".connect('toggle_game_paused', _on_game_manager_toggle_game_paused)


# GameManager's signal -> connection established above -> this function
func _on_game_manager_toggle_game_paused(is_paused: bool):
	if is_paused:
		show()
		$Panel/VBoxContainer/ResumeButton.grab_focus()
	else:
		hide()


# GameManager has a setter that toggles the pause automatically
func _on_resume_button_pressed():
	$"../..".game_paused = false


func _input(event: InputEvent):
	if(event.is_action_pressed("ui_home")):
		_on_resume_button_pressed()


func _on_main_menu_button_pressed():
	get_tree().change_scene_to_file("res://scenes/user_interface/main_menu.tscn")


func _on_exit_game_button_pressed():
	get_tree().quit()
