/*!

This component is used in vat growing to swab for microbiological samples which can then be mixed with reagents in a petridish to create a culture plate.

*/
/datum/component/swabbing
	///The current datums on the swab
	var/list/swabbed_items = list()
	///Can we swab objs?
	var/CanSwabObj
	///Can we swab turfs?
	var/CanSwabTurf
	///Can we swab mobs?
	var/CanSwabMob

/datum/component/swabbing/Initialize(CanSwabObj = TRUE, CanSwabTurf = TRUE, CanSwabMob = FALSE, swab_time = 10, max_items = 3)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_ITEM_PRE_ATTACK, .proc/TryToSwab)
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/examine)

	src.CanSwabObj = CanSwabObj
	src.CanSwabTurf = CanSwabTurf
	src.CanSwabMob = CanSwabMob

///Changes examine based on your sample
/datum/component/swabbing/proc/examine(datum/source, mob/user, list/examine_list)
	if(swabbed_items.len)
		examine_list += "<span class='nicegreen'>There is a microbiological sample on [parent]!</span>"
	if(user.research_scanner) //For some reason a mob var
		examine_list += "<span class='notice'>You can see the following micro-organism:</span>"
		for(var/i in swabbed_items)
			var/datum/biological_sample/samp = i
			examine_list += samp.GetAllDetails() //Get just the names nicely parsed.

///Ran when you attack an object, tries to get a swab of the object. if a swabbable surface is found it will run behavior and hopefully
/datum/component/swabbing/proc/TryToSwab(datum/source, atom/target, mob/user, params)
	set waitfor = FALSE //This prevents do_after() from making this proc not return it's value.

	if(istype(target, /obj/item/petri_dish))
		var/obj/item/petri_dish/dish = target
		if(dish.sample)
			return

		var/datum/biological_sample/deposited_sample

		for(var/datum/biological_sample/sample/S in swabbed_items) //Typed in case there is a non sample on the swabbing tool because someone was fucking with swabbable element
			//Collapse the samples into one sample; one gooey mess essentialy.
			if(!deposited_sample)
				deposited_sample = S
			else
				deposited_sample.Merge(S)

		dish.deposit_sample(user, deposited_sample)

		return COMPONENT_NO_ATTACK
	if(!can_swab(target))
		return NONE //Just do the normal attack.

	. = COMPONENT_NO_ATTACK //Point of no return. No more attacking after this.

	to_chat(user, "<span class='notice'>You start swabbing the surface of [target] for samples!</span>")
	if(!do_after(user, 30, TRUE, target)) // Start swabbing boi
		return

	if(swabbed_items.len >= 3)
		to_chat(user, "<span class='warning'>You cannot collect another sample on the swabber!</span>")
		return

	if(!SEND_SIGNAL(src, COMSIG_SWAB_FOR_SAMPLES, src, swabbed_items)) //If we found something to swab now we let the swabbed thing handle what it would do, we just sit back and relax now.
		to_chat(user, "<span class='warning'>You do not manage to find a anything on [target]!</span>")
		return

	if(!swabbed_items.len)
		to_chat(user, "<span class='nicegreen'>You manage to collect a microbiological sample from [target]!</span>")
	else
		to_chat(user, "<span class='warning'>You manage to collect a microbiological sample from [target]...But there was already one there!</span>")

	target.RemoveElement(/datum/element/swabable)

///Checks if the swabbing component can swab the specific object or not
/datum/component/swabbing/proc/can_swab(atom/target)
	if(isobj(target))
		return CanSwabObj
	if(isturf(target))
		return CanSwabTurf
	if(ismob(target))
		return CanSwabMob


