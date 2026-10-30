extends Area2D

@export_file("*.tscn") var target_scene: String = "res://scene/Cave.tscn"

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(_body: Node2D) -> void:
	if target_scene:
		# Call SceneTransition2 and the correct function name
		SceneTransition2.change_scene_to_file(target_scene)
	else:
		print("Error: No target scene assigned!")
