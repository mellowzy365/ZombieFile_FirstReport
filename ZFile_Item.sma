/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <fakemeta_util>
#include <engine>
#include <hamsandwich>
#include <xs>
#include <fun>
#include <cstrike>
#define pragma compress 1
#define CSW_UNARMED CSW_KNIFE
#define weapon_unarmed "weapon_knife"

#define PLUGIN "ZFile Item"
#define VERSION "1.0"
#define AUTHOR "Mellowzy"

#define IsPlayer(%1) (1 <= %1 <= get_maxplayers())
#define TASK_MEDKIT 121920919019

new const g_ItemClassName1[] = "FlashLight"; 
new const g_ItemClassName2[] = "keyuse"; 
new const g_ItemClassName3[] = "medkit";

new const item[][] = 
{
	"models/zfile_item/bg_flashlight_on.mdl",
	"models/zfile_item/bg_keymungchi01.mdl"
}

new const zfile_weapons[][] = {
	"models/zfile_weapon/v_1pve_knife.mdl",
	"models/zfile_weapon/v_1pve_unarm.mdl",
	"models/zfile_weapon/w_1pve_knife.mdl"
}
new InFlashLight[33], InUseKey[33], InUseKnife[33], UnArmed[33], bool:touched_medkit[256]
new bool:canuseit[256]
public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_forward(FM_ClientCommand , "Fw_ClientCommand")
	register_event("CurWeapon", "Event_CurWeapon", "be", "1=1")
	register_think(g_ItemClassName1, "FL_Think_Flashlight")
	register_think(g_ItemClassName2, "FL_Think_Key")
	register_touch(g_ItemClassName1, "player", "FPlayer_Touch_FlashLight")
	register_touch(g_ItemClassName2, "player", "FPlayer_Touch_Key")
	register_touch(g_ItemClassName3, "player", "player_touch_that_medkit")
	register_think(g_ItemClassName3, "medkit_obj_think")
	
	RegisterHam(Ham_Spawn, "player", "SpawnPost", 1)
	//do nothing while unarmed
	RegisterHam(Ham_Item_Deploy, weapon_unarmed, "unarmed_deploy", 1)
	RegisterHam(Ham_Weapon_WeaponIdle, weapon_unarmed, "unarmed_idle", 1)
	RegisterHam(Ham_Weapon_PrimaryAttack, weapon_unarmed, "PrimAttack", 1)
	RegisterHam(Ham_Weapon_SecondaryAttack, weapon_unarmed, "SecondAttack", 1)
	RegisterHam( Ham_TraceAttack, "player", "HamTraceAttack_Pre" );
	
	register_clcmd("dapatkankosong", "unarmed")
	register_clcmd("weapon_unarmed", "unarmed_hook")
	register_clcmd("remove_wpnunarmed", "remove_unarmed")
}
public plugin_precache()
{
	new i;
	for(i = 0 ; i <sizeof(item); i++)
		precache_model(item[i])
	for(i = 0; i <sizeof(zfile_weapons); i++)
		precache_model(zfile_weapons[i])
	
	precache_model("models/w_medkit.mdl")
	
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

public Fw_ClientCommand(id)
{
	new sCmd[32]
	read_argv(0,sCmd,31)
	
	if(equal(sCmd, "buy")) return FMRES_SUPERCEDE
	if(equal(sCmd, "+use"))
		if(!InUseKey[id] && InFlashLight[id]) return FMRES_SUPERCEDE
	if(equal(sCmd, "+attack1") && equal(sCmd, "+attack2"))
		if(!InUseKnife[id]) return FMRES_SUPERCEDE
	
	return FMRES_IGNORED
	
}
public SpawnPost(id) {
	create_flashlight(id)
	create_key(id)
	SpawnMoreMedkit(id)
	unarmed(id)
}

public Remove_Stuff(id)
{
	InUseKey[id] = 0
	InFlashLight[id] = 0
	InUseKnife[id] = 0
	UnArmed[id] = 0
	touched_medkit[id] = false
}
public unarmed(id)
{
	if(!is_user_alive(id)) return
	new unarmedw = fm_get_user_weapon_entity(id, CSW_UNARMED)
	if(!pev_valid(unarmedw)) return
	
	Stock_Drop_Slot(id, 1) 
	Stock_Drop_Slot(id, 2)
	
	UnArmed[id] = 1
	
	Set_WeaponAnim(id, 0)
	give_item(id, weapon_unarmed)
	
	if (get_user_weapon(id) == CSW_UNARMED) Event_CurWeapon(id)
	else engclient_cmd(id,weapon_unarmed)
}
public remove_unarmed(id)
{
	UnArmed[id] = 0
}
public client_PreThink(id)
{
	if(!is_user_alive(id) || !UnArmed[id])
		return 1;
	
	new iButton = pev(id, pev_button)
	if(iButton & IN_ATTACK && iButton & IN_ATTACK2) return 0;
	
	return 1;
}
public Event_CurWeapon(id)
{
	if(!is_user_alive(id))
		return
	if(get_user_weapon(id) != CSW_UNARMED)
		return
	if(!UnArmed[id])
		return
	
	set_pev(id, pev_viewmodel2, zfile_weapons[1])

}
public PrimAttack(ent)
{
	static id; id = pev(ent, pev_owner)
	if(UnArmed[id]) {
		return HAM_SUPERCEDE
	}
	
	return HAM_IGNORED
}
public SecondAttack(ent)
{
	static id; id = pev(ent, pev_owner)
	if(UnArmed[id]) {
		return HAM_SUPERCEDE
	}
	
	return HAM_IGNORED
}
public HamTraceAttack_Pre( iVictim, iAttacker, Float:flDamage, Float:fVecDir[3], tr )
{
    if( iVictim != iAttacker && IsPlayer(iAttacker) && cs_get_user_team(iAttacker) == CS_TEAM_CT && cs_get_user_team(iAttacker) == CS_TEAM_T && UnArmed[iAttacker] )
    {
        return HAM_SUPERCEDE;
    }
    return HAM_IGNORED;
}	
public unarmed_hook(id)
{
	engclient_cmd(id, weapon_unarmed)
	return PLUGIN_HANDLED
}
public unarmed_deploy(ent)
{
	if(pev_valid(ent) != 2)
		return
	static id; id = get_pdata_cbase(ent, 41, 4)
	if(get_pdata_cbase(id, 373) != ent)
		return
	if(!UnArmed[id])
		return
		
	Set_WeaponAnim(id, 0)
	set_pdata_float(ent, 48, 1.0, 4)
	//set_pdata_float( ent, 46, 9999.0, 4 );
	//set_pdata_float( ent, 47, 9999.0, 4 );
	set_pev(id, pev_viewmodel2, zfile_weapons[1])
}
public unarmed_idle(ent)
{
	if(pev_valid(ent) != 2)
		return
	static id; id = get_pdata_cbase(ent, 41, 4)
	if(get_pdata_cbase(id, 373) != ent)
		return
	if(!UnArmed[id])
		return
	
	if(get_pdata_float(ent, 48, 4) <= 0.1){
		Set_WeaponAnim(id, 1)
		set_pdata_float(ent, 48, 4.0, 4)
	}
}
public create_flashlight(id)
{
	static Float:Ori[3]
	new ent = create_entity("info_target")
	pev(id, pev_origin, Ori)
	Ori[0] = 3601.0
	Ori[1] = 2585.0
	Ori[2] = -1924.0
	set_pev(ent, pev_classname, g_ItemClassName1)
	set_pev(ent, pev_origin, Ori)
	canuseit[id] = false
	set_pev(ent, pev_owner, id)
	engfunc(EngFunc_SetSize, ent, Float:{-10.0,-10.0,0.0}, Float:{10.0,10.0,6.0})
	engfunc(EngFunc_SetModel, ent, item[0])
	set_pev(ent, pev_solid, SOLID_TRIGGER)
	set_pev(ent, pev_movetype, MOVETYPE_NONE)
	//set_rendering(ent, kRenderFxGlowShell, 0, 255, 0, kRenderNormal, 1)
	drop_to_floor(ent)
	
	set_pev(ent, pev_nextthink, get_gametime() + 0.01)
}
	
public create_key(id)
{
	static Float:Ori2[3]
	new ent = create_entity("info_target")
	Ori2[0] = 2024.0
	Ori2[1] = 3907.0
	Ori2[2] = -1906.0
	set_pev(ent, pev_classname, g_ItemClassName2)
	set_pev(ent, pev_origin, Ori2)
	set_pev(ent, pev_owner, id)
	engfunc(EngFunc_SetSize, ent, Float:{-1.0,-1.0,-1.0}, Float:{1.0,1.0,1.0})
	engfunc(EngFunc_SetModel, ent, item[1])
	set_pev(ent, pev_solid, SOLID_TRIGGER)
	set_pev(ent, pev_movetype, MOVETYPE_NONE)
	set_pev(ent, pev_rendermode, kRenderTransAdd)
	set_pev(ent, pev_renderamt, 200)
	
	drop_to_floor(ent)
	
	InUseKey[id] = 0
	
	set_pev(ent, pev_nextthink, get_gametime() + 0.01)
}
public SpawnMoreMedkit(id){
	id -= TASK_MEDKIT
	new Float:Origin1[3], Float:Origin2[3], Float:Origin3[3], Float:Origin4[3]
	
	Origin1[0] = 1628.0
	Origin1[1] = 2731.0
	Origin1[2] = -1924.0
	
	Origin2[0] = -489.0
	Origin2[1] = -443.0
	Origin2[2] = -1909.0
	
	Origin3[0] = -1486.0
	Origin3[1] = -1116.0
	Origin3[2] = -2170.0
	
	Origin4[0] = -1741.0
	Origin4[1] = -290.0
	Origin4[2] = -2178.0
	
	create_medkit(id+TASK_MEDKIT, Origin1)
	create_medkit(id+TASK_MEDKIT, Origin2)
	create_medkit(id+TASK_MEDKIT, Origin3)
	create_medkit(id+TASK_MEDKIT, Origin4)
}
public create_medkit(id, Float:Ori4[3])
{
	id -= TASK_MEDKIT
	new ent = create_entity("info_target")
	set_pev(ent, pev_origin, Ori4)
	set_pev(ent, pev_classname, g_ItemClassName3)
	set_pev(ent, pev_owner, id)
	engfunc(EngFunc_SetSize, ent, Float:{-10.0,-10.0,0.0}, Float:{10.0,10.0,6.0})
	engfunc(EngFunc_SetModel, ent, "models/w_medkit.mdl")
	set_pev(ent, pev_solid, SOLID_TRIGGER)
	set_pev(ent, pev_movetype, MOVETYPE_NONE)
	set_rendering(ent, kRenderFxGlowShell, 0, 255, 0, kRenderNormal, 1)
	drop_to_floor(ent)
	
	emit_sound(id, CHAN_VOICE, "items/gunpickup2.wav", VOL_NORM, ATTN_NONE, 0, PITCH_NORM)
	
	set_pev(ent, pev_nextthink, get_gametime() + 0.01)
}
public medkit_obj_think(ent)
{
	new id = pev(ent, pev_owner)
	if(!pev_valid(ent)) return
	if(!is_user_alive(id)) return
	set_pev(ent, pev_nextthink, get_gametime() + 0.01)
	if(touched_medkit[id]) {
		engfunc(EngFunc_RemoveEntity, ent)
		set_task(20.0, "SpawnMoreMedkit", id+TASK_MEDKIT)
	}
}
public player_touch_that_medkit(ent, id)
{
	if(!pev_valid(ent)) return
	if(!is_user_alive(id)) return
	
	new ihealth
	ihealth = get_user_health(id)
	if(ihealth < 100){
		touched_medkit[id] = true
		set_user_health(id, get_user_health(id) + 20)
		client_cmd(id, "spk %s", "items/smallmedkit1.wav")
		if(task_exists(id+TASK_MEDKIT)) remove_task(id+TASK_MEDKIT)
		set_pev(ent, pev_flags, FL_KILLME)
	} else {
		touched_medkit[id] = false
		return
	}
}
public client_impulse(id, impulse)
{
	if(impulse != 100)
		return PLUGIN_HANDLED_MAIN
	if(!canuseit[id]){
		return PLUGIN_HANDLED_MAIN
	}
	return PLUGIN_CONTINUE
}
public FL_Think_Flashlight(ent)
{
	new id = pev(ent, pev_owner)
	if(!pev_valid(ent)) return
	
	static Classname[32]
	pev(ent, pev_classname, Classname, sizeof(Classname))
	
	if(!equal(Classname, g_ItemClassName1)) return
	
	if(InFlashLight[id] && pev(id, pev_button) & IN_USE){
		canuseit[id] = true
		client_cmd(id, "spk %s", "items/gunpickup2.wav")
		set_dhudmessage(0,255, 0, -1.0, 0.13, 0, 0.0, 3.0)
		show_dhudmessage(id, "Soy : Good, this flashlight will come in handy.")
		set_task(4.0, "TIP", id)
		set_pev(ent, pev_flags, FL_KILLME)
	}
		
	set_pev(ent, pev_nextthink, get_gametime() + 0.01)
}
public TIP(id)
{
	set_dhudmessage(0,255, 0, -1.0, 0.13, 0, 0.0, 3.0)
	show_dhudmessage(id, "[TIP] Press the F key to use flashlight, it will run out of power if use it too long.")
}
public FPlayer_Touch_FlashLight(ent,id)
{
	if(!pev_valid(ent)) return
	if(!is_user_alive(id)) return
		
	InFlashLight[id] = 1
}
public FL_Think_Key(ent)
{
	new id = pev(ent, pev_owner)
	if(!pev_valid(ent)) return
	
	if(InUseKey[id] && pev(id, pev_button) & IN_USE){
		client_cmd(id, "spk %s", "items/gunpickup2.wav")
		set_dhudmessage(0,255, 0, -1.0, 0.13, 0, 0.0, 3.0)
		show_dhudmessage(id, "Soy : Got key!")
		set_pev(ent, pev_flags, FL_KILLME)
	}
		
	set_pev(ent, pev_nextthink, get_gametime() + 0.01)
}
public FPlayer_Touch_Key(ent,id)
{
	if(!pev_valid(ent)) return
	if(!is_user_alive(id)) return
		
	if(!InUseKey[id]) InUseKey[id] = 1
}

//stock
stock Set_WeaponAnim(id, anim)
{
	set_pev(id, pev_weaponanim, anim)
	
	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, {0, 0, 0}, id)
	write_byte(anim)
	write_byte(pev(id, pev_body))
	message_end()
}
stock ReplaceModel(id, const model[])
{
	cs_set_user_model(id, model, true)
	set_pev(id, pev_modelindex, model)
}
stock ResetModel(id)
{
	cs_reset_user_model(id)
	set_pev(id, pev_modelindex, pev(id, pev_modelindex))
}
stock Stock_Drop_Slot(id, iSlot) 
{
	new weapons[32], num = 0
	get_user_weapons(id, weapons, num)
	
	for(new i = 0; i < num; i++)
	{
		new slot = Stock_Get_Wpn_Slot(weapons[i])

		if(iSlot == slot)
		{
			static wname[32]
			get_weaponname(weapons[i], wname, charsmax(wname))
			engclient_cmd(id, "drop", wname)
		}
	}
}
stock Stock_Get_Wpn_Slot(iWpn)
{
	const PRIMARY_WEAPONS_BIT_SUM = (1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90)
	const SECONDARY_WEAPONS_BIT_SUM = (1<<CSW_P228)|(1<<CSW_ELITE)|(1<<CSW_FIVESEVEN)|(1<<CSW_USP)|(1<<CSW_GLOCK18)|(1<<CSW_DEAGLE)

	if(PRIMARY_WEAPONS_BIT_SUM & (1<<iWpn)) return 1
	else if(SECONDARY_WEAPONS_BIT_SUM & (1<<iWpn)) return 2
	else if(iWpn == CSW_KNIFE) return 3
	else if(iWpn == CSW_HEGRENADE) return 4
	else if(iWpn == CSW_C4) return 5
	return 6 //FLASHBANG SMOKEBANG
}