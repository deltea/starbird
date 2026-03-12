class_name CameraBounds extends Polygon2D

func get_constrained_point(point: Vector2) -> Vector2:
	if point_in_polygon(point, polygon):
		return point
	return closest_point_on_polygon(point, polygon)

func point_in_polygon(point: Vector2, poly: PackedVector2Array) -> bool:
	return Geometry2D.is_point_in_polygon(point, poly)

func closest_point_on_polygon(point: Vector2, poly: PackedVector2Array) -> Vector2:
	var closest = poly[0]
	var min_dist = point.distance_squared_to(closest)

	for i in range(poly.size()):
		var a = poly[i]
		var b = poly[(i + 1) % poly.size()]
		var closest_on_edge = Geometry2D.get_closest_point_to_segment(point, a, b)
		var dist = point.distance_squared_to(closest_on_edge)
		if dist < min_dist:
			min_dist = dist
			closest = closest_on_edge

	return closest
