extends Node2D

@export var money = 0
@export var minigame: PackedScene

var recipeBook = {
	"dagger" : [Vector2(100,100),Vector2(200,200),Vector2(150,150)],
	"scimtar" : [Vector2(600,100),Vector2(420,696),Vector2(337,808)]
}

var materialBook = {
	"tin" : {"maxTemp" : 1500, "coolRate" : 10, "heatRate" : 25, "idealTemp": 1000, "idealTempRange": 500},
	"iron" : {"maxTemp" : 2200, "coolRate" : 8, "heatRate" : 25, "idealTemp": 1600, "idealTempRange": 300},
	"bronze" : {"maxTemp" : 2600, "coolRate" : 4, "heatRate" : 25, "idealTemp": 2000, "idealTempRange": 500},
	"gold": {"maxTemp" : 1000, "coolRate" : 25, "heatRate" : 50, "idealTemp": 700, "idealTempRange": 200}
}

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
		var IngotNode = ingotCheck()
		IngotNode.recipe = recipeBook[IngotNode.recipeName]
		$AnvilGame.summonMinigame(ingotCheck())
		$Player.unFreeze()
		print("here")
	else:
		print("no ingot")
	
func playerAtForge():
	
	var query := PhysicsPointQueryParameters2D.new()
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.position = $Anvil.position + Vector2(-270,30)
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
		var ingotNode = ingotCheck()
		$Player.remove_child(ingotNode)
		add_child(ingotNode)
		ingotNode.name = "Ingot"
		ingotNode.position = $Anvil.position + Vector2(-270,30)
		ingotNode.isForge = true
		$Forge.play()
			
	else:
		if ingotCheck():
			var ingotNode = ingotCheck()
			reparentNode($Anvil, $Player, ingotNode)
			ingotNode.isForge = true
			
		else:
			print("Nothing to do, player does not have ingot")
	
func playerAtOreBox():
	if !ingotCheck():
		var item = load("res://ingot.tscn").instantiate()
		$Player.add_child(item)
		print ("Picked up ingot")
	
	else:
		print ("Player already holding ingot")
	
func playerAtCashRegister():
	if ingotCheck():
		ingotCheck().queue_free()

#Checks if player is holding an ingot, returns ingot node or false

func ingotCheck():
	for child in $Player.get_children():
		if child.is_in_group("ingot"):

			return child
	return false

func reparentNode(newParent, oldParent, node):
	oldParent.remove_child(node)
	newParent.add_child(node)
	
	node.transform = oldParent.global_transform
  


func _on_anvil_game_game_complete_signal():
	$AnvilGame.hide()
