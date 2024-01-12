/*
===================================
INFO START END TEXT
===================================
*/

void() info_startendtext_use = {
    intermission_running = 1;
    ExitIntermission();
};
 
// QUAKED info_startendtext (0.3 0.1 0.6) (-8 -8 -8) (8 8 8)
// start the end text
void() info_startendtext = {
    self.use = info_startendtext_use;
};