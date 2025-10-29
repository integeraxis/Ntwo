extends MarginContainer



func _on_close_button_pressed() -> void:
	gb.gui_ref.stack_remove(self)
