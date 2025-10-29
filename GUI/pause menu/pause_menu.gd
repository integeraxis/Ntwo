extends Control

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if visible:
			on_menu_exit()
			gb.gui_ref.stack_remove(self)
		else:
			on_menu_open()
			gb.gui_ref.stack_append(self)
		


func _on_resume_button_pressed() -> void:
	on_menu_exit()
	gb.gui_ref.stack_remove(self)
	
func _on_select_map_button_pressed() -> void:
	gb.gui_ref.stack_append($"../MapSelectMenu")

	
func _on_settings_button_pressed() -> void:
	gb.gui_ref.stack_append($"../SettingsMenu")
	
func _on_main_menu_button_pressed() -> void:
	on_menu_exit()
	get_tree().change_scene_to_file("res://GUI/start/start.tscn")

	
func _on_quit_button_pressed() -> void:
	on_menu_exit()
	get_tree().quit()
	
	
	
	
func on_menu_open():
	get_tree().paused = true

func on_menu_exit():
	get_tree().paused = false
