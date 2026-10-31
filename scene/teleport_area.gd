extends Area2D

@export_file("*.tscn") var target_scene: String = "res://scene/main_scene.tscn"
const TRANSITION_SCENE = preload("res://scene/scene_transition_3.tscn")

func _ready() -> void:
	# Only connect if it's not already connected via the editor
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		set_deferred("monitoring", false)
		
		var transition = TRANSITION_SCENE.instantiate()
		get_tree().root.add_child(transition)
		
		transition.change_scene_to_file(target_scene)
