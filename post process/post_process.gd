extends CanvasLayer

func _process(delta: float) -> void:
	$FishEye.material.set("shader_parameter/effect_amount", remap(SimulatorSettings.get_property("fisheye_strength"), 0, 1, 1, 2.5))
