extends Resource
class_name Culture
enum Cultures {
	TERRAFORM,
	CENTRALIZED,
	ECONOMY,
	EXPERIMENTAL
}
const MAX_CULTURE_VALUE := 50.0
## Ideologies
#I might wanna add the concept of "morales" and other stuff
#X_Y where X is the opposite of Y culture

#Note the definition could be altered (THIS IS TEMPORARY BTW)
#more habitations - more biomass growth and habitability related stuff
var industrial_terraform := 0.0
#more people - more efficiency (like construction
var decentralized_centralized := 0.0
#more research - more money
var science_economy := 0.0
#protocol means more safety and less accident
#experimental is opposite of protocol, which is more quicker but more risk
var protocol_experimental := 0.0

func get_value(type: Cultures) -> float:
	match type:
		Cultures.TERRAFORM:
			return industrial_terraform
		Cultures.CENTRALIZED:
			return decentralized_centralized
		Cultures.ECONOMY:
			return science_economy
		Cultures.EXPERIMENTAL:
			return protocol_experimental
		_:
			push_error("Non existent cultures type: ", Cultures)
			return 0.
