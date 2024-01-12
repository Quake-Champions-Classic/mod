/*
==============================
SOA: INFO COMMAND
==============================
*/

/*QUAKED info_command (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
 Stuffs a command into the console to allow map designers to set server variables.
 "message" is the command to send to the console.
*/
void() info_command = {
    if (self.message)
        localcmd(self.message);
};