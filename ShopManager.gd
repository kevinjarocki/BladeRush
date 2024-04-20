extends Node2D

@export var money = 0
@export var day = 1
@export var dayTimer = 0.00
@export var endDayTime = 20
@export var activeRecipe = "Awaiting Order"
@export var activeMaterial = ""
@export var minigame: PackedScene
var ingotNode = null
var gameFinished = false

var recipeBook = {

	"Dagger" : {"points": [Vector2(569, 139),Vector2(628, 191),Vector2(654, 237),Vector2(660, 291),Vector2(660, 293),Vector2(626, 328),Vector2(626, 329),Vector2(583, 353),Vector2(581, 354),Vector2(543, 372),Vector2(543, 373),Vector2(529, 405),Vector2(529, 407),Vector2(530, 217),Vector2(658, 471)], 
	"name": "dagger", "perfectRange": 5, "punishRate": 10, "value" : 1},
	
	"Scimtar" : {"points": [Vector2(553, 214),Vector2(610, 282),Vector2(515, 326),Vector2(619, 398),Vector2(534, 448)], 
	"name": "scimtar","perfectRange": 3, "punishRate": 15, "value" : 3},
	
	"Axe" : {"points": [Vector2(580, 508),Vector2(576, 431),Vector2(578, 365),Vector2(578, 287),Vector2(613, 492),Vector2(614, 440),Vector2(614, 391),Vector2(615, 325),Vector2(550, 266)], 
	"name": "axe", "perfectRange": 3, "punishRate": 15, "value" : 3}
}

var materialBook = {
	"Tin" : {"name": "tin", "coolRate" : 10, "heatRate" : 25, "idealTemp": 1000, "idealTempRange": 500, "valueMod": 1, "cost": 1},
	"Iron" : {"name": "iron", "coolRate" : 8, "heatRate" : 25, "idealTemp": 1600, "idealTempRange": 300, "valueMod": 2, "cost": 1},
	"Bronze" : {"name": "bronze", "coolRate" : 4, "heatRate" : 25, "idealTemp": 2000, "idealTempRange": 500, "valueMod": 4, "cost": 1},
	"Gold": {"name": "gold", "coolRate" : 25, "heatRate" : 50, "idealTemp": 700, "idealTempRange": 200, "valueMod": 6, "cost": 1}
}

func _process(delta):
	
	$"GUI HUD/DayTimer".value = (dayTimer/endDayTime)*100
	dayTimer += delta
	
	if dayTimer > endDayTime:
		daysDone()
		$EndDay.endDay(day, money)
	
	$"GUI HUD/ActiveRecipe".text = ("Active Recipe: " + str(activeMaterial) + " " + str(activeRecipe))
	$"GUI HUD/DayCount".text = ("Day " + str(day))
	$"GUI HUD/MoneyCount".text = ("Gold: " + str(money))
	
	if(ingotNode != null):
		var temp = ingotNode.temperature
		$"GUI HUD/ProgressBar".value = ((temp/ingotNode.maxTemp)*100)

	else:
		var temp = 0
		$"GUI HUD/ProgressBar".value = temp

func _on_player_interacted(station):
	
	#If player is at an interactable station -> Go to a function for each station
	if station:
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
		if !gameFinished:
			print("take my ingot")
			$Player.remove_child(ingotNode)
			$AnvilGame.add_child(ingotNode)
			$AnvilGame.move_child(ingotNode,1)
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
		ingotNode = ingotCheck()
		if $AnvilGame.gameCompletedBool:
			money += int(1*ingotNode.recipeProperties["value"]*ingotNode.materialProperties["valueMod"]*(ingotNode.quality/100))
			activeRecipe = "Awaiting Order"
			activeMaterial = ""
			ingotNode.queue_free()
			
			var query := PhysicsPointQueryParameters2D.new()
			query.collide_with_areas = true
			query.collide_with_bodies = false
			query.position = Vector2(173, 431)
			var space = get_world_2d().direct_space_state
	
			for x in get_world_2d().direct_space_state.intersect_point(query):

				if x.collider.owner.is_in_group("customer"):
					print(x.collider)
					x.collider.owner.ExitShop()
		else: print("Sorry bar is not complete")
		
	elif activeRecipe == "Awaiting Order" and get_tree().get_nodes_in_group("customer"):
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

func _on_anvil_game_game_complete_signal():
	gameFinished = true
	$AnvilGame.hide()

#func _input(event):
	#if Input.is_action_just_pressed("click"):
		#print(event.get_position())

func _on_button_pressed():
	var ingotNode = ingotCheck()
	money += 1*ingotNode.recipeProperties["value"]*ingotNode.materialProperties["valueMod"]*(ingotNode.quality/100)
	activeRecipe = "Awaiting Order"
	activeMaterial = ""
	ingotNode.queue_free()

func _on_ore_box_animation_looped():
	$OreBox.pause()
	
func _on_ore_box_animation_finished(Start):
	$OreBox.pause()

func _on_anvil_game_player_left(child):
		remove_child(child)
		$Player.add_child(child)
		print($Player.get_children())
		child.position = Vector2.ZERO

func _on_day_button_pressed():
	daysDone()
	$EndDay.endDay(day, money)

func _on_customer_pressed():
	createCustomer()
	pass # Replace with function body.

func daysDone():
	
	if ingotCheck():
		ingotCheck().queue_free()
		
	var query := PhysicsPointQueryParameters2D.new()
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.position = $Forge.position + Vector2(80,100)
	var space = get_world_2d().direct_space_state
	
	for x in get_world_2d().direct_space_state.intersect_point(query):
		if x.collider.owner.is_in_group("ingot"):
			x.collider.owner.queue_free()
			
	for child in get_tree().get_nodes_in_group("customer"):
		child.queue_free()

func _on_end_day_next_day_pressed():
	day += 1
	dayTimer = 0
	createCustomer()
	pass # Replace with function body.
