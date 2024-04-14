extends Control
@export var clickTarget: PackedScene
var missDistance = 10000000
var missDistanceVector = Vector2()
var userClick = Vector2(-100000,100000)
var nextClick = InstancePlaceholder
var ingotInstance = InstancePlaceholder
var gameCompletedBool = false
var recipeTool = false
var tempRecipeArray = []

signal gameCompleteSignal

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _input(event):

	if (event is InputEventMouseButton and visible and Input.is_action_just_pressed("click") and not gameCompletedBool):
		userClick = event.position
		missDistanceVector = userClick - nextClick.position
		missDistance = missDistanceVector.length()
		ingotInstance.quality -= missDistance
		print(ingotInstance.quality)
		ingotInstance.stage += 1
		if (ingotInstance.stage < ingotInstance.recipe.size()):
			nextClick.position = ingotInstance.recipe[ingotInstance.stage]
			
		else:
			nextClick.killInstance()
			gameCompletedBool = true
			gameCompleteSignal.emit()
			
func summonMinigame(instance):
	
	ingotInstance = instance
	if (ingotInstance.stage < ingotInstance.recipe.size()):
		gameCompletedBool = false
		show()
		nextClick = clickTarget.instantiate()
		nextClick.position = ingotInstance.recipe[ingotInstance.stage]
		add_child(nextClick)
	else:
		hide()

	#await get_tree().create_timer(1.0).timeout
	
func _on_button_pressed():
	recipeTool = true


func _on_player_departed(body):
	if body.owner.name == "Anvil" and !gameCompletedBool:
		nextClick.killInstance()
	hide()
