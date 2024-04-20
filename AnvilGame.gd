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
var instanceCounter = 0
var instanceBudget = 1
var mouseLocation = Vector2.ZERO
var scaleValue = Vector2(1,1)
@export var ingotPosition = Vector2(500,-500)
var gameStarted = false

signal gameCompleteSignal
signal playerLeft(child)

# Called when the node enters the scene tree for the first time.
func _ready():
	ingotPosition = $ColorRect.position + $ColorRect.pivot_offset
	hide()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _input(event):
	
	if (event is InputEventMouseButton and visible and Input.is_action_just_pressed("click") and not gameCompletedBool):
		$AnimatedSprite2D.play()
		$Ping.play()
		userClick = event.position
		missDistanceVector = userClick - nextClick.position
		missDistance = missDistanceVector.length()
		ingotInstance.quality -= missDistance
		print(ingotInstance.quality)
		ingotInstance.stage += 1
		if (ingotInstance.stage < ingotInstance.recipeProperties["points"].size()):
			nextClick.position = ingotInstance.recipeProperties["points"][ingotInstance.stage]
			
		else:
			nextClick.killInstance()
			gameCompletedBool = true
			gameCompleteSignal.emit()
	if (event is InputEventMouseMotion and visible):
		print(event.position)
		$AnimatedSprite2D.position = event.position
		
func summonMinigame(instance):
	
	ingotInstance = instance
	gameStarted = true
	ingotInstance.position = ingotPosition
	ingotInstance.scale = scaleValue
	#This will change the ingot animation to the recipe animation we need. Every animation for evcery weapon type will be a part of the ingot scene
	#ingotInstance.AnimatedSprite2D.animation = ingotInstance.recipe.name

	if (ingotInstance.stage < ingotInstance.recipeProperties["points"].size()):

		gameCompletedBool = false
		show()
		if instanceBudget > 0:
			nextClick = clickTarget.instantiate()
			instanceCounter += 1
			instanceBudget -= 1
		nextClick.position = ingotInstance.recipeProperties["points"][ingotInstance.stage]
		add_child(nextClick)
		move_child(nextClick, 2)
	else:
		hide()

	#await get_tree().create_timer(1.0).timeout
	
func _on_button_pressed():
	recipeTool = true

func _on_player_departed(body):
	if !gameCompletedBool and instanceCounter > 0:
		instanceCounter = 0
	if gameStarted:
		ingotInstance.scale = Vector2(0.25,0.25)
		remove_child(ingotInstance)
		owner.add_child(ingotInstance)
		#print(owner.get_children())
		playerLeft.emit(ingotInstance)
	if gameCompletedBool:
		instanceBudget = 1

		gameStarted = false

	ingotInstance.scale = Vector2(0.25,0.25)
	remove_child(ingotInstance)
	owner.add_child(ingotInstance)
	playerLeft.emit(ingotInstance)

	
	hide()
