/obj/terrain_generator
	name = "terrain generator"
	icon = 'icons/effects/512x512.dmi'
	icon_state = "ratvar"
	var/list/noise = list()
	var/width = 255
	var/height = 255
	var/waterlevel = 0.2
	var/beachlevel = 0.3
	var/grasslevel = 0.4
	var/junglelevel = 0.8
	var/mountainlevel = 1

/obj/terrain_generator/Initialize()
	. = ..()
	noise = GeneratePerlinNoise(width, height)
	CreateTerrain()

/obj/terrain_generator/proc/CreateTerrain()
	var/area/A = get_area(src)
	/*
	for(var/turf/open/T in A.contents)
		to_chat(world, "gay")
		if(!istype(T, /turf/open/genturf))
			continue // we only want genturf
		T.ChangeTurf(GetTerrain(noise[T.x + ((T.y-1) * width)]))

*/

/obj/terrain_generator/proc/GetTerrain(var/x)
	switch(x)
		if(0 to waterlevel)
			return /turf/open/water
		if(waterlevel to beachlevel)
			return /turf/open/floor/plating/asteroid
		if(beachlevel to grasslevel)
			return /turf/open/floor/grass
		if(grasslevel to junglelevel)
			return /turf/open/floor/plating/dirt
		if(junglelevel to mountainlevel)
			return /turf/closed/mineral/random

/area/lavaland/surface/outdoors/jungle
	icon_state = "unexplored"

/turf/open/genturf
	name = "ungenerated turf"
	desc = "If you see this, and you're not a ghost, yell at coders"
	icon = 'icons/turf/floors/debug.dmi'
	icon_state = "genturf"
