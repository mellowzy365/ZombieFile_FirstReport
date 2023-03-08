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

#define ANIM_IDLE random_num(1,2)
#define ANIM_WALK 7
#define ANIM_ATTACK random_num(32,34)
#define ANIM_DEATH random_num(44,45)
#define ANIM_FLINCH random_num(16,17)
#define ANIM_RUN 11
#define ANIM_FIND 22
#define HEALTH_OFFSET 20.0
#define ZOMBIE_HEALTH 250.0
#define NPC_KEYIMPULSE 1996

#define TASK_ATTACK 323423
#define TASK_HORDE 192912919
#define PLUGIN "AI Zombie Files Zombie"
#define VERSION "0.1"
#define AUTHOR "Mellowzy"

new const ZB_CLASSNAME[] = "zfile_zombi"
new g_ZombiKilled, m_ireg
new m_iBlood[2], bool:ai[256], bool:g_Hit[256]
new const zfile_model[][] = {
	"models/zfile_zombi/bg_zombi_1pve_man.mdl",
	"models/zfile_zombi/bg_zombi_1pve_police.mdl"
}
new const g_NpcSoundKnifeHit[][] = 
{
	"weapons/knife_hit1.wav",
	"weapons/knife_hit2.wav",
	"weapons/knife_hit3.wav",
	"weapons/knife_hit4.wav"
}
new const g_NpcSoundKnifeStab[] = "weapons/knife_stab.wav";
enum
{
	STATE_FINDING = 0,
	STATE_FOUND,
	STATE_MOVE,
	STATE_DYING,
	STATE_DEATH
}
new const zfile_sound[][] = {
	"zfile/zombi/normal_idle1.wav", //0
	"zfile/zombi/normal_idle2.wav", //1
	"zfile/zombi/normal_idle3.wav", //2
	"zfile/zombi/normal_find1.wav", //3
	"zfile/zombi/normal_critical.wav", //4
	"zfile/zombi/normal_death1.wav", //5
	"zfile/zombi/normal_death2.wav", //6
	"zfile/zombi/normal_attack1.wav", //7
	"zfile/zombi/normal_attack2.wav", //8
	"zfile/zombi/normal_attack3.wav", //9
	"zfile/zombi/normal_run1.wav", //10
	"zfile/zombi/normal_run2.wav", //11
	"zfile/zombi/normal_run3.wav" //12
}
public plugin_precache()
{
	new i;
	for(i = 0; i <sizeof(zfile_model); i++)
		precache_model(zfile_model[i])
	for(i = 0; i <sizeof(zfile_sound); i++)
		precache_sound(zfile_sound[i])
	
	m_iBlood[0] = precache_model("sprites/blood.spr")
	m_iBlood[1] = precache_model("sprites/bloodspray.spr")
	
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
public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_event("HLTV", "Event_NewRound", "a", "1=0", "2=0")
	register_forward(FM_EmitSound, "npc_EmitSound")
	RegisterHam(Ham_Think, "info_target", "npc_think")
	RegisterHam(Ham_Killed, "player", "player_killed", 1)
	register_forward(FM_TraceLine, "fw_TraceLine_Post", 1)

	register_clcmd("spawn_npc", "Spawn_Zombie")
	register_clcmd("horde", "Spawn_Zombie_Horde")
	register_clcmd("kill_horde", "hordedead")
}
public Spawn_Zombie(id)
{
	new Float:pos1[3], Float:pos2[3], Float:pos3[3], Float:pos4[3], Float:pos5[3], Float:pos6[3],
	Float:pos7[3], Float:pos8[3], Float:pos9[3], Float:pos10[3], Float:pos11[3], Float:pos12[3],
	Float:pos13[3], Float:pos14[3], Float:pos15[3]
	
	pos1[0] = 2026.0			
	pos1[1] = 2684.0				
	pos1[2] = -1924.0			
	
	pos2[0] = 1355.0
	pos2[1] = 1972.0
	pos2[2] = -1924.0
	
	pos3[0] = 2082.0
	pos3[1] = 2345.0
	pos3[2] = -1924.0
	
	pos4[0] = 2310.0
	pos4[1] = 2143.0
	pos4[2] = -1924.0
	
	pos5[0] = -95.0
	pos5[1] = -434.0
	pos5[2] = -1924.0
	
	pos6[0] = -343.0
	pos6[1] = -627.0
	pos6[2] = -1924.0
	
	pos7[0] = -629.0
	pos7[1] = -645.0
	pos7[2] = -1924.0
	
	pos8[0] = -147.0
	pos8[1] = -1157.0
	pos8[2] = -2052.0
	
	pos9[0] = -1449.0
	pos9[1] = -1470.0		
	pos9[2] = -2180.0
	
	pos10[0] = -1807.0
	pos10[1] = -1364.0		
	pos10[2] = -2180.0
	
	pos11[0] = -1687.0
	pos11[1] = -1568.0		
	pos11[2] = -2180.0
	
	pos12[0] = -1598.0
	pos12[1] = -1663.0		
	pos12[2] = -2101.0
	
	pos13[0] = 822.0
	pos13[1] = -594.0		
	pos13[2] = -1913.0
	
	pos14[0] = -145.0
	pos14[1] = -373.0		
	pos14[2] = -1899.0
	
	pos15[0] = 1743.0
	pos15[1] = 1798.0		
	pos15[2] = -1918.0
	
	create_zombie(id, zfile_model[0], pos1,0,0)
	create_zombie(id, zfile_model[0], pos2,1,0)
	create_zombie(id, zfile_model[0], pos3,0,0)
	create_zombie(id, zfile_model[0], pos4,1,0)
	create_zombie(id, zfile_model[0], pos5,0,0)
	create_zombie(id, zfile_model[0], pos6,1,0)
	create_zombie(id, zfile_model[0], pos7,1,0)
	create_zombie(id, zfile_model[0], pos8,1,0)
	create_zombie(id, zfile_model[0], pos13,0,0)
	create_zombie(id, zfile_model[0], pos14,1,0)
	create_zombie(id, zfile_model[0], pos15,1,0)
	
	//police
	create_zombie(id, zfile_model[1], pos9,0,0)
	create_zombie(id, zfile_model[1], pos10,1,0)
	create_zombie(id, zfile_model[1], pos11,1,0)
	create_zombie(id, zfile_model[1], pos12,0,0)
	
	zb2_pos(id)
}
public fw_TraceLine_Post(Float:vStart[3], Float:vEnd[3], iIgnored, id, iHandle)
{
	if(!(1 <= id <= get_maxplayers() && is_user_connected(id))) return FMRES_IGNORED
	if(!is_user_alive(id)) return FMRES_IGNORED
	new iBody = get_tr2(iHandle, TR_iHitgroup)
	if(iBody <= 0 || iBody > 7)
		set_tr2(iHandle, TR_iHitgroup, 3)
	
	return FMRES_SUPERCEDE
}
public zb2_pos(id)
{
	new Float:zb1[3], Float:zb2[3]
	
	zb1[0] = -925.0
	zb1[1] = -1080.0
	zb1[2] = -2171.0
	
	zb2[0] = -1015.0
	zb2[1] = -1348.0
	zb2[2] = -2177.0
	
	create_zombie(id, zfile_model[1], zb1,0,0)
	create_zombie(id, zfile_model[1], zb2,1,0)
}
public Spawn_Zombie_Horde(id)
{
	new Float:pos1[3], Float:pos2[3], Float:pos3[3], Float:pos4[3]
	
	pos1[0] = -1811.0			
	pos1[1] = -24.0				
	pos1[2] = -2180.0			
	
	pos2[0] = -1399.0
	pos2[1] = 169.0
	pos2[2] = -2180.0	
	
	pos3[0] = -1453.0
	pos3[1] = 38.0
	pos3[2] = -2180.0	
	
	pos4[0] = -1825.0
	pos4[1] = 58.0
	pos4[2] = -2180.0
	
	create_zombie(id, zfile_model[0], pos1,0,1)
	create_zombie(id, zfile_model[1], pos2,1,1)
	create_zombie(id, zfile_model[0], pos3,0,1)
	create_zombie(id, zfile_model[1], pos4,1,1)
}
public hordedead(id)
{
	if(task_exists(id+TASK_HORDE)) remove_task(id+TASK_HORDE)
	remove_entity_name(ZB_CLASSNAME)
}

public create_zombie(id,const model[], Float:origin[3],run,horde)
{
	new ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	entity_set_vector(ent, EV_VEC_origin, origin)

	entity_set_float(ent,EV_FL_takedamage,DAMAGE_YES)
	entity_set_float(ent,EV_FL_health,ZOMBIE_HEALTH)

	entity_set_string(ent,EV_SZ_classname,ZB_CLASSNAME);
	entity_set_model(ent, model)
	entity_set_int(ent,EV_INT_solid, SOLID_SLIDEBOX)
	entity_set_int(ent, EV_INT_movetype, MOVETYPE_PUSHSTEP)
	
	entity_set_int(ent, EV_INT_iuser1, run)
	entity_set_int(ent, EV_INT_iuser2, STATE_FINDING)
	entity_set_int(ent, EV_INT_iuser3, horde)
	entity_set_int(ent, EV_INT_iuser4, 0)
	
	entity_set_byte(ent,EV_BYTE_controller1,125);
	entity_set_byte(ent,EV_BYTE_controller2,125);
	entity_set_byte(ent,EV_BYTE_controller3,125);
	entity_set_byte(ent,EV_BYTE_controller4,125);
	
	entity_set_int(ent, EV_INT_impulse, NPC_KEYIMPULSE)
	new Float:maxs[3] = {16.0,16.0,36.0}
	new Float:mins[3] = {-16.0,-16.0,-36.0}
	entity_set_size(ent,mins,maxs)
	
	drop_to_floor(ent)
	entity_set_float(ent,EV_FL_nextthink,halflife_time() + 0.1)
	
	ai[id] = true
	
	if(!m_ireg){
		RegisterHamFromEntity(Ham_TakeDamage, ent, "npc_takedmg")
		RegisterHamFromEntity(Ham_Classify, ent, "fw_entclassify")
		RegisterHamFromEntity(Ham_Killed, ent, "fw_entkilled")
		m_ireg = 1
	}
	
	return ent;
}
public fw_entclassify(ent)
{
	if(entity_get_int(ent, EV_INT_impulse) != NPC_KEYIMPULSE) return HAM_IGNORED
	
	SetHamReturnInteger(7)
	return HAM_SUPERCEDE
}

public fw_entkilled(iVictim, iAttacker)
{
	if(entity_get_int(iVictim, EV_INT_impulse) != NPC_KEYIMPULSE) return HAM_IGNORED
	
	g_ZombiKilled ++ 
	set_frags(iVictim, g_ZombiKilled, 0)
	set_entity_anim(iVictim, ANIM_DEATH, 1.0, 1)
	emit_sound(iVictim, CHAN_BODY, zfile_sound[random_num(5,6)], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	entity_set_int(iVictim, EV_INT_movetype, MOVETYPE_NONE)
	entity_set_int(iVictim,EV_INT_solid, SOLID_NOT)
	entity_set_int(iVictim, EV_INT_iuser2, STATE_DEATH)
	entity_set_float(iVictim,EV_FL_takedamage,DAMAGE_NO)
	if(task_exists(iVictim+TASK_ATTACK)) remove_task(iVictim+TASK_ATTACK)
	entity_set_float(iVictim,EV_FL_nextthink,halflife_time() + 3.0)
	return HAM_SUPERCEDE
}

public npc_takedmg(victim, inflictor, attacker, Float:damage, damagebits)
{
	if(entity_get_int(victim, EV_INT_impulse) != NPC_KEYIMPULSE) return HAM_IGNORED
	emit_sound(victim, CHAN_BODY, zfile_sound[4], 1.0, ATTN_NORM, 0, PITCH_NORM)	
	set_entity_anim(victim, ANIM_FLINCH, 1.0, 0)
	
	Stock_Fake_KnockBack(attacker, victim, 17.5)
	
	static Float:Origin[3]
	pev(victim, pev_origin, Origin)
	
	new Float:Ent_Origin[3], Float:Vic_Origin[3]
	entity_get_vector(victim, EV_VEC_origin, Ent_Origin)
	entity_get_vector(attacker, EV_VEC_origin, Vic_Origin)
	static Float:fSpeed
	fSpeed = floatmin(0.0, vector_distance(Ent_Origin, Vic_Origin) * 0.0)
	Stock_Hook_Ent(victim, Vic_Origin, fSpeed, 1)
	
	g_Hit[attacker] = true
	
	create_blood(Origin)
	
	return HAM_IGNORED
}
	
public npc_think(ent)
{
	new cls[32]
	entity_get_string(ent, EV_SZ_classname,cls, 32)
	if(!equal(cls, ZB_CLASSNAME))
		return HAM_IGNORED
		
	if(is_valid_ent(ent))
	{
		static victim
		static Float:Origin[3], Float:VicOrigin[3], Float:distance
		new iRun = entity_get_int(ent, EV_INT_iuser1)
		new iState = entity_get_int(ent, EV_INT_iuser2)
		new Float:fTimeState = entity_get_float(ent, EV_FL_fuser1)
		new Horde = entity_get_int(ent, EV_INT_iuser3)
		new iDead = entity_get_int(ent, EV_INT_iuser4)
			
		victim = FindClosesEnemy(ent)
		entity_get_vector(ent, EV_VEC_origin, Origin)
		entity_get_vector(victim, EV_VEC_origin, VicOrigin)
		
		entity_set_float(ent, EV_FL_nextthink, halflife_time() + 0.1)
		
		if(Horde == 1 && iDead == 1) entity_set_int(ent, EV_INT_iuser4, 0)
		entity_set_float(ent, EV_FL_nextthink, halflife_time() + 0.01)
		
		distance = get_distance_f(Origin, VicOrigin)
		
		if(is_user_alive(victim))
		{
			new Float:Ent_Origin[3], Float:Vic_Origin[3]
			if(distance <= 60.0)
			{
				entity_get_vector(ent, EV_VEC_origin, Ent_Origin)
				entity_get_vector(victim, EV_VEC_origin, Vic_Origin)
			
				npc_turntotarget(ent, Ent_Origin, victim, Vic_Origin)
				hook_ent(ent,victim)
				zb_atk(ent, victim)
				entity_set_float(ent, EV_FL_nextthink, halflife_time() + 2.0)
			} else {
				if(iState == STATE_FINDING){
					set_entity_anim(ent, ANIM_FIND, 1.0, 1)
					emit_sound(ent, CHAN_BODY, zfile_sound[3], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
					entity_set_int(ent, EV_INT_iuser2, STATE_FOUND)
					entity_set_float(ent, EV_FL_fuser1, get_gametime() + 1.0)
					entity_set_float(ent, EV_FL_nextthink, halflife_time() + 0.01)
				}
				
				if(iState == STATE_FOUND && fTimeState < get_gametime()){
					entity_set_int(ent, EV_INT_iuser2, STATE_MOVE)
					entity_set_float(ent, EV_FL_fuser1, get_gametime() + 0.2)
					entity_set_float(ent, EV_FL_nextthink, halflife_time() + 0.01)
				}
				
				entity_set_float(ent, EV_FL_nextthink, halflife_time() + 0.1)
				
				if(iState == STATE_MOVE && fTimeState < get_gametime()){
					
					entity_set_float(ent, EV_FL_fuser1, 0.0)
					
					if(!iRun){
					
						new Float:Ent_Origin[3], Float:Vic_Origin[3]
						entity_get_vector(ent, EV_VEC_origin, Ent_Origin)
						entity_get_vector(victim, EV_VEC_origin, Vic_Origin)
						static Float:fSpeed
						fSpeed = floatmin(75.0, vector_distance(Ent_Origin, Vic_Origin) * 20.0)
						Stock_Hook_Ent(ent, Vic_Origin, fSpeed, 1)
						npc_turntotarget(ent, Ent_Origin, victim, Vic_Origin)
						
						if(get_anim(ent) != ANIM_WALK)
							set_entity_anim(ent, ANIM_WALK, 2.0, 1)
				
						entity_set_float(ent, EV_FL_nextthink, halflife_time() + 1.0)
					} else {
						if(get_anim(ent) != ANIM_RUN)
							set_entity_anim(ent, ANIM_RUN, 1.0, 0)
							
							
						set_task(1.0, "sound_run", ent)
						new Float:Ent_Origin[3], Float:Vic_Origin[3]
						entity_get_vector(ent, EV_VEC_origin, Ent_Origin)
						entity_get_vector(victim, EV_VEC_origin, Vic_Origin)
						static Float:fSpeed
						fSpeed = floatmin(220.0, vector_distance(Ent_Origin, Vic_Origin) * 20.0)
						Stock_Hook_Ent(ent, Vic_Origin, fSpeed, 1)
						npc_turntotarget(ent, Ent_Origin, victim, Vic_Origin)
				
						entity_set_float(ent, EV_FL_nextthink, halflife_time() + 0.3)
					}
				}
				if(iState == STATE_DEATH)
				{
					entity_set_float(ent, EV_FL_renderamt, 200.0)
					entity_set_int(ent, EV_INT_flags, entity_get_int(ent, EV_INT_flags) | FL_KILLME)
				}
			}
		} else {
			
			if(get_anim(ent) != ANIM_IDLE)
				set_entity_anim(ent, ANIM_IDLE, 1.0, 0)

			emit_sound(ent, CHAN_BODY, zfile_sound[random_num(0,1)], 1.0, ATTN_NORM, 0, PITCH_NORM)
			
			entity_set_int(ent, EV_INT_iuser2, STATE_FINDING)
			
			entity_set_float(ent, EV_FL_nextthink, halflife_time() + 1.0)
		}
	} else {
		if(get_anim(ent) != ANIM_IDLE)
			set_entity_anim(ent, ANIM_IDLE, 1.0,0)
		
		emit_sound(ent, CHAN_BODY, zfile_sound[random_num(0,1)], 1.0, ATTN_NORM, 0, PITCH_NORM)
		entity_set_int(ent, EV_INT_iuser2, STATE_FINDING)
			
		entity_set_float(ent, EV_FL_nextthink, halflife_time() + 1.0)		
	}
	
	return HAM_IGNORED
}
public Event_NewRound(id) set_frags(id,0,0)
public player_killed(id) set_frags(id,0,1)
public zb_atk(ent, victim)
{
	if(get_anim(ent) != ANIM_ATTACK)
	set_entity_anim(ent, ANIM_ATTACK, 1.0, 0)
	
	emit_sound(victim, CHAN_BODY, zfile_sound[random_num(7,8)], 1.0, ATTN_NORM, 0, PITCH_NORM)
	if(is_user_alive(victim)) set_user_health(victim, get_user_health(victim) - random_num(5,10))
	
	remove_task(ent+TASK_ATTACK)
	set_task(1.5, "stop_attack", ent+TASK_ATTACK)
}
public stop_attack(ent)
{ 
	ent -= TASK_ATTACK
	
	set_entity_anim(ent, ANIM_IDLE, 1.0, 0)
	remove_task(ent+TASK_ATTACK)
}
	
public set_frags(id, ifrags, ideath)
{
	if(!is_user_alive(id))
		return
		
	set_user_frags(id, get_user_frags(id) + ifrags)
	
	cs_set_user_deaths(id, cs_get_user_deaths(id) + ideath, true)
	
	message_begin(MSG_ALL, get_user_msgid("ScoreInfo"))
	write_byte(id)
	write_short(get_user_frags(id))
	write_short(get_user_deaths(id))
	write_short(0)
	write_short(get_user_team(id))
	message_end()
}

public sound_run(ent) emit_sound(ent, CHAN_BODY, zfile_sound[random_num(10,11)], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)

public npc_EmitSound(id, channel, sample[], Float:volume, Float:attn, flag, pitch)
{
	//Make sure player is alive
	if(!is_user_connected(id))
		return FMRES_SUPERCEDE;

	//Catch the current button player is pressing
	new iButton = get_user_button(id);
					
	//If the player knifed the NPC
	if(g_Hit[id])
	{	
		//Catch the string and make sure its a knife 
		if (sample[0] == 'w' && sample[1] == 'e' && sample[8] == 'k' && sample[9] == 'n')
		{
			//Catch the file of _hitwall1.wav or _slash1.wav/_slash2.wav
			if(sample[17] == 's' || sample[17] == 'w')
			{
				//If player is slashing then play the knife hit sound
				if(iButton & IN_ATTACK)
				{
					emit_sound(id, CHAN_WEAPON, g_NpcSoundKnifeHit[random(sizeof g_NpcSoundKnifeHit)], volume, attn, flag, pitch);
				}
				//If player is tabbing then play the stab sound
				else if(iButton & IN_ATTACK2)
				{
					emit_sound(id,CHAN_WEAPON, g_NpcSoundKnifeStab, volume, attn, flag, pitch);
				}

				//Reset our boolean as player is not hitting NPC anymore
				g_Hit[id] = false;
				
				//Block any further sounds to be played
				return FMRES_SUPERCEDE
			}
		}
	}
	
	return FMRES_IGNORED
}
stock playsound(id, const isound[])
{
	if(!is_user_alive(id)) return
	
	client_cmd(id, "spk %s", isound)
}
stock get_anim(id)
{
	if(is_valid_ent(id))
	{	
		return pev(id, pev_sequence)
	}
	
	return PLUGIN_HANDLED
}
stock Stock_Hook_Ent(ent, Float:TargetOrigin[3], Float:Speed, mode=0)
{
	static Float:fl_Velocity[3],Float:EntOrigin[3],Float:distance_f,Float:fl_Time
	pev(ent, pev_origin, EntOrigin)
	
	if(!mode)
	{
		distance_f = get_distance_f(EntOrigin, TargetOrigin)
		fl_Time = distance_f / Speed
			
		pev(ent, pev_velocity, fl_Velocity)
			
		fl_Velocity[0] = (TargetOrigin[0] - EntOrigin[0]) / fl_Time
		fl_Velocity[1] = (TargetOrigin[1] - EntOrigin[1]) / fl_Time
		fl_Velocity[2] = (TargetOrigin[2] - EntOrigin[2]) / fl_Time

		if(vector_length(fl_Velocity) > 1.0) set_pev(ent, pev_velocity, fl_Velocity)
		else set_pev(ent, pev_velocity, Float:{0.01, 0.01, 0.01})
	} else {
		static Float:fl_EntVelocity[3], Float:fl_Acc[3]
		Stock_Directed_Vector(TargetOrigin, EntOrigin, fl_Velocity)
		xs_vec_mul_scalar(fl_Velocity, Speed, fl_Velocity)
		
		for(new i =0; i<3; i++)
		{
			if(fl_Velocity[i] > fl_EntVelocity[i]) 
			{
				fl_Acc[i] = fl_Velocity[i]-fl_EntVelocity[i]
				fl_Acc[i] = floatmin(70.0, fl_Acc[i])
				fl_EntVelocity[i] += fl_Acc[i]
			}
			else if(fl_Velocity[i] < fl_EntVelocity[i])
			{
				fl_Acc[i] = fl_EntVelocity[i]-fl_Velocity[i]
				fl_Acc[i] = floatmin(70.0, fl_Acc[i])
				fl_EntVelocity[i] -= fl_Acc[i]
			}
		}
		set_pev(ent, pev_velocity, fl_EntVelocity)
	}
}
stock Stock_Directed_Vector(Float:start[3],Float:end[3],Float:reOri[3])
{	
	new Float:v3[3]
	v3[0]=start[0]-end[0]
	v3[1]=start[1]-end[1]
	v3[2]=start[2]-end[2]
	new Float:vl = vector_length(v3)
	reOri[0] = v3[0] / vl
	reOri[1] = v3[1] / vl
	reOri[2] = v3[2] / vl
}
stock hook_ent(ent, victim)
{
	static Float:fl_Velocity[3]
	static Float:VicOrigin[3], Float:EntOrigin[3]
	static Float:Speed

	pev(ent, pev_origin, EntOrigin)
	pev(victim, pev_origin, VicOrigin)
	Speed = 200.0
	
	static Float:distance_f
	distance_f = get_distance_f(EntOrigin, VicOrigin)

	if (distance_f > 60.0)
	{
		new Float:fl_Time = distance_f / Speed

		fl_Velocity[0] = (VicOrigin[0] - EntOrigin[0]) / fl_Time
		fl_Velocity[1] = (VicOrigin[1] - EntOrigin[1]) / fl_Time
		fl_Velocity[2] = (VicOrigin[2] - EntOrigin[2]) / fl_Time
	} else
	{
		fl_Velocity[0] = 0.0
		fl_Velocity[1] = 0.0
		fl_Velocity[2] = 0.0
	}

	entity_set_vector(ent, EV_VEC_velocity, fl_Velocity)
}
stock create_blood(const Float:origin[3])
{
	// Show some blood :)
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY) 
	write_byte(TE_BLOODSPRITE)
	engfunc(EngFunc_WriteCoord, origin[0])
	engfunc(EngFunc_WriteCoord, origin[1])
	engfunc(EngFunc_WriteCoord, origin[2])
	write_short(m_iBlood[1])
	write_short(m_iBlood[0])
	write_byte(75)
	write_byte(5)
	message_end()
}
public FindClosesEnemy(entid)
{
	new Float:Dist
	new Float:maxdistance=4000.0
	new indexid=0	
	for(new i=1;i<=get_maxplayers();i++){
		if(is_user_alive(i) && is_valid_ent(i) && can_see_fm(entid, i))
		{
			Dist = entity_range(entid, i)
			if(Dist <= maxdistance)
			{
				maxdistance=Dist
				indexid=i
				
				return indexid
			}
		}	
	}	
	return 0
}
public bool:can_see_fm(entindex1, entindex2)
{
	if (!entindex1 || !entindex2)
		return false

	if (pev_valid(entindex1) && pev_valid(entindex1))
	{
		new flags = pev(entindex1, pev_flags)
		if (flags & EF_NODRAW || flags & FL_NOTARGET)
		{
			return false
		}

		new Float:lookerOrig[3]
		new Float:targetBaseOrig[3]
		new Float:targetOrig[3]
		new Float:temp[3]

		pev(entindex1, pev_origin, lookerOrig)
		pev(entindex1, pev_view_ofs, temp)
		lookerOrig[0] += temp[0]
		lookerOrig[1] += temp[1]
		lookerOrig[2] += temp[2]

		pev(entindex2, pev_origin, targetBaseOrig)
		pev(entindex2, pev_view_ofs, temp)
		targetOrig[0] = targetBaseOrig [0] + temp[0]
		targetOrig[1] = targetBaseOrig [1] + temp[1]
		targetOrig[2] = targetBaseOrig [2] + temp[2]

		engfunc(EngFunc_TraceLine, lookerOrig, targetOrig, 0, entindex1, 0) //  checks the had of seen player
		if (get_tr2(0, TraceResult:TR_InOpen) && get_tr2(0, TraceResult:TR_InWater))
		{
			return false
		} 
		else 
		{
			new Float:flFraction
			get_tr2(0, TraceResult:TR_flFraction, flFraction)
			if (flFraction == 1.0 || (get_tr2(0, TraceResult:TR_pHit) == entindex2))
			{
				return true
			}
			else
			{
				targetOrig[0] = targetBaseOrig [0]
				targetOrig[1] = targetBaseOrig [1]
				targetOrig[2] = targetBaseOrig [2]
				engfunc(EngFunc_TraceLine, lookerOrig, targetOrig, 0, entindex1, 0) //  checks the body of seen player
				get_tr2(0, TraceResult:TR_flFraction, flFraction)
				if (flFraction == 1.0 || (get_tr2(0, TraceResult:TR_pHit) == entindex2))
				{
					return true
				}
				else
				{
					targetOrig[0] = targetBaseOrig [0]
					targetOrig[1] = targetBaseOrig [1]
					targetOrig[2] = targetBaseOrig [2] - 17.0
					engfunc(EngFunc_TraceLine, lookerOrig, targetOrig, 0, entindex1, 0) //  checks the legs of seen player
					get_tr2(0, TraceResult:TR_flFraction, flFraction)
					if (flFraction == 1.0 || (get_tr2(0, TraceResult:TR_pHit) == entindex2))
					{
						return true
					}
				}
			}
		}
	}
	return false
}	
stock set_entity_anim(ent, anim, Float:framerate, resetframe)
{
	if(!pev_valid(ent))
		return
	
	if(!resetframe)
	{
		if(pev(ent, pev_sequence) != anim)
		{
			set_pev(ent, pev_animtime, get_gametime())
			set_pev(ent, pev_framerate, framerate)
			set_pev(ent, pev_sequence, anim)
		}
	} else {
		set_pev(ent, pev_animtime, get_gametime())
		set_pev(ent, pev_framerate, framerate)
		set_pev(ent, pev_sequence, anim)
	}
}
stock get_speed_vector(const Float:origin1[3],const Float:origin2[3],Float:speed, Float:new_velocity[3])
{
	new_velocity[0] = origin2[0] - origin1[0]
	new_velocity[1] = origin2[1] - origin1[1]
	new_velocity[2] = origin2[2] - origin1[2]
	new Float:num = floatsqroot(speed*speed / (new_velocity[0]*new_velocity[0] + new_velocity[1]*new_velocity[1] + new_velocity[2]*new_velocity[2]))
	new_velocity[0] *= num
	new_velocity[1] *= num
	new_velocity[2] *= num
       
	return 1;
}
public Stock_Fake_KnockBack(id, iVic, Float:iKb)
{
	if(iVic > 32) return
	
	new Float:vAttacker[3], Float:vVictim[3], Float:vVelocity[3], flags
	pev(id, pev_origin, vAttacker)
	pev(iVic, pev_origin, vVictim)
	vAttacker[2] = vVictim[2] = 0.0
	flags = pev(id, pev_flags)
	
	xs_vec_sub(vVictim, vAttacker, vVictim)
	new Float:fDistance
	fDistance = xs_vec_len(vVictim)
	xs_vec_mul_scalar(vVictim, 1 / fDistance, vVictim)
	
	pev(iVic, pev_velocity, vVelocity)
	xs_vec_mul_scalar(vVictim, iKb, vVictim)
	xs_vec_mul_scalar(vVictim, 50.0, vVictim)
	vVictim[2] = xs_vec_len(vVictim) * 0.15
	
	if(flags &~ FL_ONGROUND)
	{
		xs_vec_mul_scalar(vVictim, 1.2, vVictim)
		vVictim[2] *= 0.4
	}
	if(xs_vec_len(vVictim) > xs_vec_len(vVelocity)) set_pev(iVic, pev_velocity, vVictim)
}
public npc_turntotarget(ent, Float:Ent_Origin[3], target, Float:Vic_Origin[3]) 
{
	if(target)
	{
		new Float:newAngle[3]
		entity_get_vector(ent, EV_VEC_angles, newAngle)
		new Float:x = Vic_Origin[0] - Ent_Origin[0]
		new Float:z = Vic_Origin[1] - Ent_Origin[1]

		new Float:radians = floatatan(z/x, radian)
		newAngle[1] = radians * (180 / 3.14)
		if (Vic_Origin[0] < Ent_Origin[0])
			newAngle[1] -= 180.0
        
		entity_set_vector(ent, EV_VEC_angles, newAngle)
	}
}
