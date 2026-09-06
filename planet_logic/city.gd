extends Resource
class_name City
var name := "Ciiity"
#x = latitude, y = longitude, z = elevation. 
#Z can be inferred from planet's elevation if you know x and y (however it's not needed because it's cached one time)
var geoposition: Vector3
var population := 0.0
var facilities : Array[Facility]
var events : Array
var governor : Variant
