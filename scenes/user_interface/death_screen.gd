extends Control


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	$Panel/VBoxContainer/RetryButton.grab_focus()


func _on_retry_button_pressed():
	get_tree().change_scene_to_file("res://scenes/levels/game_manager.tscn")


func _on_main_menu_button_pressed():
	get_tree().change_scene_to_file("res://scenes/user_interface/main_menu.tscn")


func _on_exit_game_button_pressed():
	get_tree().quit()
