/*
Quake Champions Classic Rule Sets and Helper Functions
*/

float(entity check_ent) not_deathmatch = {
    if (deathmatch) {
        remove(check_ent);
        return TRUE;
    }
    return FALSE;
}

float(entity check_ent) not_horde = {
    if (not_deathmatch(check_ent))
        return TRUE;
    return FALSE;
}