extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect

func _ready() -> void:
	color_rect.modulate.a = 0.0
	color_rect.visible = false

func change_scene_to_file(target_scene: String) -> void:
	color_rect.visible = true
	
	# 1. Fade out to black
	var tween_out = create_tween()
	tween_out.tween_property(color_rect, "modulate:a", 1.0, 0.4)
	await tween_out.finished
	
	# 2. Change the scene
	get_tree().change_scene_to_file(target_scene)
	
	# 3. Wait one frame for the new scene to load, then fade back in
	await get_tree().process_frame
	
	var tween_in = create_tween()
	tween_in.tween_property(color_rect, "modulate:a", 0.0, 0.4)
	await tween_in.finished
	
	# 4. Remove this transition overlay from memory
	queue_free()
