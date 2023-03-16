local emotes = {
    ["crouch"] = "/Game/Animation/Human/Hu_Crouch_LF_Idle_anm.Hu_Crouch_LF_Idle_anm",
    ["dance"] = "/Game/Animation/Human/Hu_Rct_Spell_Dance_anm.Hu_Rct_Spell_Dance_anm",
    ["dance2"] = "/Game/Animation/Human/Hu_Cmbt_Atk_AOE_Incendio_Loop_anm.Hu_Cmbt_Atk_AOE_Incendio_Loop_anm",
    ["dance3"] = "/Game/Animation/Human/Hu_Rct_Spell_Dance_v01_anm.Hu_Rct_Spell_Dance_v01_anm",
    ["drunk"] = "/Game/Animation/Human/DarkWizard/Stations/Camp/DWM_STN_STND_FS_Drunk_v01_anm.DWM_STN_STND_FS_Drunk_v01_anm",
    ["drunk2"] = "/Game/Animation/Human/DarkWizard/Stations/Camp/DWF_STN_STND_FS_Drunk_v01_anm.DWF_STN_STND_FS_Drunk_v01_anm",
    ["fetal"] = "/Game/Animation/Human/DarkWizard/Stations/Azkaban/DW_STN_SIT_Floor_Prisoner_Fetal_anm.DW_STN_SIT_Floor_Prisoner_Fetal_anm",
    ["fire"] = "/Game/Animation/Human/Hu_Env_IntrAct_Rct_HotBreath_anm.Hu_Env_IntrAct_Rct_HotBreath_anm",
    ["inspect"] = "/Game/Animation/Human/DarkWizard/DeathMinion/Stations/Silver/FGB/DM_STN_STND_FS_InspectBody_AllFours_v01_anm.DM_STN_STND_FS_InspectBody_AllFours_v01_anm",
    ["lay"] = "/Game/Animation/Human/HuF_Rct_SpelLook_Ground_LeanSit_Nap_anm.HuF_Rct_SpelLook_Ground_LeanSit_Nap_anm",
    ["lean"] = "/Game/Animation/Human/HU_STN_STND_Rct_Bump_WallLean_Fwd_v01_anm.HU_STN_STND_Rct_Bump_WallLean_Fwd_v01_anm",
    ["lean2"] = "/Game/Animation/Human/HU_STN_STND_Rct_Bump_RailLean_Bck_v01_anm.HU_STN_STND_Rct_Bump_RailLean_Bck_v01_anm",
    ["lean3"] = "/Game/Animation/Human/HU_STN_STND_Rct_Bump_WallLean_Fwd_v03_anm.HU_STN_STND_Rct_Bump_WallLean_Fwd_v03_anm",
    ["notes"] = "/Game/Animation/Human/Stations/Standing/HU_STN_NotePad_Loop_ANM.HU_STN_NotePad_Loop_ANM",
    ["peeves"] = "/Game/Animation/Human/Kid/Peeves/Peev_BM_Fly_F_Loop_anm.Peev_BM_Fly_F_Loop_anm",
    ["pet"] = "/Game/Animation/Human/Hu_Nurture_Petting_Loop_anm.Hu_Nurture_Petting_Loop_anm",
    ["sad"] = "/Game/Animation/Student/Stu_Emo_BM_Add_Sad_v01_anm.Stu_Emo_BM_Add_Sad_v01_anm",
    ["scratch"] = "/Game/Animation/Human/Hu_BM_IdleBreak_Casual_Scratch_Neck_anm.Hu_BM_IdleBreak_Casual_Scratch_Neck_anm",
    ["shake"] = "/Game/Animation/Human/DarkWizard/Stations/Azkaban/DW_STN_STND_PrisonDoor_CrazyShaking_anm.DW_STN_STND_PrisonDoor_CrazyShaking_anm",
    ["sit"] = "/Game/Animation/Human/Stations/Sitting/STUF_STN_SIT_Bench_Eat_Box_v01_anm",
    ["sit2"] = "/Game/Animation/Human/Kid/Stations/YoungStudent/STUMY_STN_SIT_TableChair_Study_Tr_Base2Study_anm.STUMY_STN_SIT_TableChair_Study_Tr_Base2Study_anm",
    ["sleep"] = "/Game/Animation/Human/DarkWizard/Stations/Sitting/DW_STN_Grnd_Sleeping_Loop_v01_anm.DW_STN_Grnd_Sleeping_Loop_v01_anm",
    ["spin"] = "/Game/Animation/Human/DarkWizard/DW_Rct_Bump_Spin_Bwd_02_Fire_anm.DW_Rct_Bump_Spin_Bwd_02_Fire_anm",
    ["stinky"] = "/Game/Animation/Human/Adult/Adult_M/Professors/Fig/Fig_BM_Idle_Loop_Stinky_anm.Fig_BM_Idle_Loop_Stinky_anm",
    ["study"] = "/Game/Animation/Human/Kid/Stations/YoungStudent/STUFY_STN_SIT_Bench_Study_Tr_Base2Study_anm.STUFY_STN_SIT_Bench_Study_Tr_Base2Study_anm",
    ["study2"] = "/Game/Animation/Human/Kid/Stations/YoungStudent/STUMY_STN_SIT_Bench_Study_Tr_Base2Study_anm.STUMY_STN_SIT_Bench_Study_Tr_Base2Study_anm",
    ["tea"] = "/Game/Animation/Human/Hu_Env_IntrAct_Drink_Tea_anm.Hu_Env_IntrAct_Drink_Tea_anm",
}

registerCommand({"e", "emote"}, function (player, args)
    if #args == 0 or args[1] == nil then
        player:RpcSetAnimation("")
        return
    end
    local calledEmote = args[1]:lower()
    for emote,animation in pairs(emotes) do
        if emote:lower() == calledEmote then
            player:RpcSetAnimation(animation)
            return
        end
    end
end)