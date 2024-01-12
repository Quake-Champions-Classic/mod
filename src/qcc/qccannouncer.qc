/*
===================================================================
QCC: ANNOUNCER
===================================================================
*/
void() QCC_AnnouncerPlayback = {
	string snd;
	float delay;
	
	delay = 0.1;
	
	// find the next sound in the queue
	if (qcc_announcer.qcc_queue_index == 1) {
		if (qcc_announcer.noise1 != string_null) {
			snd = qcc_announcer.noise1;
			qcc_announcer.noise1 = string_null;
			delay = qcc_announcer.delay1;
		}
		else
			qcc_announcer.qcc_queue_index++;
	}
	if (qcc_announcer.qcc_queue_index == 2) {
		if (qcc_announcer.noise2 != string_null) {
			snd = qcc_announcer.noise2;
			qcc_announcer.noise2 = string_null;
			delay = qcc_announcer.delay2;
		}
		else
			qcc_announcer.qcc_queue_index++;
	}
	if (qcc_announcer.qcc_queue_index == 3) {
		if (qcc_announcer.noise3 != string_null) {
			snd = qcc_announcer.noise3;
			qcc_announcer.noise3 = string_null;
			delay = qcc_announcer.delay3;
		}
		else
			qcc_announcer.qcc_queue_index++;
	}
	if (qcc_announcer.qcc_queue_index == 4) {
		if (qcc_announcer.noise4 != string_null)
		{
			snd = qcc_announcer.noise4;
			qcc_announcer.noise = string_null;
			delay = qcc_announcer.delay4;
		}
		else
			qcc_announcer.qcc_queue_index++;
	}
	
	qcc_announcer.qcc_queue_index++;
	if (qcc_announcer.qcc_queue_index > 4)
		qcc_announcer.qcc_queue_index = 1;
		
	if (snd)
		sound(qcc_announcer, CHAN_AUTO, snd, 1, ATTN_NONE);

	qcc_announcer.nextthink = time + delay;
};

void(string snd, float delay) QCC_Announce = {
	if (deathmatch) {
		if (qcc_announcer.noise1 == string_null) {
			qcc_announcer.noise1 = snd;
			qcc_announcer.delay1 = delay;
		}
		else if (qcc_announcer.noise2 == string_null) {
			qcc_announcer.noise2 = snd;
			qcc_announcer.delay2 = delay;
		}
		else if (qcc_announcer.noise3 == string_null) {
			qcc_announcer.noise3 = snd;
			qcc_announcer.delay3 = delay;
		}
		else if (qcc_announcer.noise4 == string_null) {
			qcc_announcer.noise4 = snd;
			qcc_announcer.delay4 = delay;
		}
	}
};