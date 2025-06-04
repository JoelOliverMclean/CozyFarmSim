class_name HUD
extends Control


@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var coin_label: Label = $CoinPanelContainer/MarginContainer/HBoxContainer/CoinLabel

var coins: int


func update_coins(new_coins: int) -> void:
	if new_coins < coins:
		anim.play("DropCoin")
	elif new_coins > coins:
		anim.play("BounceCoin")
	coin_label.text = str(new_coins)
	coins = new_coins
