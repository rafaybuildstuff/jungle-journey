extends Area2D

@export_file("*.tscn") var target_scene: String = "res://main_scene.tscn"

func _ready() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Debug print to make sure collision triggers
	print("Body entered teleport area: ", body.name)
	
	if body.is_in_group("player") or body.name == "Player":
		print("Player detected! Target scene path is: ", target_scene)
		
		if target_scene != "":
			# Make sure SceneTransition2 is an Autoload (Singleton)
			SceneTransition2.change_scene_to_file(target_scene)
		else:
			print("ERROR: Target scene path is empty!")
