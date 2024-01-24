void() QCC_Precaches =
{
	// Ability cooldown fx
	precache_sound("ablready.wav");
	// Gauntlet
	precache_model("progs/v_gaunt.mdl"); precache_sound("weapons/gauntshot.wav");
	// Railgun
	precache_model("progs/v_rail.mdl"); precache_model("progs/g_rail.mdl"); precache_model("progs/s_rail.mdl"); precache_sound("weapons/railshot.wav");
	// Hourglass
	precache_model("progs/qchourglass.mdl");
	precache_sound("timeoff.wav");
	// Armor
	precache_model("progs/qcarmorshard.mdl"); precache_sound("items/armorshard.wav");
	precache_model("progs/qclarmor.mdl"); precache_sound("items/lightarmor.wav");

	// RANGER
	precache_model("progs/qcranger.mdl"); precache_model("progs/v_dorb.mdl"); precache_model("progs/w_dorb.mdl"); precache_sound("misc/r_tele2.wav");

	// DEATH KNIGHT
	precache_model("progs/qcdknight.mdl"); precache_model("progs/v_dksword.mdl"); precache_model("progs/k_spike.mdl"); precache_model("progs/flame2.mdl"); // for the flame trail
	precache_model("progs/h_hellkn.mdl"); precache_sound("hknight/attack1.wav"); precache_sound("hknight/attack1.wav"); precache_sound("hknight/slash1.wav");
	precache_sound("hknight/death1.wav"); precache_sound("hknight/pain1.wav"); precache_sound("hknight/sight1.wav"); precache_sound("hknight/hit.wav");
	precache_sound("hknight/idle.wav"); precache_sound("hknight/grunt.wav");

	// NYX
	precache_model("progs/qcnyx.mdl"); precache_model("progs/qcinvis.mdl"); // ghostwalk model (really just a single tiny tri, hope it works)
	precache_model("progs/v_nxsword.mdl"); precache_model("progs/h_qcnyx.mdl");
	precache_sound("nyx/invisenter.wav"); precache_sound("nyx/invisexit.wav");
	precache_sound("nyx/invis1.wav"); precache_sound("nyx/invis2.wav"); precache_sound("nyx/invis3.wav"); precache_sound("nyx/invis4.wav");
	precache_sound("nyx/nyxjump.wav");	precache_sound("nyx/nyxland.wav"); precache_sound("nyx/nyxland2.wav");
	precache_sound("nyx/nyxpain1.wav"); precache_sound("nyx/nyxpain2.wav"); precache_sound("nyx/nyxpain3.wav"); precache_sound("nyx/nyxpain4.wav");
	precache_sound("nyx/nyxdeath1.wav"); precache_sound("nyx/nyxdeath2.wav"); precache_sound("nyx/nyxdeath3.wav");
	precache_sound("nyx/nyxgasp1.wav"); precache_sound("nyx/nyxgasp2.wav");
	precache_sound("silence.wav"); precache_sound("knight/sword1.wav");

	// DOOM SLAYER
	precache_model("progs/qcdoom.mdl"); precache_model("progs/v_punch.mdl"); precache_model("progs/h_qcdoom.mdl");
	precache_sound("doom/dsland2.wav"); precache_sound("doom/dsjump.wav"); precache_sound("doom/dsjump2.wav");
	precache_sound("doom/dsplpain.wav"); precache_sound("doom/dspldeth.wav"); precache_sound("doom/dspdiehi.wav");
	precache_sound("doom/dspunch.wav"); precache_sound("doom/dsgetpow.wav"); precache_sound("doom/dsoof.wav");

	// COMMANDER KEEN
	precache_model("progs/qckeen.mdl");  precache_model("progs/qckeen2.mdl");  precache_model("progs/v_pogo.mdl");
	precache_model("progs/v_keenray.mdl");  precache_model("progs/s_keenshot.mdl");  precache_model("progs/h_qckeen.mdl");
	precache_sound("keen/jump.wav"); precache_sound("keen/land.wav"); precache_sound("keen/land2.wav");
	precache_sound("keen/pogo.wav"); precache_sound("keen/jumpatk.wav"); 
	precache_sound("keen/rayequip.wav"); precache_sound("keen/rayshoot.wav"); precache_sound("keen/rayhit.wav"); 
	precache_sound("keen/pain0.wav"); precache_sound("keen/pain1.wav"); precache_sound("keen/pain2.wav"); 
	precache_sound("keen/death1.wav"); precache_sound("keen/death2.wav");
	precache_sound("keen/start.wav"); precache_sound("keen/mortstart.wav");

	// KEEL
	precache_model("progs/qckeel.mdl"); precache_model("progs/h_qckeel.mdl");
	precache_sound("keel/keeljump.wav"); precache_sound("keel/keelland.wav"); precache_sound("keel/keelland2.wav");
	precache_sound("keel/keelpain1.wav"); precache_sound("keel/keelpain2.wav"); precache_sound("keel/keelpain3.wav"); precache_sound("keel/keelpain4.wav");
	precache_sound("keel/keeldeath1.wav"); precache_sound("keel/keeldeath2.wav"); precache_sound("keel/keeldeath3.wav");
	precache_sound("keel/keelgasp1.wav"); precache_sound("keel/keelgasp2.wav");
	precache_sound("keel/keelabl.wav"); precache_sound("keel/keelablin.wav"); precache_sound("keel/keelablout.wav");

	// SCALEBEARER
	precache_model("progs/qcscale.mdl"); precache_model("progs/h_qcscale.mdl");
	precache_sound("scale/scalejump.wav"); precache_sound("scale/scaleland.wav"); precache_sound("scale/scaleland2.wav");
	precache_sound("scale/scalepain1.wav"); precache_sound("scale/scalepain2.wav"); precache_sound("scale/scalepain3.wav"); precache_sound("scale/scalepain4.wav");
	precache_sound("scale/scaledeath1.wav"); precache_sound("scale/scaledeath2.wav"); precache_sound("scale/scaledeath3.wav");
	precache_sound("scale/scalegasp1.wav"); precache_sound("scale/scalegasp2.wav"); precache_sound("scale/bullrush.wav");

	// SORLAG
	precache_model("progs/qcsorlag.mdl"); precache_model("progs/h_qcsorlag.mdl"); precache_model("progs/v_sorclaw.mdl");
	precache_model("progs/s_sorspit.mdl"); precache_model("progs/s_sorpool.mdl");
	precache_sound("demon/dhit2.wav"); precache_sound("sorlag/acidspit.wav"); precache_sound("blob/land1.wav");
	precache_sound("sorlag/sorjump.wav"); precache_sound("sorlag/sorland.wav"); precache_sound("sorlag/sorland2.wav");
	precache_sound("sorlag/sorpain1.wav"); precache_sound("sorlag/sorpain2.wav"); precache_sound("sorlag/sorpain3.wav"); precache_sound("sorlag/sorpain4.wav");
	precache_sound("sorlag/sordeath1.wav"); precache_sound("sorlag/sordeath2.wav"); precache_sound("sorlag/sordeath3.wav");
	precache_sound("sorlag/sorgasp1.wav"); precache_sound("sorlag/sorgasp2.wav");

	// SLASH
	precache_model("progs/qcslash.mdl"); precache_model("progs/h_qcslash.mdl"); precache_model("progs/w_plastrail.mdl");
	precache_sound("slash/slashab1.wav"); precache_sound("slash/slashab2.wav");
	precache_sound("slash/slashjump.wav");	precache_sound("slash/slashland.wav"); precache_sound("slash/slashland2.wav");
	precache_sound("slash/slashpain1.wav"); precache_sound("slash/slashpain2.wav"); precache_sound("slash/slashpain3.wav"); precache_sound("slash/slashpain4.wav");
	precache_sound("slash/slashdie1.wav"); precache_sound("slash/slashdie2.wav"); precache_sound("slash/slashdie3.wav");
	precache_sound("slash/slashgasp1.wav"); precache_sound("slash/slashgasp2.wav");
	precache_sound("slash/slidestart.wav"); precache_sound("slash/slideloop1.wav"); precache_sound("slash/slideloop2.wav"); precache_sound("slash/slideloop3.wav");
	precache_sound("slash/slideloop4.wav"); precache_sound("slash/slideloop5.wav"); precache_sound("slash/slidestop.wav");
	precache_sound("slash/plasstart.wav"); precache_sound("slash/plasloop.wav"); precache_sound("slash/plasstop.wav"); precache_sound("slash/plasexp.wav");
	precache_sound("slash/plaschain1.wav"); precache_sound("slash/plaschain2.wav"); precache_sound("slash/plaschain3.wav"); precache_sound("slash/plaschain4.wav");
	precache_sound("slash/plaschain5.wav");

	// ANARKI
	precache_model("progs/qcanarki.mdl"); precache_model("progs/h_qcanarki.mdl");
	precache_sound("anarki/anarab1.wav"); precache_sound("anarki/anarab2.wav"); precache_sound("anarki/anarab3.wav"); precache_sound("anarki/anarinject.wav");
	precache_sound("anarki/anarjump.wav");	precache_sound("anarki/anarland.wav"); precache_sound("anarki/anarland2.wav");
	precache_sound("anarki/anarpain1.wav"); precache_sound("anarki/anarpain2.wav"); precache_sound("anarki/anarpain3.wav"); precache_sound("anarki/anarpain4.wav");
	precache_sound("anarki/anardie1.wav"); precache_sound("anarki/anardie2.wav"); precache_sound("anarki/anardie3.wav");
	precache_sound("anarki/anargasp1.wav"); precache_sound("anarki/anargasp2.wav");

	// GALENA
	precache_model("progs/qcgalena.mdl"); precache_model("progs/h_qcgalena.mdl"); precache_model("progs/w_totem.mdl");
	precache_sound("galena/galjump.wav"); precache_sound("galena/galland.wav"); precache_sound("galena/galland2.wav");
	precache_sound("galena/galpain1.wav"); precache_sound("galena/galpain2.wav"); precache_sound("galena/galpain3.wav"); precache_sound("galena/galpain4.wav");
	precache_sound("galena/galdeath1.wav"); precache_sound("galena/galdeath2.wav"); precache_sound("galena/galdeath3.wav");
	precache_sound("galena/galgasp1.wav"); precache_sound("galena/galgasp2.wav");
	precache_sound("galena/galabl1.wav"); precache_sound("galena/galabl2.wav"); precache_sound("galena/galabl3.wav"); precache_sound("galena/galabl4.wav");
	precache_sound("galena/totemthro.wav"); precache_sound("galena/totemrdy.wav"); precache_sound("galena/totemkill.wav"); precache_sound("galena/totemexp.wav");
	precache_sound("galena/totemheal.wav");

	// DUKE NUKEM
	precache_model("progs/qcduke.mdl");		// player Duke model
	precache_model("progs/qcduke2.mdl");	// Duke Nukem 1 skin model
	precache_model("progs/h_qcduke.mdl");	// gib model
	precache_model("progs/v_mfoot.mdl");	// Duke melee view model
	precache_model("progs/v_deva.mdl");	// Devastator view model
	precache_sound("duke/wpnsel21.wav"); // Equip the Devastator
	precache_sound("duke/deva.wav"); // Fire the Devastator
	precache_sound("duke/kickhit.wav"); // Melee sound
	precache_sound("duke/jetpaki.wav"); // Jetpack idle
	precache_sound("duke/jetpakof.wav"); // Jetpack end
	precache_sound("duke/jump.wav"); precache_sound("duke/land02.wav"); precache_sound("duke/land2.wav");
	precache_sound("duke/pain2.wav"); precache_sound("duke/pain3.wav"); precache_sound("duke/pain5.wav"); precache_sound("duke/pain6.wav");
	precache_sound("duke/pain7.wav"); precache_sound("duke/pain8.wav");
	precache_sound("duke/dmdeath.wav"); precache_sound("duke/dscrem2.wav"); precache_sound("duke/dscrem3.wav"); precache_sound("duke/dscrem1.wav");
	precache_sound("duke/dscrem4.wav"); precache_sound("duke/dscrem5.wav"); precache_sound("duke/dscrem6.wav");
	precache_sound("duke/gasps.wav"); precache_sound("duke/drown1.wav"); precache_sound("duke/drown2.wav"); precache_sound("duke/chokn.wav");
	// Start Map
	precache_sound("duke/wthplc.wav");
	if ((serverflags & 15) == 15)
		precache_sound("duke/stormgates.wav");
	precache_sound("duke/wherami.wav"); precache_sound("duke/hell90s.wav"); precache_sound("duke/romero.wav"); precache_sound("duke/betduke.wav");
	precache_sound("duke/chew.wav"); precache_sound("duke/blowshitup.wav"); precache_sound("duke/cokrok.wav"); precache_sound("duke/wansom.wav");
	// Respawn
	precache_sound("duke/cry.wav"); precache_sound("duke/kicka.wav"); precache_sound("duke/pissin.wav"); precache_sound("duke/rip.wav");
	precache_sound("duke/smackdb.wav"); precache_sound("duke/yohoho2.wav"); precache_sound("duke/nothink.wav"); precache_sound("duke/mthrfkr.wav");
	// Devastator
	precache_sound("duke/dance.wav"); precache_sound("duke/letgod.wav"); precache_sound("duke/gotmilk.wav"); precache_sound("duke/hehehe.wav");
	precache_sound("duke/timetokill.wav"); precache_sound("duke/arrivederci.wav"); precache_sound("duke/ihop.wav"); precache_sound("duke/gunguy.wav");
	precache_sound("duke/mod.wav");
	// Killed an opponent
	precache_sound("duke/aisle.wav"); precache_sound("duke/amess.wav"); precache_sound("duke/bitchn.wav"); precache_sound("duke/blowit.wav");
	precache_sound("duke/bookem.wav"); precache_sound("duke/cool.wav"); precache_sound("duke/damn.wav"); precache_sound("duke/getsom.wav");
	precache_sound("duke/gmeovr.wav"); precache_sound("duke/gothrt.wav"); precache_sound("duke/groovy.wav"); precache_sound("duke/hail.wav");
	precache_sound("duke/holysh.wav"); precache_sound("duke/imgood.wav"); precache_sound("duke/inhell.wav"); precache_sound("duke/letsrk.wav");
	precache_sound("duke/lookin.wav"); precache_sound("duke/meat.wav"); precache_sound("duke/name.wav"); precache_sound("duke/nobody.wav"); 
	precache_sound("duke/piece.wav"); precache_sound("duke/slacker.wav"); precache_sound("duke/sukitdn.wav"); precache_sound("duke/bos.wav");
	precache_sound("duke/rokrol.wav"); precache_sound("duke/betduke2.wav"); precache_sound("duke/huckleberry.wav"); precache_sound("duke/itsgood.wav");
	precache_sound("duke/ripieces.wav"); precache_sound("duke/oneking.wav"); precache_sound("duke/fragged.wav"); precache_sound("duke/trd.wav");
	// Melee kills
	precache_sound("duke/footface.wav"); precache_sound("duke/stomped.wav"); precache_sound("duke/bloodboot.wav"); precache_sound("duke/bug.wav");
	// Opponent specific kill messages
	precache_sound("duke/myself.wav"); precache_sound("duke/realthing.wav"); precache_sound("duke/kickmyass.wav"); // DUKE
	precache_sound("duke/quake.wav"); precache_sound("duke/teleport.wav"); // RANGER, SHUB
	precache_sound("duke/doomedsm.wav"); // DOOM SLAYER
	precache_sound("duke/scrapyard.wav"); // STROGG, CLUTCH
	precache_sound("duke/allbizbabe.wav"); // NYX, GALENA, ATHENA, SORLAG
	precache_sound("duke/crowbar.wav"); // GORDON FREEMAN
	precache_sound("duke/pwrarmr.wav"); // MASTER CHIEF
	precache_sound("duke/dukesentya.wav"); // CTHON, DEATH KNIGHT

	// DUSK DUDE
	precache_model("progs/qcdusk.mdl"); precache_model("progs/h_qcdusk.mdl"); precache_model("progs/v_sickles.mdl");
	precache_sound("dusk/jump.wav"); precache_sound("dusk/land.wav"); //precache_sound("dusk/land02.wav");
	precache_sound("dusk/damage.wav"); precache_sound("dusk/death.wav");
	precache_sound("dusk/fastfire.wav"); precache_sound("dusk/fastfirestart.wav");
	precache_sound("dusk/sicklestart.wav"); precache_sound("dusk/sickleslice.wav");
	precache_sound("blob/hit1.wav"); // used for miscellaneous throws

	// BIG JOHN
	precache_model("progs/qcbigjohn.mdl"); precache_model("progs/h_qcbigjohn.mdl"); precache_model("progs/v_bigjgun.mdl"); precache_model("progs/w_bigjshot.mdl");
	precache_sound("bigjohn/bigjjump.wav"); precache_sound("bigjohn/bigjland.wav"); precache_sound("bigjohn/bigjland2.wav"); 
	precache_sound("bigjohn/bigjpain1.wav"); precache_sound("bigjohn/bigjpain2.wav"); precache_sound("bigjohn/bigjpain3.wav"); 
	precache_sound("bigjohn/bigjpain4.wav"); precache_sound("bigjohn/bigjpain5.wav"); precache_sound("bigjohn/bigjpain6.wav"); precache_sound("bigjohn/bigjaxhit.wav"); 
	precache_sound("bigjohn/bigjdeath1.wav"); precache_sound("bigjohn/bigjdeath2.wav"); precache_sound("bigjohn/bigjdeath3.wav"); 
	precache_sound("bigjohn/bigjburn1.wav"); precache_sound("bigjohn/bigjburn2.wav"); 
	precache_sound("bigjohn/bigjabl1.wav"); precache_sound("bigjohn/bigjabl2.wav"); precache_sound("bigjohn/bigjfire.wav");

};