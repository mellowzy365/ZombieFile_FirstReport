#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <fun>
#include <engine>
#include <fakemeta_util>
#include <cstrike>

#define pragma compress 1
#define VERSION "0.1"
#define LEET 1337

#define SOUND_STAMINAD 122311
#define SOUND_STAMINAU 122311
//#define DEBUG 	1

const g_iProg 		= (0xFF);
const g_iWeaps		= (0x1E);
const g_iMaxSpeed	= (0x2EE);
const g_iMaxCzas	= (0xA);
#define STEP_DELAY 0.3

new Float:g_fNextStep[33];
new g_iMaxPlayers;
new bool:canrun[33]
new Float:g_fTempMaxSpeed[0x21];
new Float:g_fSprintLeft[0x21];
#define MAX_SOUNDS 4 //Max num of sound for list below
new const soy_run[][] = {
	"player/1pve_step1.wav", //0
	"player/1pve_step2.wav",
	"player/1pve_step3.wav",
	"player/1pve_step4.wav", //3
	"player/stamina_down_loop.wav", //4
	"player/stamina_up.wav" //5
}
new const g_szStepSound[MAX_SOUNDS][] = {
	"player/1pve_step1.wav", //0
	"player/1pve_step2.wav",
	"player/1pve_step3.wav",
	"player/1pve_step4.wav", //3
}
new const Float:g_fWeaponsSpeed[g_iWeaps + 1]={ //THX 4 DARKGL ZA TABLICE ;)
	000.0,
	250.0, 000.0, 260.0, 250.0, 240.0, 
	250.0, 250.0, 240.0, 250.0, 250.0,                
	250.0, 250.0, 210.0, 240.0, 240.0,    
	250.0, 250.0, 210.0, 250.0, 220.0,              
	230.0, 230.0, 250.0, 210.0, 250.0,            
	250.0, 235.0, 221.0, 250.0, 245.0 
};

public plugin_init() {
	register_plugin("[ZFILE] Sprint Ability", VERSION, "diablix | Mellowzy")
	
	g_iMaxPlayers = get_maxplayers();
	RegisterHam(Ham_Spawn, "player", "PlayerSpawn", 1)
	
	register_forward(FM_CmdStart, "fwCmdStart", 0);
	register_event("CurWeapon", "eventCurWeapon", "be", "1=1");
	register_forward(FM_PlayerPreThink, "fwd_PlayerPreThink", 0);
	set_task(0.4, "taskPrintAmmount", _, _, _, "b");
}
public plugin_precache()
{
	new i;
	for(i = 0; i<sizeof(soy_run); i++)
		precache_sound(soy_run[i])
	for(i = 0; i< MAX_SOUNDS; i++)
		precache_sound(g_szStepSound[i])
	
	#define MAP "standalone_alpha"
	static MapName[64]; get_mapname(MapName, sizeof(MapName))
	
	if(!equal(MapName, MAP))
	{
		set_fail_state("[ZFILE]: You must play in %s", MAP)
		return
	} else {
		server_cmd("mp_timelimit 9999")	
	}
}

public PlayerSpawn(id)
{
	set_user_maxspeed(id, 120.0)
	set_user_footsteps(id, 0)
	set_task(10.0, "message_tut", id)
}
public message_tut(id){
	set_dhudmessage(0,255, 0, -1.0, 0.13, 0, 0.0, 2.0)
	show_dhudmessage(id, "[TIP] Press [SHIFT] to run, it will use stamina")
}
public eventCurWeapon(id){
	if(g_fTempMaxSpeed[id] >= float(g_iProg)){
		set_pev(id, pev_maxspeed, g_fTempMaxSpeed[id]);
		client_cmd(id, "cl_forwardspeed ^"%d^"", floatround(g_fTempMaxSpeed[id]));
		
		#if defined DEBUG
		client_print(id, 3, "%.1f", g_fTempMaxSpeed[id]);
		#endif
	}
	else{
		set_pev(id, pev_maxspeed, g_fWeaponsSpeed[get_user_weapon(id)]);
		
		#if defined DEBUG
		client_print(id, 3, "%.1f", g_fWeaponsSpeed[get_user_weapon(id)]);
		#endif
	}
}
public client_PreThink(id)
{
	if(!is_user_alive(id)) return
	
	if(g_fSprintLeft[id] >= 0.5){
		//
	}
	else
	{
		set_task(1.0, "staminad", id+SOUND_STAMINAD)
	}
}
public fwCmdStart(id, iHandle, iSeed){
	if(!is_user_alive(id)) return FMRES_IGNORED;
	
	new Float:fmove, Float:smove;
	get_uc(iHandle, UC_ForwardMove, fmove);
	get_uc(iHandle, UC_SideMove, smove);
	new bitButtons 		= get_uc(iHandle, UC_Buttons);
	new bitOldbuttons 	= pev(id, pev_oldbuttons);
	
	new Float:maxspeed;
	pev(id, pev_maxspeed, maxspeed);
	new Float:walkspeed = (maxspeed * 0.52); 
	fmove = floatabs(fmove);
	smove = floatabs(smove);
	
	if(fmove <= walkspeed && smove <= walkspeed && !(fmove == 0.0 && smove == 0.0)){	
		if(g_fSprintLeft[id] >= 0.5){
			if(task_exists(id + LEET)) remove_task(id + LEET);
			g_fTempMaxSpeed[id] = g_fTempMaxSpeed[id] < 400.0 ? 400.0 : g_fTempMaxSpeed[id];
			g_fTempMaxSpeed[id] = g_fTempMaxSpeed[id] < float(g_iMaxSpeed) ? g_fTempMaxSpeed[id] + 10.0 : g_fTempMaxSpeed[id];
			set_pev(id, pev_maxspeed, g_fTempMaxSpeed[id]);
			client_cmd(id, "cl_forwardspeed ^"%d^"", floatround(g_fTempMaxSpeed[id]));
			set_pev(id, pev_flTimeStepSound, 999);
			set_user_footsteps(id, 1)
			canrun[id] = true
			g_fSprintLeft[id] -= 0.05;
			set_user_maxspeed(id, 450.0)
			
			for(new i = 0 ; i < 0x10 ; i++){
				if(!(((1<<3)|(1<<4)|(1<<12)) & (1<<i))){
					if((bitButtons & (1<<i))){
						if((1<<2) & (1<<i))
							set_pev(id, pev_oldbuttons, bitOldbuttons | (1<<i));
						
						else
							set_uc(iHandle, UC_Buttons, bitButtons & (~(1<<i)));
						
						return FMRES_SUPERCEDE;
					}
				}
			}
		}
		else{
			canrun[id] = false
			g_fTempMaxSpeed[id] = 0.0;
			eventCurWeapon(id);
			set_user_footsteps(id, 0)
			set_user_maxspeed(id, 120.0)
			set_pev(id, pev_flTimeStepSound, 400)
		}
		return FMRES_IGNORED;
	}
	else{
		if(!task_exists(id + LEET)) set_task(1.0, "taskRecoverSprint", id + LEET);
		g_fTempMaxSpeed[id] = 0.0;
		eventCurWeapon(id);
		set_pev(id, pev_flTimeStepSound, 400)
		set_user_footsteps(id, 0)
		set_user_maxspeed(id, 120.0)
	}
	return FMRES_IGNORED;
}

public staminad(id)
{
	id -= SOUND_STAMINAD
	emit_sound(id, CHAN_VOICE, soy_run[4], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	remove_task(id+SOUND_STAMINAD)
	set_task(2.0, "staminau", id+SOUND_STAMINAU)
}
public staminau(id)
{
	id -= SOUND_STAMINAU
	emit_sound(id, CHAN_VOICE, soy_run[5], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	remove_task(id+SOUND_STAMINAD)
	remove_task(id+SOUND_STAMINAU)
}
public taskRecoverSprint(task_id){
	new id = task_id - LEET;
	
	g_fSprintLeft[id]++;
	
	if(floatround(g_fSprintLeft[id]) < g_iMaxCzas || floatround(g_fSprintLeft[id]) > g_iMaxCzas){
		if(floatround(g_fSprintLeft[id]) < g_iMaxCzas) set_task(1.0, "taskRecoverSprint", id + LEET);
		if(floatround(g_fSprintLeft[id]) > g_iMaxCzas) {
			g_fSprintLeft[id] = float(g_iMaxCzas);
			canrun[id] = true
		}
	}
}

public taskPrintAmmount(){
	static id; //statyczna
	for(id = 1 ; id <= g_iMaxPlayers ; id++){
		if(is_user_alive(id)){
			new iSprint = floatround(g_fSprintLeft[id]);
			new sSprint[g_iMaxCzas];
			
			while(iSprint >= 1){
				iSprint--;
				add(sSprint, sizeof sSprint - 1, "*");
			}
			iSprint = floatround(g_fSprintLeft[id]);
			set_hudmessage(iSprint ? 0x64 : 0xFF, iSprint ? 0x48 : 0x0, iSprint ? 0xC : 0x0, 0.01, 0.77, 0, 0.000001, 0.405, 0.000001, 0.000001, -1);
			show_hudmessage(id, "[%s]", sSprint);	
		}
	}
}
public fwd_PlayerPreThink(id)
{
    if(!is_user_alive(id))
        return FMRES_IGNORED;
    
    if(g_fNextStep[id] < get_gametime())
    {
        if(fm_get_ent_speed(id) && get_user_footsteps(id))
            emit_sound(id, CHAN_BODY, g_szStepSound[random(MAX_SOUNDS)], VOL_NORM, ATTN_STATIC, 0, PITCH_NORM);
        
        g_fNextStep[id] = get_gametime() + STEP_DELAY;
    }
    
    return FMRES_IGNORED;
}
stock Float:fm_get_ent_speed(id)
{
    if(!pev_valid(id))
        return 0.0;
    
    static Float:vVelocity[3];
    pev(id, pev_velocity, vVelocity);
    
    vVelocity[2] = 0.0;
    
    return vector_length(vVelocity);
}  
