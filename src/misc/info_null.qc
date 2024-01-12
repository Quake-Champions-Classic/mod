/*
====================================
INFO NULL & NOT NULL
====================================
*/

// QUAKED info_null (0 0.5 0) (-4 -4 -4) (4 4 4)
// Used as a positional target for spotlights, etc.
void() info_null = {
	remove(self);
};

// QUAKED info_notnull (0 0.5 0) (-4 -4 -4) (4 4 4)
// Used as a positional target for lightning.
void() info_notnull = {};