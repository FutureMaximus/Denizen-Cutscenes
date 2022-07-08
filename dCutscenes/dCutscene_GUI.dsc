# Denizen Cutscenes GUI
# This contains events for the GUI including animation modifiers, tasks for handling the GUI and inventory script containers for the GUI.

##Cutscene Events#######
dcutscene_events:
    type: world
    #TODO: Set this to false
    debug: true
    events:
        on player quits:
        - if <player.has_flag[cutscene_modify]>:
          - flag <player> cutscene_modify:!
        - if <player.has_flag[dcutscene_save_data]>:
          - define data <player.flag[dcutscene_save_data]>
          - define root <[data.root]||null>
          - if <[root]> != null:
            - define type <[data.type]>
            - choose <[type]>:
              - case player_model:
                - run pmodels_remove_model def:<[root]>
              - default:
                - remove <[root]>
          - flag <player> dcutscene_save_data:!
        ##Main cutscene gui ####
        after player clicks dcutscene_keyframes_list in dcutscene_inventory_scene:
        - ~run dcutscene_keyframe_modify
        after player clicks dcutscene_save_file_item in dcutscene_inventory_scene:
        - ratelimit <player> 2s
        - define cutscene <player.flag[cutscene_data]>
        - ~run dcutscene_save_file def:<[cutscene]>
        - define text "Cutscene <green><[cutscene.name]> <gray>has been saved to <green>Denizen/data/dcutscenes/scenes<gray>."
        - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
        ########################
        ##Misc #################
        after player clicks dcutscene_exit in inventory:
        - inventory close
        ##Right click for location input in keyframe modifier##
        after player right clicks block flagged:cutscene_modify using:hand:
        - choose <player.flag[cutscene_modify]>:
          - case sound_location:
            - run dcutscene_animator_keyframe_edit def:sound|set_location|<context.location>
          - case create_present_cam_look_loc:
            - run dcutscene_cam_keyframe_edit def:edit|create_look_location|<context.location>
        ##Tab completion ############
        after tab complete flagged:cutscene_modify:
        - define list <context.completions>
        - if <[list].contains[sound]>:
            - flag <player> cutscene_modify_tab:sound
        - else if <[list].contains[animate]>:
            - flag <player> cutscene_modify_tab:animate
        #input for dcutscene gui elements
        ##Chat Input ################
        on player chats flagged:cutscene_modify:
        - define msg <context.message>
        - if <[msg]> == cancel:
          - flag <player> cutscene_modify:!
          - if <player.gamemode> == spectator:
            - adjust <player> gamemode:creative
          - determine passively cancelled
          - stop
        - choose <player.flag[cutscene_modify]>:
          - case camera_path:
            - if <[msg]> == stop:
              - flag <player> cutscene_modify:!
          #New cutscene name
          - case new_name:
            - run dcutscene_new_scene def:name|<[msg]>
          #Modify name for present cutscene
          - case name:
            - define name
          #Modify description for present cutscene
          - case desc:
            - define desc
          #Create new camera modifier
          - case create_cam:
            - if <[msg]> == confirm:
              - run dcutscene_cam_keyframe_edit def:create
          #Modify present camera in keyframe
          - case create_present_cam:
            - if <[msg]> == confirm:
              - run dcutscene_cam_keyframe_edit def:edit|create_new_location
          #Input new volume for sound modifier
          - case sound_volume:
            - run dcutscene_animator_keyframe_edit def:sound|set_volume|<[msg]>
          #Input new pitch for sound modifier
          - case sound_pitch:
            - run dcutscene_animator_keyframe_edit def:sound|set_pitch|<[msg]>
          #Input new sound location
          - case sound_location:
            - if <[msg]> == confirm:
              - run dcutscene_animator_keyframe_edit def:sound|set_location|<player.location>
            - else if <[msg]> == false:
              - run dcutscene_animator_keyframe_edit def:sound|set_location|false
            - else:
              - run dcutscene_animator_keyframe_edit def:sound|set_location|<[msg]>
          #Input new look location
          - case create_present_cam_look_loc:
            - if <[msg]> == confirm:
              - run dcutscene_cam_keyframe_edit def:edit|create_look_location|<player.eye_location>
            - else if <[msg]> == false:
              - run dcutscene_cam_keyframe_edit def:edit|create_look_location|false
            - else:
              - run dcutscene_cam_keyframe_edit def:edit|create_look_location|<[msg]>
          #Create new screeneffect modifier
          - case screeneffect:
            - run dcutscene_animator_keyframe_edit def:screeneffect|create|<[msg]>
          #Set new time
          - case screeneffect_time:
            - run dcutscene_animator_keyframe_edit def:screeneffect|set_time|<[msg]>
          #Set new color
          - case screeneffect_color:
            - run dcutscene_animator_keyframe_edit def:screeneffect|set_color|<[msg]>
          #Create new run task modifier
          - case run_task:
            - run dcutscene_animator_keyframe_edit def:run_task|create|<[msg]>
          #Change run task modifier script
          - case run_task_change:
            - run dcutscene_animator_keyframe_edit def:run_task|change_task|<[msg]>
          #Set definitions for run task
          - case run_task_def_set:
            - run dcutscene_animator_keyframe_edit def:run_task|set_task_definition|<[msg]>
          #Set delay for run task
          - case run_task_delay:
            - run dcutscene_animator_keyframe_edit def:run_task|change_delay|<[msg]>
          #Create new player model id
          - case new_player_model_id:
            - run dcutscene_model_keyframe_edit def:player_model|create|id_set|<[msg]>
          #Set new player model location
          - case new_player_model_location:
            - if <[msg]> == confirm:
              - run dcutscene_model_keyframe_edit def:player_model|create|location_set|<player.location>
        - determine cancelled
        ###########################
        ##Keyframe GUI ####################
        after player clicks dcutscene_new_scene_item in dcutscene_inventory_main:
        - inventory close
        - run dcutscene_new_scene
        after player clicks item in dcutscene_inventory_main:
        - define i <context.item>
        - if <[i].has_flag[cutscene_data]>:
          - inventory open d:dcutscene_inventory_scene
          - flag <player> cutscene_data:<[i].flag[cutscene_data]>
        after player clicks item in dcutscene_inventory_keyframe:
        - define i <context.item>
        - if <[i].has_flag[keyframe_data]>:
          - flag <player> sub_keyframe_tick_page:0
          - inventory open d:dcutscene_inventory_sub_keyframe
          - ~run dcutscene_sub_keyframe_modify def:<[i].flag[keyframe_data]>
        #Present animators to modify
        after player clicks item in dcutscene_inventory_sub_keyframe:
        - define i <context.item>
        #New keyframe modifier
        - if <[i].has_flag[keyframe_modify]>:
          - flag <player> dcutscene_tick_modify:<[i].flag[keyframe_modify]>
          - inventory open d:dcutscene_inventory_keyframe_modify
        #Modify present keyframe modifier
        - else if <[i].has_flag[keyframe_opt_modify]>:
          #Modify type
          - choose <[i].flag[keyframe_opt_modify.type]>:
            #Camera type
            - case camera:
              - flag <player> dcutscene_tick_modify:<[i].flag[keyframe_opt_modify.tick]>
              - inventory open d:dcutscene_inventory_keyframe_modify_camera
            #Player Model type
            - case player_model:
              - flag <player> dcutscene_tick_modify:<[i].flag[keyframe_opt_modify]>
              - inventory open d:dcutscene_inventory_keyframe_modify_player_model
            #Run Task Type
            - case run_task:
              - flag <player> dcutscene_tick_modify:<[i].flag[keyframe_opt_modify]>
              - inventory open d:dcutscene_inventory_keyframe_modify_run_task
            #Sound type
            - case sound:
              - flag <player> dcutscene_tick_modify:<[i].flag[keyframe_opt_modify]>
              - inventory open d:dcutscene_inventory_keyframe_modify_sound
            #Screeneffect
            - case screeneffect:
              - flag <player> dcutscene_tick_modify:<[i].flag[keyframe_opt_modify]>
              - inventory open d:dcutscene_inventory_keyframe_modify_screeneffect
        #Scroll up
        on player clicks dcutscene_scroll_up in dcutscene_inventory_sub_keyframe:
        - if !<player.has_flag[sub_keyframe_tick_page]>:
          - flag <player> sub_keyframe_tick_page:0
          - define tick_page 0
        - define tick_page <player.flag[sub_keyframe_tick_page].sub[4]>
        - if <[tick_page]> < 1:
          - define tick_page 0
        - flag <player> sub_keyframe_tick_page:<[tick_page]>
        - ~run dcutscene_sub_keyframe_modify def:<player.flag[dcutscene_sub_keyframe_back_data]>
        #Scroll down
        on player clicks dcutscene_scroll_down in dcutscene_inventory_sub_keyframe:
        - if !<player.has_flag[sub_keyframe_tick_page]>:
          - flag <player> sub_keyframe_tick_page:0
          - define tick_page 0
        - define tick_page <player.flag[sub_keyframe_tick_page].add[4]>
        - flag <player> sub_keyframe_tick_page:<[tick_page]>
        - ~run dcutscene_sub_keyframe_modify def:<player.flag[dcutscene_sub_keyframe_back_data]>
        #####################################
        ##Option GUI events ###########
        ##Camera #####
        #Add a new camera
        after player clicks dcutscene_add_cam in dcutscene_inventory_keyframe_modify:
        - run dcutscene_cam_keyframe_edit def:new
        #New location
        after player clicks dcutscene_camera_loc_modify in dcutscene_inventory_keyframe_modify_camera:
        - run dcutscene_cam_keyframe_edit def:edit|new_location
        #New look location
        after player clicks dcutscene_camera_look_modify in dcutscene_inventory_keyframe_modify_camera:
        - run dcutscene_cam_keyframe_edit def:edit|new_look_location
        #Remove camera
        after player clicks dcutscene_camera_remove_modify in dcutscene_inventory_keyframe_modify_camera:
        - run dcutscene_cam_keyframe_edit def:edit|remove_camera
        #Teleport to camera
        after player clicks dcutscene_camera_teleport in dcutscene_inventory_keyframe_modify_camera:
        - run dcutscene_cam_keyframe_edit def:teleport
        #Modify path interpolation
        after player clicks dcutscene_camera_interp_modify in dcutscene_inventory_keyframe_modify_camera:
        - ratelimit <player> 0.5s
        - run dcutscene_cam_keyframe_edit def:edit|interpolation_change|<context.item>|<context.slot>
        #Determine move
        after player clicks dcutscene_camera_move_modify in dcutscene_inventory_keyframe_modify_camera:
        - ratelimit <player> 0.5s
        - run dcutscene_cam_keyframe_edit def:edit|move_change|<context.item>|<context.slot>
        #Determine interpolate look
        after player clicks dcutscene_camera_interpolate_look in dcutscene_inventory_keyframe_modify_camera:
        - ratelimit <player> 0.5s
        - run dcutscene_cam_keyframe_edit def:edit|interpolate_look|<context.item>|<context.slot>
        #Determine Camera Look Rotation
        after player clicks dcutscene_camera_rotate_modify in dcutscene_inventory_keyframe_modify_camera:
        - ratelimit <player> 0.5s
        - run dcutscene_cam_keyframe_edit def:edit|rotate_change|<context.item>|<context.slot>
        #Show camera path
        after player clicks dcutscene_camera_path_show in dcutscene_inventory_keyframe_modify_camera:
        - inventory close
        - run dcutscene_path_show_interval def:camera
        ## Models #######
        #New Model in model list gui
        after player clicks dcutscene_add_new_model in dcutscene_inventory_keyframe_model_list:
        - choose <player.flag[dcutscene_save_data.type]>:
          - case player_model:
            - flag <player> cutscene_modify:new_player_model_id expire:2m
            - define text "Chat the name of the player model this will be used as an identifier."
            - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
            - inventory close
        after player clicks dcutscene_add_player_model in dcutscene_inventory_keyframe_modify:
        - run dcutscene_model_keyframe_edit def:player_model|new
        ##Run Task ######
        after player clicks dcutscene_add_run_task in dcutscene_inventory_keyframe_modify:
        - run dcutscene_animator_keyframe_edit def:run_task|new
        after player clicks dcutscene_run_task_change_modify in dcutscene_inventory_keyframe_modify_run_task:
        - run dcutscene_animator_keyframe_edit def:run_task|change_task_prepare
        after player clicks dcutscene_run_task_def_modify in dcutscene_inventory_keyframe_modify_run_task:
        - run dcutscene_animator_keyframe_edit def:run_task|task_definition
        after player clicks dcutscene_run_task_wait_modify in dcutscene_inventory_keyframe_modify_run_task:
        - run dcutscene_animator_keyframe_edit def:run_task|change_waitable|<context.item>|<context.slot>
        after player clicks dcutscene_run_task_delay_modify in dcutscene_inventory_keyframe_modify_run_task:
        - run dcutscene_animator_keyframe_edit def:run_task|delay_prepare
        after player clicks dcutscene_run_task_remove_modify in dcutscene_inventory_keyframe_modify_run_task:
        - run dcutscene_animator_keyframe_edit def:run_task|remove
        ##Sound #####
        #Add new sound
        after player clicks dcutscene_add_sound in dcutscene_inventory_keyframe_modify:
        - run dcutscene_animator_keyframe_edit def:sound|new
        #New volume
        after player clicks dcutscene_sound_volume_modify in dcutscene_inventory_keyframe_modify_sound:
        - run dcutscene_animator_keyframe_edit def:sound|new_volume
        #New pitch
        after player clicks dcutscene_sound_pitch_modify in dcutscene_inventory_keyframe_modify_sound:
        - run dcutscene_animator_keyframe_edit def:sound|new_pitch
        #Determine custom
        after player clicks dcutscene_sound_custom_modify in dcutscene_inventory_keyframe_modify_sound:
        - run dcutscene_animator_keyframe_edit def:sound|set_custom|<context.item>|<context.slot>
        #New location
        after player clicks dcutscene_sound_loc_modify in dcutscene_inventory_keyframe_modify_sound:
        - run dcutscene_animator_keyframe_edit def:sound|new_location
        #Remove sound
        after player clicks dcutscene_sound_remove_modify in dcutscene_inventory_keyframe_modify_sound:
        - run dcutscene_animator_keyframe_edit def:sound|remove_sound
        ##Cinematic Screeneffect #####
        #Add new cinematic screeneffect
        after player clicks dcutscene_add_screeneffect in dcutscene_inventory_keyframe_modify:
        - run dcutscene_animator_keyframe_edit def:screeneffect|new
        #Set cinematic screeneffect time for present modifier
        after player clicks dcutscene_screeneffect_time_modify in dcutscene_inventory_keyframe_modify_screeneffect:
        - run dcutscene_animator_keyframe_edit def:screeneffect|new_time
        #Set cinematic screeneffect color for present modifier
        after player clicks dcutscene_screeneffect_color_modify in dcutscene_inventory_keyframe_modify_screeneffect:
        - run dcutscene_animator_keyframe_edit def:screeneffect|new_color
        #Remove cinematic screeneffect
        after player clicks dcutscene_screeneffect_remove_modify in dcutscene_inventory_keyframe_modify_screeneffect:
        - run dcutscene_animator_keyframe_edit def:screeneffect|remove
        #################################
        ##Next and Previous Buttons ###
        after player clicks dcutscene_next in dcutscene_inventory_keyframe:
        - ~run dcutscene_keyframe_modify def:next
        after player clicks dcutscene_previous in dcutscene_inventory_keyframe:
        - ~run dcutscene_keyframe_modify def:previous
        ###############################
        ##back page functions ##########
        after player clicks dcutscene_back_page in dcutscene_inventory_sub_keyframe:
        - ~run dcutscene_keyframe_modify def:back
        after player clicks dcutscene_back_page in dcutscene_inventory_keyframe:
        - inventory open d:dcutscene_inventory_scene
        after player clicks dcutscene_back_page in dcutscene_inventory_scene:
        - ~run dcutscene_scene_show
        after player clicks dcutscene_back_page in dcutscene_inventory_keyframe_modify_camera:
        - inventory open d:dcutscene_inventory_sub_keyframe
        - ~run dcutscene_sub_keyframe_modify def:<player.flag[dcutscene_sub_keyframe_back_data]>
        after player clicks dcutscene_back_page in dcutscene_inventory_keyframe_modify_player_model:
        - inventory open d:dcutscene_inventory_sub_keyframe
        - ~run dcutscene_sub_keyframe_modify def:<player.flag[dcutscene_sub_keyframe_back_data]>
        after player clicks dcutscene_back_page in dcutscene_inventory_keyframe_modify_run_task:
        - inventory open d:dcutscene_inventory_sub_keyframe
        - ~run dcutscene_sub_keyframe_modify def:<player.flag[dcutscene_sub_keyframe_back_data]>
        after player clicks dcutscene_back_page in dcutscene_inventory_keyframe_modify_sound:
        - inventory open d:dcutscene_inventory_sub_keyframe
        - ~run dcutscene_sub_keyframe_modify def:<player.flag[dcutscene_sub_keyframe_back_data]>
        after player clicks dcutscene_back_page in dcutscene_inventory_keyframe_modify_screeneffect:
        - inventory open d:dcutscene_inventory_sub_keyframe
        - ~run dcutscene_sub_keyframe_modify def:<player.flag[dcutscene_sub_keyframe_back_data]>
        after player clicks dcutscene_back_page in dcutscene_inventory_keyframe_modify:
        - inventory open d:dcutscene_inventory_sub_keyframe
        - ~run dcutscene_sub_keyframe_modify def:<player.flag[dcutscene_sub_keyframe_back_data]>
        ##############################
########################

## GUI Tasks ################
#Show list of cutscenes in a gui
#TODO:
#- Add page system for this
dcutscene_scene_show:
    type: task
    debug: true
    script:
    - inventory open d:dcutscene_inventory_main
    - define inv <player.open_inventory>
    - if <server.has_flag[dcutscenes]>:
      - foreach <server.flag[dcutscenes]> key:id as:cutscene:
        - define item <[cutscene.item]>
        - define name <[cutscene.name]>
        - define name_col <[cutscene.name_color]>
        - define desc <[cutscene.desc]>
        - define world <[cutscene.world]>
        - adjust <[item]> display:<[name_col]><[name]> save:item
        - define item <entry[item].result>
        - flag <[item]> cutscene_data:<[cutscene]>
        - inventory set d:<[inv]> o:<[item]> slot:<[loop_index]>
        - define index <[loop_index]>
      - inventory set d:<[inv]> o:dcutscene_new_scene_item slot:<[index].add[1]>
    - else:
      - inventory set d:<[inv]> o:dcutscene_new_scene_item slot:1

#TODO:
#- If there is only 1 animator show that elements item
#- Add list function to where if there are multiple of the same animators like sound put that into a gui list
#Main keyframes that contain sub-keyframes to modify
dcutscene_keyframe_modify:
    type: task
    debug: false
    definitions: page
    script:
    - define data <player.flag[cutscene_data]>
    - define keyframes <[data.keyframes]>
    #max adjustable slots in inventory
    - define max 45
    #0.45 = 9 ticks because 9 slots for a row
    - if !<player.has_flag[keyframe_modify_index]>:
      - inventory open d:dcutscene_inventory_keyframe
      - flag <player> keyframe_modify_index:1
      - define page_index 1
    - else:
      #determine page
      - define page <[page]||null>
      - if <[page]> == null:
        - inventory open d:dcutscene_inventory_keyframe
        - define page_index 1
        - flag <player> keyframe_modify_index:<[page_index]>
      - else:
        - choose <[page]>:
          #next page button
          - case next:
            - define page_index <player.flag[keyframe_modify_index].add[1]>
            - flag <player> keyframe_modify_index:<[page_index]>
          #previous page button
          - case previous:
            - define page_index <player.flag[keyframe_modify_index].sub[1]>
            - if <[page_index]> < 1:
              - define page_index 1
            - flag <player> keyframe_modify_index:<[page_index]>
          #back page
          - case back:
            - inventory open d:dcutscene_inventory_keyframe
            - define page_index <player.flag[keyframe_modify_index]>
    - define inv <player.open_inventory>
    #time increments
    - define inc <element[0.45]>
    #constant increment
    - define new_inc <[inc].mul[45].mul[<[page_index].sub[1]>]>
    - repeat <[max]> as:loop_i:
        - define lore_list:!
        #### Time calculations ###############
        #page 1 and loop 1
        - if <[loop_i]> == 1 && <[page_index]> == 1:
          - define time <[inc].round_up_to_precision[0.1]>s
          - define timespot <[inc]>
          #format the time should it be greater than 1 minute
          - if <duration[<[time]>].is_more_than_or_equal_to[60s]>:
            - define time <duration[<[time]>].formatted>
          - define display "<blue><bold>Time <gray><bold><[time]>"
        - else:
          #default
          - if <[page_index]> == 1:
            - define inc <[inc].add[0.45]>
            - define timespot <[inc]>
            - define time <duration[<[inc].round_up_to_precision[0.1]>].formatted>
            - if <duration[<[time]>].is_more_than_or_equal_to[60s]>:
              - define time <duration[<[time]>].formatted>
            - define display "<blue><bold>Time <gray><bold><[time]>"
          #calculate new pages
          - else:
            - define inc <[inc].add[0.45]>
            - define timespot <[inc].add[<[new_inc]>]>
            - define time <[inc].add[<[new_inc]>].round_up_to_precision[0.1]>s
            - if <duration[<[time]>].is_more_than_or_equal_to[60s]>:
              - define time <duration[<[time]>].formatted>
            - define display "<blue><bold>Time <gray><bold><[time]>"
        #######################################
        ####Keyframe calculation ##############
        - define keyframe_data <proc[dcutscene_keyframe_calculate].context[<[data.name]>|<[timespot]>]>
        - if <[keyframe_data].equals[null]>:
          - define lore_list null
        - else:
          #Camera
          - define camera <[keyframe_data.camera]||null>
          - if <[camera]> != null:
            - foreach <[camera]> key:tick as:camera:
              - define text "<aqua>Camera on tick <green><[tick]>t <aqua>at location <green><[camera.location].simple>"
              - define lore_list:->:<[text]>
          #Player Model
          - define player_model <[keyframe_data.player_model]||null>
          - if <[player_model]> != null:
            - foreach <[player_model]> key:tick as:p_model:
              - foreach <[p_model].exclude[model_list]> key:p_uuid as:p_data:
                - define text "<aqua>Player Model <green><[p_data.id]> <aqua>on tick <green><[tick]>t"
                - define lore_list:->:<[text]>
          #Run Task
          - define run_task <[keyframe_data.run_task]||null>
          - if <[run_task]> != null:
            - foreach <[run_task]> key:tick as:task_ids:
              - foreach <[task_ids]> as:task_uuid:
                - define task_data <[keyframes.elements.run_task.<[tick]>.<[task_uuid]>]||null>
                - if <[task_data]> != null:
                  - define text "<aqua>Run Task <green><[task_data.script]> <aqua>on tick <green><[tick]>t"
                  - define lore_list:->:<[text]>
          #Screeneffect
          - define screeneffect <[keyframe_data.screeneffect]||null>
          - if <[screeneffect]> != null:
            - foreach <[screeneffect]> key:tick as:screeneffect:
              - define text "<aqua>Cinematic Screeneffect on tick <green><[tick]>t"
              - define lore_list:->:<[text]>
          #Sound
          - define sounds <[keyframe_data.sound]||null>
          - if <[sounds]> != null:
            - foreach <[sounds]> key:tick as:sound_ids:
              - foreach <[sound_ids]> as:sound_uuid:
                - define sound_data <[keyframes.elements.sound.<[tick]>.<[sound_uuid]>]||null>
                - if <[sound_data]> != null:
                  - define text "<aqua>Sound <green><[sound_data.sound]> <aqua>on tick <green><[tick]>t"
                  - define lore_list:->:<[text]>
        #######################################
        ## Setting information on items #######
        - if <[lore_list]> != null:
          - define item <item[dcutscene_keyframe_contains]>
        - else:
          - define item <item[dcutscene_keyframe]>
        - adjust <[item]> display:<[display]> save:item
        - define item <entry[item].result>
        - define click "<gray><italic>Click to modify keyframe"
        - define animators "<blue><bold>Animators:"
        - if <[lore_list]> != null:
          - if <[lore_list].size> == 1:
            - define animators "<blue><bold>Animator:"
          - adjust <[item]> lore:<list[<empty>|<[animators]>|<[lore_list]>|<[click]>].combine> save:item
          - define item <entry[item].result>
        - else:
          - adjust <[item]> lore:<list[<empty>|<[click]>]> save:item
        - define item <entry[item].result>
        - define keyframe.timespot <[timespot]>
        - flag <[item]> keyframe_data:<[keyframe]>
        - inventory set d:<[inv]> o:<[item]> slot:<[loop_i]>
        ########################################

#Determine if the keyframe has variables
dcutscene_keyframe_calculate:
    type: procedure
    debug: false
    definitions: scene_name|timespot
    script:
    - define data <server.flag[dcutscenes]>
    - define keyframes <[data.<[scene_name]>.keyframes]>
    - define tick_max <duration[<[timespot]>s].in_ticks>
    - define tick_min <[tick_max].sub[9]>
    - define tick_map <map>
    - repeat 9 as:loop_i:
      - define tick <[tick_min].add[<[loop_i]>]>
      #Camera Search
      - define cam_search <[keyframes.camera.<[tick]>]||null>
      - if <[cam_search]> != null:
        - define tick_map.camera.<[tick]> <[cam_search]>
      #Player Model search
      - define player_model_search <[keyframes.models.<[tick]>]||null>
      - if <[player_model_search]> != null:
        - define tick_map.player_model.<[tick]> <[player_model_search]>
      #Run Task Search
      - define task_search <[keyframes.elements.run_task.<[tick]>.run_task_list]||null>
      - if <[task_search]> != null:
        - define tick_map.run_task.<[tick]> <[task_search]>
      #Screeneffect Search
      - define screeneffect_search <[keyframes.elements.screeneffect.<[tick]>]||null>
      - if <[screeneffect_search]> != null:
        - define tick_map.screeneffect.<[tick]> <[screeneffect_search]>
      #Sound Search
      - define sound_search <[keyframes.elements.sound.<[tick]>.sounds]||null>
      - if <[sound_search]> != null:
        - define tick_map.sound.<[tick]> <[sound_search]>
    - if !<[tick_map].is_empty>:
      - determine <[tick_map]>
    - else:
      - determine null

#TODO:
# - Ensure elements that contain lists are a single thing and only when clicking it can you view that list such as multiple sounds on the same tick
#Sub keyframe list
dcutscene_sub_keyframe_modify:
    type: task
    debug: false
    definitions: keyframe
    script:
    #Data for returning to previous page
    - flag <player> dcutscene_sub_keyframe_back_data:<[keyframe]>
    - define data <player.flag[cutscene_data]>
    - define keyframes <[data.keyframes]>
    - define camera <[keyframes.camera]||null>
    - define models <[keyframes.models]||null>
    - define elements <[keyframes.elements]||null>
    - define inv <player.open_inventory>
    - define slots <[inv].map_slots>
    #Reset inv
    - repeat 45 as:slot_i:
      - define slot <[slots.<[slot_i]>]||null>
      - if <[slot]> != null:
        - inventory set d:<[inv]> o:air slot:<[slot_i]>
    - define time <[keyframe.timespot]>
    - define tick_max <duration[<[time]>s].in_ticks>
    - define tick_min <[tick_max].sub[9]>
    #Used for scrolling down or up
    - define tick_page <player.flag[sub_keyframe_tick_page]>
    - define tick_page_max <[tick_page].add[4]>
    - repeat 9 as:loop_i:
        #Reset for each tick
        - define tick_index:0
        - define tick_row:0
        - define cam_lore:!
        #Tick
        - define tick <[tick_min].add[<[loop_i]>]>
        #Ticks columns
        - define tick_column 9
        #If column contains animators
        - define tick_column_check none
        #=========== Camera check ============
        - if <[camera]> != null && <[camera].contains[<[tick]>]>:
          - define tick_column_check true
          - define tick_index <[tick_index].add[1]>
          - define tick_row:++
          - if <[tick_row]> > 4:
            - define tick_row:1
          - if <[tick_index]> > <[tick_page]>:
            - define cam_item <item[dcutscene_camera_keyframe]>
            - define cam_data <[camera.<[tick]>]>
            - define cam_loc "<aqua>Location: <gray><location[<[cam_data.location]>].simple>"
            - define cam_eye_loc <[cam_data.eye_loc.boolean]>
            - choose <[cam_eye_loc]>:
              - case true:
                - define cam_look_data <location[<[cam_data.eye_loc.location]>].simple>
              - case false:
                - define cam_look_data false
            - define cam_look "<aqua>Look Location: <gray><[cam_look_data]>"
            - define cam_interp "<aqua>Interpolation: <gray><[cam_data.interpolation].to_uppercase>"
            - define cam_rotate "<aqua>Rotate: <gray><[cam_data.rotate]||false>"
            - define cam_interp_look "<aqua>Interpolate Look: <gray><[cam_data.interpolate_look]||true>"
            - define cam_move "<aqua>Move: <gray><[cam_data.move]||true>"
            - define cam_tick "<aqua>Time: <gray><[cam_data.tick]||<[tick]>>t"
            - define modify "<gray><italic>Click to modify camera"
            - define cam_lore <list[<empty>|<[cam_loc]>|<[cam_look]>|<[cam_interp]>|<[cam_rotate]>|<[cam_interp_look]>|<[cam_move]>|<[cam_tick]>|<empty>|<[modify]>]>
            - adjust <[cam_item]> lore:<[cam_lore]> save:item
            - define cam_item <entry[item].result>
            - define display <dark_gray><bold>Camera
            - adjust <[cam_item]> display:<[display]> save:item
            - define cam_item <entry[item].result>
            #Data to pass through for use of modifying the camera
            - define modify_data.type camera
            - define modify_data.tick <[tick]>
            - define modify_data.data <[cam_data]>
            - flag <[cam_item]> keyframe_opt_modify:<[modify_data]>
            - inventory set d:<[inv]> o:<[cam_item]> slot:<[loop_i].add[<[tick_column].mul[<[tick_row]>]>]>
            - define add_item <item[dcutscene_keyframe_tick_add]>
            - flag <[add_item]> keyframe_modify:<[tick]>
            - inventory set d:<[inv]> o:<[add_item]> slot:<[loop_i].add[<[tick_column].mul[<[tick_index]>]>].add[9]>
          - else:
            - define add_item <item[dcutscene_keyframe_tick_add]>
            - flag <[add_item]> keyframe_modify:<[tick]>
            - inventory set d:<[inv]> o:<[add_item]> slot:<[loop_i].add[<[tick_column]>]>

        #========= Model Animators Check ===========
        - define model_data <[models.<[tick]>]||null>
        - if <[model_data]> != null:
          - define tick_column_check true
          - define model_list <[model_data.model_list]>
          - foreach <[model_list]> as:model_uuid:
            - define tick_index <[tick_index].add[1]>
            - define tick_row:++
            - if <[tick_row]> > 4:
              - define tick_row:1
            - if <[tick_index]> > <[tick_page]>:
              - define data <[model_data.<[model_uuid]>]>
              - define type <[data.type]>
              - choose <[type]>:
                #===== Player Model =====
                - case player_model:
                  - define opt_item <item[dcutscene_keyframe_player_model]>
                  - define pmodel_id "<aqua>ID: <gray><[data.id]>"
                  - define time_lore "<aqua>Time: <gray><[tick]>t"
                  - define modify "<gray><italic>Click to modify player model"
                  - define m_lore <list[<empty>|<[pmodel_id]>|<[time_lore]>|<empty>|<[modify]>]>
                  - adjust <[opt_item]> lore:<[m_lore]> save:item
                  - define opt_item <entry[item].result>
                  #Data to pass through for use of modifying the modifier
                  - define modify_data.type player_model
                  - define modify_data.tick <[tick]>
                  - define modify_data.data <[data]>
                  - define modify_data.uuid <[model_uuid]>
                  - flag <[opt_item]> keyframe_opt_modify:<[modify_data]>
                  #GUI placement calculation for tick row
                  - if <[tick_index]> <= <[tick_page_max]>:
                    - inventory set d:<[inv]> o:<[opt_item]> slot:<[loop_i].add[<[tick_column].mul[<[tick_row]>]>]>
                    - define add_slot <[loop_i].add[<[tick_column].mul[<[tick_row]>]>].add[9]>
                    - if <[add_slot]> < 46:
                      - define add_item <item[dcutscene_keyframe_tick_add]>
                      - flag <[add_item]> keyframe_modify:<[tick]>
                      - inventory set d:<[inv]> o:<[add_item]> slot:<[add_slot]>
            - else:
              - define add_item <item[dcutscene_keyframe_tick_add]>
              - flag <[add_item]> keyframe_modify:<[tick]>
              - inventory set d:<[inv]> o:<[add_item]> slot:<[loop_i].add[<[tick_column]>]>
        #======== Regular Animators check =========

        #========= Run Task =========
        - define run_task <[elements.run_task.<[tick]>]||null>
        - if <[run_task]> != null:
          - define tick_column_check true
          - define opt_item <item[dcutscene_run_task_keyframe]>
          - define run_task_list <[elements.run_task.<[tick]>.run_task_list]>
          - foreach <[run_task_list]> as:task_id:
            - define tick_index <[tick_index].add[1]>
            - define tick_row:++
            - if <[tick_row]> > 4:
              - define tick_row:1
            - if <[tick_index]> > <[tick_page]>:
              - define data <[elements.run_task.<[tick]>.<[task_id]>]>
              - define task_name "<aqua>Script: <gray><[data.script]>"
              - define task_defs "<aqua>Definitions: <gray><[data.defs]>"
              - define task_wait "<aqua>Waitable: <gray><[data.waitable]>"
              - define task_delay "<aqua>Delay: <gray><duration[<[data.delay]>].in_seconds>s"
              - define modify "<gray><italic>Click to modify run task"
              - define task_lore <list[<empty>|<[task_name]>|<[task_defs]>|<[task_wait]>|<[task_delay]>|<empty>|<[modify]>]>
              - adjust <[opt_item]> lore:<[task_lore]> save:item
              - define opt_item <entry[item].result>
              #Data to pass through for use of modifying the modifier
              - define modify_data.type run_task
              - define modify_data.tick <[tick]>
              - define modify_data.data <[data]>
              - define modify_data.uuid <[task_id]>
              - flag <[opt_item]> keyframe_opt_modify:<[modify_data]>
              #GUI placement calculation for tick row
              - if <[tick_index]> <= <[tick_page_max]>:
                - inventory set d:<[inv]> o:<[opt_item]> slot:<[loop_i].add[<[tick_column].mul[<[tick_row]>]>]>
                - define add_slot <[loop_i].add[<[tick_column].mul[<[tick_row]>]>].add[9]>
                - if <[add_slot]> < 46:
                  - define add_item <item[dcutscene_keyframe_tick_add]>
                  - flag <[add_item]> keyframe_modify:<[tick]>
                  - inventory set d:<[inv]> o:<[add_item]> slot:<[add_slot]>
            - else:
              - define add_item <item[dcutscene_keyframe_tick_add]>
              - flag <[add_item]> keyframe_modify:<[tick]>
              - inventory set d:<[inv]> o:<[add_item]> slot:<[loop_i].add[<[tick_column]>]>

        #========== Screeneffect ==========
        - define screeneffect <[elements.screeneffect.<[tick]>]||null>
        - if <[screeneffect]> != null:
          - define tick_column_check true
          - define opt_item <item[dcutscene_screeneffect_keyframe]>
          - define tick_index <[tick_index].add[1]>
          - define tick_row:++
          #Only 4 rows
          - if <[tick_row]> > 4:
            - define tick_row:1
          - if <[tick_index]> > <[tick_page]>:
            - define fade_in "<aqua>Fade in: <gray><[screeneffect.fade_in].in_seconds||0>s"
            - define stay "<aqua>Stay: <gray><[screeneffect.stay].in_seconds||0>s"
            - define fade_out "<aqua>Fade out: <gray><[screeneffect.fade_out].in_seconds||0>s"
            - define color "<aqua>Color: <gray><[screeneffect.color]||black>"
            - define effect_time "<aqua>Time: <gray><[tick]>t"
            - define modify "<gray><italic>Click to modify screeneffect"
            - define effect_lore <list[<empty>|<[fade_in]>|<[stay]>|<[fade_out]>|<[color]>|<[effect_time]>|<empty>|<[modify]>]>
            - adjust <[opt_item]> lore:<[effect_lore]> save:item
            - define opt_item <entry[item].result>
            #Data to pass through for use of modifying the sound modifier
            - define modify_data.type screeneffect
            - define modify_data.tick <[tick]>
            - define modify_data.data <[screeneffect]>
            - flag <[opt_item]> keyframe_opt_modify:<[modify_data]>
            #GUI placement calculation for tick row
            - if <[tick_index]> <= <[tick_page_max]>:
              - inventory set d:<[inv]> o:<[opt_item]> slot:<[loop_i].add[<[tick_column].mul[<[tick_row]>]>]>
              - define add_slot <[loop_i].add[<[tick_column].mul[<[tick_row]>]>].add[9]>
              - if <[add_slot]> < 46:
                - define add_item <item[dcutscene_keyframe_tick_add]>
                - flag <[add_item]> keyframe_modify:<[tick]>
                - inventory set d:<[inv]> o:<[add_item]> slot:<[add_slot]>
          - else:
              - define add_item <item[dcutscene_keyframe_tick_add]>
              - flag <[add_item]> keyframe_modify:<[tick]>
              - inventory set d:<[inv]> o:<[add_item]> slot:<[loop_i].add[<[tick_column]>]>

        #============ Sound =============
        - define sound <[elements.sound.<[tick]>]||null>
        - if <[sound]> != null:
          - define tick_column_check true
          #Option Item
          - define opt_item <item[dcutscene_sound_keyframe]>
          - define sound_list <[elements.sound.<[tick]>.sounds]>
          #Gather data from sound list
          - foreach <[sound_list]> as:sound_id:
            - define tick_index <[tick_index].add[1]>
            - define tick_row:++
            - if <[tick_row]> > 4:
              - define tick_row:1
            - if <[tick_index]> > <[tick_page]>:
              - define data <[elements.sound.<[tick]>.<[sound_id]>]>
              - define sound_name "<aqua>Sound: <gray><[data.sound]>"
              - define sound_loc "<aqua>Location: <gray><[data.location].simple||false>"
              - define sound_vol "<aqua>Volume: <gray><[data.volume]>"
              - define sound_pitch "<aqua>Pitch: <gray><[data.pitch]>"
              - define sound_custom "<aqua>Custom: <gray><[data.custom]>"
              - define sound_time "<aqua>Time: <gray><[tick]>t"
              - define modify "<gray><italic>Click to modify sound"
              - define sound_lore <list[<empty>|<[sound_name]>|<[sound_loc]>|<[sound_vol]>|<[sound_pitch]>|<[sound_custom]>|<[sound_time]>|<empty>|<[modify]>]>
              - adjust <[opt_item]> lore:<[sound_lore]> save:item
              - define opt_item <entry[item].result>
              #Data to pass through for use of modifying the sound modifier
              - define modify_data.type sound
              - define modify_data.tick <[tick]>
              - define modify_data.data <[data]>
              - define modify_data.uuid <[sound_id]>
              - flag <[opt_item]> keyframe_opt_modify:<[modify_data]>
              #GUI placement calculation for tick row
              - if <[tick_index]> <= <[tick_page_max]>:
                - inventory set d:<[inv]> o:<[opt_item]> slot:<[loop_i].add[<[tick_column].mul[<[tick_row]>]>]>
                - define add_slot <[loop_i].add[<[tick_column].mul[<[tick_row]>]>].add[9]>
                - if <[add_slot]> < 46:
                  - define add_item <item[dcutscene_keyframe_tick_add]>
                  - flag <[add_item]> keyframe_modify:<[tick]>
                  - inventory set d:<[inv]> o:<[add_item]> slot:<[add_slot]>
            - else:
              - define add_item <item[dcutscene_keyframe_tick_add]>
              - flag <[add_item]> keyframe_modify:<[tick]>
              - inventory set d:<[inv]> o:<[add_item]> slot:<[loop_i].add[<[tick_column]>]>

        #======= No Animator ========
        - else if <[tick_column_check]> == none:
          - define opt_item <item[dcutscene_keyframe_tick_add]>
          - flag <[opt_item]> keyframe_modify:<[tick]>
          - define tick_index:++
          - inventory set d:<[inv]> o:<[opt_item]> slot:<[loop_i].add[<[tick_column].mul[<[tick_index]>]>]>
        #If a tick contains 4 or more animators add the up and down buttons
        - if <[tick_index]> >= 4:
          - inventory set d:<[inv]> o:<item[dcutscene_scroll_down]> slot:51
          - inventory set d:<[inv]> o:<item[dcutscene_scroll_up]> slot:49
        #Tick info item
        - define item <item[dcutscene_sub_keyframe]>
        - define display "<aqua><bold>Tick <gray><bold><[tick]>t"
        - adjust <[item]> display:<[display]> save:item
        - define item <entry[item].result>
        - define t_lore "<blue><bold>Main Keyframe Time <gray><bold><duration[<[time]>].formatted>"
        - define s_lore "<green><bold>Tick to seconds <gray><bold><duration[<[tick]>t].in_seconds.round_down_to_precision[0.05]>s"
        - adjust <[item]> lore:<list[<[t_lore]>|<[s_lore]>]> save:item
        - define item <entry[item].result>
        - inventory set d:<[inv]> o:<[item]> slot:<[loop_i]>
#############################

##Cutscene Inventories (In case your wondering why so many inventories it's just easier to manage)###################
#Main dcutscene gui
dcutscene_inventory_main:
    type: inventory
    inventory: CHEST
    title: <&color[<script[dcutscenes_config].data_key[config].get[cutscene_title_color]>]><script[dcutscenes_config].data_key[config].get[cutscene_title]>
    size: 54
    gui: true
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] [dcutscene_exit]

#TODO:
#- Add ability to use cutscene on multiple worlds this allows for the same world but different name
#Gui for cutscene scene where you can modify settings and keyframes of the scene
dcutscene_inventory_scene:
    type: inventory
    inventory: CHEST
    title: <&color[<script[dcutscenes_config].data_key[config].get[cutscene_title_color]>]><script[dcutscenes_config].data_key[config].get[cutscene_title]>
    size: 54
    gui: true
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [dcutscene_keyframes_list] [] [] [] [dcutscene_settings] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [dcutscene_back_page] [] [] [] [dcutscene_play_cutscene_item] [] [dcutscene_save_file_item] [] [dcutscene_exit]

#Scene keyframes
dcutscene_inventory_keyframe:
    type: inventory
    inventory: CHEST
    title: <&color[<script[dcutscenes_config].data_key[config].get[cutscene_title_color]>]><script[dcutscenes_config].data_key[config].get[cutscene_title]>
    size: 54
    gui: true
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [dcutscene_back_page] [] [] [dcutscene_previous] [] [dcutscene_next] [] [] [dcutscene_exit]

#Sub keyframe inventory
dcutscene_inventory_sub_keyframe:
    type: inventory
    inventory: CHEST
    title: <&color[<script[dcutscenes_config].data_key[config].get[cutscene_title_color]>]><script[dcutscenes_config].data_key[config].get[cutscene_title]>
    size: 54
    gui: true
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [dcutscene_back_page] [] [] [] [] [] [] [] [dcutscene_exit]

#Modify gui for a sub-keyframe tick
dcutscene_inventory_keyframe_modify:
    type: inventory
    inventory: CHEST
    title: <&color[<script[dcutscenes_config].data_key[config].get[cutscene_title_color]>]><script[dcutscenes_config].data_key[config].get[cutscene_title]>
    size: 54
    gui: true
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [dcutscene_add_cam] [dcutscene_add_sound] [dcutscene_add_entity] [dcutscene_add_model] [dcutscene_add_player_model] [] []
    - [] [] [dcutscene_add_run_task] [dcutscene_add_fake_structure] [dcutscene_add_screeneffect] [dcutscene_add_particle] [dcutscene_send_title] [] []
    - [] [] [dcutscene_play_command] [dcutscene_add_msg] [dcutscene_send_time] [dcutscene_set_weather] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [dcutscene_back_page] [] [] [] [] [] [] [] [dcutscene_exit]

#Camera GUI
dcutscene_inventory_keyframe_modify_camera:
    type: inventory
    inventory: CHEST
    title: <&color[<script[dcutscenes_config].data_key[config].get[cutscene_title_color]>]><script[dcutscenes_config].data_key[config].get[cutscene_title]>
    size: 54
    gui: true
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [dcutscene_camera_loc_modify] [dcutscene_camera_look_modify] [dcutscene_camera_move_modify] [] [] []
    - [] [] [] [dcutscene_camera_rotate_modify] [dcutscene_camera_interpolate_look] [dcutscene_camera_upside_down] [] [] []
    - [] [] [] [dcutscene_camera_teleport] [dcutscene_camera_interp_modify] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [dcutscene_back_page] [] [dcutscene_camera_path_show] [] [dcutscene_camera_remove_modify] [] [] [] [dcutscene_exit]

#Location Tool Modify GUI
dcutscene_inventory_location_tool:
    type: inventory
    inventory: CHEST
    title: <&color[<script[dcutscenes_config].data_key[config].get[cutscene_title_color]>]><script[dcutscenes_config].data_key[config].get[cutscene_title]>
    size: 54
    gui: true
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [dcutscene_location_tool_item] [] [dcutscene_location_tool_ray_trace_item] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] [dcutscene_exit]

#Model List (If there are previously created models this GUI will appear)
dcutscene_inventory_keyframe_model_list:
    type: inventory
    inventory: CHEST
    title: <&color[<script[dcutscenes_config].data_key[config].get[cutscene_title_color]>]><script[dcutscenes_config].data_key[config].get[cutscene_title]>
    size: 54
    gui: true
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [dcutscene_back_page] [] [dcutscene_previous] [] [dcutscene_add_new_model] [] [dcutscene_next] [] [dcutscene_exit]

#Player Model modifier GUI
dcutscene_inventory_keyframe_modify_player_model:
    type: inventory
    inventory: CHEST
    title: <&color[<script[dcutscenes_config].data_key[config].get[cutscene_title_color]>]><script[dcutscenes_config].data_key[config].get[cutscene_title]>
    size: 54
    gui: true
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [dcutscene_player_model_change_id] [dcutscene_player_model_change_location] [dcutscene_player_model_ray_trace_floor] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [dcutscene_back_page] [] [] [] [dcutscene_remove_player_model] [] [] [] [dcutscene_exit]

#Run Task GUI
dcutscene_inventory_keyframe_modify_run_task:
    type: inventory
    inventory: CHEST
    title: <&color[<script[dcutscenes_config].data_key[config].get[cutscene_title_color]>]><script[dcutscenes_config].data_key[config].get[cutscene_title]>
    size: 54
    gui: true
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [dcutscene_run_task_change_modify] [dcutscene_run_task_def_modify] [dcutscene_run_task_wait_modify] [] [] []
    - [] [] [] [dcutscene_run_task_delay_modify] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [dcutscene_back_page] [] [] [] [dcutscene_run_task_remove_modify] [] [] [] [dcutscene_exit]

#Sound GUI
dcutscene_inventory_keyframe_modify_sound:
    type: inventory
    inventory: CHEST
    title: <&color[<script[dcutscenes_config].data_key[config].get[cutscene_title_color]>]><script[dcutscenes_config].data_key[config].get[cutscene_title]>
    size: 54
    gui: true
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [dcutscene_sound_modify] [dcutscene_sound_volume_modify] [dcutscene_sound_pitch_modify] [] [] []
    - [] [] [] [dcutscene_sound_loc_modify] [dcutscene_sound_custom_modify] [dcutscene_sound_stop_modify] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [dcutscene_back_page] [] [] [] [dcutscene_sound_remove_modify] [] [] [] [dcutscene_exit]

#Screeneffect GUI
dcutscene_inventory_keyframe_modify_screeneffect:
    type: inventory
    inventory: CHEST
    title: <&color[<script[dcutscenes_config].data_key[config].get[cutscene_title_color]>]><script[dcutscenes_config].data_key[config].get[cutscene_title]>
    size: 54
    gui: true
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [dcutscene_screeneffect_time_modify] [] [dcutscene_screeneffect_color_modify] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [dcutscene_back_page] [] [] [] [dcutscene_screeneffect_remove_modify] [] [] [] [dcutscene_exit]
####################################################
