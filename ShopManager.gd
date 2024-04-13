extends Node2D

@export var money = 0
@export var minigame: PackedScene

func _on_player_interacted(station):
	if station:
		print(station.owner.name)
	else:
		print("No station nearby")
	
	if station.owner.name == "Anvil":
		$Player.freeze()
		$AnvilGame.summonMinigame(InstancePlaceholder)
		print("here")
		
