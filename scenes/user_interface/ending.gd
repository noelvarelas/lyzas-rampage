extends Control


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	$Menu/Panel/VBoxContainer/MainMenuButton.grab_focus()


func _on_main_menu_button_pressed():
	get_tree().change_scene_to_file("res://scenes/user_interface/main_menu.tscn")


func _on_exit_button_pressed():
	get_tree().quit()
