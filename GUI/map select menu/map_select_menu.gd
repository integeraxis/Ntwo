extends MarginContainer




func _ready() -> void:
	load_maps(MapManager.MAP_DIRECTORY)
	
	
	
func load_maps(directory:String):
	for subdir in DirAccess.get_directories_at(directory):
		load_map(directory.path_join(subdir))
	
	
func load_map(directory:String):
	MapManager.maps.append(directory)
	
	var map_tile = preload("res://GUI/map select menu/map_tile.tscn").instantiate()
	$VBoxContainer/PanelContainer/ScrollContainer/Maps.add_child(map_tile)
	map_tile.map_directory = directory
	
	var thumbnail_path = directory.path_join("thumbnail.png")
	if FileAccess.file_exists(thumbnail_path):
		map_tile.map_thumbnail = load(thumbnail_path)
	else:
		printerr("no thumbnail.png found!")
		print("thumbnail_path: "+thumbnail_path)
	


func _on_close_button_pressed() -> void:
	gb.gui_ref.stack_remove(self)
