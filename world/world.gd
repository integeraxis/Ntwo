extends Node3D

func _ready():
	gb.world_ref = self
	set_map(MapManager.current_map)

func _process(_delta: float) -> void:
	$SubViewportContainer.stretch_shrink = 1.0/SimulatorSettings.get_property("resolution_scale")

func set_map(map_directory:String):
	var map_name = map_directory.get_basename().split("/")[-1]
	
	
	var allowed_scene_ext = [".scn", ".tscn"]
	
	for ext in allowed_scene_ext:
		var scene_path = map_directory.path_join(map_name+ext)
		if ResourceLoader.exists(scene_path):
			var map = load(scene_path).instantiate()
			$SubViewportContainer/SubViewport/Map.add_child(map)
			return

	#no scene file is found
	printerr("no scene file found! Make sure the scene file matches the scene folder name.")
