/mob/living/carbon/movement_delay()
	. = ..()

	if(!get_leg_ignore() && legcuffed) //ignore the fact we lack legs
		. += legcuffed.slowdown

/mob/living/carbon/slip(knockdown_amount, obj/O, lube, paralyze, force_drop)
	if(movement_type & FLYING)
		return 0
	if(!(lube&SLIDE_ICE))
		log_combat(src, (O ? O : get_turf(src)), "slipped on the", null, ((lube & SLIDE) ? "(LUBE)" : null))
	return loc.handle_slip(src, knockdown_amount, O, lube, paralyze, force_drop)

/mob/living/carbon/Process_Spacemove(movement_dir = 0)
	if(..())
		return 1
	if(!isturf(loc))
		return 0

	// Do we have a jetpack implant (and is it on)?
	var/obj/item/organ/cyberimp/chest/thrusters/T = getorganslot(ORGAN_SLOT_THRUSTERS)
	if(istype(T) && movement_dir && T.allow_thrust(0.01))
		return 1

	var/obj/item/tank/jetpack/J = get_jetpack()
	if(istype(J) && (movement_dir || J.stabilizers) && J.allow_thrust(0.01, src))
		return 1

/mob/living/carbon/Move(NewLoc, direct)
	. = ..()
	if(. && mob_has_gravity()) //floating is easy
		if(HAS_TRAIT(src, TRAIT_NOHUNGER))
			nutrition = NUTRITION_LEVEL_FED - 1	//just less than feeling vigorous
		else if(nutrition && stat != DEAD) // GS13 : one fourth of the consumed energy comes from fat
			var/fat_burned = min(HUNGER_FACTOR/40, fatness)
			var/nutrition_lost_divider = 12
			if(m_intent == MOVE_INTENT_RUN) // GS13 : running will burn more fat (you'll get more tired tho)
				fat_burned = min(HUNGER_FACTOR/20, fatness)
				nutrition_lost_divider = 5
			nutrition -= (HUNGER_FACTOR/nutrition_lost_divider - fat_burned)
			fatness -= fat_burned
