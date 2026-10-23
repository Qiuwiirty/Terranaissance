extends Resource
class_name SunProperties
const STAR_TYPE_COLORS: Gradient = preload("uid://bm3hy58cgtcim")
var star_type : Sun.StarType:
	get:
		return clampi(roundi(spectrum * 6.0), 0, 6) as Sun.StarType
var light_color : Color:
	get:
		return STAR_TYPE_COLORS.sample(spectrum)
@export var spectrum : float = Sun.StarType.G / 6. #Spectrum range from 0 to 1, where 0 is M and 1 is O. Everything in between can be defined by n/6 
@export var light_intensity: float = 1.0
