extends Area2D

@export_file("*.tscn") var target_scene: String = "res://scene/forest.tscn"

func _ready() -> void:
	# Only connect if it hasn't already been connected in the Editor UI
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if target_scene:
			SceneTransition2.change_scene_to_file(target_scene)
		else:
			print("Error: No target scene assigned!")
