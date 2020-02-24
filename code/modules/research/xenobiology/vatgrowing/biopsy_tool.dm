///Tool capable of taking biological samples from mobs
/obj/item/biopsy_tool
	name = "biopsy tool"
	desc = "Don't worry, it won't sting."
	icon = 'icons/obj/xenobiology/vatgrowing.dmi'
	icon_state = "biopsy"

///Adds the swabbing component to the biopsy tool
/obj/item/biopsy_tool/Initialize()
	. = ..()
	AddComponent(/datum/component/swabbing, TRUE, TRUE, TRUE, CALLBACK(src, .proc/update_swab_icon), max_items = 1)


/obj/item/biopsy_tool/proc/update_swab_icon(list/swabbed_items)
	message_admins("biopsy tool thingies [swabbed_items.len]")
	if(swabbed_items.len)
		icon_state = "biopsy_full"
	else
		icon_state = "biopsy"


