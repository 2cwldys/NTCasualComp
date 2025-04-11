Casual Comp PUG Server for NEOTOKYO°

Add your STEAMID[64] to admins.cfg in addons/sourcemod/configs.

This allows you to run an ordinary PUB server with rate fixing, quality of life plugins, ghost and weapon tweaks, while obscuring competitive plugins until enabled.

!admin > server settings > exec cfg > warmode ON to enable competitive play.

sm_newpassword (admin only) generates a server password
sm_emptypassword (admin only) empties server password to "" on demand

RTVing or changing the MAP will result in the server password being restored to "" nothing.
Typing !pug as generic sourcemod admin will trigger sm_nt_pugmode 0/1 values, which handle sm_warmode_on/off.cfg(s)
Typing !privatepug as generic sourcemod admin will trigger sm_nt_privatepug 0/1 values, which indicate if the server will be locked in PUG mode.

KNOWN ISSUES:
If you disable warmode to restore original pub server state, player enemies remain unkillable due to comp godmode,
Do !rtv or !map to leave the current map to reset functionality.

ALL PLUGINS AND THEIR SOURCE CODE BELONG TO THEIR RESPECTIVE OWNERS.
