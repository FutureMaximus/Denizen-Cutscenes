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
        after player clicks dcutscene_play_cutscene_item in dcutscene_inventory_scene:
        - define cutscene <player.flag[cutscene_data.name]>
        - if <server.flag[dcutscenes.<[cutscene]>]||null> != null:
          - inventory close
          - run dcutscene_animation_begin def.scene:<[cutscene]> def.player:<player>
        - else:
          - debug error "Could not play scene <[cutscene]>."
        ##Settings #############
        ##Misc #################
        after player clicks dcutscene_exit in inventory:
        - inventory close
        ##Right click for location input in animator modifier
        after player right clicks block flagged:cutscene_modify using:hand:
        - ratelimit <player> 1t
        - choose <player.flag[cutscene_modify]>:
          #Sound location
          - case sound_location:
            - run dcutscene_animator_keyframe_edit def:sound|set_location|<context.location>
          #Set look location for camera
          - case create_present_cam_look_loc:
            - run dcutscene_cam_keyframe_edit def:edit|create_look_location|<context.location>
          #Fake block
          - case fake_block_location:
            - run dcutscene_animator_keyframe_edit def:fake_object|new_fake_block_loc|<context.location>
          - case set_fake_block_location:
            - run dcutscene_animator_keyframe_edit def:fake_object|set_fake_block_loc|<context.location>
          #Fake schem
          - case new_fake_schem_loc:
            - run dcutscene_animator_keyframe_edit def:fake_object|new_schem_create|<context.location.center>
          - case change_fake_schem_loc:
            - run dcutscene_animator_keyframe_edit def:fake_object|change_schem_loc|<context.location.center>
          #Particle
          - case new_particle_loc:
            - run dcutscene_animator_keyframe_edit def:particle|new_particle|<context.relative>
          - case change_particle_loc:
            - run dcutscene_animator_keyframe_edit def:particle|change_particle_loc|<context.relative>
        ##Tab completion ############
        after tab complete flagged:cutscene_modify:
        - define list <context.completions>
        - if <[list].contains[sound]>:
            - flag <player> cutscene_modify_tab:sound
        - else if <[list].contains[animate]>:
            - flag <player> cutscene_modify_tab:animate
        - else if <[list].contains[material]>:
            - flag <player> cutscene_modify_tab:material
        - else if <[list].contains[particle]>:
            - flag <player> cutscene_modify_tab:particle
        #input for dcutscene gui elements
        ##Chat Input ################
        on player chats flagged:cutscene_modify:
        - define msg <context.message>
        - determine passively cancelled
        - if <[msg]> == cancel:
          - flag <player> cutscene_modify:!
          - flag <player> dcutscene_animator_change:!
          - if <player.gamemode> == spectator:
            - adjust <player> gamemode:creative
          - stop
        - choose <player.flag[cutscene_modify]>:
          #Show camera path in cutscene
          - case camera_path:
            - if <[msg]> == stop:
              - flag <player> cutscene_modify:!
          #Show player model path in cutscene
          - case player_model_path:
            - if <[msg]> == stop:
              - flag <player> cutscene_modify:!
          #New cutscene name
          - case new_name:
            - run dcutscene_new_scene def.type:name def.scene:<[msg]>
          #Modify name for present cutscene
          - case name:
            - define name
          #Modify description for present cutscene
          - case desc:
            - define desc
          ##Camera
          #Create new camera modifier
          - case create_cam:
            - if <[msg]> == confirm:
              - run dcutscene_cam_keyframe_edit def:create
          #Modify present camera in keyframe
          - case create_present_cam:
            - if <[msg]> == confirm:
              - run dcutscene_cam_keyframe_edit def:edit|create_new_location
          #Sets rotation multiplier for camera
          - case new_rotation_mul:
            - run dcutscene_cam_keyframe_edit def:edit|rotate_change|set_mul|<[msg]>
          #Input new look location
          - case create_present_cam_look_loc:
            - if <[msg]> == confirm:
              - run dcutscene_cam_keyframe_edit def:edit|create_look_location|<player.eye_location>
            - else if <[msg]> == false:
              - run dcutscene_cam_keyframe_edit def:edit|create_look_location|false
            - else:
              - run dcutscene_cam_keyframe_edit def:edit|create_look_location|<[msg]>
          #Set camera record to false
          - case camera_record_false:
            - if <[msg].equals[false]>:
              - run dcutscene_cam_keyframe_edit def:edit|record_camera_false|<[msg]>
          #Set duration for camera recorder
          - case camera_recorder_duration:
            - run dcutscene_cam_keyframe_edit def:edit|record_camera_begin|own|<[msg]>
          ##Sound
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
          ##Screeneffect
          #Create new screeneffect modifier
          - case screeneffect:
            - run dcutscene_animator_keyframe_edit def:screeneffect|create|<[msg]>
          #Set new time
          - case screeneffect_time:
            - run dcutscene_animator_keyframe_edit def:screeneffect|set_time|<[msg]>
          #Set new color
          - case screeneffect_color:
            - run dcutscene_animator_keyframe_edit def:screeneffect|set_color|<[msg]>
          ##Run Task
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
          ##Player model
          #Create new player model id
          - case new_player_model_id:
            - run dcutscene_model_keyframe_edit def:player_model|create|id_set|<[msg]>
          #Set new player model location
          - case new_player_model_location:
            - if <[msg]> == confirm:
              - run dcutscene_model_keyframe_edit def:player_model|create|location_set|<player.flag[dcutscene_location_editor.location]>
          #Put new player model keyframe point based on previous player model
          - case new_player_model_keyframe_point:
            - if <[msg]> == confirm:
              - run dcutscene_model_keyframe_edit def:player_model|create_present|new_keyframe_set|<player.flag[dcutscene_location_editor.location]>
          #Sets a new id for the player model
          - case set_player_model_id:
            - run dcutscene_model_keyframe_edit def:player_model|change_id|id_set|<[msg]>
          #Sets new location for already created player model
          - case set_new_player_model_location:
            - if <[msg]> == confirm:
              - run dcutscene_model_keyframe_edit def:player_model|location|set_location|<player.flag[dcutscene_location_editor.location]>
          #Set rotation multiplier
          - case player_model_change_rotate_mul:
            - run dcutscene_model_keyframe_edit def:player_model|change_rotate_mul|<[msg]>
          #Sets a new skin for the player model
          - case player_model_change_skin:
            - run dcutscene_model_keyframe_edit def:player_model|change_skin|set_new_skin|<[msg]>
          ##Fake block
          #New fake block location
          - case fake_block_location:
            - run dcutscene_animator_keyframe_edit def:fake_object|new_fake_block_loc|<[msg].parsed>
          #Set new fake block location for already created keyframe
          - case set_fake_block_location:
            - run dcutscene_animator_keyframe_edit def:fake_object|set_fake_block_loc|<[msg].parsed>
          #Set fake block duration
          - case fake_block_duration:
            - run dcutscene_animator_keyframe_edit def:fake_object|set_fake_block_duration|<[msg]>
          #Set procedure script for fake block
          - case fake_block_proc_script:
            - run dcutscene_animator_keyframe_edit def:fake_object|set_fake_block_proc|<[msg]>
          #Set procedure definitions for fake block
          - case fake_block_proc_def:
            - run dcutscene_animator_keyframe_edit def:fake_object|set_fake_block_proc_def|<[msg]>
          ##Fake Schematic
          #Input fake schem name
          - case new_fake_schem_name:
            - run dcutscene_animator_keyframe_edit def:fake_object|new_schem_loc|<[msg]>
          #Input fake schem location
          - case new_fake_schem_loc:
            - run dcutscene_animator_keyframe_edit def:fake_object|new_schem_create|<[msg].parsed.center||null>
          #Change fake schem name
          - case change_fake_schem_name:
            - run dcutscene_animator_keyframe_edit def:fake_object|change_schem_name|<[msg]>
          #Change fake schem loc
          - case change_fake_schem_loc:
            - run dcutscene_animator_keyframe_edit def:fake_object|change_schem_loc|<[msg].parsed.center||null>
          #Change fake schem duration
          - case change_fake_schem_duration:
            - run dcutscene_animator_keyframe_edit def:fake_object|change_schem_duration|<[msg]>
          ##Particle
          #Input new particle location
          - case new_particle_loc:
            - run dcutscene_animator_keyframe_edit def:particle|new_particle|<[msg].parsed||null>
          #Input particle location
          - case change_particle_loc:
            - run dcutscene_animator_keyframe_edit def:particle|change_particle_loc|<[msg].parsed||null>
          #Input particle quantity
          - case change_particle_quantity:
            - run dcutscene_animator_keyframe_edit def:particle|change_particle_quantity|<[msg]>
          #Input particle visibility range
          - case change_particle_range:
            - run dcutscene_animator_keyframe_edit def:particle|change_particle_range|<[msg]>
          #Input particle repeat count
          - case change_particle_repeat_count:
            - run dcutscene_animator_keyframe_edit def:particle|change_particle_repeat_count|<[msg]>
          #Input particle repeat interval
          - case change_particle_repeat_interval:
            - run dcutscene_animator_keyframe_edit def:particle|change_particle_repeat_interval|<[msg]>
          #Input particle offset
          - case change_particle_offset:
            - run dcutscene_animator_keyframe_edit def:particle|change_particle_offset|<[msg].parsed>
          #Input particle procedure
          - case change_particle_proc_script:
            - run dcutscene_animator_keyframe_edit def:particle|change_particle_procedure_script|<[msg]>
          #Input particle definitions
          - case change_particle_proc_defs:
            - run dcutscene_animator_keyframe_edit def:particle|change_particle_procedure_defs|<[msg]>
          #Input particle special data
          - case change_particle_special_data:
            - run dcutscene_animator_keyframe_edit def:particle|change_particle_special_data|<[msg]>
          #Input particle velocity
          - case change_particle_velocity:
            - run dcutscene_animator_keyframe_edit def:particle|change_particle_velocity|<[msg].parsed>
          ##Title
          #Change title
          - case change_title:
            - run dcutscene_animator_keyframe_edit def:title|set_title|<[msg]>
          #Change subtitle
          - case change_subtitle:
            - run dcutscene_animator_keyframe_edit def:title|set_subtitle|<[msg]>
          #Change duration
          - case change_title_duration:
            - run dcutscene_animator_keyframe_edit def:title|set_duration|<[msg]>
          ##Command
          #New command
          - case new_command:
            - run dcutscene_animator_keyframe_edit def:command|new_command|<[msg]>
          #Change command
          - case change_command:
            - run dcutscene_animator_keyframe_edit def:command|change_command|<[msg]>
          ##Message
          #New message
          - case new_message:
            - run dcutscene_animator_keyframe_edit def:message|new_message|<[msg]>
          #Change message
          - case change_message:
            - run dcutscene_animator_keyframe_edit def:message|change_message|<[msg]>
          ##Time
          #New time
          - case new_time:
            - run dcutscene_animator_keyframe_edit def:time|new_time|<[msg]>
          #Change time
          - case change_time:
            - run dcutscene_animator_keyframe_edit def:time|change_time|<[msg]>
          #Change time duration
          - case change_time_duration:
            - run dcutscene_animator_keyframe_edit def:time|change_time_duration|<[msg]>
          ##Weather
          #Change weather duration
          - case change_weather_duration:
            - run dcutscene_animator_keyframe_edit def:weather|change_weather_duration|<[msg]>
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
        ##########################
        ##Animators to modify click event
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
            #Fake Block Type
            - case fake_block:
              - flag <player> dcutscene_tick_modify:<[i].flag[keyframe_opt_modify]>
              - inventory open d:dcutscene_inventory_fake_object_block_modify
            #Fake Schem Type
            - case fake_schem:
              - flag <player> dcutscene_tick_modify:<[i].flag[keyframe_opt_modify]>
              - inventory open d:dcutscene_inventory_fake_object_schem_modify
            #Particle Type
            - case particle:
              - flag <player> dcutscene_tick_modify:<[i].flag[keyframe_opt_modify]>
              - inventory open d:dcutscene_inventory_particle_modify
            #Sound type
            - case sound:
              - flag <player> dcutscene_tick_modify:<[i].flag[keyframe_opt_modify]>
              - inventory open d:dcutscene_inventory_keyframe_modify_sound
            #Screeneffect
            - case screeneffect:
              - flag <player> dcutscene_tick_modify:<[i].flag[keyframe_opt_modify]>
              - inventory open d:dcutscene_inventory_keyframe_modify_screeneffect
            #Title
            - case title:
              - flag <player> dcutscene_tick_modify:<[i].flag[keyframe_opt_modify.tick]>
              - inventory open d:dcutscene_inventory_keyframe_modify_title
            #Command
            - case command:
              - flag <player> dcutscene_tick_modify:<[i].flag[keyframe_opt_modify]>
              - inventory open d:dcutscene_inventory_keyframe_modify_command
            #Message
            - case message:
              - flag <player> dcutscene_tick_modify:<[i].flag[keyframe_opt_modify]>
              - inventory open d:dcutscene_inventory_keyframe_modify_message
            #Time
            - case time:
              - flag <player> dcutscene_tick_modify:<[i].flag[keyframe_opt_modify.tick]>
              - inventory open d:dcutscene_inventory_keyframe_modify_time
            #Weather
            - case weather:
              - flag <player> dcutscene_tick_modify:<[i].flag[keyframe_opt_modify.tick]>
              - inventory open d:dcutscene_inventory_keyframe_modify_weather
            #Stop Point
            - case stop_point:
              - flag <player> dcutscene_tick_modify:<[i].flag[keyframe_opt_modify]>
              - inventory open d:dcutscene_inventory_keyframe_modify_stop_point

        #Used for moving or duplicating animators
        - else if <[i].has_flag[change_animator]>:
          - if <player.has_flag[dcutscene_animator_change]>:
            - flag <player> dcutscene_tick_modify:<[i].flag[keyframe_tick]>
            - define data <player.flag[dcutscene_animator_change]>
            - choose <[data.animator]>:
              #Camera
              - case camera:
                - choose <[data.type]>:
                  - case move:
                    - run dcutscene_cam_keyframe_edit def:edit|move_camera
                  - case duplicate:
                    - run dcutscene_cam_keyframe_edit def:edit|duplicate_camera
              #Player Model
              - case player_model:
                - choose <[data.type]>:
                  - case move:
                    - run dcutscene_model_keyframe_edit def:player_model|move_to
                  - case duplicate:
                    - run dcutscene_model_keyframe_edit def:player_model|duplicate
              #Run Task
              - case run_task:
                - choose <[data.type]>:
                  - case move:
                    - run dcutscene_animator_keyframe_edit def:run_task|move_to
                  - case duplicate:
                    - run dcutscene_animator_keyframe_edit def:run_task|duplicate
              #Screeneffect
              - case screeneffect:
                - choose <[data.type]>:
                  - case move:
                    - run dcutscene_animator_keyframe_edit def:screeneffect|move_to
                  - case duplicate:
                    - run dcutscene_animator_keyframe_edit def:screeneffect|duplicate
              #Sound
              - case sound:
                - choose <[data.type]>:
                  - case move:
                    - run dcutscene_animator_keyframe_edit def:sound|move_to
                  - case duplicate:
                    - run dcutscene_animator_keyframe_edit def:sound|duplicate
              #Fake Block
              - case fake_block:
                - choose <[data.type]>:
                  - case move:
                    - run dcutscene_animator_keyframe_edit def:fake_object|move_to_fake_block
                  - case duplicate:
                    - run dcutscene_animator_keyframe_edit def:fake_object|duplicate_fake_block
              #Fake Schem
              - case fake_schem:
                - choose <[data.type]>:
                  - case move:
                    - run dcutscene_animator_keyframe_edit def:fake_object|move_to_fake_schem
                  - case duplicate:
                    - run dcutscene_animator_keyframe_edit def:fake_object|duplicate_fake_schem
              #Particle
              - case particle:
                - choose <[data.type]>:
                  - case move:
                    - run dcutscene_animator_keyframe_edit def:particle|move_to
                  - case duplicate:
                    - run dcutscene_animator_keyframe_edit def:particle|duplicate
              #Title
              - case title:
                - choose <[data.type]>:
                  - case move:
                    - run dcutscene_animator_keyframe_edit def:title|move_to
                  - case duplicate:
                    - run dcutscene_animator_keyframe_edit def:title|duplicate
              #Command
              - case command:
                - choose <[data.type]>:
                  - case move:
                    - run dcutscene_animator_keyframe_edit def:command|move_to
                  - case duplicate:
                    - run dcutscene_animator_keyframe_edit def:command|duplicate
              #Message
              - case message:
                - choose <[data.type]>:
                  - case move:
                    - run dcutscene_animator_keyframe_edit def:message|move_to
                  - case duplicate:
                    - run dcutscene_animator_keyframe_edit def:message|duplicate
              #Time
              - case time:
                - choose <[data.type]>:
                  - case move:
                    - run dcutscene_animator_keyframe_edit def:time|move_to
                  - case duplicate:
                    - run dcutscene_animator_keyframe_edit def:time|duplicate
              #Weather
              - case weather:
                - choose <[data.type]>:
                  - case move:
                    - run dcutscene_animator_keyframe_edit def:weather|move_to
                  - case duplicate:
                    - run dcutscene_animator_keyframe_edit def:weather|duplicate
        #Previous models that were created and can be modified for further use
        after player clicks item in dcutscene_inventory_keyframe_model_list:
        - define i <context.item>
        - if <[i].has_flag[model_keyframe_modify]>:
          - define data <[i].flag[model_keyframe_modify]>
          - choose <[data.type]>:
            - case player_model:
              - run dcutscene_model_keyframe_edit def:player_model|create_present|new_keyframe_prepare|<[data]>
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
        - run dcutscene_cam_keyframe_edit def:edit|interpolation_change|<context.item>|<context.slot>
        #Record camera
        after player clicks dcutscene_camera_record_player in dcutscene_inventory_keyframe_modify_camera:
        - run dcutscene_cam_keyframe_edit def:edit|record_camera_prep
        #Determine move
        after player clicks dcutscene_camera_move_modify in dcutscene_inventory_keyframe_modify_camera:
        - run dcutscene_cam_keyframe_edit def:edit|move_change|<context.item>|<context.slot>
        #Determine interpolate look
        after player clicks dcutscene_camera_interpolate_look in dcutscene_inventory_keyframe_modify_camera:
        - run dcutscene_cam_keyframe_edit def:edit|interpolate_look|<context.item>|<context.slot>
        #Determine Camera Look Rotation
        after player clicks dcutscene_camera_rotate_modify in dcutscene_inventory_keyframe_modify_camera:
        - run dcutscene_cam_keyframe_edit def:edit|rotate_change|new_mul
        #Determine camera look invert
        after player clicks dcutscene_camera_upside_down in dcutscene_inventory_keyframe_modify_camera:
        - run dcutscene_cam_keyframe_edit def:edit|invert_camera|<context.item>|<context.slot>
        #Show camera path
        after player clicks dcutscene_camera_path_show in dcutscene_inventory_keyframe_modify_camera:
        - inventory close
        - run dcutscene_path_show_interval def:camera
        #Move camera to new keyframe
        after player clicks dcutscene_camera_move_to_keyframe in dcutscene_inventory_keyframe_modify_camera:
        - run dcutscene_cam_keyframe_edit def:edit|move_camera_prep
        #Duplicate camera to new keyframe
        after player clicks dcutscene_camera_duplicate_to_keyframe in dcutscene_inventory_keyframe_modify_camera:
        - run dcutscene_cam_keyframe_edit def:edit|duplicate_camera_prep
        ## All Models #######
        #New Model in model list gui
        after player clicks dcutscene_add_new_model in dcutscene_inventory_keyframe_model_list:
        - choose <player.flag[dcutscene_save_data.type]>:
          - case player_model:
            - flag <player> cutscene_modify:new_player_model_id expire:2m
            - define text "Chat the name of the player model this will be used as an identifier."
            - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
            - inventory close
        #Confirms location for location tool
        after player clicks dcutscene_location_tool_confirm_location in dcutscene_inventory_location_tool:
        - choose <player.flag[cutscene_modify]>:
          #New location for brand new model
          - case new_player_model_location:
            - run dcutscene_model_keyframe_edit def:player_model|create|location_set|<player.flag[dcutscene_location_editor.location]>
          #New location for new model with a root model
          - case new_player_model_keyframe_point:
            - run dcutscene_model_keyframe_edit def:player_model|create_present|new_keyframe_set|<player.flag[dcutscene_location_editor.location]>
          #Setting a new location for the already created model
          - case set_new_player_model_location:
            - run dcutscene_model_keyframe_edit def:player_model|location|set_location|<player.flag[dcutscene_location_editor.location]>
        ## Player Model ####
        #New model
        after player clicks dcutscene_add_player_model in dcutscene_inventory_keyframe_modify:
        - run dcutscene_model_keyframe_edit def:player_model|new
        #Set animation
        after player clicks dcutscene_player_model_change_animation in dcutscene_inventory_keyframe_modify_player_model:
        - run dcutscene_model_keyframe_edit def:player_model|animate|new_animation_prepare
        #Change move
        after player clicks dcutscene_player_model_change_move in dcutscene_inventory_keyframe_modify_player_model:
        - run dcutscene_model_keyframe_edit def:player_model|set_move|<context.slot>
        #Change location
        after player clicks dcutscene_player_model_change_location in dcutscene_inventory_keyframe_modify_player_model:
        - run dcutscene_model_keyframe_edit def:player_model|location|new_location_prepare
        #Ray Trace GUI
        after player clicks dcutscene_player_model_ray_trace_change in dcutscene_inventory_keyframe_modify_player_model:
        - inventory open d:dcutscene_inventory_keyframe_ray_trace_player_model
        #Move to a new keyframe
        after player clicks dcutscene_player_model_move_to_keyframe in dcutscene_inventory_keyframe_modify_player_model:
        - run dcutscene_model_keyframe_edit def:player_model|move_to_prep
        #Duplicate
        after player clicks dcutscene_player_model_duplicate in dcutscene_inventory_keyframe_modify_player_model:
        - run dcutscene_model_keyframe_edit def:player_model|duplicate_prep
        #Remove from tick
        after player clicks dcutscene_remove_player_model_tick in dcutscene_inventory_keyframe_modify_player_model:
        - run dcutscene_model_keyframe_edit def:player_model|remove_tick
        #Remove from cutscene
        after player clicks dcutscene_remove_player_model in dcutscene_inventory_keyframe_modify_player_model:
        - inventory close
        - clickable dcutscene_model_keyframe_edit def:player_model|remove_all save:remove_model
        - define prefix <element[DCutscenes].color_gradient[from=blue;to=aqua].bold>
        - define text "Are you sure you want to remove this player model? <green><bold><element[Yes].on_hover[<[prefix]> <gray>This will permanently remove this player model from this scene.].type[SHOW_TEXT].on_click[<entry[remove_model].command>]>"
        - narrate "<[prefix]> <gray><[text]>"
        #Preparation for new player model id
        after player clicks dcutscene_player_model_change_id in dcutscene_inventory_keyframe_modify_player_model:
        - run dcutscene_model_keyframe_edit def:player_model|change_id|new_id_prepare
        #Change path interpolation method
        after player clicks dcutscene_player_model_interp_method in dcutscene_inventory_keyframe_modify_player_model:
        - run dcutscene_model_keyframe_edit def:player_model|change_path_interp|<context.slot>
        #Change ray trace direction
        after player clicks dcutscene_player_model_ray_trace_determine in dcutscene_inventory_keyframe_ray_trace_player_model:
        - run dcutscene_model_keyframe_edit def:player_model|ray_trace|ray_trace_direction|<context.slot>
        #Change ray trace liquid
        after player clicks dcutscene_player_model_ray_trace_liquid in dcutscene_inventory_keyframe_ray_trace_player_model:
        - run dcutscene_model_keyframe_edit def:player_model|ray_trace|ray_trace_liquid|<context.slot>
        #Change ray trace passable
        after player clicks dcutscene_player_model_ray_trace_passable in dcutscene_inventory_keyframe_ray_trace_player_model:
        - run dcutscene_model_keyframe_edit def:player_model|ray_trace|ray_trace_passable|<context.slot>
        #Change the player model skin
        after player clicks dcutscene_player_model_change_skin in dcutscene_inventory_keyframe_modify_player_model:
        - run dcutscene_model_keyframe_edit def:player_model|change_skin|new_skin_prepare
        #Change path rotation interpolation
        after player clicks dcutscene_player_model_interp_rotate_change in dcutscene_inventory_keyframe_modify_player_model:
        - run dcutscene_model_keyframe_edit def:player_model|change_rotate_interp|<context.slot>
        #Change path rotation multiplier
        after player clicks dcutscene_player_model_interp_rotate_mul in dcutscene_inventory_keyframe_modify_player_model:
        - run dcutscene_model_keyframe_edit def:player_model|change_rotate_mul_prep|<context.slot>
        #Teleport to player model location
        after player clicks dcutscene_player_model_teleport_loc in dcutscene_inventory_keyframe_modify_player_model:
        - run dcutscene_model_keyframe_edit def:player_model|teleport_to
        #Path shower
        after player clicks dcutscene_player_model_show_path in dcutscene_inventory_keyframe_modify_player_model:
        - run dcutscene_path_show_interval def:player_model|<player.flag[dcutscene_tick_modify.tick]>|<player.flag[dcutscene_tick_modify.uuid]>
        - inventory close
        ##Run Task ######
        #Add new run task
        after player clicks dcutscene_add_run_task in dcutscene_inventory_keyframe_modify:
        - run dcutscene_animator_keyframe_edit def:run_task|new
        #Change the run task script
        after player clicks dcutscene_run_task_change_modify in dcutscene_inventory_keyframe_modify_run_task:
        - run dcutscene_animator_keyframe_edit def:run_task|change_task_prepare
        #Set definitions for run task
        after player clicks dcutscene_run_task_def_modify in dcutscene_inventory_keyframe_modify_run_task:
        - run dcutscene_animator_keyframe_edit def:run_task|task_definition
        #Determine if run task is waitable
        after player clicks dcutscene_run_task_wait_modify in dcutscene_inventory_keyframe_modify_run_task:
        - run dcutscene_animator_keyframe_edit def:run_task|change_waitable|<context.item>|<context.slot>
        #Determine if the run task is delayed
        after player clicks dcutscene_run_task_delay_modify in dcutscene_inventory_keyframe_modify_run_task:
        - run dcutscene_animator_keyframe_edit def:run_task|delay_prepare
        #Move to new tick
        after player clicks dcutscene_run_task_move_to_keyframe in dcutscene_inventory_keyframe_modify_run_task:
        - run dcutscene_animator_keyframe_edit def:run_task|move_to_prep
        #Duplicate run task
        after player clicks dcutscene_run_task_duplicate in dcutscene_inventory_keyframe_modify_run_task:
        - run dcutscene_animator_keyframe_edit def:run_task|duplicate_prep
        #Remove the run task
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
        #Move to new tick
        after player clicks dcutscene_sound_move_to_keyframe in dcutscene_inventory_keyframe_modify_sound:
        - run dcutscene_animator_keyframe_edit def:sound|move_to_prep
        #Duplicate
        after player clicks dcutscene_sound_duplicate in dcutscene_inventory_keyframe_modify_sound:
        - run dcutscene_animator_keyframe_edit def:sound|duplicate_prep
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
        #Move to new keyframe
        after player clicks dcutscene_screeneffect_move_to_keyframe in dcutscene_inventory_keyframe_modify_screeneffect:
        - run dcutscene_animator_keyframe_edit def:screeneffect|move_to_prep
        #Move to another keyframe
        after player clicks dcutscene_screeneffect_duplicate in dcutscene_inventory_keyframe_modify_screeneffect:
        - run dcutscene_animator_keyframe_edit def:screeneffect|duplicate_prep
        #Remove cinematic screeneffect
        after player clicks dcutscene_screeneffect_remove_modify in dcutscene_inventory_keyframe_modify_screeneffect:
        - run dcutscene_animator_keyframe_edit def:screeneffect|remove
        ##Fake Object ###########
        ##Fake Block ##
        #Add new fake block
        after player clicks dcutscene_add_fake_block in dcutscene_inventory_keyframe_modify:
        - run dcutscene_animator_keyframe_edit def:fake_object|new_fake_block_material
        #New fake block
        after player clicks dcutscene_fake_object_block_select in dcutscene_inventory_fake_object_selection:
        - run dcutscene_animator_keyframe_edit def:fake_object|new_fake_block_material
        #Fake block modify gui
        after player clicks dcutscene_fake_object_block_modify in dcutscene_inventory_fake_object_selection_modify:
        - inventory open d:dcutscene_inventory_fake_object_block_modify
        #Change location
        after player clicks dcutscene_fake_object_block_loc_change in dcutscene_inventory_fake_object_block_modify:
        - run dcutscene_animator_keyframe_edit def:fake_object|set_fake_block_prepare
        #Change material
        after player clicks dcutscene_fake_object_block_material_change in dcutscene_inventory_fake_object_block_modify:
        - run dcutscene_animator_keyframe_edit def:fake_object|set_fake_block_material_prep
        #Change duration
        after player clicks dcutscene_fake_object_block_duration_change in dcutscene_inventory_fake_object_block_modify:
        - run dcutscene_animator_keyframe_edit def:fake_object|set_fake_block_duration_prepare
        #Set procedure script
        after player clicks dcutscene_fake_object_block_proc_change in dcutscene_inventory_fake_object_block_modify:
        - run dcutscene_animator_keyframe_edit def:fake_object|set_fake_block_proc_prepare
        #Set procedure definitions
        after player clicks dcutscene_fake_object_block_proc_def_change in dcutscene_inventory_fake_object_block_modify:
        - run dcutscene_animator_keyframe_edit def:fake_object|set_fake_block_proc_def_prepare
        #Teleport to fake block
        after player clicks dcutscene_fake_object_block_teleport in dcutscene_inventory_fake_object_block_modify:
        - run dcutscene_animator_keyframe_edit def:fake_object|teleport_to_fake_block
        #Move fake block animator
        after player clicks dcutscene_fake_block_move_to_keyframe in dcutscene_inventory_fake_object_block_modify:
        - run dcutscene_animator_keyframe_edit def:fake_object|move_to_fake_block_prep
        #Duplicate fake block animator
        after player clicks dcutscene_fake_block_duplicate in dcutscene_inventory_fake_object_block_modify:
        - run dcutscene_animator_keyframe_edit def:fake_object|duplicate_fake_block_prep
        #Remove the fake block
        after player clicks dcutscene_fake_object_block_remove in dcutscene_inventory_fake_object_block_modify:
        - run dcutscene_animator_keyframe_edit def:fake_object|remove_fake_block
        ##Fake Schem ###
        #Add new fake schem
        after player clicks dcutscene_add_fake_schem in dcutscene_inventory_keyframe_modify:
        - run dcutscene_animator_keyframe_edit def:fake_object|new_schem_name
        #Change fake schem name
        after player clicks dcutscene_fake_object_schem_name_change in dcutscene_inventory_fake_object_schem_modify:
        - run dcutscene_animator_keyframe_edit def:fake_object|change_schem_name_prep
        #Change fake schem loc
        after player clicks dcutscene_fake_object_schem_loc_change in dcutscene_inventory_fake_object_schem_modify:
        - run dcutscene_animator_keyframe_edit def:fake_object|change_schem_loc_prep
        #Change fake schem duration
        after player clicks dcutscene_fake_object_schem_duration_change in dcutscene_inventory_fake_object_schem_modify:
        - run dcutscene_animator_keyframe_edit def:fake_object|change_schem_duration_prep
        #Change fake schem noair
        after player clicks dcutscene_fake_object_schem_noair_change in dcutscene_inventory_fake_object_schem_modify:
        - run dcutscene_animator_keyframe_edit def:fake_object|change_schem_noair|<context.slot>
        #Change fake schem waitable
        after player clicks dcutscene_fake_object_schem_waitable_change in dcutscene_inventory_fake_object_schem_modify:
        - run dcutscene_animator_keyframe_edit def:fake_object|change_schem_waitable|<context.slot>
        #Change fake schem direction
        after player clicks dcutscene_fake_object_schem_angle_change in dcutscene_inventory_fake_object_schem_modify:
        - run dcutscene_animator_keyframe_edit def:fake_object|change_schem_direction|<context.slot>
        #Teleport to fake schem location
        after player clicks dcutscene_fake_object_schem_teleport in dcutscene_inventory_fake_object_schem_modify:
        - run dcutscene_animator_keyframe_edit def:fake_object|teleport_to_fake_schem
        #Move to new keyframe
        after player clicks dcutscene_fake_schem_move_to in dcutscene_inventory_fake_object_schem_modify:
        - run dcutscene_animator_keyframe_edit def:fake_object|move_to_fake_schem_prep
        #Duplicate
        after player clicks dcutscene_fake_schem_duplicate in dcutscene_inventory_fake_object_schem_modify:
        - run dcutscene_animator_keyframe_edit def:fake_object|duplicate_fake_schem_prep
        #Remove fake schem
        after player clicks dcutscene_fake_object_schem_remove in dcutscene_inventory_fake_object_schem_modify:
        - run dcutscene_animator_keyframe_edit def:fake_object|remove_fake_schem
        ## Particle ######
        #Add new particle
        after player clicks dcutscene_add_particle in dcutscene_inventory_keyframe_modify:
        - run dcutscene_animator_keyframe_edit def:particle|new_particle_prep
        #Change particle
        after player clicks dcutscene_particle_modify in dcutscene_inventory_particle_modify:
        - run dcutscene_animator_keyframe_edit def:particle|change_particle_prep
        #Change location
        after player clicks dcutscene_particle_loc_modify in dcutscene_inventory_particle_modify:
        - run dcutscene_animator_keyframe_edit def:particle|change_particle_loc_prep
        #Change quantity
        after player clicks dcutscene_particle_quantity_modify in dcutscene_inventory_particle_modify:
        - run dcutscene_animator_keyframe_edit def:particle|change_particle_quantity_prep
        #Change visible range
        after player clicks dcutscene_particle_range_modify in dcutscene_inventory_particle_modify:
        - run dcutscene_animator_keyframe_edit def:particle|change_particle_range_prep
        #Change repeat count
        after player clicks dcutscene_particle_repeat_modify in dcutscene_inventory_particle_modify:
        - run dcutscene_animator_keyframe_edit def:particle|change_particle_repeat_count_prep
        #Change repeat interval
        after player clicks dcutscene_particle_repeat_interval_modify in dcutscene_inventory_particle_modify:
        - run dcutscene_animator_keyframe_edit def:particle|change_particle_repeat_interval_prep
        #Change particle offset
        after player clicks dcutscene_particle_offset_modify in dcutscene_inventory_particle_modify:
        - run dcutscene_animator_keyframe_edit def:particle|change_particle_offset_prep
        #Change particle procedure script
        after player clicks dcutscene_particle_procedure_modify in dcutscene_inventory_particle_modify:
        - run dcutscene_animator_keyframe_edit def:particle|change_particle_procedure_script_prep
        #Change particle procedure definitions
        after player clicks dcutscene_particle_procedure_defs_modify in dcutscene_inventory_particle_modify:
        - run dcutscene_animator_keyframe_edit def:particle|change_particle_procedure_defs_prep
        #Change particle special data
        after player clicks dcutscene_particle_special_data_modify in dcutscene_inventory_particle_modify:
        - run dcutscene_animator_keyframe_edit def:particle|change_particle_special_data_prep
        #Change particle velocity
        after player clicks dcutscene_particle_velocity_modify in dcutscene_inventory_particle_modify:
        - run dcutscene_animator_keyframe_edit def:particle|change_particle_velocity_prep
        #Teleport to particle
        after player clicks dcutscene_particle_teleport_to in dcutscene_inventory_particle_modify:
        - run dcutscene_animator_keyframe_edit def:particle|teleport_to_particle
        #Move to new keyframe
        after player clicks dcutscene_particle_move_to_keyframe in dcutscene_inventory_particle_modify:
        - run dcutscene_animator_keyframe_edit def:particle|move_to_prep
        #Duplicate
        after player clicks dcutscene_particle_duplicate in dcutscene_inventory_particle_modify:
        - run dcutscene_animator_keyframe_edit def:particle|duplicate_prep
        #Remove particle
        after player clicks dcutscene_particle_remove in dcutscene_inventory_particle_modify:
        - run dcutscene_animator_keyframe_edit def:particle|remove_particle
        ## Title ######
        #Add new title
        after player clicks dcutscene_send_title in dcutscene_inventory_keyframe_modify:
        - run dcutscene_animator_keyframe_edit def:title|new_title
        #Change title
        after player clicks dcutscene_title_title_modify in dcutscene_inventory_keyframe_modify_title:
        - run dcutscene_animator_keyframe_edit def:title|set_title_prep
        #Change subtitle
        after player clicks dcutscene_title_subtitle_modify in dcutscene_inventory_keyframe_modify_title:
        - run dcutscene_animator_keyframe_edit def:title|set_subtitle_prep
        #Change duration
        after player clicks dcutscene_title_duration_modify in dcutscene_inventory_keyframe_modify_title:
        - run dcutscene_animator_keyframe_edit def:title|set_duration_prep
        #Move to a new keyframe
        after player clicks dcutscene_title_move_to_keyframe in dcutscene_inventory_keyframe_modify_title:
        - run dcutscene_animator_keyframe_edit def:title|move_to_prep
        #Duplicate
        after player clicks dcutscene_title_duplicate in dcutscene_inventory_keyframe_modify_title:
        - run dcutscene_animator_keyframe_edit def:title|duplicate_prep
        #Remove title
        after player clicks dcutscene_title_remove_modify in dcutscene_inventory_keyframe_modify_title:
        - run dcutscene_animator_keyframe_edit def:title|remove_title
        ## Command ####
        #Add new command
        after player clicks dcutscene_play_command in dcutscene_inventory_keyframe_modify:
        - run dcutscene_animator_keyframe_edit def:command|new_command_prep
        #Change command
        after player clicks dcutscene_command_modify in dcutscene_inventory_keyframe_modify_command:
        - run dcutscene_animator_keyframe_edit def:command|change_command_prep
        #Change execute_as
        after player clicks dcutscene_command_execute_as_modify in dcutscene_inventory_keyframe_modify_command:
        - run dcutscene_animator_keyframe_edit def:command|change_execute_as|<context.slot>
        #Change silent command
        after player clicks dcutscene_command_silent_modify in dcutscene_inventory_keyframe_modify_command:
        - run dcutscene_animator_keyframe_edit def:command|change_silent|<context.slot>
        #Move to new keyframe
        after player clicks dcutscene_command_move_to_keyframe in dcutscene_inventory_keyframe_modify_command:
        - run dcutscene_animator_keyframe_edit def:command|move_to_prep
        #Duplicate
        after player clicks dcutscene_command_duplicate in dcutscene_inventory_keyframe_modify_command:
        - run dcutscene_animator_keyframe_edit def:command|duplicate_prep
        #Remove command
        after player clicks dcutscene_command_remove_modify in dcutscene_inventory_keyframe_modify_command:
        - run dcutscene_animator_keyframe_edit def:command|remove_command
        ## Message ####
        #New message
        after player clicks dcutscene_add_msg in dcutscene_inventory_keyframe_modify:
        - run dcutscene_animator_keyframe_edit def:message|new_message_prep
        #Change message
        after player clicks dcutscene_message_modify in dcutscene_inventory_keyframe_modify_message:
        - run dcutscene_animator_keyframe_edit def:message|change_message_prep
        #Move to a keyframe
        after player clicks dcutscene_message_move_to_keyframe in dcutscene_inventory_keyframe_modify_message:
        - run dcutscene_animator_keyframe_edit def:message|move_to_prep
        #Duplicate
        after player clicks dcutscene_message_duplicate in dcutscene_inventory_keyframe_modify_message:
        - run dcutscene_animator_keyframe_edit def:message|duplicate_prep
        #Remove message
        after player clicks dcutscene_message_remove_modify in dcutscene_inventory_keyframe_modify_message:
        - run dcutscene_animator_keyframe_edit def:message|remove_message
        ## Time ####
        #Add time
        after player clicks dcutscene_send_time in dcutscene_inventory_keyframe_modify:
        - run dcutscene_animator_keyframe_edit def:time|new_time_prep
        #Set time
        after player clicks dcutscene_time_modify in dcutscene_inventory_keyframe_modify_time:
        - run dcutscene_animator_keyframe_edit def:time|change_time_prep
        #Set duration
        after player clicks dcutscene_time_duration_modify in dcutscene_inventory_keyframe_modify_time:
        - run dcutscene_animator_keyframe_edit def:time|change_time_duration_prep
        #Change time freeze
        after player clicks dcutscene_time_freeze_modify in dcutscene_inventory_keyframe_modify_time:
        - run dcutscene_animator_keyframe_edit def:time|change_time_freeze|<context.slot>
        #Change time reset
        after player clicks dcutscene_time_reset_modify in dcutscene_inventory_keyframe_modify_time:
        - run dcutscene_animator_keyframe_edit def:time|change_time_reset|<context.slot>
        #Move to a keyframe
        after player clicks dcutscene_time_move_to_keyframe in dcutscene_inventory_keyframe_modify_time:
        - run dcutscene_animator_keyframe_edit def:time|move_to_prep
        #Duplicate
        after player clicks dcutscene_time_duplicate in dcutscene_inventory_keyframe_modify_time:
        - run dcutscene_animator_keyframe_edit def:time|duplicate_prep
        #Remove time
        after player clicks dcutscene_time_remove_modify in dcutscene_inventory_keyframe_modify_time:
        - run dcutscene_animator_keyframe_edit def:time|remove_time
        ## Weather ####
        #Add weather
        after player clicks dcutscene_set_weather in dcutscene_inventory_keyframe_modify:
        - run dcutscene_animator_keyframe_edit def:weather|new_weather
        #Set weather
        after player clicks dcutscene_weather_modify in dcutscene_inventory_keyframe_modify_weather:
        - run dcutscene_animator_keyframe_edit def:weather|change_weather|<context.slot>
        #Set weather duration
        after player clicks dcutscene_weather_duration_modify in dcutscene_inventory_keyframe_modify_weather:
        - run dcutscene_animator_keyframe_edit def:weather|change_weather_duration_prep
        #Move to a keyframe
        after player clicks dcutscene_weather_move_to_keyframe in dcutscene_inventory_keyframe_modify_weather:
        - run dcutscene_animator_keyframe_edit def:weather|move_to_prep
        #Duplicate
        after player clicks dcutscene_weather_duplicate in dcutscene_inventory_keyframe_modify_weather:
        - run dcutscene_animator_keyframe_edit def:weather|duplicate_prep
        #Remove weather
        after player clicks dcutscene_weather_remove_modify in dcutscene_inventory_keyframe_modify_weather:
        - run dcutscene_animator_keyframe_edit def:weather|remove_weather
        ## Stop Point #####
        #Add new stop point
        after player clicks dcutscene_stop_scene in dcutscene_inventory_keyframe_modify:
        - run dcutscene_stop_scene_keyframe def:new
        #Remove stop point
        after player clicks dcutscene_stop_point_remove_modify in dcutscene_inventory_keyframe_modify_stop_point:
        - run dcutscene_stop_scene_keyframe def:remove
        ##Next and Previous Buttons ###
        after player clicks dcutscene_next in dcutscene_inventory_keyframe:
        - ~run dcutscene_keyframe_modify def:next
        after player clicks dcutscene_previous in dcutscene_inventory_keyframe:
        - ~run dcutscene_keyframe_modify def:previous
        ###############################
        ##Back page functions ##########
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
        after player clicks dcutscene_back_page in dcutscene_inventory_keyframe_model_list:
        - inventory open d:dcutscene_inventory_keyframe_modify
        after player clicks dcutscene_back_page in dcutscene_inventory_keyframe_ray_trace_player_model:
        - inventory open d:dcutscene_inventory_keyframe_modify_player_model
        after player clicks dcutscene_back_page in dcutscene_inventory_fake_object_block_modify:
        - inventory open d:dcutscene_inventory_sub_keyframe
        - ~run dcutscene_sub_keyframe_modify def:<player.flag[dcutscene_sub_keyframe_back_data]>
        after player clicks dcutscene_back_page in dcutscene_inventory_keyframe_modify_stop_point:
        - inventory open d:dcutscene_inventory_sub_keyframe
        - ~run dcutscene_sub_keyframe_modify def:<player.flag[dcutscene_sub_keyframe_back_data]>
        after player clicks dcutscene_back_page in dcutscene_inventory_fake_object_schem_modify:
        - inventory open d:dcutscene_inventory_sub_keyframe
        - ~run dcutscene_sub_keyframe_modify def:<player.flag[dcutscene_sub_keyframe_back_data]>
        after player clicks dcutscene_back_page in dcutscene_inventory_particle_modify:
        - inventory open d:dcutscene_inventory_sub_keyframe
        - ~run dcutscene_sub_keyframe_modify def:<player.flag[dcutscene_sub_keyframe_back_data]>
        after player clicks dcutscene_back_page in dcutscene_inventory_keyframe_modify_title:
        - inventory open d:dcutscene_inventory_sub_keyframe
        - ~run dcutscene_sub_keyframe_modify def:<player.flag[dcutscene_sub_keyframe_back_data]>
        after player clicks dcutscene_back_page in dcutscene_inventory_keyframe_modify_command:
        - inventory open d:dcutscene_inventory_sub_keyframe
        - ~run dcutscene_sub_keyframe_modify def:<player.flag[dcutscene_sub_keyframe_back_data]>
        after player clicks dcutscene_back_page in dcutscene_inventory_keyframe_modify_message:
        - inventory open d:dcutscene_inventory_sub_keyframe
        - ~run dcutscene_sub_keyframe_modify def:<player.flag[dcutscene_sub_keyframe_back_data]>
        after player clicks dcutscene_back_page in dcutscene_inventory_keyframe_modify_time:
        - inventory open d:dcutscene_inventory_sub_keyframe
        - ~run dcutscene_sub_keyframe_modify def:<player.flag[dcutscene_sub_keyframe_back_data]>
        after player clicks dcutscene_back_page in dcutscene_inventory_keyframe_modify_weather:
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
    debug: false
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
      #Stop Search
      - define stop_search <[keyframes.stop.tick]||none>
      - if <[stop_search].equals[<[tick]>]>:
        - define tick_map.stop_point.tick <[tick]>
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
      #Fake Block Search
      - define fake_block_search <[keyframes.elements.fake_object.fake_block.<[tick]>.fake_blocks]||null>
      - if <[fake_block_search]> != null:
        - define tick_map.fake_blocks.<[tick]> <[fake_block_search]>
      #Fake Schem Search
      - define fake_schem_search <[keyframes.elements.fake_object.fake_schem.<[tick]>.fake_schems]||null>
      - if <[fake_schem_search]> != null:
        - define tick_map.fake_schems.<[tick]> <[fake_schem_search]>
      #Particle Search
      - define particle_search <[keyframes.elements.particle.<[tick]>.particle_list]||null>
      - if <[particle_search]> != null:
        - define tick_map.particle.<[tick]> <[particle_search]>
      #Title Search
      - define title_search <[keyframes.elements.title.<[tick]>]||null>
      - if <[title_search]> != null:
        - define tick_map.title.<[tick]> <[title_search]>
      #Command Search
      - define command_search <[keyframes.elements.command.<[tick]>.command_list]||null>
      - if <[command_search]> != null:
        - define tick_map.command.<[tick]> <[command_search]>
      #Message Search
      - define message_search <[keyframes.elements.message.<[tick]>.message_list]||null>
      - if <[message_search]> != null:
        - define tick_map.message.<[tick]> <[message_search]>
      #Time Search
      - define time_search <[keyframes.elements.time.<[tick]>]||null>
      - if <[time_search]> != null:
        - define tick_map.time.<[tick]> <[time_search]>
      #Weather Search
      - define weather_search <[keyframes.elements.weather.<[tick]>]||null>
      - if <[weather_search]> != null:
        - define tick_map.weather.<[tick]> <[weather_search]>
    - if !<[tick_map].is_empty>:
      - determine <[tick_map]>
    - else:
      - determine null

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
    #0.45 = 9 ticks for 9 slots per row
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
    - define inc 0.45
    #constant increment
    - define new_inc <[inc].mul[45].mul[<[page_index].sub[1]>]>
    - repeat <[max]> as:loop_i:
        - define lore_list:!
        - define stop_point null
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
        - define keyframe_data <[data.name].proc[dcutscene_keyframe_calculate].context[<[timespot]>]>
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
          #Fake Blocks
          - define fake_blocks <[keyframe_data.fake_blocks]||null>
          - if <[fake_blocks]> != null:
            - foreach <[fake_blocks]> key:tick as:object_ids:
              - foreach <[object_ids]> as:object_uuid:
                - define fake_block <[keyframes.elements.fake_object.fake_block.<[tick]>.<[object_uuid]>]||null>
                - if <[fake_block]> != null:
                  - define block <material[<[fake_block.block]>].name>
                  - define text "<aqua>Fake block <green><[block]> <aqua>on tick <green><[tick]>t"
                  - define lore_list:->:<[text]>
          #Fake Schems
          - define fake_schems <[keyframe_data.fake_schems]||null>
          - if <[fake_schems]> != null:
            - foreach <[fake_schems]> key:tick as:object_ids:
              - foreach <[object_ids]> as:object_uuid:
                - define fake_schem <[keyframes.elements.fake_object.fake_schem.<[tick]>.<[object_uuid]>]||null>
                - if <[fake_schem]> != null:
                  - define schem_name <[fake_schem.schem]>
                  - define text "<aqua>Fake schem <green><[schem_name]> <aqua>on tick <green><[tick]>t"
                  - define lore_list:->:<[text]>
          #Particle
          - define particles <[keyframe_data.particle]||null>
          - if <[particles]> != null:
            - foreach <[particles]> key:tick as:particle_ids:
              - foreach <[particle_ids]> as:particle_uuid:
                - define particle_data <[keyframes.elements.particle.<[tick]>.<[particle_uuid]>]||null>
                - if <[particle_data]> != null:
                  - define text "<aqua>Particle <green><[particle_data.particle]> <aqua>on tick <green><[tick]>t"
                  - define lore_list:->:<[text]>
          #Title
          - define title <[keyframe_data.title]||null>
          - if <[title]> != null:
            - foreach <[title]> key:tick as:title:
              - define text "<aqua>Title <white><[title.title].parse_color> <aqua>on tick <green><[tick]>t"
              - define lore_list:->:<[text]>
          #Command
          - define command <[keyframe_data.command]||null>
          - if <[command]> != null:
            - foreach <[command]> key:tick as:command_ids:
              - foreach <[command_ids]> as:command_uuid:
                - define command_data <[keyframes.elements.command.<[tick]>.<[command_uuid]>]||null>
                - if <[command_data]> != null:
                  - define text "<aqua>Command on tick <green><[tick]>t"
                  - define lore_list:->:<[text]>
          #Message
          - define message <[keyframe_data.message]||null>
          - if <[message]> != null:
            - foreach <[message]> key:tick as:message_ids:
              - foreach <[message_ids]> as:message_uuid:
                - define msg_data <[keyframes.elements.message.<[tick]>.<[message_uuid]>]||null>
                - if <[msg_data]> != null:
                  - define text "<aqua>Message on tick <green><[tick]>t"
                  - define lore_list:->:<[text]>
          #Time
          - define time <[keyframe_data.time]||null>
          - if <[time]> != null:
            - foreach <[time]> key:tick as:time:
              - define text "<aqua>Time <green><duration[<[time.time]>].in_ticks>t <aqua>on tick <green><[tick]>t"
              - define lore_list:->:<[text]>
          #Weather
          - define weather <[keyframe_data.weather]||null>
          - if <[weather]> != null:
            - foreach <[weather]> key:tick as:weather:
              - define text "<aqua>Weather <green><[weather.weather]> <aqua>on tick <green><[tick]>t"
              - define lore_list:->:<[text]>
          #Stop Point
          - define stop_point <[keyframe_data.stop_point]||null>
          - if <[stop_point]> != null:
            - define stop_tick <[stop_point.tick]>
            - define text "<red>Stop point on tick <green><[stop_tick]>t"
            - define lore_list:->:<[text]>
          #If lore list exceeds lore limit
          - define max_lore_size <script[dcutscenes_config].data_key[config].get[cutscene_main_keyframe_lore_limit]||15>
          - define lore_list <[lore_list]||<list>>
          - if <[lore_list].size> > <[max_lore_size]>:
            - define lore_list <[lore_list].get[1].to[<[max_lore_size]>]>
            - define lore_list:->:<gray>...
        #######################################
        ## Setting information on items #######
        - if <[lore_list]> != null && <[stop_point]> == null:
          - define item <item[dcutscene_keyframe_contains]>
        - else if <[stop_point]> != null:
          - define item <item[dcutscene_keyframe_stop_point]>
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

#Sub keyframe list
dcutscene_sub_keyframe_modify:
    type: task
    debug: false
    definitions: keyframe
    script:
    #Data for returning to previous page
    - flag <player> dcutscene_sub_keyframe_back_data:<[keyframe]>
    - define data <player.flag[cutscene_data]>
    - define scene_name <[data.name]>
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
        #=========== Camera check (First Priority)============
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
            - define cam_interp "<aqua>Path Interpolation: <gray><[cam_data.interpolation].to_uppercase>"
            - define cam_rotate "<aqua>Rotate Multiplier: <gray><[cam_data.rotate_mul]||1.0>"
            - define cam_interp_look "<aqua>Interpolate Look: <gray><[cam_data.interpolate_look]||true>"
            - define cam_move "<aqua>Move: <gray><[cam_data.move]||true>"
            - define cam_invert "<aqua>Invert Look: <gray><[cam_data.invert]||false>"
            - if <[cam_data.recording.bool]> != false:
              - define cam_recording "<aqua>Recording: <gray>true"
            - else:
              - define cam_recording "<aqua>Recording: <gray>false"
            - define cam_tick "<aqua>Time: <gray><[cam_data.tick]||<[tick]>>t"
            - define modify "<gray><italic>Click to modify camera"
            - define cam_lore <list[<empty>|<[cam_loc]>|<[cam_look]>|<[cam_interp]>|<[cam_rotate]>|<[cam_interp_look]>|<[cam_move]>|<[cam_invert]>|<[cam_recording]>|<[cam_tick]>|<empty>|<[modify]>]>
            - adjust <[cam_item]> lore:<[cam_lore]> save:item
            - define cam_item <entry[item].result>
            - define display <dark_gray><bold>Camera
            - adjust <[cam_item]> display:<[display]> save:item
            - define cam_item <entry[item].result>
            #Data to pass through for use of modifying the camera
            - definemap modify_data type:camera tick:<[tick]> data:<[cam_data]>
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
          - define model_list <[model_data.model_list]||<list>>
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
                  #If the model has a root model show the starting point
                  - if <[data.root]||none> != none:
                    - define root_tick <[data.root.tick]>
                    - define root_uuid <[data.root.uuid]>
                    #Lore information
                    - define start_tick <[models.<[root_tick]>.<[root_uuid]>.path].keys.first||null>
                    - define lore_data <[models.<[root_tick]>.<[root_uuid]>.path.<[tick]>]>
                    - define anim_lore "<aqua>Animation: <gray><[lore_data.animation]>"
                    - define loc_lore "<aqua>Location: <gray><[lore_data.location].simple>"
                    - define path_interp_lore "<aqua>Path Interpolation: <gray><[lore_data.interpolation]>"
                    - define rotate_interp "<aqua>Rotate Interpolation: <gray><[lore_data.rotate_interp]>"
                    - define rotate_mul "<aqua>Rotate Multiplier: <gray><[lore_data.rotate_mul]||1.0>"
                    - define ray_dir "<aqua>Ray Trace Direction: <gray><[lore_data.ray_trace.direction]>"
                    - define move_lore "<aqua>Move: <gray><[lore_data.move]>"
                    - define skin <proc[dcutscene_determine_player_model_skin].context[<[scene_name]>|<[tick]>|<[model_uuid]>]||none>
                    - if <[skin]> == none || <[skin]> == player:
                      - define skin <player>
                    #If the starting point keyframe has a skin update the ones without a skin
                    - adjust <[opt_item]> skull_skin:<[skin].parsed.skull_skin||<player.skull_skin>> save:item
                    - define opt_item <entry[item].result>
                    - define skin_lore "<aqua>Skin: <gray><[skin].parsed.name||<[skin].name>>"
                    - if <[start_tick]> == null:
                      - define start_lore <empty>
                      - define m_lore <list[<empty>|<[pmodel_id]>|<[time_lore]>|<[anim_lore]>|<[skin_lore]>|<[loc_lore]>|<[path_interp_lore]>|<[rotate_interp]>|<[rotate_mul]>|<[ray_dir]>|<[move_lore]>|<empty>|<[modify]>]>
                    - else:
                      - define start_lore "<aqua>Starting Frame: <gray><[start_tick]>t"
                      - define m_lore <list[<empty>|<[pmodel_id]>|<[time_lore]>|<[anim_lore]>|<[skin_lore]>|<[loc_lore]>|<[path_interp_lore]>|<[rotate_interp]>|<[rotate_mul]>|<[ray_dir]>|<[move_lore]>|<[start_lore]>|<empty>|<[modify]>]>

                  #If the model is a root data model
                  - else:
                    #Lore information
                    - define lore_data <[models.<[tick]>.<[model_uuid]>.path.<[tick]>]>
                    - define anim_lore "<aqua>Animation: <gray><[lore_data.animation]>"
                    - define loc_lore "<aqua>Location: <gray><[lore_data.location].simple>"
                    - define path_interp_lore "<aqua>Path Interpolation: <gray><[lore_data.interpolation]>"
                    - define rotate_interp "<aqua>Rotate Interpolation: <gray><[lore_data.rotate_interp]>"
                    - define rotate_mul "<aqua>Rotate Multiplier: <gray><[lore_data.rotate_mul]||1.0>"
                    - define ray_dir "<aqua>Ray Trace Direction: <gray><[lore_data.ray_trace.direction]>"
                    - define move_lore "<aqua>Move: <gray><[lore_data.move]>"
                    - define skin <proc[dcutscene_determine_player_model_skin].context[<[scene_name]>|<[tick]>|<[model_uuid]>]||none>
                    - if <[skin]> == none || <[skin]> == player:
                      - define skin <player>
                    - adjust <[opt_item]> skull_skin:<[skin].parsed.skull_skin||<player.skull_skin>> save:item
                    - define opt_item <entry[item].result>
                    - define skin_lore "<aqua>Skin: <gray><[skin].parsed.name||<[skin].name>>"
                    - define m_lore <list[<empty>|<[pmodel_id]>|<[time_lore]>|<[anim_lore]>|<[skin_lore]>|<[loc_lore]>|<[path_interp_lore]>|<[rotate_interp]>|<[rotate_mul]>|<[ray_dir]>|<[move_lore]>|<empty>|<[modify]>]>
                  - adjust <[opt_item]> lore:<[m_lore]> save:item
                  - define opt_item <entry[item].result>
                  #Data to pass through for use of modifying the modifier
                  - definemap modify_data type:player_model tick:<[tick]> data:<[data]> uuid:<[model_uuid]>
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
          - define run_task_list <[elements.run_task.<[tick]>.run_task_list]||<list>>
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
              #Data to pass through for use of modifying the animator
              - definemap modify_data type:run_task tick:<[tick]> data:<[data]> uuid:<[task_id]>
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

        #========== Fake Objects =========
        #==== Fake Schematic ====
        - define fake_schem_check <[elements.fake_object.fake_schem.<[tick]>]||null>
        - if <[fake_schem_check]> != null:
          - define tick_column_check true
          - define opt_item <item[dcutscene_fake_schem_keyframe]>
          - define fake_schems_list <[elements.fake_object.fake_schem.<[tick]>.fake_schems]||<list>>
          - foreach <[fake_schems_list]> as:object_id:
            - define tick_index <[tick_index].add[1]>
            - define tick_row:++
            - if <[tick_row]> > 4:
              - define tick_row:1
            - if <[tick_index]> > <[tick_page]>:
              - define obj_data <[elements.fake_object.fake_schem.<[tick]>.<[object_id]>]>
              - define l1 "<aqua>Name: <gray><[obj_data.schem]>"
              - define l2 "<aqua>Location: <gray><[obj_data.loc].simple>"
              - define l3 "<aqua>Duration: <gray><duration[<[obj_data.duration]>].formatted>"
              - define l4 "<aqua>Noair: <gray><[obj_data.noair]>"
              - define l5 "<aqua>Waitable: <gray><[obj_data.waitable]>"
              - define l6 "<aqua>Direction: <gray><[obj_data.angle]>"
              - define modify "<gray><italic>Click to modify fake schematic"
              - define schem_lore <list[<empty>|<[l1]>|<[l2]>|<[l3]>|<[l4]>|<[l5]>|<[l6]>|<empty>|<[modify]>]>
              - adjust <[opt_item]> lore:<[schem_lore]> save:item
              - define opt_item <entry[item].result>
              #Data to pass through for use of modifying the animator
              - definemap modify_data type:fake_schem tick:<[tick]> data:<[obj_data]> uuid:<[object_id]>
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

        #==== Fake Block ====
        - define fake_block_check <[elements.fake_object.fake_block.<[tick]>]||null>
        - if <[fake_block_check]> != null:
          - define tick_column_check true
          - define opt_item <item[dcutscene_fake_block_keyframe]>
          - define fake_blocks_list <[elements.fake_object.fake_block.<[tick]>.fake_blocks]||<list>>
          - foreach <[fake_blocks_list]> as:object_id:
            - define tick_index <[tick_index].add[1]>
            - define tick_row:++
            - if <[tick_row]> > 4:
              - define tick_row:1
            - if <[tick_index]> > <[tick_page]>:
              - define obj_data <[elements.fake_object.fake_block.<[tick]>.<[object_id]>]>
              - define modify "<gray><italic>Click to modify fake block"
              - define block_mat <[obj_data.block]>
              - define block_mat_lore "<aqua>Material: <gray><[block_mat].name>"
              - adjust <[opt_item]> material:<material[<[block_mat]>]> save:item
              - define opt_item <entry[item].result>
              - define block_proc "<aqua>Procedure: <gray><[obj_data.procedure.script]||none>"
              - define block_proc_defs "<aqua>Procedure Definition: <gray><[obj_data.procedure.defs]||none>"
              - define block_loc "<aqua>Location: <gray><[obj_data.loc].simple>"
              - define block_time "<aqua>Duration: <gray><duration[<[obj_data.duration]>].formatted>"
              - define fake_obj_lore <list[<empty>|<[block_mat_lore]>|<[block_loc]>|<[block_time]>|<[block_proc]>|<[block_proc_defs]>|<empty>|<[modify]>]>
              - adjust <[opt_item]> lore:<[fake_obj_lore]> save:item
              - define opt_item <entry[item].result>
              #Data to pass through for use of modifying the animator
              - definemap modify_data type:fake_block tick:<[tick]> data:<[obj_data]> uuid:<[object_id]>
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

        #========= Particle ===========
        - define particle <[elements.particle.<[tick]>]||null>
        - if <[particle]> != null:
          - define tick_column_check true
          - define opt_item <item[dcutscene_particle_keyframe]>
          - define particle_list <[elements.particle.<[tick]>.particle_list]||<list>>
          - foreach <[particle_list]> as:particle_id:
            - define tick_index <[tick_index].add[1]>
            - define tick_row:++
            - if <[tick_row]> > 4:
              - define tick_row:1
            - if <[tick_index]> > <[tick_page]>:
              - define p_data <[elements.particle.<[tick]>.<[particle_id]>]>
              - define modify "<gray><italic>Click to modify particle"
              - define l1 "<aqua>Particle: <gray><[p_data.particle]>"
              - define l2 "<aqua>Location: <gray><[p_data.loc].simple>"
              - define l3 "<aqua>Quantity: <gray><[p_data.quantity]>"
              - define l4 "<aqua>Range: <gray><[p_data.range]>"
              - define l5 "<aqua>Repeat: <gray><[p_data.repeat]>"
              - define l6 "<aqua>Repeat Interval: <gray><duration[<[p_data.repeat_interval]>].formatted||0>"
              - define l7 "<aqua>Offset: <gray><[p_data.offset]>"
              - define l8 "<aqua>Procedure: <gray><[p_data.procedure.script]>"
              - define l9 "<aqua>Procedure Definition: <gray><[p_data.procedure.defs]>"
              - define l10 "<aqua>Special Data: <gray><[p_data.special_data]>"
              - define l11 "<aqua>Velocity: <gray><[p_data.velocity]>"
              - define lore <list[<empty>|<[l1]>|<[l2]>|<[l3]>|<[l4]>|<[l5]>|<[l6]>|<[l7]>|<[l8]>|<[l9]>|<[l10]>|<[l11]>|<empty>|<[modify]>]>
              - adjust <[opt_item]> lore:<[lore]> save:item
              - define opt_item <entry[item].result>
              #Data to pass through for use of modifying the animator
              - definemap modify_data type:particle tick:<[tick]> data:<[p_data]> uuid:<[particle_id]>
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
            #Data to pass through for use of modifying the animator
            - definemap modify_data type:screeneffect tick:<[tick]> data:<[screeneffect]>
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
          - define sound_list <[elements.sound.<[tick]>.sounds]||<list>>
          #Gather data from sound list
          - foreach <[sound_list]> as:sound_id:
            - define tick_index <[tick_index].add[1]>
            - define tick_row:++
            - if <[tick_row]> > 4:
              - define tick_row:1
            - if <[tick_index]> > <[tick_page]>:
              - define sound_data <[elements.sound.<[tick]>.<[sound_id]>]>
              - define sound_name "<aqua>Sound: <gray><[sound_data.sound]>"
              - define sound_loc "<aqua>Location: <gray><[sound_data.location].simple||false>"
              - define sound_vol "<aqua>Volume: <gray><[sound_data.volume]>"
              - define sound_pitch "<aqua>Pitch: <gray><[sound_data.pitch]>"
              - define sound_custom "<aqua>Custom: <gray><[sound_data.custom]>"
              - define sound_time "<aqua>Time: <gray><[tick]>t"
              - define modify "<gray><italic>Click to modify sound"
              - define sound_lore <list[<empty>|<[sound_name]>|<[sound_loc]>|<[sound_vol]>|<[sound_pitch]>|<[sound_custom]>|<[sound_time]>|<empty>|<[modify]>]>
              - adjust <[opt_item]> lore:<[sound_lore]> save:item
              - define opt_item <entry[item].result>
              #Data to pass through for use of modifying the animator
              - definemap modify_data type:sound tick:<[tick]> data:<[sound_data]> uuid:<[sound_id]>
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

        #======== Title ==========
        - define title <[elements.title.<[tick]>]||null>
        - if <[title]> != null:
          - define tick_column_check true
          - define opt_item <item[dcutscene_title_keyframe]>
          - define tick_index <[tick_index].add[1]>
          - define tick_row:++
          #Only 4 rows
          - if <[tick_row]> > 4:
            - define tick_row:1
          - if <[tick_index]> > <[tick_page]>:
            - define l1 "<aqua>Title: <white><[title.title].parse_color>"
            - define l2 "<aqua>Subtitle: <white><[title.subtitle].parse_color>"
            - define l3 "<aqua>Fade in: <gray><[title.fade_in].in_seconds||0>s"
            - define l4 "<aqua>Stay: <gray><[title.stay].in_seconds||0>s"
            - define l5 "<aqua>Fade out: <gray><[title.fade_out].in_seconds||0>s"
            - define modify "<gray><italic>Click to modify title"
            - define title_lore <list[<empty>|<[l1]>|<[l2]>|<[l3]>|<[l4]>|<[l5]>|<empty>|<[modify]>]>
            - adjust <[opt_item]> lore:<[title_lore]> save:item
            - define opt_item <entry[item].result>
            #Data to pass through for use of modifying the animator
            - definemap modify_data type:title tick:<[tick]> data:<[title]>
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

        #========= Command ===========
        - define command <[elements.command.<[tick]>]||null>
        - if <[command]> != null:
          - define tick_column_check true
          #Option Item
          - define opt_item <item[dcutscene_command_keyframe]>
          - define command_list <[elements.command.<[tick]>.command_list]||<list>>
          - foreach <[command_list]> as:command_id:
            - define tick_index <[tick_index].add[1]>
            - define tick_row:++
            - if <[tick_row]> > 4:
              - define tick_row:1
            - if <[tick_index]> > <[tick_page]>:
              - define cmd_data <[elements.command.<[tick]>.<[command_id]>]>
              - define l1 "<aqua>Command: <gray><[cmd_data.command]>"
              - define l2 "<aqua>Execute as: <gray><[cmd_data.execute_as]>"
              - define l3 "<aqua>Silent <gray><[cmd_data.silent]>"
              - define modify "<gray><italic>Click to modify command"
              - define command_lore <list[<empty>|<[l1]>|<[l2]>|<[l3]>|<empty>|<[modify]>]>
              - adjust <[opt_item]> lore:<[command_lore]> save:item
              - define opt_item <entry[item].result>
              #Data to pass through for use of modifying the animator
              - definemap modify_data type:command tick:<[tick]> data:<[cmd_data]> uuid:<[command_id]>
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

        #======== Message =========
        - define message <[elements.message.<[tick]>]||null>
        - if <[message]> != null:
          - define tick_column_check true
          #Option Item
          - define opt_item <item[dcutscene_message_keyframe]>
          - define message_list <[elements.message.<[tick]>.message_list]||<list>>
          - foreach <[message_list]> as:msg_id:
            - define tick_index <[tick_index].add[1]>
            - define tick_row:++
            - if <[tick_row]> > 4:
              - define tick_row:1
            - if <[tick_index]> > <[tick_page]>:
              - define msg_data <[elements.message.<[tick]>.<[msg_id]>]>
              - define l1 "<aqua>Message: <white><[msg_data.message].parse_color>"
              - define modify "<gray><italic>Click to modify message"
              - define msg_lore <list[<empty>|<[l1]>|<empty>|<[modify]>]>
              - adjust <[opt_item]> lore:<[msg_lore]> save:item
              - define opt_item <entry[item].result>
              #Data to pass through for use of modifying the animator
              - definemap modify_data type:message tick:<[tick]> data:<[msg_data]> uuid:<[msg_id]>
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

        #======= Time =========
        - define time_anim <[elements.time.<[tick]>]||null>
        - if <[time_anim]> != null:
          - define tick_column_check true
          #Option Item
          - define opt_item <item[dcutscene_time_keyframe]>
          - define tick_index <[tick_index].add[1]>
          - define tick_row:++
          #Only 4 rows
          - if <[tick_row]> > 4:
            - define tick_row:1
          - if <[tick_index]> > <[tick_page]>:
            - define l1 "<aqua>Time: <gray><duration[<[time_anim.time]>].in_ticks>t"
            - define l2 "<aqua>Duration: <gray><duration[<[time_anim.duration]>].formatted>"
            - define l3 "<aqua>Freeze: <gray><[time_anim.freeze]>"
            - define l4 "<aqua>Reset: <gray><[time_anim.reset]>"
            - define modify "<gray><italic>Click to modify time"
            - define time_lore <list[<empty>|<[l1]>|<[l2]>|<[l3]>|<[l4]>|<empty>|<[modify]>]>
            - adjust <[opt_item]> lore:<[time_lore]> save:item
            - define opt_item <entry[item].result>
            #Data to pass through for use of modifying the animator
            - definemap modify_data type:time tick:<[tick]> data:<[time]>
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

        #======= Weather ========
        - define weather <[elements.weather.<[tick]>]||null>
        - if <[weather]> != null:
          - define tick_column_check true
          #Option Item
          - define opt_item <item[dcutscene_weather_keyframe]>
          - define tick_index <[tick_index].add[1]>
          - define tick_row:++
          #Only 4 rows
          - if <[tick_row]> > 4:
            - define tick_row:1
          - if <[tick_index]> > <[tick_page]>:
            - define l1 "<aqua>Weather: <gray><[weather.weather]>"
            - define l2 "<aqua>Duration: <gray><duration[<[weather.duration]>].formatted>"
            - define modify "<gray><italic>Click to modify weather"
            - define time_lore <list[<empty>|<[l1]>|<[l2]>|<empty>|<[modify]>]>
            - adjust <[opt_item]> lore:<[time_lore]> save:item
            - define opt_item <entry[item].result>
            #Data to pass through for use of modifying the animator
            - definemap modify_data type:weather tick:<[tick]> data:<[time]>
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

        #======== Stop Point =========
        - define stop_point <[keyframes.stop.tick]||none>
        - if <[stop_point].equals[<[tick]>]>:
          - define tick_column_check true
          - define opt_item <item[dcutscene_stop_scene_keyframe_item]>
          - define tick_index <[tick_index].add[1]>
          - define tick_row:++
          #Only 4 rows
          - if <[tick_row]> > 4:
            - define tick_row:1
          - if <[tick_index]> > <[tick_page]>:
            - define l_1 "<gray>The cutscene will stop here."
            - define modify "<gray><italic>Click to modify stop point"
            - define stop_lore <list[<empty>|<[l_1]>|<empty>|<[modify]>]>
            - adjust <[opt_item]> lore:<[stop_lore]> save:item
            - define opt_item <entry[item].result>
            #Data to pass through for use of modifying the animator
            - definemap modify_data type:stop_point tick:<[tick]> data:<[keyframes.stop]>
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
        - flag <[item]> keyframe_tick:<[tick]>
        - define display "<aqua><bold>Tick <gray><bold><[tick]>t"
        - adjust <[item]> display:<[display]> save:item
        - define item <entry[item].result>
        - define t_lore "<blue><bold>Main Keyframe Time <gray><bold><duration[<[time]>].formatted>"
        - define s_lore "<green><bold>Tick to seconds <gray><bold><duration[<[tick]>t].in_seconds.round_down_to_precision[0.05]>s"
        #If player is moving or duplicating an animator modify the lore
        - if <player.has_flag[dcutscene_animator_change]>:
          - flag <[item]> change_animator
          - define data <player.flag[dcutscene_animator_change]>
          - choose <[data.type]>:
            - case move:
              - define modify "<gray><italic>Click to move <green><[data.animator].replace[_].with[ ]> <gray><italic>from tick <green><[data.tick]>t <gray><italic>here"
            - case duplicate:
              - define modify "<gray><italic>Click to duplicate <green><[data.animator].replace[_].with[ ]> <gray><italic>from tick <green><[data.tick]>t <gray><italic>here"
          - define lore <list[<[t_lore]>|<[s_lore]>|<empty>|<[modify]>]>
        - else:
          - define lore <list[<[t_lore]>|<[s_lore]>]>
        - adjust <[item]> lore:<[lore]> save:item
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

dcutscene_inventory_settings:
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
    - [] [] [] [] [dcutscene_delete_cutscene] [] [] [] [dcutscene_exit]

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
    - [] [] [dcutscene_add_cam] [dcutscene_add_sound] [dcutscene_add_model] [dcutscene_add_player_model] [dcutscene_add_entity] [] []
    - [] [] [dcutscene_add_run_task] [dcutscene_add_fake_block] [dcutscene_add_fake_schem] [dcutscene_add_screeneffect] [dcutscene_add_particle] [] []
    - [] [] [dcutscene_send_title] [dcutscene_play_command] [dcutscene_add_msg] [dcutscene_send_time] [dcutscene_set_weather] [] []
    - [] [] [dcutscene_stop_scene] [] [] [] [] [] []
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
    - [] [] [dcutscene_camera_loc_modify] [dcutscene_camera_look_modify] [dcutscene_camera_move_modify] [dcutscene_camera_rotate_modify] [dcutscene_camera_interpolate_look] [] []
    - [] [] [dcutscene_camera_upside_down] [dcutscene_camera_interp_modify] [dcutscene_camera_record_player] [dcutscene_camera_path_show] [dcutscene_camera_move_to_keyframe] [] []
    - [] [] [dcutscene_camera_duplicate_to_keyframe] [dcutscene_camera_teleport] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [dcutscene_back_page] [] [] [] [dcutscene_camera_remove_modify] [] [] [] [dcutscene_exit]

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
    - [] [] [] [dcutscene_location_tool_ray_trace_item] [] [dcutscene_location_tool_item] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [dcutscene_location_tool_confirm_location] [] [] [] [dcutscene_exit]

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
    - [] [] [dcutscene_player_model_change_id] [dcutscene_player_model_change_location] [dcutscene_player_model_ray_trace_change] [dcutscene_player_model_change_move] [dcutscene_player_model_change_animation] [] []
    - [] [] [dcutscene_player_model_change_skin] [dcutscene_player_model_interp_method] [dcutscene_player_model_show_path] [dcutscene_player_model_interp_rotate_change] [dcutscene_player_model_interp_rotate_mul] [] []
    - [] [] [dcutscene_player_model_move_to_keyframe] [dcutscene_player_model_duplicate] [dcutscene_player_model_teleport_loc] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [dcutscene_back_page] [] [] [dcutscene_remove_player_model_tick] [] [dcutscene_remove_player_model] [] [] [dcutscene_exit]

#Ray Trace modification for the player model.
dcutscene_inventory_keyframe_ray_trace_player_model:
    type: inventory
    inventory: CHEST
    title: <&color[<script[dcutscenes_config].data_key[config].get[cutscene_title_color]>]><script[dcutscenes_config].data_key[config].get[cutscene_title]>
    size: 54
    gui: true
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [dcutscene_player_model_ray_trace_determine] [dcutscene_player_model_ray_trace_liquid] [dcutscene_player_model_ray_trace_passable] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [dcutscene_back_page] [] [] [] [] [] [] [] [dcutscene_exit]

#Particle modify GUI
dcutscene_inventory_particle_modify:
    type: inventory
    inventory: CHEST
    title: <&color[<script[dcutscenes_config].data_key[config].get[cutscene_title_color]>]><script[dcutscenes_config].data_key[config].get[cutscene_title]>
    size: 54
    gui: true
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [dcutscene_particle_modify] [dcutscene_particle_loc_modify] [dcutscene_particle_quantity_modify] [dcutscene_particle_range_modify] [dcutscene_particle_repeat_modify] [] []
    - [] [] [dcutscene_particle_repeat_interval_modify] [dcutscene_particle_offset_modify] [dcutscene_particle_procedure_modify] [dcutscene_particle_procedure_defs_modify] [dcutscene_particle_special_data_modify] [] []
    - [] [] [dcutscene_particle_velocity_modify] [dcutscene_particle_move_to_keyframe] [dcutscene_particle_duplicate] [dcutscene_particle_teleport_to] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [dcutscene_back_page] [] [] [] [dcutscene_particle_remove] [] [] [] [dcutscene_exit]

#Fake block modify GUI
dcutscene_inventory_fake_object_block_modify:
    type: inventory
    inventory: CHEST
    title: <&color[<script[dcutscenes_config].data_key[config].get[cutscene_title_color]>]><script[dcutscenes_config].data_key[config].get[cutscene_title]>
    size: 54
    gui: true
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [dcutscene_fake_object_block_loc_change] [dcutscene_fake_object_block_material_change] [dcutscene_fake_object_block_duration_change] [] [] []
    - [] [] [] [dcutscene_fake_object_block_proc_change] [dcutscene_fake_object_block_proc_def_change] [dcutscene_fake_object_block_teleport] [] [] []
    - [] [] [] [dcutscene_fake_block_move_to_keyframe] [dcutscene_fake_block_duplicate] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [dcutscene_back_page] [] [] [] [dcutscene_fake_object_block_remove] [] [] [] [dcutscene_exit]

#Fake schem modify GUI
dcutscene_inventory_fake_object_schem_modify:
    type: inventory
    inventory: CHEST
    title: <&color[<script[dcutscenes_config].data_key[config].get[cutscene_title_color]>]><script[dcutscenes_config].data_key[config].get[cutscene_title]>
    size: 54
    gui: true
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [dcutscene_fake_object_schem_name_change] [dcutscene_fake_object_schem_loc_change] [dcutscene_fake_object_schem_duration_change] [] [] []
    - [] [] [] [dcutscene_fake_object_schem_noair_change] [dcutscene_fake_object_schem_waitable_change] [dcutscene_fake_object_schem_angle_change] [] [] []
    - [] [] [] [dcutscene_fake_schem_move_to] [dcutscene_fake_schem_duplicate] [dcutscene_fake_object_schem_teleport] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [dcutscene_back_page] [] [] [] [dcutscene_fake_object_schem_remove] [] [] [] [dcutscene_exit]

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
    - [] [] [] [dcutscene_run_task_delay_modify] [dcutscene_run_task_move_to_keyframe] [dcutscene_run_task_duplicate] [] [] []
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
    - [] [] [] [dcutscene_sound_move_to_keyframe] [dcutscene_sound_duplicate] [] [] [] []
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
    - [] [] [] [dcutscene_screeneffect_time_modify] [dcutscene_screeneffect_color_modify] [dcutscene_screeneffect_move_to_keyframe] [] [] []
    - [] [] [] [dcutscene_screeneffect_duplicate] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [dcutscene_back_page] [] [] [] [dcutscene_screeneffect_remove_modify] [] [] [] [dcutscene_exit]

#Title GUI
dcutscene_inventory_keyframe_modify_title:
    type: inventory
    inventory: CHEST
    title: <&color[<script[dcutscenes_config].data_key[config].get[cutscene_title_color]>]><script[dcutscenes_config].data_key[config].get[cutscene_title]>
    size: 54
    gui: true
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [dcutscene_title_title_modify] [dcutscene_title_subtitle_modify] [dcutscene_title_duration_modify] [] [] []
    - [] [] [] [dcutscene_title_move_to_keyframe] [dcutscene_title_duplicate] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [dcutscene_back_page] [] [] [] [dcutscene_title_remove_modify] [] [] [] [dcutscene_exit]

#Play command GUI
dcutscene_inventory_keyframe_modify_command:
    type: inventory
    inventory: CHEST
    title: <&color[<script[dcutscenes_config].data_key[config].get[cutscene_title_color]>]><script[dcutscenes_config].data_key[config].get[cutscene_title]>
    size: 54
    gui: true
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [dcutscene_command_modify] [dcutscene_command_execute_as_modify] [dcutscene_command_silent_modify] [] [] []
    - [] [] [] [dcutscene_command_move_to_keyframe] [dcutscene_command_duplicate] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [dcutscene_back_page] [] [] [] [dcutscene_command_remove_modify] [] [] [] [dcutscene_exit]

#Send message GUI
dcutscene_inventory_keyframe_modify_message:
    type: inventory
    inventory: CHEST
    title: <&color[<script[dcutscenes_config].data_key[config].get[cutscene_title_color]>]><script[dcutscenes_config].data_key[config].get[cutscene_title]>
    size: 54
    gui: true
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [dcutscene_message_modify] [dcutscene_message_move_to_keyframe] [dcutscene_message_duplicate] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [dcutscene_back_page] [] [] [] [dcutscene_message_remove_modify] [] [] [] [dcutscene_exit]

#Time GUI
dcutscene_inventory_keyframe_modify_time:
    type: inventory
    inventory: CHEST
    title: <&color[<script[dcutscenes_config].data_key[config].get[cutscene_title_color]>]><script[dcutscenes_config].data_key[config].get[cutscene_title]>
    size: 54
    gui: true
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [dcutscene_time_modify] [dcutscene_time_duration_modify] [dcutscene_time_freeze_modify] [] [] []
    - [] [] [] [dcutscene_time_reset_modify] [dcutscene_time_move_to_keyframe] [dcutscene_time_duplicate] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [dcutscene_back_page] [] [] [] [dcutscene_time_remove_modify] [] [] [] [dcutscene_exit]

#Weather GUI
dcutscene_inventory_keyframe_modify_weather:
    type: inventory
    inventory: CHEST
    title: <&color[<script[dcutscenes_config].data_key[config].get[cutscene_title_color]>]><script[dcutscenes_config].data_key[config].get[cutscene_title]>
    size: 54
    gui: true
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [dcutscene_weather_modify] [dcutscene_weather_duration_modify] [dcutscene_weather_move_to_keyframe] [] [] []
    - [] [] [] [dcutscene_weather_duplicate] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [dcutscene_back_page] [] [] [] [dcutscene_weather_remove_modify] [] [] [] [dcutscene_exit]

#Stop point GUI
dcutscene_inventory_keyframe_modify_stop_point:
    type: inventory
    inventory: CHEST
    title: <&color[<script[dcutscenes_config].data_key[config].get[cutscene_title_color]>]><script[dcutscenes_config].data_key[config].get[cutscene_title]>
    size: 54
    gui: true
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [dcutscene_stop_point_remove_modify] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [dcutscene_back_page] [] [] [] [] [] [] [] [dcutscene_exit]
####################################################
