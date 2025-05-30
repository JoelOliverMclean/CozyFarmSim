class_name ShopItemPanel
extends Panel


func init(name: String, texture: Texture2D, cost: int):
	$VBoxContainer/Name.text = name
	$VBoxContainer/Image.texture = texture
	$VBoxContainer/Cost.text = str(cost) + " coins"
