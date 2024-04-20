extends Node2D

@export var money = 0
@export var day = 0
@export var activeRecipe = "Awaiting Order"
@export var activeMaterial = ""
@export var minigame: PackedScene
var ingotNode = null
var gameFinished = false

var recipeBook = {

	"dagger" : {"points": [Vector2(100,100),Vector2(200,200),Vector2(150,150)], "perfectRange": 5, "punishRate": 10, "value" : 1},
	"scimtar" : {"points": [Vector2(600,100),Vector2(420,696),Vector2(337,808)], "perfectRange": 3, "punishRate": 15, "value" : 3},
	"axe" : {"points": [Vector2(466, 236),Vector2(480, 263),Vector2(473, 284),Vector2(454, 306),Vector2(452, 309),Vector2(413, 319),Vector2(412, 320),Vector2(397, 333),Vector2(397, 334),Vector2(439, 350),Vector2(440, 350),Vector2(504, 347),Vector2(508, 347),Vector2(558, 327),Vector2(602, 284),Vector2(603, 282),Vector2(618, 250),Vector2(619, 249),Vector2(631, 226),Vector2(593, 234),Vector2(564, 229),Vector2(562, 229),Vector2(525, 200),Vector2(525, 199),Vector2(561, 245),Vector2(543, 261),Vector2(542, 261),Vector2(512, 267),Vector2(510, 267),Vector2(488, 269),Vector2(458, 349),Vector2(570, 338),Vector2(571, 338),Vector2(620, 274),Vector2(620, 273)], 
		"perfectRange": 3, "punishRate": 15, "value" : 3}
}

var materialBook = {
	"tin" : {"coolRate" : 10, "heatRate" : 25, "idealTemp": 1000, "idealTempRange": 500, "valueMod": 1, "cost": 1},
	"iron" : {"coolRate" : 8, "heatRate" : 25, "idealTemp": 1600, "idealTempRange": 300, "valueMod": 2, "cost": 1},
	"bronze" : {"coolRate" : 4, "heatRate" : 25, "idealTemp": 2000, "idealTempRange": 500, "valueMod": 4, "cost": 1},
	"gold": {"coolRate" : 25, "heatRate" : 50, "idealTemp": 700, "idealTempRange": 200, "valueMod": 6, "cost": 1}
}

func _process(delta):
	$"GUI HUD/ActiveRecipe".text = ("Active Recipe: " + str(activeMaterial) + " " + str(activeRecipe))
	$"GUI HUD/DayCount".text = ("Day " + str(day))
	$"GUI HUD/MoneyCount".text = ("Gold: " + str(money))
	
	if(ingotNode != null):
		var temp = ingotNode.temperature
		$"GUI HUD/ProgressBar".value = ((temp/ingotNode.maxTemp)*100)
		
		#$"GUI HUD/ColorRect2".position.y = (ingotNode.materialProperties["idealTemp"] + ingotNode.materialProperties["idealRange"])
		#$"GUI HUD/ColorRect2".size.y = ingotNode.materialProperties["idealRange"]*2

	else:
		var temp = 0
		$"GUI HUD/ProgressBar".value = temp

func _on_player_interacted(station):
	
	#If player is at an interactable station -> Go to a function for each station
	if station:
		print(station.owner.name)
		if station.owner.name == "Anvil":
			playerAtAnvil()
		elif station.owner.name == "Forge":
			playerAtForge()
		elif station.owner.name == "OreBox":
			playerAtOreBox()
		elif station.owner.name == "CashRegister":
			playerAtCashRegister()
			
	else:
		print("No station nearby")
	
func playerAtAnvil():
	if (ingotCheck()):
		$Player.freeze()
		var ingotNode = ingotCheck()
		ingotNode.recipe = recipeBook[ingotNode.recipeName]
		if !gameFinished:
			print("take my ingot")
			$Player.remove_child(ingotNode)
			$AnvilGame.add_child(ingotNode)
			$AnvilGame.summonMinigame(ingotNode)
			
		else:
			print("dont take my ingot")
		
		$Player.unFreeze()
	else:
		print("no ingot")
	
func playerAtForge():
	
	var query := PhysicsPointQueryParameters2D.new()
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.position = $Forge.position + Vector2(80,100)
	var space = get_world_2d().direct_space_state
	
	for x in get_world_2d().direct_space_state.intersect_point(query):

		if x.collider.owner.is_in_group("ingot"):
			remove_child(x.collider.owner)
			$Player.add_child(x.collider.owner)
			x.collider.owner.position = Vector2.ZERO
			x.collider.owner.isForge = false
			$Forge.pause()
			$Forge.set_frame_and_progress(0,0)
			return
	
	if ingotCheck():
		ingotNode = ingotCheck()
		$Player.remove_child(ingotNode)
		add_child(ingotNode)
		ingotNode.name = "Ingot"
		ingotNode.position = $Forge.position + Vector2(80,100)
		ingotNode.isForge = true
		$Forge.play()
		$Fire.play()
			
	else:
		print("Nothing to do, player does not have ingot")
	
func playerAtOreBox():
	
	print("still interacting")

	if !ingotCheck() and activeRecipe != "Awaiting Order":
		
		$OreBox.play()
		$Ferret.play()
		$Dirt.play()
	
		gameFinished = false
		var ingotNode = load("res://ingot.tscn").instantiate()
		$Player.add_child(ingotNode)
		print ("Picked up ingot")
		
		ingotNode.recipeProperties = recipeBook[activeRecipe]
		ingotNode.materialProperties = materialBook[activeMaterial]

		$"GUI HUD/ProgressBar/IdealHeat".size.y = ((ingotNode.materialProperties["idealTempRange"]*2)/ingotNode.maxTemp)*$"GUI HUD/ProgressBar".size.y
		if ingotNode.materialProperties["idealTemp"] + ingotNode.materialProperties["idealTempRange"] > ingotNode.maxTemp:
			pass
		else: $"GUI HUD/ProgressBar/IdealHeat".position.y = $"GUI HUD/ProgressBar".size.y - ((ingotNode.materialProperties["idealTemp"] + ingotNode.materialProperties["idealTempRange"])/ingotNode.maxTemp)*$"GUI HUD/ProgressBar".size.y
	
	else:
		print ("Player already holding ingot")
	
func playerAtCashRegister():
	if ingotCheck():
		ingotCheck().queue_free()
		money += 1
		activeRecipe = "Awaiting Order"
		activeMaterial = ""
		
	elif activeRecipe == "Awaiting Order":
		activeRecipe = recipeBook.keys()[randi_range(0, recipeBook.size()-1)]
		activeMaterial = materialBook.keys()[randi_range(0, materialBook.size()-1)]
		
#Checks if player is holding an ingot, returns ingot node or false
func ingotCheck():
	for child in $Player.get_children():
		if child.is_in_group("ingot"):
			return child
	return false

func createCustomer():
	var item = load("res://Customer.tscn").instantiate()
	add_child(item)
	item.position = Vector2(172,580)
	item.speed = 100
	item.want = randi_range(0, recipeBook.size()-1)
	print(item.want)
  
func nextDay():
	day += 1

func _on_anvil_game_game_complete_signal():
	gameFinished = true
	$AnvilGame.hide()

#func _input(event):
	#if Input.is_action_just_pressed("click"):
		#print(event.get_position())

func _on_button_pressed():
	createCustomer()
	pass # Replace with function body.

func _on_ore_box_animation_looped():
	print("loop anim")
	$OreBox.pause()
	
func _on_ore_box_animation_finished(Start):
	print("fninshedm")
	$OreBox.pause()

func _on_anvil_game_player_left(child):
		remove_child(child)
		$Player.add_child(child)
		print($Player.get_children())
		child.position = Vector2.ZERO

func _on_day_button_pressed():
	nextDay()
	pass # Replace with function body.
