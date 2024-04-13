extends Node2D

@export var money = 0
@export var minigame: PackedScene


@export var materialBook = {
	"bronze": {"minTemp": 25, "maxTemp": 1200, "coolCurve": 2},
	"iron": {"minTemp": 25, "maxTemp": 800, "coolCurve": 4},
	"gold": {"minTemp": 25, "maxTemp": 1200, "coolCurve": 5}
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
	$Player.freeze()
	$AnvilGame.summonMinigame(InstancePlaceholder)
	print("here")
	
func playerAtForge():
	
	var query := PhysicsPointQueryParameters2D.new()
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.position = Vector2(575,155)
	var space = get_world_2d().direct_space_state
	
	for x in get_world_2d().direct_space_state.intersect_point(query):
		if x.collider.owner.name == "@Node2D@2":
			remove_child(x.collider)
			$Player.add_child(x.collider)
			x.collider.owner.position = $Player.position

			print (x.collider.owner.position)
			print($Player.position)
			return
	
	if ingotCheck():
		var ingotNode = ingotCheck()
		$Player.remove_child(ingotNode)
		add_child(ingotNode)
		ingotNode.position = Vector2(575,155)
		ingotNode.isForge = true
		$Forge.play()
			
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
	pass

#Checks if player is holding an ingot, returns ingot node or false
func ingotCheck():
	for child in $Player.get_children():
		if child.name == "Ingot":
			return child
	return false

func reparentNode(newParent, oldParent, node):
	oldParent.remove_child(node)
	newParent.add_child(node)
	
	node.transform = oldParent.global_transform
  
func _input(event):
	if Input.is_action_just_pressed("click"):
		print(event.position)
