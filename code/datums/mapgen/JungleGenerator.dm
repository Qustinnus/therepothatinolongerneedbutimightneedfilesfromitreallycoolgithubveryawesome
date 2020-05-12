/datum/map_generator/jungle_generator
	///2D list of all biomes based on heat and humidity combos.
	var/list/possible_biomes = list(BIOME_LOW_HEAT = list(BIOME_LOW_HUMIDITY = /datum/biome/plains, BIOME_MEDIUM_HUMIDITY = /datum/biome/mudlands, BIOME_HIGH_HUMIDITY = /datum/biome/water), BIOME_MEDIUM_HEAT = list(BIOME_LOW_HUMIDITY = /datum/biome/plains, BIOME_MEDIUM_HUMIDITY = /datum/biome/jungle, BIOME_HIGH_HUMIDITY = /datum/biome/jungle),BIOME_HIGH_HEAT = list(BIOME_LOW_HUMIDITY = /datum/biome/wasteland, BIOME_MEDIUM_HUMIDITY = /datum/biome/jungle, BIOME_HIGH_HUMIDITY = /datum/biome/jungle/deep))

///Goes through all turfs and generates biomes based on noise-based height humidity and heat, creating a somewhat seamless transition between biomes.
/datum/map_generator/jungle_generator/generate_terrain(var/list/turfs)
	. = ..()
	to_chat(world, "[turfs.len]")
	var/height_seed = rand(0, 50000)
	var/humidity_seed = rand(0, 50000)
	var/heat_seed = rand(0, 50000)

	for(var/turf/T in turfs) //Go through all the turfs and generate them
		var/height = text2num(rustg_noise_get_at_coordinates("[height_seed]", "T.x", "T.y"))

		var/datum/biome/selected_biome

		if(height <= 0.85) //If height is less than 0.85, we generate biomes based on the heat and humidity of the area.
			var/humidity = text2num(rustg_noise_get_at_coordinates("[humidity_seed]", "T.x", "T.y"))
			var/heat = text2num(rustg_noise_get_at_coordinates("[heat_seed]", "T.x", "T.y"))
			to_chat(world, "[heat]")
			var/heat_level //Type of heat zone we're in LOW-MEDIUM-HIGH
			var/humidity_level  //Type of humidity zone we're in LOW-MEDIUM-HIGH

			switch(heat)
				if(0 to 0.33)
					heat_level = BIOME_LOW_HEAT
				if(0.33 to 0.66)
					heat_level = BIOME_MEDIUM_HEAT
				if(0.66 to 1)
					heat_level = BIOME_HIGH_HEAT
			switch(humidity)
				if(0 to 0.33)
					humidity_level = BIOME_LOW_HUMIDITY
				if(0.33 to 0.66)
					humidity_level = BIOME_MEDIUM_HUMIDITY
				if(0.66 to 1)
					humidity_level = BIOME_HIGH_HUMIDITY
			selected_biome = possible_biomes[heat_level][humidity_level]
		else //Over 0.85; It's a mountain
			selected_biome = /datum/biome/mountain
		selected_biome = SSmapping.biomes[selected_biome] //Get the instance of this biome from SSmapping
		selected_biome.generate_turf(T)
		CHECK_TICK

/turf/open/genturf
	name = "ungenerated turf"
	desc = "If you see this, and you're not a ghost, yell at coders"
	icon = 'icons/turf/debug.dmi'
	icon_state = "genturf"

/area/mine/planetgeneration
	name = "planet generation area"
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	map_generator = /datum/map_generator/jungle_generator
