extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect

func transition_to(target_scene: String) -> void:
	# 1. Fade to black
	color_rect.visible = true
	var tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 1.0, 0.5)
	await tween.finished
	
	# 2. Change the scene in the background
	get_tree().change_scene_to_file(target_scene)
	
	# 3. Fade back in from black
	tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 0.0, 0.5)
	await tween.finished
	color_rect.visible = false
