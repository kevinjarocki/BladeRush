extends Node2D

@export var money = 0
@export var minigame: PackedScene
var ingotNode = null

var recipeBook = {
	"dagger" : [Vector2(100,100),Vector2(200,200),Vector2(150,150)],
	"scimtar" : [Vector2(600,100),Vector2(420,696),Vector2(337,808)],
	"axe" : 
		[
		Vector2(466, 236),
		Vector2(480, 263),
		Vector2(473, 284),
		Vector2(454, 306),
		Vector2(452, 309),
		Vector2(413, 319),
		Vector2(412, 320),
		Vector2(397, 333),
		Vector2(397, 334),
		Vector2(439, 350),
		Vector2(440, 350),
		Vector2(504, 347),
		Vector2(508, 347),
		Vector2(558, 327),
		Vector2(602, 284),
		Vector2(603, 282),
		Vector2(618, 250),
		Vector2(619, 249),
		Vector2(631, 226),
		Vector2(593, 234),
		Vector2(564, 229),
		Vector2(562, 229),
		Vector2(525, 200),
		Vector2(525, 199),
		Vector2(561, 245),
		Vector2(543, 261),
		Vector2(542, 261),
		Vector2(512, 267),
		Vector2(510, 267),
		Vector2(488, 269),
		Vector2(458, 349),
		Vector2(570, 338),
		Vector2(571, 338),
		Vector2(620, 274),
		Vector2(620, 273),
		]
}

var materialBook = {
	"tin" : {"coolRate" : 10, "heatRate" : 25, "idealTemp": 1000, "idealTempRange": 500, "valueMod": 1, "cost": 1},
	"iron" : {"coolRate" : 8, "heatRate" : 25, "idealTemp": 1600, "idealTempRange": 300, "valueMod": 2, "cost": 1},
	"bronze" : {"coolRate" : 4, "heatRate" : 25, "idealTemp": 2000, "idealTempRange": 500, "valueMod": 4, "cost": 1},
	"gold": {"coolRate" : 25, "heatRate" : 50, "idealTemp": 700, "idealTempRange": 200, "valueMod": 6, "cost": 1}
}
func _on_ingot_temperature_broadcast(temp, maxTemp):

	$"GUI HUD/ProgressBar".value = temp
	
	pass # Replace with function body.

func _process(delta):
	if(ingotNode != null):
		var temp = ingotNode.temperature
		ingotNode.temperature
		$"GUI HUD/ProgressBar".value = temp
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
	query.position = $Anvil.position + Vector2(-270,24)
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
		ingotNode.position = $Anvil.position + Vector2(-270,30)
		ingotNode.isForge = true
		$Forge.play()
			
	else:
		print("Nothing to do, player does not have ingot")
	
func playerAtOreBox():
	if !ingotCheck():
		var item = load("res://ingot.tscn").instantiate()
		$Player.add_child(item)
		ingotNode = item
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
  
func _on_anvil_game_game_complete_signal():
	$AnvilGame.hide()

