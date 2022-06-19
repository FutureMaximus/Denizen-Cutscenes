###############################
# +---------------------------
# |
# | D e n i z e n   C u t s c e n e s
# |
# | The ultimate cutscene tool.
# |
# +---------------------------
# @Contributor Max^
# @date 2022/06/16
# @updated 2022/06/16
# @denizen-build REL-1771
# @script-version 1.0 BETA
##Description:
#Denizen Cutscenes allows you to create cutscenes in a very simple
#way from a gui. Similar to animation keyframes you can adjust what happens within each keyframe.
#You can show specific animated models to players very useful for something like an intro to a boss level.
#For even more customization you can use your own run tasks within keyframes.
#The editor mode allows you to visualize your cutscenes whether it'd be paths, camera locations, or specific locations for elements.

##NOTICE:
#To use all the features you need a resource pack and know the basics of operating one.

#There are resource pack assets you can use to improve the experience such as
#the 3d modeled camera that can be viewed in editor mode.

##Save file location
#Denizen/data/dcutscenes/scenes

#Config for DCutscenes
dcutscenes_config:
    type: data
    config:
      #title of cutscene gui
      cutscene_title: 
      #color of title in cutscene gui
      cutscene_title_color: gray
      #unicode image of cutscene black bar on the top (set it to false to disable this)
      ##Note: This uses a bossbar other plugins may interfere see if you can disable their functions before starting the cutscene
      cutscene_black_bar_top: lol
      #unicode image of cutscene black bar on the bottom (set it to false to disable this)
      ##Note: This uses an actionbar other plugins may interfere see if you can disable their functions before starting the cutscene
      cutscene_black_bar_bottom: lol

#Things you can do:
# - Display custom models with animations including a specific yaw to spawn that model at (Requires Denizen Models)
# - Display player models with animations (Requires Denizen Player Models)
# - Use your own run tasks in a keyframe for more customization
# - Play particles at any specified location
# - Play sound
# - Modify where the camera will look and go
# - Modify target locations using buttons in your inventory for precise locations
# - Send titles
# - Send fake schematics or blocks

##GUI Items  ##########################
#(Do not change the item script names or definitions passed through lore please you are free to change anything else)

#The visible camera when editing cutscenes
dcutscene_camera_item:
    type: item
    material: stick
    mechanisms:
      custom_model_data: 0

#The exit button for the cutscene gui
dcutscene_exit:
    type: item
    material: stick
    display name: <red><bold>Exit
    lore:
    - <empty>
    mechanisms:
      custom_model_data: 0

#Next page button in keyframe page
dcutscene_next:
    type: item
    material: blue_wool
    display name: <blue><bold>Next Page

#Previous page button in keyframe page
dcutscene_previous:
    type: item
    material: blue_wool
    display name: <blue><bold>Previous Page

#Keyframe Item
dcutscene_keyframe:
    type: item
    material: blue_stained_glass_pane
    mechanisms:
      custom_model_data: 0

#Keyframe that contains elements
dcutscene_keyframe_contains:
    type: item
    material: green_stained_glass_pane
    mechanisms:
      custom_model_data: 0

#Sub keyframe
dcutscene_sub_keyframe:
    type: item
    material: cyan_stained_glass_pane
    mechanisms:
      custom_model_data: 0

#Create new cutscene item
dcutscene_new_scene_item:
    type: item
    material: green_stained_glass_pane
    display name: <green><bold>New Scene +
    lore:
    - <gray>Create a new cutscene
    mechanisms:
      custom_model_data: 0

#back page button
dcutscene_back_page:
    type: item
    material: blue_wool
    display name: <blue><bold>Back

#Settings button
dcutscene_settings:
    type: item
    material: gray_wool
    display name: <dark_gray><bold>Settings
    lore:
    - <gray>Change the settings of this cutscene.

#Modify keyframes button
dcutscene_keyframes_list:
    type: item
    material: blue_wool
    display name: <blue><bold>Modify Keyframes

#Add animator button
dcutscene_keyframe_tick_add:
    type: item
    material: green_stained_glass
    display name: <green><bold>Add Animator +

#Default item for cutscenes
dcutscene_scene_item_default:
    type: item
    material: green_wool

#Option Items
##Camera
dcutscene_add_cam:
    type: item
    material: gray_wool
    display name: <dark_gray><bold>Modify Camera
    lore:
    - <gray>Change where the camera moves or looks

dcutscene_camera_keyframe:
    type: item
    material: gray_wool
    display name: <dark_gray><bold>Camera

dcutscene_camera_loc_modify:
    type: item
    material: book
    display name: <blue><bold>Change Location
########

dcutscene_add_sound:
    type: item
    material: jukebox
    display name: <blue><bold>Play Sound
    lore:
    - <gray>Play a sound to the player.

dcutscene_add_entity:
    type: item
    material: zombie_head
    display name: <green><bold>Show entity
    lore:
    - <gray>Show an entity to the player and modify it.

dcutscene_add_model:
    type: item
    material: dragon_head
    display name: <red><bold>Show Model
    lore:
    - <gray>Show a model to the player and play animations with it.
    - <blue>Requires DModels

dcutscene_add_player_model:
    type: item
    material: player_head
    display name: <blue><bold>Show Player Model
    mechanisms:
      skull_skin: <player.skull_skin>
    lore:
    - <gray>Show a player model of the player and play animations with it.
    - <blue>Requires Denizen Player Models

dcutscene_add_run_task:
    type: item
    material: enchanted_book
    display name: <dark_purple><bold>Run a task
    lore:
    - <gray>Run a task you made.
    - <blue>- run give_rewards def.player:the_player

dcutscene_add_fake_structure:
    type: item
    material: stone
    display name: <aqua><bold>Show a fake block or fake schematic

dcutscene_add_screeneffect:
    type: item
    material: lectern
    display name: <light_purple><bold>Cinematic Screeneffect
    lore:
    - <gray>Useful for scene transitions.

dcutscene_add_particle:
    type: item
    material: nether_star
    display name: <green><bold>Show a particle
    lore:
    - <gray>Show a particle to the player at a location.

dcutscene_send_title:
    type: item
    material: bookshelf
    display name: <dark_aqua><bold>Send a title
    lore:
    - <gray>Send a title to the player.
##################################
#TODO:
# - Implement data structure for cutscenes
# - Implement model support

#The data is similar to animation keyframes where should there be something occuring in a certain time like 0.5
#it will input that information and wait until time = 0.5