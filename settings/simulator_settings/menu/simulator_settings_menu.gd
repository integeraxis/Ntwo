extends MarginContainer

func _ready():
	$ScrollContainer/VBoxContainer/Graphics/PanelContainer/VBoxContainer/ResolutionScaleSlider.slider_value = SimulatorSettings.get_property("resolution_scale")
	$ScrollContainer/VBoxContainer/Graphics/PanelContainer/VBoxContainer/FisheyeSlider.slider_value = SimulatorSettings.get_property("fisheye_strength")


func _on_resolution_scale_slider_value_changed(new_value: float) -> void:
	SimulatorSettings.set_property("resolution_scale", new_value)



func _on_fisheye_slider_value_changed(new_value: float) -> void:
	SimulatorSettings.set_property("fisheye_strength", new_value)
