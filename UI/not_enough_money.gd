extends SimplePopup
class_name NotEnoughMoneyPopup
func notice(price: float = 0, verb : String = "build", object : String = "") -> void:
	open()
	if !price == 0 or object == "":
		%Description.text = str("You don't have enough money to purchase this")
	%Description.text = str("You only have ", int(Game.terras) ," Tr while you need ", int(price) ," Tr to ", verb ," this ", object)
	
