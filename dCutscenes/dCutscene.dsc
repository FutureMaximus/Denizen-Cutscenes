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

##NOTICE (These are optional but are highly recommended for use of the entire cutscene tool):
#Denizen Models will allow you to display animated models in cutscenes
#Forums: https://forum.denizenscript.com/resources/denizen-models.103/
#Github: https://github.com/mcmonkeyprojects/DenizenModels

#Denizen Player Models will allow you to display animated player models
#with multiple joints in cutscenes (Compatible with mccosmetics plugin)
#Forums: https://forum.denizenscript.com/resources/denizen-player-models.107/
#Github: https://github.com/FutureMaximus/Denizen-Player-Models

#There are resource pack assets you can use to improve the overall look of the tool such as
#the 3d modeled camera that can be viewed in editor mode and custom GUI it also contains the
#cinematic screeneffect and cutscene black bars so if you'd like to use all features it's highly
#recommended to use these assets.

##Save file location
#Denizen/data/dcutscenes/scenes

#Config for DCutscenes
dcutscenes_config:
    type: data
    config:
      #title of cutscene gui
      cutscene_title: 
      #color of title in cutscene gui (rgb values also work 255,255,255)
      cutscene_title_color: gray
      #whether to use the cutscene black bars
      use_cutscene_black_bars: true
      #unicode image of cutscene black bar on the top (set it to false to disable this)
      ##Note: This uses a bossbar other plugins may interfere see if you can disable their functions before starting the cutscene
      cutscene_black_bar_top: 
      #unicode image of cutscene black bar on the bottom (set it to false to disable this)
      ##Note: This uses an actionbar other plugins may interfere see if you can disable their functions before starting the cutscene
      cutscene_black_bar_bottom: 
      #cinematic screen effect unicode image
      cutscene_transition_unicode: 
      #How far path particles can be seen at and tracked setting this value higher will decrease performance be careful with this
      cutscene_path_distance: 50
      #The rate in seconds of updating the visible path in cutscene editor mode setting this value lower will decrease performance
      cutscene_path_update_interval: 2s
      #The material of the path particles (must be a valid material https://hub.spigotmc.org/javadocs/spigot/org/bukkit/Material.html)
      cutscene_path_material: cyan_stained_glass
      #Maximum amount of lines main keyframes can display animators
      cutscene_main_keyframe_lore_limit: 15
      #Max distance the ray trace can go for the location editor this is useful for moving the location with your cursor
      cutscene_loc_tool_ray_dist: 4

##Want to contribute?
#You can find me in the Denizen discord just ping me there if you make a pull request on github
#and we can discuss the changes you made.
#Max^#0001

##Cutscene Command (You can change the usage, name and aliases for the command)#######
#TODO:
# - Add play option
# - Add remove option
# - Add modify option
dcutscene_command:
    type: command
    name: dcutscene
    usage: /dcutscene
    aliases:
    - dscene
    description: Cutscene command for DCutscene
    tab completions:
      1: <proc[dcutscene_command_list]>
      2: <proc[dcutscene_data_list].context[<player>]>
    permission: op.op
    script:
    - define a_1 <context.args.get[1].if_null[n]>
    - define a_2 <context.args.get[2].if_null[n]>
    - if <[a_1].equals[n]> || <[a_1]> == open:
      - inventory open d:dcutscene_inventory_main
      - ~run dcutscene_scene_show
    - else:
      - choose <[a_1]>:
        - case load:
          - if <[a_2].equals[n]>:
            - ~run dcutscene_load_files
          - else:
            - ~run dcutscene_load_files def.cutscene:<[a_2]>
        - case save:
          - if !<[a_2].equals[n]>:
            - ~run dcutscene_save_file def.cutscene:<[a_2]>
          - else:
            - ~run dcutscene_save_file
        - case play:
          - if !<[a_2].equals[n]>:
            - run dcutscene_animation_begin def:<[a_2]>
        - case sound:
          - if !<[a_2].equals[n]> && <player.has_flag[cutscene_modify]> && <player.flag[cutscene_modify]> == sound:
            - run dcutscene_animator_keyframe_edit def:sound|create|<[a_2]>
###################################

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
# - Set the time for the player

##GUI Items  ##########################
#(Do not change the item script names please you are free to change anything else)

#The visible camera when editing cutscenes
dcutscene_camera_item:
    type: item
    material: scute
    mechanisms:
      custom_model_data: 10001

dcutscene_play_cutscene_item:
    type: item
    material: paper
    display name: <blue><bold>Play Cutscene
    lore:
    - <empty>
    - <gray><italic>Click to play this cutscene

dcutscene_save_file_item:
    type: item
    material: enchanted_book
    display name: <blue><bold>Save Cutscene
    lore:
    - <empty>
    - <gray>Saves the cutscene to a directory
    - <gray>for use in other servers or data backup.
    - <green>Denizen/data/dcutscenes/scenes

dcutscene_add_new_model:
    type: item
    material: green_stained_glass_pane
    display name: <green><bold>Add New Model +
    lore:
    - <empty>
    - <gray><italic>Click to add new model

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

#Scroll down the page
dcutscene_scroll_down:
    type: item
    material: blue_wool
    display name: <blue><bold>Scroll Down

#Scroll up the page
dcutscene_scroll_up:
    type: item
    material: blue_wool
    display name: <blue><bold>Scroll Up

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
    material: scute
    mechanisms:
      custom_model_data: 10001
    display name: <dark_gray><bold>Modify Camera
    lore:
    - <gray>Change where the camera moves or looks

dcutscene_camera_path_show:
    type: item
    material: paper
    display name: <dark_aqua><bold>Camera Path
    lore:
    - <gray>Shows the camera's path in the cutscene

dcutscene_camera_keyframe:
    type: item
    material: scute
    mechanisms:
      custom_model_data: 10001
    display name: <dark_gray><bold>Camera

dcutscene_camera_loc_modify:
    type: item
    material: book
    display name: <blue><bold>Change Camera Location
    lore:
    - <empty>
    - "<gray><italic>Click to change location of camera in keyframe"

dcutscene_camera_remove_modify:
    type: item
    material: paper
    display name: <red><bold>Remove camera from keyframe
    lore:
    - <empty>
    - "<gray><italic>Click to remove camera from keyframe"

dcutscene_camera_teleport:
    type: item
    material: paper
    display name: <aqua><bold>Teleport to location

dcutscene_camera_interp_modify:
    type: item
    material: lead
    display name: <green><bold>Path Interpolation Method
    lore:
    - <empty>
    - "<gray>The interpolation method for the movement"
    - "<gray>path of the camera"
    - "<gray>Linear: A straight line (Linear Interpolation)"
    - "<gray>Smooth: A spline curve (Centripetal Catmullrom Interpolation)"
    - <empty>
    - "<gray><italic>Click to modify interpolation method"

dcutscene_camera_move_modify:
    type: item
    material: paper
    display name: <green><bold>Move Camera
    lore:
    - <empty>
    - "<gray>Determine if the camera will move to the next keyframe point"
    - <empty>
    - "<gray><italic>Click to modify movement for camera"

dcutscene_camera_upside_down:
    type: item
    material: paper
    display name: <dark_purple><bold>Upside Down Camera
    lore:
    - <empty>
    - <gray>Determine if the camera is upside down or not
    - <empty>
    - <red>EXPIREMENTAL
    - <empty>
    - <gray><italic>Click to change upside down feature

dcutscene_camera_look_modify:
    type: item
    material: paper
    display name: <green><bold>Set look location
    lore:
    - <empty>
    - <gray>Set the look location for the
    - <gray>camera in this keyframe.
    - <gray>Input <red>false <gray>to disable.
    - <gray>Note: If rotate is false this will
    - <gray>be ignored.
    - <empty>
    - <gray><italic>Click to set the look location

dcutscene_camera_rotate_modify:
    type: item
    material: compass
    display name: <dark_aqua><bold>Rotate Camera
    lore:
    - <empty>
    - <gray>Determine if the camera will rotate and look
    - <gray>at the next look point otherwise it will use
    - <gray>the previous pitch and yaw.
    - <empty>
    - <gray><italic>Click to change camera rotate

dcutscene_camera_interpolate_look:
    type: item
    material: compass
    display name: <dark_green><bold>Interpolate Look
    lore:
    - <empty>
    - <gray>If true the camera will smoothly
    - <gray>transition to the next look point
    - <gray>If false the camera will instantly look
    - <gray>at the next look point.
    - <gray>Note: If rotate is false this will
    - <gray>be ignored.
    - <empty>
    - <gray><italic>Click to modify look interpolation for camera
########

##Sound
dcutscene_add_sound:
    type: item
    material: jukebox
    display name: <blue><bold>Add Sound
    lore:
    - <gray>Play a sound to the player.

dcutscene_sound_keyframe:
    type: item
    material: jukebox
    display name: <red><bold>Sound

dcutscene_sound_modify:
    type: item
    material: jukebox
    display name: <blue><bold>Change Sound
    lore:
    - <empty>
    - <gray><italic>Click to change sound

dcutscene_sound_volume_modify:
    type: item
    material: repeater
    display name: <aqua><bold>Change Volume
    lore:
    - <empty>
    - <gray>Volumes greater than 1.0 will be audible from farther away.
    - <empty>
    - <gray><italic>Click to change sound volume

dcutscene_sound_pitch_modify:
    type: item
    material: lever
    display name: <dark_blue><bold>Change Pitch
    lore:
    - <empty>
    - <gray><italic>Click to change sound pitch

dcutscene_sound_loc_modify:
    type: item
    material: beacon
    display name: <dark_aqua><bold>Change Location
    lore:
    - <empty>
    - <gray>The sound will play at this location.
    - <empty>
    - <gray><italic>Click to change sound location

dcutscene_sound_custom_modify:
    type: item
    material: note_block
    display name: <dark_purple><bold>Custom Sound
    lore:
    - <empty>
    - <gray>If you have a custom sound make sure this is true.
    - <empty>
    - <gray><italic>Click to change custom sound

dcutscene_sound_stop_modify:
    type: item
    material: paper
    display name: <red><bold>Stop Sound
    lore:
    - <empty>
    - <gray>Determine what sound or if all sounds will be stopped in this tick.
    - <empty>
    - <gray><italic>Click to stop sound

dcutscene_sound_remove_modify:
    type: item
    material: paper
    display name: <red><bold>Remove Sound
    lore:
    - <empty>
    - <gray><italic>Click to remove sound
######

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

## Player Model ###
dcutscene_add_player_model:
    type: item
    material: player_head
    display name: <blue><bold>Show Player Model
    mechanisms:
      skull_skin: <player.skull_skin>
    lore:
    - <gray>Show a player model of the player and play animations with it.
    - <blue>Requires Denizen Player Models

dcutscene_keyframe_player_model:
    type: item
    material: player_head
    display name: <blue><bold>Player Model
    mechanisms:
      skull_skin: <player.skull_skin>

dcutscene_player_model_change_id:
    type: item
    material: name_tag
    display name: <blue><bold>Change ID
    lore:
    - <empty>
    - <gray><italic>Click to change player model ID

dcutscene_player_model_change_location:
    type: item
    material: tripwire_hook
    display name: <green><bold>Change Location
    lore:
    - <empty>
    - <gray><italic>Click to change player model location

dcutscene_player_model_ray_trace_floor:
    type: item
    material: observer
    display name: <dark_aqua><bold>Ray Trace Floor
    lore:
    - <empty>
    - <gray>Determine if the model will be on the floor during movement
    - <gray>generally this should be kept true unless not needed such as
    - <gray>a flying model.
    - <empty>
    - <gray><italic>Click to change ray trace floor

dcutscene_player_model_move:
    type: item
    material: tripwire_hook
    display name: <green><bold>Move Model
    lore:
    - <empty>
    - <gray>Determine if the player model will move to the next keyframe point
    - <empty>
    - <gray><italic>Click to change player model location

dcutscene_remove_player_model:
    type: item
    material: paper
    display name: <red><bold>Remove Player Model
    lore:
    - <empty>
    - <gray><italic>Click to remove player model

##Run Task ###
dcutscene_add_run_task:
    type: item
    material: enchanted_book
    display name: <dark_purple><bold>Run a task
    lore:
    - <gray>Run a task you made.
    - <blue>Example: run give_rewards def.player:the_player

dcutscene_run_task_keyframe:
    type: item
    material: enchanted_book
    display name: <dark_purple><bold>Run Task

dcutscene_run_task_change_modify:
    type: item
    material: enchanted_book
    display name: <dark_purple><bold>Change Run Task Script
    lore:
    - <empty>
    - <gray><italic>Click to change run task script

dcutscene_run_task_def_modify:
    type: item
    material: writable_book
    display name: <dark_blue><bold>Set Definitions
    lore:
    - <empty>
    - <gray>Pass definitions through the
    - <gray>run task.
    - <empty>
    - <gray><italic>Click to set definitions

dcutscene_run_task_wait_modify:
    type: item
    material: clock
    display name: <gold><bold>Waitable Task
    lore:
    - <empty>
    - <gray>Determine if the run task will
    - <gray>will be performed in a slowed
    - <gray>execution. (Useful for resource
    - <gray>intensive tasks ensuring the server
    - <gray>does not freeze.)
    - <empty>
    - <gray><italic>Click to change waitable

dcutscene_run_task_delay_modify:
    type: item
    material: repeater
    display name: <aqua><bold>Task Delay
    lore:
    - <empty>
    - <gray>Delays the script before
    - <gray>it runs.
    - <empty>
    - <gray><italic>Click to change run task delay

dcutscene_run_task_remove_modify:
    type: item
    material: paper
    display name: <red><bold>Remove Run Task
    lore:
    - <empty>
    - <gray><italic>Click to remove run task

##############

dcutscene_add_fake_structure:
    type: item
    material: stone
    display name: <aqua><bold>Show a fake block or fake schematic

##Screeneffect ###
dcutscene_add_screeneffect:
    type: item
    material: lectern
    display name: <light_purple><bold>Cinematic Screeneffect
    lore:
    - <gray>Useful for scene transitions.
    - <blue>Requires screeneffect unicode in resource pack

dcutscene_screeneffect_keyframe:
    type: item
    material: lectern
    display name: <light_purple><bold>Cinematic Screeneffect
    lore:
    - <empty>
    - <gray><italic>Click to modify screeneffect

dcutscene_screeneffect_time_modify:
    type: item
    material: note_block
    display name: <blue><bold>Change time
    lore:
    - <empty>
    - <gray><italic>Click to change screeneffect time

dcutscene_screeneffect_color_modify:
    type: item
    material: painting
    display name: <red><bold>Change Color
    lore:
    - <empty>
    - <gray><italic>Click to change screeneffect color

dcutscene_screeneffect_remove_modify:
    type: item
    material: paper
    display name: <red><bold>Remove Screeneffect
    lore:
    - <empty>
    - <gray><italic>Click to remove screeneffect
#################

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

dcutscene_play_command:
    type: item
    material: book
    display name: <dark_aqua><bold>Play Command
    lore:
    - <gray>Play a command to the player or console.

dcutscene_add_msg:
    type: item
    material: oak_sign
    display name: <gold><bold>Send Message
    lore:
    - <gray>Send a message to the player

dcutscene_send_time:
    type: item
    material: clock
    display name: <dark_green><bold>Set Time
    lore:
    - <gray>Set the time for the player in the cutscene.

dcutscene_set_weather:
    type: item
    material: lightning_rod
    display name: <white><bold>Set Weather
    lore:
    - <gray>Set the weather for the player in the cutscene.
##################################