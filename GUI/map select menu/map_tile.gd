extends MarginContainer

var map_name := "":
	set(new_value):
		map_name = new_value
		$PanelContainer/VBoxContainer/Label.text = map_name

var map_directory := "":
	set(new_value):
		map_directory = new_value
		map_name = map_directory.get_basename().split("/")[-1]
		$PanelContainer/VBoxContainer/Label.tooltip_text = map_directory

var map_thumbnail :Texture:
	set(new_value):
		map_thumbnail = new_value
		$PanelContainer/VBoxContainer/TextureRect.texture = map_thumbnail


func _on_play_button_pressed() -> void:
	MapManager.set_map(map_directory)
