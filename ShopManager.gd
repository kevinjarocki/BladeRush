extends Node2D

@export var money = 0



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
	pass
	
func playerAtForge():
	
	if ingotCheck($Anvil) and ingotCheck($Player):
		print("Cant add another ingot")
	
	elif ingotCheck($Anvil):
		var IngotNode = ingotCheck($Anvil)
		$Anvil.remove_child(IngotNode)
		$Player.add_child(IngotNode)
		IngotNode.isForge = false
	
	else:
		if ingotCheck($Player):
			var ingotNode = ingotCheck($Player)
			reparentNode($Anvil, $Player, ingotNode)
			ingotNode.isForge = true
			
		else:
			print("Nothing to do, player does not have ingot")
	
func playerAtOreBox():
	if !ingotCheck($Player):
		var item = load("res://ingot.tscn").instantiate()
		$Player.add_child(item)
		print ("Picked up ingot")
	
	else:
		print ("Player already holding ingot")
	
func playerAtCashRegister():
	pass

#Checks if player is holding an ingot, returns ingot node or false
func ingotCheck(node):
	for child in node.get_children():
		if child.name == "Ingot":
			return child
	return false

func reparentNode(newParent, oldParent, node):
	oldParent.remove_child(node)
	newParent.add_child(node)
	
	node.transform = oldParent.global_transform
