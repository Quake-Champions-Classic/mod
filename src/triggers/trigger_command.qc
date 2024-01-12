/*
=================================
SOA: TRIGGER COMMAND
=================================
*/

void() trigger_command_use = {
    if (self.message)
        localcmd(self.message);
};

/*QUAKED trigger_command (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
 When triggered, stuffs a command into the console to allow map
 designers to set server variables.
 "message" is the command to send to the console.
*/

void() trigger_command = {
    self.use = trigger_command_use;
    self.think = SUB_Null;
};