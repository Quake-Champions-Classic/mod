/*
===========
ClientObituary

called when a player dies
============
*/
void(entity targ, entity attacker, entity inflictor) ClientObituaryOld;

void(entity targ, entity attacker, entity inflictor) ClientObituary = {
	float rnum, attackerteam, targteam;
	string deathstring, deathstring2; // Needed for QCC custom stuff because I don't know how to make 

	if (!ExtSupported("EX_BPRINT")) { // Backwards compatibility - may want to provide language support later
		ClientObituaryOld(targ, attacker, inflictor);
		return;
	}
	
	attackerteam = attacker.team;
	targteam = targ.team;

	rnum = random();

	if (targ.classname == "player") {
		if (attacker.classname == "teledeath") {
			// QCC ------------------------------------------------------------------
			if (attacker.owner.qccChampion == QCC_RANGER && attacker.owner.qccAbilityTimer > time + 43) {
				bprint(targ.netname);
				bprint(" was disintegrated by ");
				bprint(attacker.owner.netname);
				bprint("'s deadly slipgate\n");
			}
			else if (attacker.owner.qccChampion == QCC_NYX && attacker.owner.weapon == QCC_ABILITY) {	
				bprint(targ.netname);
				bprint(" was turned inside out by ");
				bprint(attacker.owner.netname);
				bprint("\n");
			}
			// ----------------------------------------------------------------------
			else
				bprint("$qc_telefragged", targ.netname, attacker.owner.netname);
			
			add_frag(attacker.owner, 1);
			return;
		}

		if (attacker.classname == "teledeath2") {
			bprint("$qc_satans_power", targ.netname);
			add_frag(targ, -1);
			return;
		}

		if (inflictor.qccFlags & QCC_FL_THROWABLE && inflictor.qccAbilityOwner.qccChampion == QCC_DUSKDUDE) {
			bprint(targ.netname);
			bprint(" caught ");
			bprint(inflictor.qccAbilityOwner.netname);
			bprint("'s pass with their face\n");
			return;
		}

		if (attacker.classname == "player") {
			if (targ == attacker) {
				// killed self
				add_frag(attacker, -1);
				
				if (targ.weapon == 64 && targ.waterlevel > 1) {
					if (targ.watertype == CONTENT_SLIME)
						bprint("$qc_discharge_slime", targ.netname);

					else if (targ.watertype == CONTENT_LAVA)
						bprint("$qc_discharge_lava", targ.netname);

					else
						bprint("$qc_discharge_water", targ.netname);

					return;
				}
				if (targ.weapon == IT_GRENADE_LAUNCHER) {
					bprint("$qc_suicide_pin", targ.netname); 
					return;
				}
				
				if (targ.weapon == QCC_ABILITY) {
					switch (targ.qccChampion) {
					case QCC_DUKENUKEM: 
						bprint(" devastated theirself.\n"); 
						return;
					case QCC_CALEB: 
						bprint(" didn't pay attention to the fuse.\n"); 
						return;
					}
				}
				if (inflictor.classname == "flamestrike") {
					bprint("'s Incendimus backfired.\n");
					return;
				}
				if (inflictor.classname == "keelgrenade" || inflictor.classname == "keelminigrenade") {
					bprint(" choked on his own pineapples.\n");
					return;
				}
				
				// Probably a rocket launcher
				if (rnum > 0.4)
					bprint("$qc_suicide_bored", targ.netname);
				else
					bprint("$qc_suicide_loaded", targ.netname);
				return;
			}
			else if ((teamplay == 2 || deathmatch >= QCC_TDM) && (targteam == attackerteam) && (attackerteam != 0)) {
				if (rnum < 0.25)
					bprint("$qc_ff_teammate", attacker.netname);
				else if (rnum < 0.50)
					bprint("$qc_ff_glasses", attacker.netname);
				else if (rnum < 0.75)
					bprint("$qc_ff_otherteam", attacker.netname);
				else
					bprint("$qc_ff_friend", attacker.netname);

				add_frag(attacker, -1);
				return;
			}
			else {
				add_frag(attacker, 1);

				// HIP ---------------------------------------------------------------------
				//MED 01/19/97
				if (empathyused == 1) {
					if (random()<0.5)
						bprint("$qc_death_empathy1", targ.netname, attacker.netname);
					else
						bprint("$qc_death_empathy2", targ.netname, attacker.netname);
					return;
				}

				//MED 11/18/96
				if (targ.dmg_inflictor.classname == "proximity_grenade") {
					if (random()<0.5)
						bprint("$qc_death_bomb1", targ.netname, attacker.netname);
					else
						bprint("$qc_death_bomb2", targ.netname, attacker.netname);
					return;
				}
				// --------------------------------------------------------------------------

				rnum = attacker.weapon;
				
				// QCC: Ability entity death messages --------------------------------------------
				if (inflictor.classname == "direorb") {
					bprint(targ.netname);
					bprint(" was caught in ");
					bprint(attacker.netname);
					bprint("'s deadly slipgate\n");
					return;
				}
				if (inflictor.classname == "flamestrike") {
					bprint(targ.netname);
					bprint(" was immolated by ");
					bprint(attacker.netname);
					bprint("'s Incendimus\n");
					return;
				}
				if (inflictor.classname == "keenshot") {
					bprint(targ.netname);
					bprint(" had their brain fried by ");
					bprint(attacker.netname);
					bprint("'s Neural Stunner\n");
					return;
				}
				if (inflictor.classname == "keelgrenade" || inflictor.classname == "keelminigrenade") {
					bprint(targ.netname);
					bprint(" was blown apart by ");
					bprint(attacker.netname);
					bprint("'s pineapple\n");
					return;
				}
				if (inflictor.classname == "heavyweight") {
					bprint(targ.netname);
					bprint(" couldn't stop ");
					bprint(attacker.netname);
					bprint("'s momentum\n");
					return;
				}
                if (inflictor.classname == "acidspit") {
					bprint(targ.netname);
					bprint(" was melted down by ");
					bprint(attacker.netname);
					bprint("'s acid spit\n");
					return;
				}
				else if (inflictor.classname == "unholy_totoem") {
					bprint(targ.netname);
					bprint(" was cursed by ");
					bprint(attacker.netname);
					bprint("'s unholy totem.\n");
					return;
				}
				if (inflictor.classname == "dynamite") {
					bprint(targ.netname);
					bprint(" was turned into barbecue by ");
					bprint(attacker.netname);
					bprint("\n");
					return;
				}
				if (inflictor.classname == "bigjohnshot") {
					bprint(targ.netname);
					bprint(" couldn't do it to ");
					bprint(attacker.netname);
					bprint("\n");
					return;
				}
				// ----------------------------------------------------------------------------------------
				if (rnum == IT_AXE) {
					deathstring2 = "\n";
					if (attacker.qccChampion == QCC_RANGER) {
						bprint("$qc_death_ax", targ.netname, attacker.netname);
						return;
					}
					else if (attacker.qccChampion == QCC_DEATHKNIGHT || attacker.qccChampion == QCC_NYX)
						deathstring = " was cut down by ";
					else if (attacker.qccChampion == QCC_DOOMSLAYER) {
						if (attacker.qccAbilityTimer < 0)
							deathstring = " was ripped and torn by ";
						else	
							deathstring = " was beaten to a pulp by ";
					}
					else if (attacker.qccChampion == QCC_KEEN)
						deathstring = " was pogostuck by ";
                    else if (attacker.qccChampion == QCC_SORLAG)
						deathstring = " had the flesh peeled from their bones by ";
					else if (attacker.qccChampion == QCC_DUKENUKEM)
						deathstring = " received an ass-kicking by ";
					else if (attacker.qccChampion == QCC_CALEB)
						deathstring = " was impaled by ";
					else if (attacker.qccChampion == QCC_DUSKDUDE)
						deathstring = " was reaped by ";
					else 
						deathstring = " was humiliated by ";
					bprint(targ.netname);
					bprint(deathstring);
					bprint(attacker.netname);
					bprint(deathstring2);
					return;
				}

				if (rnum == IT_SHOTGUN) {
					bprint("$qc_death_sg", targ.netname, attacker.netname);
					return;
				}
				if (rnum == IT_SUPER_SHOTGUN) {
					bprint("$qc_death_dbl", targ.netname, attacker.netname);
					return;
				}
				if (rnum == IT_NAILGUN) {
					bprint("$qc_death_nail", targ.netname, attacker.netname);
					return;
				}
				if (rnum == IT_SUPER_NAILGUN) {
					bprint("$qc_death_sng", targ.netname, attacker.netname);
					return;
				}
				if (rnum == IT_GRENADE_LAUNCHER) {
					if (targ.health < -40)
						bprint("$qc_death_gl1", targ.netname, attacker.netname);
					else
						bprint("$qc_death_gl2", targ.netname, attacker.netname);
					return;
				}
				if (rnum == IT_ROCKET_LAUNCHER) {
					if (attacker.super_damage_finished > 0 && targ.health < -40) {
						rnum = random();
						if (rnum < 0.3)
							bprint("$qc_death_rl_quad1", targ.netname, attacker.netname);
						else if (rnum < 0.6)
							bprint("$qc_death_rl_quad2", targ.netname, attacker.netname);
						else
							bprint("$qc_death_rl1", targ.netname, attacker.netname);
                        return;
					}
					else {
						if (targ.health < -40)
							bprint("$qc_death_rl2", targ.netname, attacker.netname);
						else
							bprint("$qc_death_rl3", targ.netname, attacker.netname);
                        return;
					}
				}
				if (rnum == IT_LIGHTNING) {
					if (attacker.waterlevel > 1) {
						bprint("$qc_death_lg1", targ.netname, attacker.netname);
						if (attacker.invincible_finished) {
							msg_entity = attacker;
							WriteByte(MSG_ONE, SVC_ACHIEVEMENT);
							WriteString(MSG_ONE, "ACH_SURVIVE_DISCHARGE");
						}
					}
					else
						bprint("$qc_death_lg2", targ.netname, attacker.netname);					
					return;
				}

				// HIP: MED ------------------------------------------------------------
				if (rnum == IT_LASER_CANNON) {
					if (random()<0.5)
						bprint("$qc_death_laser1", targ.netname, attacker.netname);
					else
						bprint("$qc_death_laser2", targ.netname, attacker.netname);
					return;
				}
				if (rnum == IT_MJOLNIR) {
					bprint("$qc_death_hammer", targ.netname, attacker.netname);
					return;
				}
				// ---------------------------------------------------------------------

				// QCC -----------------------------------------------------------------
				if (rnum == QCC_IT_RAILGUN) {
					deathstring = " was impressed by ";
					deathstring2 = "'s rail\n";
					if (targ.health < -40) {
						deathstring = " was gibbed by ";
						deathstring2 = "'s rail\n";
					}
					bprint(targ.netname);
					bprint(deathstring);
					bprint(attacker.netname);
					bprint(deathstring2);
					return;
				}
				if (rnum == QCC_ABILITY) {
                    if (attacker.qccChampion == QCC_DEATHKNIGHT) {
						deathstring = " was immolated by ";
						deathstring2 = "'s Incendimus\n";
					}
                    else if (attacker.qccChampion == QCC_SCALEBEARER) {
						deathstring = " should've moved out of ";
						deathstring2 = "'s way, filth\n";
					}
					else if (attacker.qccChampion == QCC_DUKENUKEM) {
						deathstring = " was devastated by ";
						deathstring2 = "\n";
					}
					bprint(targ.netname);
					bprint(deathstring);
					bprint(attacker.netname);
					bprint(deathstring2);
					return;
				}
				if (attacker.qccAbilityTimer < 0) {
					if (attacker.qccChampion == QCC_DUSKDUDE) {
						bprint(targ.netname);
						bprint(" was overwhelmed by ");
						bprint(attacker.netname);
						bprint("'s onslaught\n");
						return;
					}
					else if (attacker.qccChampion == QCC_SLASH) {
						bprint(targ.netname);
						bprint(" was dazzled by ");
						bprint(attacker.netname);
						bprint("'s ballet\n");
						return;
					}
					else if (attacker.qccChampion == QCC_ANARKI) {
						bprint(targ.netname);
						bprint(" needs to know where he can get some of what ");
						bprint(attacker.netname);
						bprint("'s having\n");
						return;
					}
				}
				// -----------------------------------------------------------
			}
			return;
		}
		else {
			add_frag(targ, -1);		// killed self
			rnum = targ.watertype;

			// HIP: JIM ---------------------------------------
			if (attacker.deathtype) {
				bprint(attacker.deathtype, targ.netname);
				return;
			}
			// ------------------------------------------------

			// ROGUE -------------------------------------------------
			if (attacker.classname == "Vengeance") {
				// vengeance sphere doesn't count as a negative frag
				add_frag(targ, 1);
				bprint("$qc_death_vengeance", targ.netname);
				return;
			}
			if (attacker.classname == "power_shield") {
				// shield attacks should count for frags too..
				// shield death doesn't count as a negative frag
				add_frag(targ, 1);
				add_frag(attacker.owner, 1);
				bprint("$qc_death_smashed", targ.netname, attacker.owner.netname);
				return;
			}
			// ----------------------------------------------------------

			if (rnum == -3) {
				if (random() < 0.5)
					bprint("$qc_death_drown1", targ.netname);
				else
					bprint("$qc_death_drown2", targ.netname);

				return;
			}
			else if (rnum == -4) {
				if (random() < 0.5)
					bprint("$qc_death_slime1", targ.netname);
				else
					bprint("$qc_death_slime2", targ.netname);

				return;
			}
			else if (rnum == -5) {
				if (targ.health < -15) {
					bprint("$qc_death_lava1", targ.netname);
					return;
				}
				if (random() < 0.5)
					bprint("$qc_death_lava2", targ.netname);
				else
					bprint("$qc_death_lava3", targ.netname);
				return;
			}

			if (attacker.solid == SOLID_BSP && attacker != world) {	
				bprint("$qc_death_squish", targ.netname);
				return;
			}

			if (attacker.killstring) {
				bprint(attacker.killstring, targ.netname);
				return;
			}

			if (targ.deathtype == "falling") {
				targ.deathtype = string_null;
				bprint("$qc_death_fall", targ.netname);
				return;
			}

			bprint("$qc_death_died", targ.netname);
		}
	}
};


/*
QCC ===========================================
ClientObituaryOld

for backwards compatibility
===============================================
*/
void(entity targ, entity attacker, entity inflictor) ClientObituaryOld = {
	local	float rnum;
	local	string deathstring, deathstring2;
	rnum = random();

	if (targ.classname == "player") {
		if (attacker.classname == "teledeath") {
			bprint(targ.netname);
			// QCC -----------------------------------------------------------------------------
			if (attacker.owner.qccChampion == QCC_RANGER && attacker.owner.qccAbilityTimer > time + 43) {
				bprint(" was disintegrated by ");
				bprint(attacker.owner.netname);
				bprint("'s deadly slipgate");
			}
			else if (attacker.owner.qccChampion == QCC_NYX && attacker.owner.weapon == QCC_ABILITY) {	
				bprint(" was turned inside out by ");
				bprint(attacker.owner.netname);
			}
			// ---------------------------------------------------------------------------------
			else {
				bprint(" was telefragged by ");
				bprint(attacker.owner.netname);
			}
			bprint("\n");
			add_frag(attacker.owner, 1);
			return;
		}

		if (attacker.classname == "teledeath2") {
			bprint("Satan's power deflects ");
			bprint(targ.netname);
			bprint("'s telefrag\n");
			add_frag(targ, -1);
			return;
		}

		// QCC: Duskdude threw stuff and killed you ---------------------------------------------------------
		if (inflictor.qccFlags & QCC_FL_THROWABLE && inflictor.qccAbilityOwner.qccChampion == QCC_DUSKDUDE) {
			bprint(targ.netname);
			bprint(" caught ");
			bprint(inflictor.qccAbilityOwner.netname);
			bprint("'s pass with their face\n");
			return;
		}
		// --------------------------------------------------------------------------------------------------

		if (attacker.classname == "player") {
			if (targ == attacker) {
				// killed self
				add_frag(attacker, -1);
				bprint(targ.netname);
				
				if (targ.weapon == IT_LIGHTNING && targ.waterlevel > 1) {
					bprint(" discharges into the water.\n");
					return;
				}
				if (targ.weapon == IT_GRENADE_LAUNCHER) {
					bprint(" tries to put the pin back in\n");
					return;
				}

				if (targ.weapon == QCC_ABILITY) {
					switch (targ.qccChampion) {
						case QCC_DUKENUKEM: 
							bprint(" devastated theirself.\n"); 
							return;
						case QCC_CALEB: 
							bprint(" didn't pay attention to the fuse.\n"); 
							return;
					}
				}
				if (inflictor.classname == "flamestrike") {
					bprint("'s Incendimus backfired.\n");
					return;
				}
				if (inflictor.classname == "keelgrenade" || inflictor.classname == "keelminigrenade") {
					bprint(" choked on his own pineapples.\n");
					return;
				}

				// Probably a rocket launcher
				if (rnum > 0.4)
					bprint(" becomes bored with life\n");
				else
					bprint(" checks if their weapon is loaded\n"); // HIP: JIM
				return;
			}
			else if ((teamplay == 2 || deathmatch >= QCC_TDM) && (targ.team > 0)&&(targ.team == attacker.team)) {
				if (rnum < 0.25)
					deathstring = " mows down a teammate\n";
				else if (rnum < 0.50)
					deathstring = " checks his glasses\n";
				else if (rnum < 0.75)
					deathstring = " gets a frag for the other team\n";
				else
					deathstring = " loses another friend\n";
				bprint(attacker.netname);
				bprint(deathstring);
				add_frag(attacker, -1);
				return;
			}
			else {
				add_frag(attacker, 1);

				// HIP START -------------------------------------------------
				//MED 01/19/97
				if (empathyused == 1) {
					bprint(targ.netname);
					if (random()<0.5)
						bprint(" shares ");
					else
						bprint(" feels ");
					bprint(attacker.netname);
					bprint("'s pain\n");
					return;
				}
 				//MED 11/18/96
				if (targ.dmg_inflictor.classname == "proximity_grenade") {
					bprint(targ.netname);
					if (random()<0.5)
						bprint(" got too friendly with ");
					else
						bprint(" did the rhumba with ");
					bprint(attacker.netname);
					bprint("'s bomb\n");
					return;
				}
				// HIP END ---------------------------------------------------

				rnum = attacker.weapon;

				// QCC: Ability entity death messages ---------------------------------
				if (inflictor.classname == "direorb") {
					deathstring = " was caught in ";
					deathstring2 = "'s deadly slipgate\n";
				}
				else if (inflictor.classname == "flamestrike") {
					deathstring = " was immolated by ";
					deathstring2 = "'s Incendimus\n";
				}
				else if (inflictor.classname == "keenshot") {
					deathstring = " had their brain fried by ";
					deathstring2 = "'s Neural Stunner\n";
				}
				else if (inflictor.classname == "keelgrenade" || inflictor.classname == "keelminigrenade") {
					deathstring = " was blown apart by ";
					deathstring2 = "'s pineapple\n";
				}
				else if (inflictor.classname == "heavyweight") {
					deathstring = " couldn't stop ";
					deathstring2 = "'s momentum\n";
				}
                else if (inflictor.classname == "acidspit") {
					deathstring = " was melted down by ";
					deathstring2 = "'s acid spit\n";
				}
				else if (inflictor.classname == "unholy_totoem") {
					deathstring = " was cursed by ";
					deathstring2 = "'s unholy totem.\n";
				}
				else if (inflictor.classname == "dynamite") {
					deathstring = " was turned into barbecue by ";
					deathstring2 = "\n";
				}
				else if (inflictor.classname == "bigjohnshot") {
					deathstring = " couldn't do it to ";
					deathstring2 = "\n";
				}
				// --------------------------------------------------------------------

				else if (rnum == IT_AXE) {
					deathstring2 = "\n";
					if (attacker.qccChampion == QCC_RANGER)
						deathstring = " was ax-murdered by ";
					else if (attacker.qccChampion == QCC_DEATHKNIGHT || attacker.qccChampion == QCC_NYX)
						deathstring = " was cut down by ";
					else if (attacker.qccChampion == QCC_DOOMSLAYER) {
						if (attacker.qccAbilityTimer < 0)
							deathstring = " was ripped and torn by ";
						else	
							deathstring = " was beaten to a pulp by ";
					}
					else if (attacker.qccChampion == QCC_KEEN)
						deathstring = " was pogostuck by ";
                    else if (attacker.qccChampion == QCC_SORLAG)
						deathstring = " had the flesh peeled from their bones by ";
					else if (attacker.qccChampion == QCC_DUKENUKEM)
						deathstring = " received an ass-kicking by ";
					else if (attacker.qccChampion == QCC_CALEB)
						deathstring = " was impaled by ";
					else if (attacker.qccChampion == QCC_DUSKDUDE)
						deathstring = " was reaped by ";
					else 
						deathstring = " was humiliated by ";
				}
				else if (rnum == IT_SHOTGUN) {
					deathstring = " chewed on ";
					deathstring2 = "'s boomstick\n";
				}
				else if (rnum == IT_SUPER_SHOTGUN) {
					deathstring = " ate 2 loads of ";
					deathstring2 = "'s buckshot\n";
				}
				else if (rnum == IT_NAILGUN) {
					deathstring = " was nailed by ";
					deathstring2 = "\n";
				}
				else if (rnum == IT_SUPER_NAILGUN) {
					deathstring = " was punctured by ";
					deathstring2 = "\n";
				}
				else if (rnum == IT_GRENADE_LAUNCHER) {
					deathstring = " eats ";
					deathstring2 = "'s pineapple\n";
					if (targ.health < -40) {
						deathstring = " was gibbed by ";
						deathstring2 = "'s grenade\n";
					}
				}
				else if (rnum == IT_ROCKET_LAUNCHER) {
					deathstring = " rides ";
					deathstring2 = "'s rocket\n";
					if (targ.health < -40) {
						deathstring = " was gibbed by ";
						deathstring2 = "'s rocket\n" ;
					}
				}
				else if (rnum == IT_LIGHTNING) {
					deathstring = " accepts ";
					if (attacker.waterlevel > 1)
						deathstring2 = "'s discharge\n";
					else
						deathstring2 = "'s shaft\n";
				}

				// HIP: MED ----------------------------------------------------
				else if (rnum == IT_LASER_CANNON) {
					if (random()<0.5)
						deathstring = " was toasted by ";
					else
						deathstring = " was radiated by ";
					deathstring2 = "'s laser\n";
				}
				else if (rnum == IT_MJOLNIR) {
					deathstring = " was slammed by ";
					deathstring2 = "'s hammer\n";
				}
				// -------------------------------------------------------------

				// QCC ---------------------------------------------------------
				else if (rnum == QCC_IT_RAILGUN) {
					deathstring = " was impressed by ";
					deathstring2 = "'s rail\n";
					if (targ.health < -40) {
						deathstring = " was gibbed by ";
						deathstring2 = "'s rail\n" ;
					}
				}
				else if (rnum == QCC_ABILITY) {
					if (attacker.qccChampion == QCC_DEATHKNIGHT) {
						deathstring = " was immolated by ";
						deathstring2 = "'s Incendimus\n";
					}
                    else if (attacker.qccChampion == QCC_SCALEBEARER) {
						deathstring = " should've moved out of ";
						deathstring2 = "'s way, filth\n";
					}
					else if (attacker.qccChampion == QCC_DUKENUKEM) {
						deathstring = " was devastated by ";
						deathstring2 = "\n";
					}
				}
				if (attacker.qccAbilityTimer < 0) {
					if (attacker.qccChampion == QCC_DUSKDUDE) {
						deathstring = " was overwhelmed by ";
						deathstring2 = "'s onslaught\n";
					}
					else if (attacker.qccChampion == QCC_SLASH) {
						deathstring = " was dazzled by ";
						deathstring2 = "'s ballet\n";
					}
					else if (attacker.qccChampion == QCC_ANARKI) {
						deathstring = " needs to know where he can get some of what ";
						deathstring2 = "'s having\n";
					}
				}
				// ------------------------------------------------------------
				bprint(targ.netname);
				bprint(deathstring);
				bprint(attacker.netname);
				bprint(deathstring2);
			}
			return;
		}
		else {
			add_frag(targ, -1);
			bprint(targ.netname);

			// HIP: JIM ----------------------------
			if (attacker.deathtype) {
            	bprint(" ");
            	bprint(attacker.deathtype);
            	bprint("\n");
            	return;
            }
			// -------------------------------------

			// ROGUE -------------------------------------------------
			if (attacker.classname == "Vengeance") {
				// vengeance sphere doesn't count as a negative frag
				add_frag(targ, 1);
				bprint(" was purged by the Vengeance Sphere\n");
				return;
			}
			if (attacker.classname == "power_shield") {
				// shield attacks should count for frags too..
				// shield death doesn't count as a negative frag
				add_frag(targ, 1);
				add_frag(attacker.owner, 1);
				bprint(" was smashed by ");
				bprint(attacker.owner.netname);
				return;
			}
			// ----------------------------------------------------------

			rnum = targ.watertype;
			if (rnum == -3) {
				if (random() < 0.5)
					bprint(" sleeps with the fishes\n");
				else
					bprint(" sucks it down\n");
				return;
			}
			else if (rnum == -4) {
				if (random() < 0.5)
					bprint(" gulped a load of slime\n");
				else
					bprint(" can't exist on slime alone\n");
				return;
			}
			else if (rnum == -5) {
				if (targ.health < -15) {
					bprint(" burst into flames\n");
					return;
				}
				if (random() < 0.5)
					bprint(" turned into hot slag\n");
				else
					bprint(" visits the Volcano God\n");
				return;
			}
			
			if (attacker.solid == SOLID_BSP && attacker != world) {	
				bprint(" was squished\n");
				return;
			}

			if (attacker.killstring) {
				bprint(attacker.killstring);
				return;
			}

			// fell to their death?
			if (targ.deathtype == "falling") {
				targ.deathtype = "";
				bprint(" fell to his death\n");
				return;
			}

			// hell if I know; he's just dead!!!
			bprint(" died\n");
		}
	}
};