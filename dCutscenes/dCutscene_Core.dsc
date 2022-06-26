#Denizen Cutscenes Core
#This is required for DCutscenes to function.

##Contents:
#Events
#Tab Completion Procedures
#Data Operations
#GUI Tasks
#Keyframe Modify Tasks
#Animator Tasks
#GUI Script Containers

##Cutscene Events#######
dcutscene_events:
    type: world
    #TODO: Set this to false
    debug: true
    events:
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
        after player right clicks block flagged:cutscene_modify:
        - choose <player.flag[cutscene_modify]>:
          - case sound_location:
            - run dcutscene_animator_keyframe_edit def:sound|set_location|<context.location>
        ##Tab completion ############
        after tab complete flagged:cutscene_modify:
        - choose <context.current_arg>:
          - case sound:
            - flag <player> cutscene_modify_tab:sound
        #input for dcutscene gui elements
        ##Chat Input ################
        on player chats flagged:cutscene_modify:
        - define msg <context.message>
        - if <[msg]> == cancel:
          - flag <player> cutscene_modify:!
          - determine passively cancelled
          - stop
        - choose <player.flag[cutscene_modify]>:
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
          #Input new sound location based on player location
          - case sound_location:
            - if <[msg]> == confirm:
              - run dcutscene_animator_keyframe_edit def:sound|set_location|<player.location>
            - else if <[msg]> == false:
              - run dcutscene_animator_keyframe_edit def:sound|set_location|false
            - else:
              - run dcutscene_animator_keyframe_edit def:sound|set_location|<[msg]>
          #Create new screeneffect modifier
          - case screeneffect:
            - run dcutscene_animator_keyframe_edit def:screeneffect|create|<[msg]>
          #Set new time
          - case screeneffect_time:
            - run dcutscene_animator_keyframe_edit def:screeneffect|set_time|<[msg]>
          #Set new color
          - case screeneffect_color:
            - run dcutscene_animator_keyframe_edit def:screeneffect|set_color|<[msg]>
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

##Core Tasks#######################################

## Tab Completion Procedures ########
#Tab completion for arguments that can be utilized
dcutscene_command_list:
    type: procedure
    debug: false
    script:
    - define list <list[load|save|open]>
    - determine <[list]>

#Tab completion for list of cutscenes
dcutscene_data_list:
    type: procedure
    debug: false
    definitions: player
    script:
    - if <[player].has_flag[cutscene_modify]>:
      - if <[player].has_flag[cutscene_modify_tab]>:
        - choose <[player].flag[cutscene_modify_tab]>:
          - case sound:
            - determine <server.sound_types>
            - stop
    - if <server.has_flag[dcutscenes]>:
      - foreach <server.flag[dcutscenes]> key:c_id as:cutscene:
        - define list:->:<[c_id]>
      - determine <[list]>
############################

## Data Operations #########
#Saving cutscenes to a directory
dcutscene_save_file:
    type: task
    debug: false
    definitions: cutscene
    script:
    - define cutscene <[cutscene]||null>
    - define data <server.flag[dcutscenes]>
    - if <[cutscene]> == null:
      - foreach <[data]> key:c_id as:cutscene:
        - ~filewrite path:data/dcutscenes/scenes/<[c_id]>.dcutscene.json data:<[cutscene].to_json[native_types=true;indent=4].utf8_encode>
    - else:
      - define cutscene_data <server.flag[dcutscenes.<[cutscene.name]>]||null>
      - if !<[cutscene_data].equals[null]>:
        - define c_id <[cutscene_data.name]>
        - ~filewrite path:data/dcutscenes/scenes/<[c_id]>.dcutscene.json data:<[cutscene].to_json[native_types=true;indent=4].utf8_encode>
      - else:
        - debug error "DCutscenes Invalid cutscene did you type the name correctly?"

#Loading cutscene files in a directory
dcutscene_load_files:
    type: task
    debug: false
    script:
    - define files <server.list_files[data/dcutscenes/scenes]||null>
    - if <[files]> != null:
      - foreach <[files]> as:file:
        - define check <[file].split[.]>
        - if <[check].contains[dcutscene]>:
          - ~yaml id:file_<[file]> load:data/dcutscenes/scenes/<[file]>
          - define name <yaml[file_<[file]>].read[name]||null>
          - if <[name]> == null:
            - debug error "<[file]> is an invalid dcutscene file"
            - foreach next
          - define cutscene.name <[name]>
          - define cutscene.name_color <yaml[file_<[file]>].read[name_color]||<empty>>
          - define cutscene.description <yaml[file_<[file]>].read[description]||<empty>>
          - define cutscene.world <yaml[file_<[file]>].read[world]||<empty>>
          - define cutscene.item <yaml[file_<[file]>].read[item]||<empty>>
          - define cutscene.length <yaml[file_<[file]>].read[length]||<empty>>
          - define cutscene.keyframes <yaml[file_<[file]>].read[keyframes]||<empty>>
          - flag server dcutscenes.<[name]>:<[cutscene]>
          - ~run dcutscene_sort_data def:<[cutscene.name]>
        - else:
          - debug error "<[file]> is not a dcutscene file in Denizen/data/dcutscenes/scenes"

#Sort the keyframes
dcutscene_sort_data:
    type: task
    debug: false
    definitions: cutscene
    script:
    - define cutscene <[cutscene]||null>
    - if <[cutscene]> != null:
      - define data <server.flag[dcutscenes.<[cutscene]>]||null>
      - if <[data]> == null:
        - debug error "Invalid cutscene <[cutscene]> in dcutscene_sort_data."
        - stop
      - define name <[data.name]>
      - define keyframes <[data.keyframes]>
      #Camera
      - define camera <[keyframes.camera].sort_by_value[get[tick]]||null>
      - if <[camera]> != null:
        - define keyframes.camera <[camera]>
      #Screeneffect
      - define screeneffect <[keyframes.screeneffect].sort_by_value[get[tick]]||null>
      - if <[screeneffect]> != null:
        - define keyframes.screeneffect <[screeneffect]>
      #Sound
      - define sound <[keyframes.sound].sort_by_value[get[tick]]||null>
      - if <[sound]> != null:
        - define keyframes.sound <[sound]>
      - define ticks <proc[dcutscene_animation_length].context[<[cutscene]>]>
      #Total cutscene length
      - if !<[ticks].is_empty>:
        - define animation_length <duration[<[ticks].highest>t].in_seconds>s
        - define data.length <[animation_length]>
        - flag server dcutscenes.<[name]>.length:<[data.length]>
      - flag server dcutscenes.<[name]>.keyframes:<[keyframes]>
    - else:
      - if <server.has_flag[dcutscenes]>:
        - foreach <server.flag[dcutscenes]> key:c_id as:cutscene:
          - define ticks:!
          - define keyframes <[cutscene.keyframes]>
          #Camera
          - define camera <[keyframes.camera].sort_by_value[get[tick]]||null>
          - if <[camera]> != null:
            - define keyframes.camera <[camera]>
          #Screeneffect
          - define screeneffect <[keyframes.screeneffect].sort_by_value[get[tick]]||null>
          - if <[screeneffect]> != null:
            - define keyframes.screeneffect <[screeneffect]>
          #Sound
          - define sound <[keyframes.sound].sort_by_value[get[tick]]||null>
          - if <[sound]> != null:
            - define keyframes.sound <[sound]>
          - define ticks <proc[dcutscene_animation_length].context[<[c_id]>]>
          #Total cutscene length
          - if !<[ticks].is_empty>:
            - define animation_length <duration[<[ticks].highest>t].in_seconds>s
            - define data.length <[animation_length]>
            - flag server dcutscenes.<[c_id]>.length:<[data.length]>
          - flag server dcutscenes.<[c_id]>.keyframes:<[keyframes]>
      - else:
        - debug error "DCutscenes There are no cutscenes to sort!"

#Returns total animation length of cutscene
dcutscene_animation_length:
    type: procedure
    debug: false
    definitions: cutscene
    script:
    - define data <server.flag[dcutscenes.<[cutscene]>]>
    - define keyframes <[data.keyframes]>
    #Camera
    - define ticks <list>
    - define cam_keyframes <[keyframes.camera]||null>
    - if <[cam_keyframes]> != null:
      - define highest <[cam_keyframes].keys.highest>
      - define ticks:->:<[highest]>
    #Screeneffect
    - define effect_keyframes <[keyframes.screeneffect]||null>
    - if <[effect_keyframes]> != null:
      - define highest <[effect_keyframes].keys.highest>
      - define ticks:->:<[highest]>
    #Sound
    - define sound_keyframes <[keyframes.sound]||null>
    - if <[sound_keyframes]> != null:
      - define highest <[cam_keyframes].keys.highest>
      - define ticks:->:<[highest]>
    - determine <[ticks]>

#Removes any corrupt data
dcutscene_validate_data:
    type: task
    debug: false
    definitions: cutscene
    script:
    - define data lol

#############################

## GUI Tasks ################
#Show list of cutscenes in a gui
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

#Create a new cutscene
dcutscene_new_scene:
    type: task
    debug: true
    definitions: type|arg
    script:
    - define type <[type]||null>
    #new cutscene name
    - if <[type]> == null:
        - flag <player> cutscene_modify:new_name expire:60s
        - define text "Chat the name of the new cutscene. Chat <red>cancel <gray>to stop."
        - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
    - else:
        - define arg <[arg]||null>
        - if <[arg].equals[null]>:
          - stop
        - define search <server.flag[dcutscenes.<[arg]>]||null>
        - if !<[search].equals[null]>:
          - define text "A cutscene with the name <underline><[arg]> <gray>already exists!"
          - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
          - stop
        - flag <player> cutscene_modify:!
        #default data
        - define cutscene.name <[arg]>
        - define cutscene.name_color <blue><bold>
        - define cutscene.description <empty>
        - define cutscene.world <list[<player.world.name>]>
        - define cutscene.item <item[dcutscene_scene_item_default]>
        - define cutscene.length 0
        - define cutscene.keyframes <empty>
        - flag server dcutscenes.<[arg]>:<[cutscene]>
        - inventory open d:dcutscene_inventory_main
        - run dcutscene_scene_show
        - define text "New cutscene <underline><[arg]> <gray>has been created."
        - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"

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
        ##camera check ############
        - if <[camera]> != null && <[camera].contains[<[tick]>]>:
          - define tick_index <[tick_index].add[1]>
          - define tick_row:++
          - if <[tick_row]> > 4:
            - define tick_row:1
          - if <[tick_index]> > <[tick_page]>:
            - define cam_item <item[dcutscene_camera_keyframe]>
            - define cam_data <[camera.<[tick]>]>
            - define cam_loc "<aqua>Location: <gray><location[<[cam_data.location]>].simple>"
            - define cam_look "<aqua>Look Location: <gray><location[<[cam_data.eye_loc]>].simple>"
            - define cam_interp "<aqua>Interpolation: <gray><[cam_data.interpolation].to_uppercase>"
            - define cam_rotate "<aqua>Rotate: <gray><[cam_data.rotate]||false>"
            - define cam_move "<aqua>Move: <gray><[cam_data.move]||true>"
            - define cam_tick "<aqua>Time: <gray><[cam_data.tick]||<[tick]>>t"
            - define modify "<gray><italic>Click to modify camera"
            - define cam_lore <list[<empty>|<[cam_loc]>|<[cam_look]>|<[cam_interp]>|<[cam_rotate]>|<[cam_move]>|<[cam_tick]>|<empty>|<[modify]>]>
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
        ##Animators check ##########
        ##Screeneffect
        - define screeneffect <[elements.screeneffect.<[tick]>]||null>
        - if <[screeneffect]> != null:
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
        ##sound
        - define sound <[elements.sound.<[tick]>]||null>
        - if <[sound]> != null:
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
        ########
        ##default #####################
        - else:
          - define opt_item <item[dcutscene_keyframe_tick_add]>
          - flag <[opt_item]> keyframe_modify:<[tick]>
          - define tick_index:++
          - inventory set d:<[inv]> o:<[opt_item]> slot:<[loop_i].add[<[tick_column].mul[<[tick_index]>]>]>
        #If a tick contains 4 or more elements add the up and down buttons
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

##Keyframe Modifiers ##############################

##Camera ################

#The Camera
dcutscene_camera_entity:
    type: entity
    debug: false
    entity_type: armor_stand
    mechanisms:
        marker: false
        visible: true
        is_small: false
        invulnerable: true
        gravity: false

#Camera Modifier
dcutscene_cam_keyframe_edit:
    type: task
    debug: false
    definitions: option|arg|arg_2|arg_3
    script:
    - define option <[option]||null>
    - define arg <[arg]||null>
    - if <[option].equals[null]>:
      - debug error "Something went wrong in dcutscene_cam_keyframe_edit could not determine option."
    - else:
      - choose <[option]>:
        #prepare to create new keyframe modifier
        - case new:
          - flag <player> cutscene_modify:create_cam expire:120s
          - spawn dcutscene_camera_entity <player.location> save:camera
          - define camera <entry[camera].spawned_entity>
          - flag <player> dcutscene_camera:<[camera]>
          - fakeequip <[camera]> head:<item[dcutscene_camera_item]>
          - define text "Go to the location you'd like this camera to be at and chat <green>confirm<gray>."
          - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
          - adjust <player> gamemode:spectator
          - inventory close
        #create the camera keyframe modifier
        - case create:
          - flag <player> cutscene_modify:!
          - adjust <player> gamemode:creative
          - define camera <player.flag[dcutscene_camera]>
          - teleport <[camera]> <player.location>
          - define ray <player.eye_location.ray_trace[range=4;return=precise;default=air]>
          #data input
          - define tick <player.flag[dcutscene_tick_modify]>
          - define cam_keyframe.eye_loc <[ray]>
          - define cam_keyframe.location <player.location>
          - define cam_keyframe.rotate false
          - define cam_keyframe.interpolation linear
          - define cam_keyframe.move true
          #Reason we're storing the tick is so the sort task has something to sort the map with
          - define data <player.flag[cutscene_data]>
          - define name <[data.name]>
          - define cam_keyframe.tick <[tick]>
          - look <[camera]> <[ray]> duration:2t
          - adjust <[camera]> armor_pose:[head=<player.location.pitch.to_radians>,0.0,0.0]
          - define text "Camera location set to <green><player.location.simple> <gray>and look point <green><[ray].simple><gray> <gray>for keyframe tick <green><[tick]>t <gray>for scene <green><[name]><gray>."
          - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
          - define data.keyframes.camera.<[tick]>:<[cam_keyframe]>
          - flag server dcutscenes.<[name]>:<[data]>
          #Sort the newly created data
          - ~run dcutscene_sort_data def:<[name]>
          #Update the player's cutscene data
          - flag <player> cutscene_data:<server.flag[dcutscenes.<[name]>]>
          - ~run dcutscene_sub_keyframe_modify def:<player.flag[dcutscene_sub_keyframe_back_data]>
        #teleport to camera location
        - case teleport:
          - define tick <player.flag[dcutscene_tick_modify]>
          - define cam_loc <location[<player.flag[cutscene_data.keyframes.camera.<[tick]>.location]>]||null>
          - if <[cam_loc].equals[null]>:
            - debug error "Could not find location for camera in dcutscene_cam_keyframe_edit"
          - else:
            - teleport <player> <[cam_loc]>
            - define text "You have teleported to <green><[cam_loc].simple> <gray>at tick <green><[tick]>t<gray>."
            - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
            - inventory open d:dcutscene_inventory_keyframe_modify_camera
        #edit the camera keyframe modifier
        - case edit:
          - if <[arg]> != null:
            - define inv <player.open_inventory>
            - define data <[arg]>
            - define modify_loc <item[dcutscene_camera_loc_modify]>
            - choose <[arg]>:
              #preparation for new location in present camera keyframe
              - case new_location:
                - flag <player> cutscene_modify:create_present_cam expire:120s
                - spawn dcutscene_camera_entity <player.location> save:camera
                - define camera <entry[camera].spawned_entity>
                - flag <player> dcutscene_camera:<[camera]>
                - fakeequip <[camera]> head:<item[dcutscene_camera_item]>
                - define text "Go to the location you'd like this camera to be at and chat <green>confirm<gray>."
                - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
                - adjust <player> gamemode:spectator
                - inventory close
              #Create the new location in a present camera keyframe
              - case create_new_location:
                - flag <player> cutscene_modify:!
                - adjust <player> gamemode:creative
                - define camera <player.flag[dcutscene_camera]>
                - teleport <[camera]> <player.location>
                - define ray <player.eye_location.ray_trace[range=4;return=precise;default=air]>
                - look <[camera]> <[ray]> duration:2t
                - adjust <[camera]> armor_pose:[head=<player.location.pitch.to_radians>,0.0,0.0]
                #data input
                - define tick <player.flag[dcutscene_tick_modify]>
                - define cam_keyframe <player.flag[cutscene_data.keyframes.camera.<[tick]>]>
                - define cam_keyframe.rotate <[cam_keyframe.rotate]||false>
                - if <[cam_keyframe.rotate].equals[false]>:
                  - define cam_keyframe.eye_loc <[ray]>
                - define cam_keyframe.eye_loc <[cam_keyframe.eye_loc]||<[ray]>>
                - define cam_keyframe.location <player.location>
                - define cam_keyframe.tick <[tick]>
                #fallback should they not exist
                - define cam_keyframe.interpolation <[cam_keyframe.interpolation]||linear>
                - define cam_keyframe.move <[cam_keyframe.move]||true>
                #final data input
                - define data <player.flag[cutscene_data]>
                - define name <[data.name]>
                - define data.keyframes.camera.<[tick]>:<[cam_keyframe]>
                - flag server dcutscenes.<[name]>:<[data]>
                - define text "Camera location set to <green><player.location.simple> <gray>and look point <green><[ray].simple><gray> <gray>for keyframe tick <green><[tick]>t <gray>in scene <green><[name]><gray>."
                - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
                #Update the player's cutscene data
                - flag <player> cutscene_data:<server.flag[dcutscenes.<[name]>]>
                - ~run dcutscene_sub_keyframe_modify def:<player.flag[dcutscene_sub_keyframe_back_data]>
              #Change interpolation method
              - case interpolation_change:
                - define arg_2 <[arg_2]||null>
                - define arg_3 <[arg_3]||null>
                - if <[arg_2]> != null:
                  - define item <item[<[arg_2]>]>
                  - define tick <player.flag[dcutscene_tick_modify]>
                  - define data <player.flag[cutscene_data]>
                  - define keyframes <[data.keyframes]>
                  - define cam_keyframe <[keyframes.camera.<[tick]>]>
                  - define interp_method <[cam_keyframe.interpolation]>
                  - choose <[interp_method]>:
                    - case linear:
                      - define new_interp_method smooth
                    - case smooth:
                      - define new_interp_method linear
                  - define cam_keyframe.interpolation <[new_interp_method]>
                  - flag server dcutscenes.<[data.name]>.keyframes.camera.<[tick]>:<[cam_keyframe]>
                  - flag <player> cutscene_data:<server.flag[dcutscenes.<[data.name]>]>
                  - define interp_msg "<green><bold>Interpolation: <gray><[new_interp_method].to_uppercase>"
                  - define click "<gray><italic>Click to modify interpolation method"
                  - define lore <list[<empty>|<[interp_msg]>|<empty>|<[click]>]>
                  - inventory adjust d:<player.open_inventory> slot:<[arg_3]> lore:<[lore]>
                - else:
                  - debug error "Could not determine item to change for interpolation in dcutscene_cam_keyframe_edit!"
              #Change if the camera will move to the next point
              - case move_change:
                - define arg_2 <[arg_2]||null>
                - define arg_3 <[arg_3]||null>
                - if <[arg_2]> != null:
                  - define item <item[<[arg_2]>]>
                  - define tick <player.flag[dcutscene_tick_modify]>
                  - define data <player.flag[cutscene_data]>
                  - define keyframes <[data.keyframes]>
                  - define cam_keyframe <[keyframes.camera.<[tick]>]>
                  - define move <[cam_keyframe.move]>
                  - choose <[move]>:
                    - case true:
                      - define new_move false
                    - case false:
                      - define new_move true
                  - define cam_keyframe.move <[new_move]>
                  - flag server dcutscenes.<[data.name]>.keyframes.camera.<[tick]>:<[cam_keyframe]>
                  - flag <player> cutscene_data:<server.flag[dcutscenes.<[data.name]>]>
                  - define info_msg "<gray>Determine if the camera will move to the next keyframe point"
                  - define interp_msg "<green><bold>Move: <gray><[new_move]>"
                  - define click "<gray><italic>Click to modify movement for camera"
                  - define lore <list[<empty>|<[info_msg]>|<empty>|<[interp_msg]>|<empty>|<[click]>]>
                  - inventory adjust d:<player.open_inventory> slot:<[arg_3]> lore:<[lore]>
                - else:
                  - debug error "Could not determine item to change for move change in dcutscene_cam_keyframe_edit!"
              #Remove camera from keyframe
              - case remove_camera:
                - define tick <player.flag[dcutscene_tick_modify]>
                - define cam_keyframe <player.flag[cutscene_data.keyframes.camera].deep_exclude[<[tick]>]>
                - define data <player.flag[cutscene_data]>
                - define data.keyframes.camera:<[cam_keyframe]>
                - define name <[data.name]>
                - flag server dcutscenes.<[name]>:<[data]>
                - flag <player> cutscene_data:<server.flag[dcutscenes.<[name]>]>
                - ~run dcutscene_sub_keyframe_modify def:<player.flag[dcutscene_sub_keyframe_back_data]>
          - else:
            - debug error "Could not determine argument for edit option in dcutscene_cam_keyframe_edit"
############################

##Regular Animators #################
#List of animators (Type List means there can be multiple of the same animator in 1 tick Type Once means there can only be 1 per tick)
#- Sound TYPE: List
#- Particle TYPE: List
#- Title TYPE: Once
#- Cinematic Screeneffect TYPE: Once
#- Fake block or schematic TYPE: List
#- Send command to player or console TYPE: List
#- Run a custom task TYPE: List
#- Set the time for the player TYPE: Once

#Modify regular animators in cutscenes (Regular animators are things that play only once and do not use the path system such as the camera)
dcutscene_animator_keyframe_edit:
    type: task
    debug: false
    definitions: option|arg|arg_2|arg_3
    script:
    - define option <[option]||null>
    - define arg <[arg]||null>
    - if <[option].equals[null]> && <[arg].equals[null]>:
      - debug error "Something went wrong in dcutscene_element_edit could not determine option"
    - else:
      - define data <player.flag[cutscene_data]>
      - define keyframes <[data.keyframes.elements]>
      - define scene_name <[data.name]>
      - choose <[option]>:
        ## Cinematic Screeneffect Modifier #####
        - case screeneffect:
          - choose <[arg]>:
            #Prepare for new screeneffect
            - case new:
              - flag <player> cutscene_modify:screeneffect expire:2m
              - define text "Chat the screeneffect fade in, stay, and fade out like this <green>1s,5s,2s<gray>."
              - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
              - inventory close
            #Create new screeneffect
            - case create:
              - define arg_2 <[arg_2]||null>
              - if <[arg_2]> != null:
                - define split <[arg_2].split[,]>
                - define fade_in <duration[<[split].get[1]>]||null>
                - define stay <duration[<[split].get[2]>]||null>
                - define fade_out <duration[<[split].get[3]>]||null>
                - if <[fade_in]> != null && <[stay]> != null && <[fade_out]> != null:
                  - flag <player> cutscene_modify:!
                  - define tick <player.flag[dcutscene_tick_modify]>
                  - define data <player.flag[cutscene_data]>
                  - define keyframes.screeneffect.<[tick]>
                  - define keyframes.screeneffect.<[tick]>.fade_in <[fade_in]>
                  - define keyframes.screeneffect.<[tick]>.stay <[stay]>
                  - define keyframes.screeneffect.<[tick]>.fade_out <[fade_out]>
                  - define keyframes.screeneffect.<[tick]>.color black
                  - flag server dcutscenes.<[data.name]>.keyframes.elements:<[keyframes]>
                  - flag <player> cutscene_data:<server.flag[dcutscenes.<[data.name]>]>
                  - ~run dcutscene_sort_data def:<[data.name]>
                  - inventory open d:dcutscene_inventory_sub_keyframe
                  - ~run dcutscene_sub_keyframe_modify def:<player.flag[dcutscene_sub_keyframe_back_data]>
                  - define text "Cinematic Screeneffect created at tick <green><[tick]>t <gray>in scene <green><[data.name]><gray>."
                  - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
                - else:
                  - define text "Invalid input to specify fade in, stay, and fade out chat it like this <green>1s,5s,1s<gray>."
                  - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
            #Prepare for presently new screeneffect time
            - case new_time:
              - flag <player> cutscene_modify:screeneffect_time expire:2m
              - define text "Chat the screeneffect fade in, stay, and fade out like this <green>1s,5s,2s<gray>."
              - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
              - inventory close
            #Set the new time
            - case set_time:
              - define arg_2 <[arg_2]||null>
              - if <[arg_2]> != null:
                - define split <[arg_2].split[,]>
                - define fade_in <duration[<[split].get[1]>]||null>
                - define stay <duration[<[split].get[2]>]||null>
                - define fade_out <duration[<[split].get[3]>]||null>
                - if <[fade_in]> != null && <[stay]> != null && <[fade_out]> != null:
                  - flag <player> cutscene_modify:!
                  - define tick <player.flag[dcutscene_tick_modify.tick]>
                  - define data <player.flag[cutscene_data]>
                  - define keyframe <[data.keyframes.elements.screeneffect.<[tick]>]>
                  - define keyframe.fade_in <[fade_in]>
                  - define keyframe.stay <[stay]>
                  - define keyframe.fade_out <[fade_out]>
                  - flag server dcutscenes.<[data.name]>.keyframes.elements.screeneffect.<[tick]>:<[keyframe]>
                  - flag <player> cutscene_data:<server.flag[dcutscenes.<[data.name]>]>
                  - ~run dcutscene_sort_data def:<[data.name]>
                  - define text "New cinematic screeneffect time created at tick <green><[tick]>t <gray>in scene <green><[data.name]><gray>."
                  - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
                  - inventory open d:dcutscene_inventory_keyframe_modify_screeneffect
                - else:
                  - define text "Invalid input to specify fade in, stay, and fade out chat it like this <green>1s,5s,1s<gray>."
                  - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
            #Prepare for present screeneffect new color
            - case new_color:
              - flag <player> cutscene_modify:screeneffect_color expire:1.5m
              - define text "Chat the color for the screeneffect you may also specify rgb as well Example: <green>blue <gray>or <green>150,39,255<gray>."
              - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
              - inventory close
            #Set new screeneffect color
            - case set_color:
              - define arg_2 <[arg_2]||null>
              - if <[arg_2]> != null:
                - define color <&color[<[arg_2]>]||null>
                - if <[color]> != null:
                  - define tick <player.flag[dcutscene_tick_modify.tick]>
                  - define data <player.flag[cutscene_data]>
                  - define keyframe <[data.keyframes.elements.screeneffect.<[tick]>]>
                  - define keyframe.color <[arg_2]>
                  - flag server dcutscenes.<[data.name]>.keyframes.elements.screeneffect.<[tick]>:<[keyframe]>
                  - flag <player> cutscene_data:<server.flag[dcutscenes.<[data.name]>]>
                  - ~run dcutscene_sort_data def:<[data.name]>
                  - define text "New cinematic screeneffect color created at tick <green><[tick]>t <gray>in scene <green><[data.name]><gray>."
                  - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
                  - inventory open d:dcutscene_inventory_keyframe_modify_screeneffect
                - else:
                  - define text "Invalid color."
                  - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
            #Remove the screeneffect modifier
            - case remove:
              - define tick <player.flag[dcutscene_tick_modify.tick]>
              - define data <player.flag[cutscene_data]>
              - define keyframe <[data.keyframes.elements.screeneffect].deep_exclude[<[tick]>]>
              - flag server dcutscenes.<[data.name]>.keyframes.elements.screeneffect:<[keyframe]>
              - flag <player> cutscene_data:<server.flag[dcutscenes.<[data.name]>]>
              - define text "Cinematic Screeneffect has been removed from tick <green><[tick]>t <gray>in scene <green><[data.name]><gray>."
              - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
              - inventory open d:dcutscene_inventory_sub_keyframe
              - ~run dcutscene_sub_keyframe_modify def:<player.flag[dcutscene_sub_keyframe_back_data]>
        ## Sound Modifier #####################
        - case sound:
          - choose <[arg]>:
            #Prepare for sound creation
            - case new:
              - flag <player> cutscene_modify:sound expire:2.5m
              - define text "To add a sound to this keyframe do /dcutscene sound my_sound."
              - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
              - inventory close
            #Create new sound
            - case create:
              - define arg_2 <[arg_2]||null>
              - if <[arg_2]> != null:
                - define tick <player.flag[dcutscene_tick_modify]>
                - define text "Sound <green><[arg_2]> <gray>has been added to tick <green><[tick]>t <gray>in scene <green><[scene_name]><gray>."
                - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
                - if <server.sound_types.contains[<[arg_2]>]>:
                  - playsound <player> sound:<[arg_2]>
                - define uuid <util.random_uuid>
                #List of sounds by uuid
                - define keyframes.sound.<[tick]>.sounds:->:<[uuid]>
                #Default values when creating new sound
                - define keyframes.sound.<[tick]>.<[uuid]>.sound <[arg_2]>
                - define keyframes.sound.<[tick]>.<[uuid]>.volume 1.0
                - define keyframes.sound.<[tick]>.<[uuid]>.location false
                - define keyframes.sound.<[tick]>.<[uuid]>.pitch 1
                - define keyframes.sound.<[tick]>.<[uuid]>.custom false
                #Input the data
                - flag server dcutscenes.<[scene_name]>.keyframes.elements:<[keyframes]>
                - flag <player> cutscene_data:<server.flag[dcutscenes.<[scene_name]>]>
                - ~run dcutscene_sort_data def:<[scene_name]>
                - inventory open d:dcutscene_inventory_sub_keyframe
                - ~run dcutscene_sub_keyframe_modify def:<player.flag[dcutscene_sub_keyframe_back_data]>
              - else:
                - debug error "Could not determine new sound in dcutscene_animator_keyframe_edit"
            #Prepare for new volume
            - case new_volume:
              - flag <player> cutscene_modify:sound_volume expire:1.5m
              - define text "Chat the volume of the sound."
              - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
              - inventory close
            #Set new volume
            - case set_volume:
              - define arg_2 <[arg_2]||null>
              - if <[arg_2]> != null && <[arg_2].is_decimal>:
                - flag <player> cutscene_modify:!
                - define tick <player.flag[dcutscene_tick_modify.tick]>
                - define uuid <player.flag[dcutscene_tick_modify.uuid]>
                - define data <player.flag[cutscene_data]>
                - define keyframe <[data.keyframes.elements.sound.<[tick]>.<[uuid]>]||null>
                - if <[keyframe]> != null:
                  - define keyframe.volume <[arg_2].abs>
                  - flag server dcutscenes.<[data.name]>.keyframes.elements.sound.<[tick]>.<[uuid]>:<[keyframe]>
                  - flag <player> cutscene_data:<server.flag[dcutscenes.<[data.name]>]>
                  - define text "Sound <green><[keyframe.sound]> <gray>now has a volume of <green><[keyframe.volume].abs><gray> in tick <green><[tick]>t <gray> for scene <green><[data.name]><gray>."
                  - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
                  - inventory open d:dcutscene_inventory_keyframe_modify_sound
                - else:
                  - debug error "Something went wrong in dcutscene_animator_keyframe_edit for set_volume in sound modifier"
              - else if <[arg_2]> != null && !<[arg_2].is_decimal>:
                - define text "<green><[arg_2]> <gray>is not a number!"
                - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
              - else:
                - define text "Specify a number for the volume."
                - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
            #Prepare for new pitch
            - case new_pitch:
              - flag <player> cutscene_modify:sound_pitch expire:1.5m
              - define text "Chat the pitch of the sound."
              - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
              - inventory close
            #Set new pitch
            - case set_pitch:
              - define arg_2 <[arg_2]||null>
              - if <[arg_2]> != null && <[arg_2].is_decimal>:
                - flag <player> cutscene_modify:!
                - define tick <player.flag[dcutscene_tick_modify.tick]>
                - define uuid <player.flag[dcutscene_tick_modify.uuid]>
                - define data <player.flag[cutscene_data]>
                - define keyframe <[data.keyframes.elements.sound.<[tick]>.<[uuid]>]||null>
                - if <[keyframe]> != null:
                  - define keyframe.pitch <[arg_2].abs>
                  - flag server dcutscenes.<[data.name]>.keyframes.elements.sound.<[tick]>.<[uuid]>:<[keyframe]>
                  - flag <player> cutscene_data:<server.flag[dcutscenes.<[data.name]>]>
                  - define text "Sound <green><[keyframe.sound]> <gray>now has a pitch of <green><[keyframe.pitch].abs><gray> in tick <green><[tick]>t <gray>for scene <green><[data.name]><gray>."
                  - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
                  - inventory open d:dcutscene_inventory_keyframe_modify_sound
                - else:
                  - debug error "Something went wrong in dcutscene_animator_keyframe_edit for set_pitch in sound modifier"
              - else if <[arg_2]> != null && !<[arg_2].is_decimal>:
                - define text "<green><[arg_2]> <gray>is not a number!"
                - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
              - else:
                - define text "Specify a number for the pitch."
                - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
            #Determine if sound is custom or not
            - case set_custom:
              - define arg_2 <[arg_2]||null>
              - if <[arg_2]> != null:
                - define tick <player.flag[dcutscene_tick_modify.tick]>
                - define uuid <player.flag[dcutscene_tick_modify.uuid]>
                - define data <player.flag[cutscene_data]>
                - define keyframe <[data.keyframes.elements.sound.<[tick]>.<[uuid]>]||null>
                - if <[keyframe]> != null:
                  - choose <[keyframe.custom]||false>:
                    - case true:
                      - define keyframe.custom false
                    - case false:
                      - define keyframe.custom true
                  - flag server dcutscenes.<[data.name]>.keyframes.elements.sound.<[tick]>.<[uuid]>:<[keyframe]>
                  - flag <player> cutscene_data:<server.flag[dcutscenes.<[data.name]>]>
                  - define item <item[<[arg_2]>]||null>
                  - if <[arg_2]> != null:
                    - define inv <player.open_inventory>
                    - define lore "<dark_purple><bold>Custom <gray><[keyframe.custom]>"
                    - define click "<gray><italic>Click to change custom sound"
                    - adjust <[item]> lore:<list[<empty>|<[lore]>|<empty>|<[click]>]> save:item
                    - define item <entry[item].result>
                    - inventory set d:<[inv]> o:<[item]> slot:<[arg_3]>
                - else:
                  - debug error "Something went wrong in dcutscene_animator_keyframe_edit for set_custom in sound modifier"
            #Prepare for new sound location
            - case new_location:
              - flag <player> cutscene_modify:sound_location expire:3m
              - define text "Available Inputs:"
              - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
              - narrate "<gray>Chat <green>confirm <gray>to input your location"
              - narrate "<gray>Chat a valid location tag"
              - narrate "<gray>Right click a block"
              - narrate "<gray>Chat <red>false <gray>to disable sound location"
              - inventory close
            #Set new sound location
            - case set_location:
              - define arg_2 <[arg_2]||null>
              - if <[arg_2]> != null:
                - if <[arg_2]> != false:
                  - define loc <location[<[arg_2].parsed>]||null>
                  - if <[loc]> == null:
                    - define text "<green><[arg_2]> <gray>is not a valid location."
                    - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
                    - stop
                - else:
                  - define loc false
                - define tick <player.flag[dcutscene_tick_modify.tick]>
                - define uuid <player.flag[dcutscene_tick_modify.uuid]>
                - define data <player.flag[cutscene_data]>
                - define keyframe <[data.keyframes.elements.sound.<[tick]>.<[uuid]>]||null>
                - if <[keyframe]> != null:
                  - flag <player> cutscene_modify:!
                  - define keyframe.location <[loc]>
                  - flag server dcutscenes.<[data.name]>.keyframes.elements.sound.<[tick]>.<[uuid]>:<[keyframe]>
                  - flag <player> cutscene_data:<server.flag[dcutscenes.<[data.name]>]>
                  - define text "Sound <green><[keyframe.sound]> <gray>location is now <green><[keyframe.location]><gray> in tick <green><[tick]>t <gray>for scene <green><[data.name]><gray>."
                  - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
                  - inventory open d:dcutscene_inventory_keyframe_modify_sound
                - else:
                  - debug error "Something went wrong in dcutscene_animator_keyframe_edit for set_location in sound modifier"
              - else:
                - debug error "Something went wrong in dcutscene_animator_keyframe_edit for set_location in sound modifier"
            #Remove sound from tick
            - case remove_sound:
              - define tick <player.flag[dcutscene_tick_modify.tick]>
              - define uuid <player.flag[dcutscene_tick_modify.uuid]>
              - define data <player.flag[cutscene_data]>
              - define sound <[data.keyframes.elements.sound.<[tick]>.<[uuid]>.sound]>
              - define keyframe <[data.keyframes.elements.sound]>
              #New modified data with sound removed
              - define new_keyframe <[keyframe.<[tick]>].deep_exclude[<[uuid]>]>
              - define new_keyframe.sounds:<-:<[uuid]>
              #If the animator list is empty for the tick remove the tick
              - if <[new_keyframe.sounds].is_empty>:
                #Keyframe with tick removed
                - define keyframe <[data.keyframes.elements.sound].deep_exclude[<[tick]>]>
              - else:
                #Keyframe with tick intact due to present sounds in tick
                - define keyframe.<[tick]> <[new_keyframe]>
              - if <[new_keyframe]> != null:
                - flag server dcutscenes.<[data.name]>.keyframes.elements.sound:<[keyframe]>
                - flag <player> cutscene_data:<server.flag[dcutscenes.<[data.name]>]>
                - define text "Sound <green><[sound]> <gray>has been removed from tick <green><[tick]>t <gray>for scene <green><[data.name]><gray>."
                - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
                - inventory open d:dcutscene_inventory_sub_keyframe
                - ~run dcutscene_sub_keyframe_modify def:<player.flag[dcutscene_sub_keyframe_back_data]>
              - else:
                - debug error "Something went wrong in dcutscene_animator_keyframe_edit for remove_sound in sound modifier"
        #########################################

#############################
###################################################

## Cutscene Animator Tasks and Procedures ########################

#Start the cutscene
dcutscene_animation_begin:
    type: task
    debug: false
    definitions: cutscene
    script:
    - define cutscene <server.flag[dcutscenes.<[cutscene]>]||null>
    - if <[cutscene]> != null:
      - define keyframes <[cutscene.keyframes]||null>
      - define length <[cutscene.length]||null>
      - if <[keyframes]> != null && <[length]> != null:
        #All cutscenes require a camera or it cannot play
        - define camera <[keyframes.camera]||null>
        #Elements in keyframe
        - define elements <[keyframes.elements]||null>
        - if <[camera]> != null:
          #Chunks must be loaded to begin cutscene
          - define first <[camera].keys.first>
          - define first_loc <location[<[camera.<[first]>.location]>]||null>
          - if <[first_loc]> != null:
            - teleport <player> <[first_loc]>
            #Reason for delay is so chunks get properly loaded
            - wait 5t
          - if <player.has_flag[dcutscene_camera]>:
            - remove <player.flag[dcutscene_camera]>
            - flag <player> dcutscene_camera:!
          - run dcutscene_bars
          - cast INVISIBILITY d:100000000000s hide_particles no_ambient no_icon
          - define uuid <util.random_uuid>
          - spawn dcutscene_camera_entity <player.location> save:<[uuid]>
          - define camera_ent <entry[<[uuid]>].spawned_entity>
          - define m_uuid <util.random_uuid>
          #Used as mount
          - spawn dcutscene_camera_entity <player.location> save:<[m_uuid]>
          - define camera_mount <entry[<[m_uuid]>].spawned_entity>
          - adjust <[camera_mount]> tracking_range:256
          - adjust <[camera_ent]> tracking_range:256
          - mount <player>|<[camera_mount]>
          - flag <player> dcutscene_camera:<[camera_ent]>
          #reason for a mount is the camera does not load chunks
          - flag <player> dcutscene_mount:<[camera_mount]>
          - define cam_count 0
          - adjust <player> spectate:<[camera_ent]>
          - repeat <duration[<[length]>].in_ticks> as:tick:
            - if <[camera_ent].is_spawned>:
              - define cam_data <[camera.<[tick]>]||null>
              #There can only be 1 camera of course
              - if <[cam_data]> != null && <[cam_count]> < 1:
                - define cam_count:++
                - run dcutscene_path_move def:<[cutscene.name]>|<[camera_ent]>|camera
              - if <[elements]> != null:
                #sound uuids
                - define sounds <[elements.sound.<[tick]>.sounds]||null>
                - if <[sounds]> != null:
                  - foreach <[sounds]> as:uuid:
                    - define data <[elements.sound.<[tick]>.<[uuid]>]||null>
                    - if <[data]> != null:
                      - define loc <[data.location]||false>
                      - define custom <[data.custom]||false>
                      - if <[loc].equals[false]>:
                        - define sound_to <player>
                      - else:
                        - define sound_to <location[<[loc]>]>
                      - if <[custom].equals[false]>:
                        - playsound <[sound_to]> sound:<[data.sound]> volume:<[data.volume]||1.0> pitch:<[data.pitch]||1.0>
                      - else if <[custom].equals[true]>:
                        - playsound <[sound_to]> sound:<[data.sound]> volume:<[data.volume]||1.0> pitch:<[data.pitch]||1.0> custom
                - define screeneffect <[elements.screeneffect.<[tick]>]||null>
                - if <[screeneffect]> != null:
                  - define title <script[dcutscenes_config].data_key[config].get[cutscene_transition_unicode]||null>
                  - if <[title]> != null:
                    - title title:<&color[<[screeneffect.color]>]><[title]> fade_in:<[screeneffect.fade_in].in_seconds>s stay:<[screeneffect.stay].in_seconds>s fade_out:<[screeneffect.fade_out].in_seconds>s targets:<player>
                  - else:
                    - debug error "Could not find cinematic screeneffect unicode in dcutscene_animation_begin"
            - else:
              - stop
            - wait 1t
        - else:
          - debug error "Cutscene <[cutscene]> does not have a camera!"
    - else:
      - debug error "Cutscene could not be found."

#TODO:
#- Give option of interpolating to the next eye location instead of it being instant
#Path movement for camera, models, and entities
dcutscene_path_move:
    type: task
    debug: false
    definitions: cutscene|entity|type
    script:
    - define cutscene <server.flag[dcutscenes.<[cutscene]>]||null>
    - if <[cutscene]> != null:
      - define mount <player.flag[dcutscene_mount]>
      - define type <[type]||null>
      - if <[type]> != null:
        - choose <[type]>:
          - case camera:
            - define keyframes <[cutscene.keyframes.camera]>
            #before
            - foreach <[keyframes]> key:c_id as:keyframe:
              - define interpolation <[keyframe.interpolation]>
              - define time_1 <[keyframe.tick]>
              - define loc_1 <location[<[keyframe.location]>]||null>
              - define rotate <[keyframe.rotate]>
              - if <[rotate].equals[false]>:
                - define eye_loc <[entity].eye_location>
              - else:
                - define eye_loc <[keyframe.eye_loc]>
              - define move <[keyframe.move]>
              - if <[loc_1]> == null:
                - foreach next
              #after
              - foreach <[keyframes]> key:2_id as:2_keyframe:
                - define compare <[2_keyframe.tick].is_more_than[<[time_1]>]>
                - if <[compare].equals[true]>:
                  - define time_2 <[2_keyframe.tick]>
                  - define loc_2 <location[<[2_keyframe.location]>]||null>
                  - define eye_loc_2 <location[<[2_keyframe.eye_loc]>]||null>
                  - foreach stop
              - define loc_2 <[loc_2]||null>
              - if <[loc_2]> == null:
                - foreach next
              - define time <[time_2].sub[<[time_1]>]>
              - choose <[interpolation]>:
                #Linear Interpolation
                - case linear:
                  - repeat <[time]>:
                    - if <[entity].is_spawned>:
                      - define time_index <[value]>
                      - if <[time_index]> < <[time]>:
                        - define time_percent <[time_index].div[<[time]>]>
                        #Lerp calc
                        - define data <[loc_2].as_location.sub[<[loc_1]>].mul[<[time_percent]>].add[<[loc_1]>]>
                        #Eye location interp
                        - define yaw <[eye_loc_2].yaw.sub[<[eye_loc].yaw>].mul[<[time_percent]>].add[<[eye_loc].yaw>]>
                        - define pitch <[eye_loc_2].pitch.sub[<[eye_loc].pitch>].mul[<[time_percent]>].add[<[eye_loc].pitch>]>
                      - else:
                        - define data <[loc_2].as_location>
                        - define yaw <[eye_loc_2].yaw>
                        - define pitch <[eye_loc_2].pitch>
                      - if <[rotate].equals[false]> && <[move].equals[true]>:
                        - teleport <[entity]> <[data].with_yaw[<[yaw]>].with_pitch[<[pitch]>]>
                        - teleport <[mount]> <[data].with_yaw[<[eye_loc].yaw>].below[2]>
                      - else if <[move].equals[false]>:
                        - teleport <[entity]> <[loc_1].with_yaw[<[eye_loc].yaw>].with_pitch[<[eye_loc].pitch>]>
                        - teleport <[mount]> <[loc_1].with_yaw[<[eye_loc].yaw>].below[2]>
                    - else:
                      - stop
                    - wait 1t
                #Smooth Interpolation
                - case smooth:
                  #after extra
                  - foreach <[keyframes]> key:a_e_id as:a_e_keyframe:
                    - define compare <[a_e_keyframe.tick].is_more_than[<[time_2]>]>
                    - if <[compare].equals[true]>:
                      - define loc_2_after <[a_e_keyframe.location]>
                      - foreach stop
                  - define loc_2_after <[loc_2_after]||<[loc_2]>>
                  #before extra
                  - define list <list>
                  - foreach <[keyframes]> key:b_e_id as:b_e_keyframe:
                    - define compare <[b_e_keyframe.tick].is_less_than[<[time_1]>]>
                    - if <[compare].equals[true]>:
                      - define list:->:<[b_e_keyframe]>
                  - if <[list].is_empty>:
                    - define list:->:<[keyframe]>
                  - define loc_1_prev <[list].last.get[location]||null>
                  - repeat <[time]>:
                    - if <[entity].is_spawned>:
                      - define time_index <[value]>
                      - if <[time_index]> < <[time]>:
                        - define time_percent <[time_index].div[<[time]>]>
                        - define p0 <[loc_1_prev].as_location>
                        - define p1 <[loc_1].as_location>
                        - define p2 <[loc_2].as_location>
                        - define p3 <[loc_2_after].as_location>
                        #Catmullrom calc
                        - define data <proc[dcutscene_catmullrom_proc].context[<[p0]>|<[p1]>|<[p2]>|<[p3]>|<[time_percent]>]>
                        #Eye location interp
                        - define yaw <[eye_loc_2].yaw.sub[<[eye_loc].yaw>].mul[<[time_percent]>].add[<[eye_loc].yaw>]>
                        - define pitch <[eye_loc_2].pitch.sub[<[eye_loc].pitch>].mul[<[time_percent]>].add[<[eye_loc].pitch>]>
                      - else:
                        - define data <[loc_2_after].as_location>
                        - define yaw <[loc_2].yaw>
                        - define pitch <[loc_2].pitch>
                      - if <[rotate].equals[false]> && <[move].equals[true]>:
                        - teleport <[entity]> <[data].with_yaw[<[yaw]>].with_pitch[<[pitch]>]>
                        - teleport <[mount]> <[data].with_yaw[<[eye_loc].yaw>].below[2]>
                      - else if <[move].equals[false]>:
                        - teleport <[entity]> <[loc_1].with_yaw[<[eye_loc].yaw>].with_pitch[<[eye_loc].pitch>]>
                        - teleport <[mount]> <[loc_1].with_yaw[<[eye_loc].yaw>].with_pitch[<[eye_loc].pitch>].below[2]>
                    - else:
                      - stop
                    - wait 1t
                - default:
                  - foreach next
            - run dcutscene_animation_stop

#Stops the cutscene animation from processing further
dcutscene_animation_stop:
    type: task
    debug: false
    script:
    - adjust <player> spectate:<player>
    - cast INVISIBILITY remove
    - run dcutscene_bars_remove
    - remove <player.flag[dcutscene_camera]>
    - remove <player.flag[dcutscene_mount]>
    - flag <player> dcutscene_camera:!
    - flag <player> dcutscene_mount:!

#Shows cutscene paths in editor mode
#TODO:
#- Use this for model or entity paths
dcutscene_path_show:
    type: task
    debug: false
    definitions: cutscene
    script:
    - define data <server.flag[dcutscenes.<[cutscene]>]||null>
    - if <[data]> != null:
      - define keyframes <[data.keyframes.camera]>
      - define dist <script[dcutscenes_config].data_key[config].get[cutscene_path_distance]||50>
      - foreach <[keyframes]> key:id as:keyframe:
        - define interpolation <[keyframe.interpolation]>
        - define time_1 <[keyframe.tick]>
        - define loc_1 <[keyframe.location]>
        - choose <[interpolation]>:
          #Linear Interpolation
          - case linear:
            #after
            - foreach <[keyframes]> key:2_id as:2_keyframe:
              - define compare <[2_keyframe.tick].is_more_than[<[time_1]>]>
              - if <[compare].equals[true]>:
                - define time_2 <[2_keyframe.tick]>
                - define loc_2 <location[<[2_keyframe.location]>]>
                - foreach stop
            #time
            - define time <[time_2].sub[<[time_1]>]>
            - define path <proc[dcutscene_path_creator].context[<player>|<[loc_1]>|<[loc_2]>|linear|<[time]>]>
            - if <[path]> != null:
              - foreach <[path]> as:point:
                #for some optimization it should only play when the player is facing the location and is within range
                - if <player.location.facing[<[point]>].degrees[60]> && <player.location.distance[<[point]>]> <= <[dist].mul[2.5]>:
                  - define p_2 <[path].get[<[loop_index].add[1]>]||<[point]>>
                  - define p_loc <location[<[point]>].points_between[<[p_2]>].distance[1.5]>
                  - if !<[p_loc].is_empty>:
                    - foreach <[p_loc]> as:p_b:
                      - if <player.location.facing[<[p_b]>].degrees[60]> && <player.location.distance[<[p_b]>]> <= <[dist].mul[2.5]>:
                        - playeffect effect:barrier at:<[p_b]> offset:0,0,0 visibility:<[dist]> targets:<player>
          #Catmullrom Interpolation
          - case smooth:
            #after & time 2
            - foreach <[keyframes]> key:a_id as:a_keyframe:
              - define compare <[a_keyframe.tick].is_more_than[<[time_1]>]>
              - if <[compare].equals[true]>:
                - define time_2 <[a_keyframe.tick]>
                - define loc_2 <[a_keyframe.location]>
                - foreach stop
            - define loc_2 <[loc_2]||<[loc_1]>>
            #after extra
            - foreach <[keyframes]> key:a_e_id as:a_e_keyframe:
              - define compare <[a_e_keyframe.tick].is_more_than[<[time_2]>]>
              - if <[compare].equals[true]>:
                - define loc_2_after <[a_e_keyframe.location]>
                - foreach stop
            - define loc_2_after <[loc_2_after]||<[loc_2]>>
            #before extra
            - define list <list>
            - foreach <[keyframes]> key:b_e_id as:b_e_keyframe:
              - define compare <[b_e_keyframe.tick].is_less_than[<[time_1]>]>
              - if <[compare].equals[true]>:
                - define list:->:<[b_e_keyframe]>
            - if <[list].is_empty>:
              - define list:->:<[keyframe]>
            - define loc_1_prev <[list].last.get[location]||null>
            #time
            - define time <[time_2].sub[<[time_1]>]>
            - define path <proc[dcutscene_path_creator].context[<player>|<[loc_1]>|<[loc_2]>|smooth|<[time]>|<[loc_1_prev]>|<[loc_2_after]>]||null>
            - if <[path]> != null:
              #reason for not using points between here is it was very performance heavy but this still gets the job done on demonstrating the spline curve
              - foreach <[path]> as:point:
                - if <player.location.facing[<[point]>].degrees[60]> && <player.location.distance[<[point]>]> <= <[dist].mul[2.5]>:
                  - playeffect effect:barrier at:<[point]> offset:0,0,0 visibility:<[dist]> targets:<player>
          - default:
            - debug error "Could not determine interpolation type in dcutscene_path_show"
    - else:
      - debug error "Could not find cutscene in dcutscene_path_show"

#Creates a list of path points using interpolation methods
dcutscene_path_creator:
    type: procedure
    debug: false
    definitions: player|loc_1|loc_2|type|time|loc_1_prev|loc_2_after
    script:
    - define time <[time]||null>
    - define dist <script[dcutscenes_config].data_key[config].get[cutscene_path_distance]||50>
    - if <[time]> != null:
      - choose <[type]>:
        #Linear Interpolation
        - case linear:
          - repeat <[time]>:
            - define time_index <[value]>
            - if <[time_index]> < <[time]>:
              - define time_percent <[time_index].div[<[time]>]>
              #Lerp calc
              - define data <[loc_2].as_location.sub[<[loc_1]>].mul[<[time_percent]>].add[<[loc_1]>]>
            - else:
              - define data <[loc_2].as_location>
            #This ensures points that are not visible will not show particles for optimization
            - if <[player].location.facing[<[data]>].degrees[60]> && <[player].location.distance[<[data]>]> <= <[dist].mul[2.5]>:
              #Input data to path list
              - define points:->:<[data]>
          - determine <[points]||<empty>>
        #Catmullrom Interpolation
        - case smooth:
          - repeat <[time]>:
            - define time_index <[value]>
            - if <[time_index]> < <[time]>:
              - define time_percent <[time_index].div[<[time]>]>
              - define p0 <[loc_1_prev].as_location>
              - define p1 <[loc_1].as_location>
              - define p2 <[loc_2].as_location>
              - define p3 <[loc_2_after].as_location>
              #Catmullrom calc
              - define data <proc[dcutscene_catmullrom_proc].context[<[p0]>|<[p1]>|<[p2]>|<[p3]>|<[time_percent]>]>
            - else:
              - define data <[loc_2_after].as_location>
            - if <[player].location.facing[<[data]>].degrees[60]> && <[player].location.distance[<[data]>]> <= <[dist].mul[2.5]>:
              #Input data to path list
              - define points:->:<[data]>
          - determine <[points]||<empty>>
        - default:
          - debug error "Could not determine interpolation type in dcutscene_path_creator"
    - else:
      - determine null

dcutscene_catmullrom_get_t:
    type: procedure
    debug: false
    definitions: t|p0|p1
    script:
    # This is more complex for different alpha values, but alpha=1 compresses down to a '.vector_length' call conveniently
    - determine <[p1].sub[<[p0]>].vector_length.add[<[t]>]>

dcutscene_catmullrom_proc:
    type: procedure
    debug: false
    definitions: p0|p1|p2|p3|t
    script:
    # Zero distances are impossible to calculate
    - if <[p2].sub[<[p1]>].vector_length> < 0.01:
        - determine <[p2]>
    # Based on https://en.wikipedia.org/wiki/Centripetal_Catmull%E2%80%93Rom_spline#Code_example_in_Unreal_C++
    # With safety checks added for impossible situations
    - define t0 0
    - define t1 <proc[dcutscene_catmullrom_get_t].context[0|<[p0]>|<[p1]>]>
    - define t2 <proc[dcutscene_catmullrom_get_t].context[<[t1]>|<[p1]>|<[p2]>]>
    - define t3 <proc[dcutscene_catmullrom_get_t].context[<[t2]>|<[p2]>|<[p3]>]>
    # Divide-by-zero safety check
    - if <[t1].abs> < 0.001 || <[t2].sub[<[t1]>].abs> < 0.001 || <[t2].abs> < 0.001 || <[t3].sub[<[t1]>].abs> < 0.001:
        - determine <[p2].sub[<[p1]>].mul[<[t]>].add[<[p1]>]>
    - define t <[t2].sub[<[t1]>].mul[<[t]>].add[<[t1]>]>
    # ( t1-t )/( t1-t0 )*p0 + ( t-t0 )/( t1-t0 )*p1;
    - define a1 <[p0].mul[<[t1].sub[<[t]>].div[<[t1]>]>].add[<[p1].mul[<[t].div[<[t1]>]>]>]>
    # ( t2-t )/( t2-t1 )*p1 + ( t-t1 )/( t2-t1 )*p2;
    - define a2 <[p1].mul[<[t2].sub[<[t]>].div[<[t2].sub[<[t1]>]>]>].add[<[p2].mul[<[t].sub[<[t1]>].div[<[t2].sub[<[t1]>]>]>]>]>
    # FVector A3 = ( t3-t )/( t3-t2 )*p2 + ( t-t2 )/( t3-t2 )*p3;
    - define a3 <[a1].mul[<[t2].sub[<[t]>].div[<[t2]>]>].add[<[a2].mul[<[t].div[<[t2]>]>]>]>
    # FVector B1 = ( t2-t )/( t2-t0 )*A1 + ( t-t0 )/( t2-t0 )*A2;
    - define b1 <[a1].mul[<[t2].sub[<[t]>].div[<[t2]>]>].add[<[a2].mul[<[t].div[<[t2]>]>]>]>
    # FVector B2 = ( t3-t )/( t3-t1 )*A2 + ( t-t1 )/( t3-t1 )*A3;
    - define b2 <[a2].mul[<[t3].sub[<[t]>].div[<[t3].sub[<[t1]>]>]>].add[<[a3].mul[<[t].sub[<[t1]>].div[<[t3].sub[<[t1]>]>]>]>]>
    # FVector C  = ( t2-t )/( t2-t1 )*B1 + ( t-t1 )/( t2-t1 )*B2;
    - determine <[b1].mul[<[t2].sub[<[t]>].div[<[t2].sub[<[t1]>]>]>].add[<[b2].mul[<[t].sub[<[t1]>].div[<[t2].sub[<[t1]>]>]>]>]>

dcutscene_bars:
    type: task
    debug: false
    script:
    - define script <script[dcutscenes_config].data_key[config]>
    - define bool <[script.use_cutscene_black_bars]||null>
    - if <[bool].equals[true]> || null:
      - if <player.has_flag[dcutscene_bars]>:
        - flag <player> dcutscene_bars:!
      - define top <[script.cutscene_black_bar_top]>
      - define bottom <[script.cutscene_black_bar_bottom]>
      - define uuid <util.random_uuid>
      - bossbar create players:<player> id:<[uuid]> title:<[top]> color:BLUE
      - flag <player> dcutscene_bars:<[uuid]>
      - while <player.has_flag[dcutscene_bars]>:
        - actionbar <[bottom]> targets:<player>
        - wait 1.2s

dcutscene_bars_remove:
    type: task
    debug: false
    script:
    - bossbar remove id:<player.flag[dcutscene_bars]> players:<player>
    - flag <player> dcutscene_bars:!
    - actionbar <empty> targets:<player>
###################################################
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
    - [] [] [dcutscene_play_command] [dcutscene_send_time] [dcutscene_set_weather] [] [] [] []
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
    - [] [] [] [dcutscene_camera_rotate_modify] [dcutscene_camera_upside_down] [dcutscene_camera_interpolate_rotate] [] [] []
    - [] [] [] [dcutscene_camera_teleport] [dcutscene_camera_interp_modify] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [dcutscene_back_page] [] [] [] [dcutscene_camera_remove_modify] [] [] [] [dcutscene_exit]

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

##################################################################################
