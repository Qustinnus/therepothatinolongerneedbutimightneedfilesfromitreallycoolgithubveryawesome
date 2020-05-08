GLOBAL_DATUM_INIT(glass_backdrop, /atom/movable/glass_backdrop, new)

/atom/movable/glass_backdrop
	name			= "glass_backdrop"
	icon            = 'icons/turf/floors.dmi'
	icon_state      = "transparent"
	anchored		= TRUE
	plane           = GLASS_BACKDROP_PLANE
	mouse_opacity 	= MOUSE_OPACITY_TRANSPARENT
	layer           = SPLASHSCREEN_LAYER
	appearance_flags = KEEP_TOGETHER


/turf/open/transparent
	baseturfs = /turf/open/transparent/openspace
	intact = FALSE //this means wires go on top

/turf/open/transparent/Initialize() // handle plane and layer here so that they don't cover other obs/turfs in Dream Maker
	. = ..()
	plane = OPENSPACE_PLANE
	layer = OPENSPACE_LAYER

	return INITIALIZE_HINT_LATELOAD

/turf/open/transparent/LateInitialize()
	update_multiz(TRUE, TRUE)

/turf/open/transparent/Destroy()
	vis_contents.len = 0
	return ..()

/turf/open/transparent/update_multiz(prune_on_fail = FALSE, init = FALSE)
	. = ..()
	var/turf/T = below()
	if(!T)
		vis_contents.len = 0
		if(!show_bottom_level() && prune_on_fail) //If we cant show whats below, and we prune on fail, change the turf to plating as a fallback
			ChangeTurf(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
		return FALSE
	if(init)
		vis_contents += T
	return TRUE

/turf/open/transparent/multiz_turf_del(turf/T, dir)
	if(dir != DOWN)
		return
	update_multiz()

/turf/open/transparent/multiz_turf_new(turf/T, dir)
	if(dir != DOWN)
		return
	update_multiz()

///Called when there is no real turf below this turf
/turf/open/transparent/proc/show_bottom_level()
	var/turf/path = SSmapping.level_trait(z, ZTRAIT_BASETURF) || /turf/open/space
	if(!ispath(path))
		path = text2path(path)
		if(!ispath(path))
			warning("Z-level [z] has invalid baseturf '[SSmapping.level_trait(z, ZTRAIT_BASETURF)]'")
			path = /turf/open/space
	var/mutable_appearance/underlay_appearance = mutable_appearance(initial(path.icon), initial(path.icon_state), layer = TURF_LAYER, plane = PLANE_SPACE)
	underlays += underlay_appearance
	return TRUE


/turf/open/transparent/glass
	name = "Glass floor"
	desc = "Dont jump on it, or do, I'm not your mom."
	icon = 'icons/turf/floors/glass.dmi'
	icon_state = "floor_glass"
	smooth = SMOOTH_MORE
	canSmoothWith = list(/turf/open/transparent/glass, /turf/open/transparent/glass/reinforced)
	footstep = FOOTSTEP_PLATING
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/transparent/glass/Initialize()
	icon_state = "" //Prevent the normal icon from appearing behind the smooth overlays
	. = ..()
	vis_contents += GLOB.glass_backdrop //Add this after ..() so we get it in the right order

/turf/open/transparent/glass/reinforced
	name = "Reinforced glass floor"
	desc = "Do jump on it, it can take it."
	icon = 'icons/turf/floors/reinf_glass.dmi'
