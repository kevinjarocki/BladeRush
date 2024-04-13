extends Control
@export var clickTarget: PackedScene
var missDistance = 10000000
var missDistanceVector = Vector2()
var userClick = Vector2(-100000,100000)
var nextClick = InstancePlaceholder
var ingotInstance = InstancePlaceholder
# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _input(event):
	if (event is InputEventMouseButton and visible and Input.is_action_just_pressed("click")):
		userClick = event.position
		missDistanceVector = userClick - nextClick.position
		missDistance = missDistanceVector.length()
		ingotInstance.quality -= missDistance
		print(ingotInstance.quality)
		ingotInstance.stage += 1
		if (ingotInstance.stage < ingotInstance.recipe.size()):
			nextClick.position = ingotInstance.recipe[ingotInstance.stage]
			print("here")
			
		else:
			nextClick.killInstance()
			print("kill me")
func summonMinigame(instance):
	ingotInstance = instance
	show()
	nextClick = clickTarget.instantiate()
	nextClick.position = ingotInstance.recipe[0]
	add_child(nextClick)

	#await get_tree().create_timer(1.0).timeout
	
