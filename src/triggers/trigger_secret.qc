/*QUAKED trigger_secret (.5 .5 .5) ?
secret counter trigger
sounds
1)	secret
2)	beep beep
3)
4)
set "message" to text string
*/
void() trigger_secret = {
	INHIBIT_COOP // MG1
	total_secrets = total_secrets + 1;
	self.wait = -1;

	if (!self.message) {
		if (ExtSupported("EX_CENTERPRINT"))
			self.message = "$qc_found_secret";
		else
			self.message = "You found a secret area!";
	}

	if (!self.sounds)
		self.sounds = 1;
	
	if (self.sounds == 1) {
		precache_sound("misc/secret.wav");
		self.noise = "misc/secret.wav";
	}
	else if (self.sounds == 2) {
		precache_sound("misc/talk.wav");
		self.noise = "misc/talk.wav";
	}

	trigger_multiple ();
};