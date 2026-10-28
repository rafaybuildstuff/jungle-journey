extends Area2D

@export_file("*.tscn") var target_scene: String = "res://scene/forest.tscn"

func _on_body_entered(_body: Node2D) -> void:
	# Calls the global fade transition script we just set up
	SceneTransition.transition_to(target_scene)
