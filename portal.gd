extends Area2D

# This creates a field in the Inspector where you can pick your cave scene file (.tscn)
@export_file("*.tscn") var target_scene: String

func _ready() -> void:
	# Automatically connect the body_entered signal when the portal starts
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Check if the object entering the portal belongs to the "player" group
	if body.is_in_group("player"):
		if target_scene:
			# Call your SceneTransition2 autoload to handle the fade & scene change
			SceneTransition2.change_scene_to_file(target_scene)
		else:
			print("Error: No target scene assigned to this portal!")
