###############################
# +---------------------------
# |
# | D e n i z e n   C u t s c e n e s
# |
# | The ultimate cutscene tool.
# |
# +---------------------------
# @Author Max^
# @date 2022/06/16
# @updated 2022/08/27
# @denizen-build REL-1771
# @script-version 1.0 BETA

#-Github: https://github.com/FutureMaximus/Denizen-Cutscenes

##Description:
#Denizen Cutscenes allows you to create cutscenes in a very simple
#way from a gui. Similar to animation keyframes you can adjust what happens within each keyframe.
#You can show specific animated models to players very useful for something like an intro to a boss level.
#For even more customization you can use your own run tasks within keyframes.
#The editor mode allows you to visualize your cutscenes whether it'd be paths, camera locations, or specific locations for animators.

##NOTICE (These are are highly recommended for use of the entire cutscene tool):
#Denizen Models will allow you to display animated models in cutscenes
#Forums: https://forum.denizenscript.com/resources/denizen-models.103/
#Github: https://github.com/mcmonkeyprojects/DenizenModels

#Denizen Player Models will allow you to display animated player models
#with multiple joints in cutscenes (Compatible with mccosmetics plugin)
#Forums: https://forum.denizenscript.com/resources/denizen-player-models.107/
#Github: https://github.com/FutureMaximus/Denizen-Player-Models

#There are resource pack assets you can use to improve the overall look of the tool such as
#the 3D modeled camera that can be viewed in editor mode and custom GUI it also contains the
#cinematic screeneffect and cutscene black bars so if you'd like to use all features it's highly
#recommended to use these assets.
#If you need some info on resource packs https://guide.denizenscript.com/guides/non-denizen/resource-packs.html

##Save file location (Must have allow write on true in Denizen config)
#Denizen/data/dcutscenes/scenes

#Config for DCutscenes (See the wiki for more explanation on what these do.)
dcutscenes_config:
    type: data
    config:
      #Compress the save file saving storage if you want to debug the save file put false
      #Note that allow write must be true in your Denizen config for this to function.
      cutscene_compress_save_file: false

      #Prefix for messages (Use & for color codes)
      cutscene_prefix: &9&lDCutscenes

      #title of cutscene gui
      cutscene_title: 

      #color of title in cutscene gui (rgb values also work 255,255,255)
      cutscene_title_color: gray

      #whether to use the cutscene black bars
      use_cutscene_black_bars: true

      #unicode image of cutscene black bar on the top (set it to false to disable this)
      #-Note: This uses a bossbar other plugins may interfere see if you can disable their functions before starting the cutscene
      cutscene_black_bar_top: 

      #unicode image of cutscene black bar on the bottom (set it to false to disable this)
      #-Note: This uses an actionbar other plugins may interfere see if you can disable their functions before starting the cutscene
      cutscene_black_bar_bottom: 

      #cinematic screen effect unicode image
      cutscene_transition_unicode: 

      #How far path particles can be seen at and tracked setting this value higher will decrease performance be careful with this
      cutscene_path_distance: 50

      #The rate in seconds of updating the visible path in cutscene editor mode setting this value lower will decrease performance
      cutscene_path_update_interval: 2s

      #The material of the path particles (must be a valid material https://hub.spigotmc.org/javadocs/spigot/org/bukkit/Material.html)
      cutscene_path_material: cyan_stained_glass

      #The rate in seconds of updating the visible semi path in cutscene editor mode setting this value lower will decrease performance
      cutscene_semi_path_update_interval: 0.5s

      #The color of the semi path particles (can also be rgb like 255,255,255)
      cutscene_semi_path_color: aqua

      #Maximum amount of lines main keyframes can display animators
      cutscene_main_keyframe_lore_limit: 15

      #Max distance the ray trace can go for the location editor this is for moving locations with your cursor
      cutscene_loc_tool_ray_dist: 6

      #Max delay the cutscene will wait for chunks to be loaded allowing the camera to be spawned.
      cutscene_chunk_load_delay: 10t

      #If true data for debug will be sent to Denizen/data/dcutscenes/debug. Note that if this is on every time you modify keyframes the data will be sent here
      #and server dcutscene data will not be updated this is used when handling maptag data so you can visualize the changes without creating corrupt data by accident.
      #If you don't plan on making contributions keep this false.
      cutscene_tool_debugger_mode: false

###################################

#==== API Usage ====

#==Run Tasks

# To begin a cutscene. You may also specify the time it will begin:
# - run dcutscene_animation_begin def.scene:my_scene def.player:<player> def.timespot:0s def.world:<player.world>

# To stop the cutscene for the player
# - run dcutscene_animation_stop def.player:<player>

# Show the screeneffect to the player
# - run dcutscene_screeneffect def.player:<player> def.fade_in:1s def.stay:3s def.fade_out:1s def.color:<black>

#==Cutscene Flags (Returns null if data is not available)

# Returns the name of the player's played scene
# - define played_scene <player.flag[dcutscene_played_scene.name].if_null[null]>

# Returns the uuid of the player's played scene
# - define played_scene_uuid <player.flag[dcutscene_played_scene.uuid].if_null[null]>

# Returns the player cutscene timespot in ticks
# - define player_timespot <player.flag[dcutscene_timespot].if_null[null]>

# Returns a spawned entity or model within the cutscene make sure you use .root at the end for the entity itself
# The input is the ID of the model or entity in the cutscene
# - define scene_entity <player.flag[dcutscene_spawned_models.my_models_name.root].if_null[null]>

# Returns the type of the spawned entity use .type at the end
# Possible return types are: entity, model, or player_model
# - define scene_entity_type <player.flag[dcutscene_spawned_models.my_models_name.type].if_null[null]>

#===================

##################################

#==== Planned ====
#- Implement entity animator
#- Implement recording system for models and entity animators
#- Implement ability for camera to follow a model or entity in the cutscene relative to it's location
#- Make it so camera or model spawns between the path and start there based on the timespot
#- Implement ability to move or duplicate animators to another scene
#=================