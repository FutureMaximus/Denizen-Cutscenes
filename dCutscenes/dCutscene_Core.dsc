#Denizen Cutscenes tasks
#This is required for DCutscenes to function.

##Core Tasks for DCutscenes ###################################################

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
        - ratelimit <player> 5s
        - define cutscene <player.flag[cutscene_data]>
        - ~run dcutscene_save_file def:<[cutscene]>
        - define text "Cutscene <green><[cutscene.name]> <gray>has been saved to <green>Denizen/data/dcutscenes/scenes<gray>."
        - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
        ########################
        ##Misc #################################################
        after player clicks dcutscene_exit in inventory:
        - inventory close
        #input for dcutscene gui elements
        ##Chat Input ################
        on player chats flagged:cutscene_modify:
        - define msg <context.message>
        - if <[msg]> == cancel:
          - flag <player> cutscene_modify:!
          - determine passively cancelled
          - stop
        - choose <player.flag[cutscene_modify]>:
          - case new_name:
            - run dcutscene_new_scene def:name|<[msg]>
          - case name:
            - define name
          - case desc:
            - define desc
          - case create_cam:
            - if <[msg]> == confirm:
              - run dcutscene_cam_keyframe_edit def:create
          - case create_present_cam:
            - if <[msg]> == confirm:
              - run dcutscene_cam_keyframe_edit def:edit|create_new_location
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
          - ~run dcutscene_sub_keyframe_modify def:<[i].flag[keyframe_data]>
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
            - case camera:
              - flag <player> dcutscene_tick_modify:<[i].flag[keyframe_opt_modify.tick]>
              - inventory open d:dcutscene_inventory_keyframe_modify_camera
              - ~run dcutscene_cam_keyframe_edit def:edit|<[i].flag[keyframe_opt_modify]>
        #####################################
        ##Option GUI events ###########
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
        after player clicks dcutscene_camera_interp_modify in dcutscene_inventory_keyframe_modify_camera:
        - ratelimit <player> 0.5s
        - run dcutscene_cam_keyframe_edit def:edit|interpolation_change|<context.item>|<context.slot>
        #######################
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
        - ~run dcutscene_sub_keyframe_modify def:<player.flag[dcutscene_sub_keyframe_back_data]>
        after player clicks dcutscene_back_page in dcutscene_inventory_keyframe_modify:
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
    script:
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
      - define data <server.flag[dcutscenes.<[cutscene]>]>
      - define name <[data.name]>
      - define keyframes <[data.keyframes]>
      #Camera Sort
      - define ticks <list>
      - define keyframes.camera <[keyframes.camera]||null>
      - if <[keyframes.camera]> != null:
        - define keyframes.camera <[keyframes.camera].sort_by_value[get[tick]]>
        - define highest <[keyframes.camera].keys.highest>
        - define ticks:->:<[highest]>
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
          #Camera sort
          - define ticks <list>
          - define keyframes.camera <[keyframes.camera]||null>
          - if <[keyframes.camera]> != null:
            - define keyframes.camera <[keyframes.camera].sort_by_value[get[tick]]>
            - define highest <[keyframes.camera].keys.highest>
            - define ticks:->:<[highest]>
          #Total cutscene length
          - if !<[ticks].is_empty>:
            - define animation_length <duration[<[ticks].highest>t].in_seconds>s
            - define data.length <[animation_length]>
            - flag server dcutscenes.<[c_id]>.length:<[data.length]>
          - flag server dcutscenes.<[c_id]>.keyframes:<[keyframes]>
      - else:
        - debug error "DCutscenes There are no cutscenes to sort!"
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
        - define search <server.flag[dcutscenes]>
        - define search <[search.<[arg]>]||null>
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
    #slots in inventory
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
          - define camera <[keyframe_data.camera]||null>
          - foreach <[camera]> key:id as:camera:
            - define text "<aqua>Camera on tick <green><[id]> <aqua>at location <green><[camera.location].simple>"
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
        - define elements "<blue><bold>Elements:"
        - if <[lore_list]> != null:
          - adjust <[item]> lore:<list[<empty>|<[elements]>|<[lore_list]>|<[click]>].combine> save:item
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
      - define cam_search <[keyframes.camera.<[tick]>]||null>
      - if <[cam_search]> != null:
        - define tick_map.camera.<[tick]> <[cam_search]>
    - if !<[tick_map].is_empty>:
      - determine <[tick_map]>
    - else:
      - determine null

#TODO:
# - Implement up and down listing for tick
#Sub keyframe list
dcutscene_sub_keyframe_modify:
    type: task
    debug: false
    definitions: keyframe
    script:
    - flag <player> dcutscene_sub_keyframe_back_data:<[keyframe]>
    - define data <player.flag[cutscene_data]>
    - define keyframes <[data.keyframes]>
    - define keyframes.camera <[keyframes.camera]||null>
    - inventory open d:dcutscene_inventory_sub_keyframe
    - define inv <player.open_inventory>
    - define time <[keyframe.timespot]>
    - define tick_max <duration[<[time]>s].in_ticks>
    - define tick_min <[tick_max].sub[9]>
    - repeat 9 as:loop_i:
        - define cam_lore:!
        - define item <item[dcutscene_sub_keyframe]>
        - define tick <[tick_min].add[<[loop_i]>]>
        ##camera check ############
        - if <[keyframes.camera]> != null && <[keyframes.camera].contains[<[tick]>]>:
          - define opt_item <item[dcutscene_camera_keyframe]>
          - define cam_data <[keyframes.camera.<[tick]>]>
          - define cam_loc "<aqua>Location: <gray><location[<[cam_data.location]>].simple>"
          - define cam_look "<aqua>Look Location: <gray><location[<[cam_data.eye_loc]>].simple>"
          - define cam_interp "<aqua>Interpolation: <gray><[cam_data.interpolation].to_uppercase>"
          - define cam_rotate "<aqua>Rotate: <gray><[cam_data.rotate]||false>"
          - define cam_move "<aqua>Move: <gray><[cam_data.move]||true>"
          - define cam_tick "<aqua>Time: <gray><[cam_data.tick]||<[tick]>>t"
          - define modify "<gray><italic>Click to modify camera"
          - define cam_lore <list[<empty>|<[cam_loc]>|<[cam_look]>|<[cam_interp]>|<[cam_rotate]>|<[cam_move]>|<[cam_tick]>|<empty>|<[modify]>]>
          - adjust <[opt_item]> lore:<[cam_lore]> save:item
          - define opt_item <entry[item].result>
          - define display <dark_gray><bold>Camera
          - adjust <[opt_item]> display:<[display]> save:item
          - define opt_item <entry[item].result>
          #Data to pass through for use of modifying the camera
          - define modify_data.type camera
          - define modify_data.tick <[tick]>
          - define modify_data.data <[cam_data]>
          - flag <[opt_item]> keyframe_opt_modify:<[modify_data]>
          - inventory set d:<[inv]> o:<[opt_item]> slot:<[loop_i].add[9]>
        ##default #####################
        - else:
          - define opt_item <item[dcutscene_keyframe_tick_add]>
          - flag <[opt_item]> keyframe_modify:<[tick]>
          - inventory set d:<[inv]> o:<[opt_item]> slot:<[loop_i].add[9]>
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
    debug: true
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
          - define cam_keyframe.tick <[tick]>
          - look <[camera]> <[ray]> duration:2t
          - adjust <[camera]> armor_pose:[head=<player.location.pitch.to_radians>,0.0,0.0]
          - define text "Camera location set to <green><player.location.simple> <gray>and look point <green><[ray].simple><gray> <gray>for keyframe tick <green><[tick]>t<gray>."
          - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
          - define data <player.flag[cutscene_data]>
          - define name <[data.name]>
          - define data.keyframes.camera.<[tick]>:<[cam_keyframe]>
          - flag server dcutscenes.<[name]>:<[data]>
          #Sort the newly created data
          - ~run dcutscene_sort_data def:<[name]>
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
              #create the new location in a present camera keyframe
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
                - define text "Camera location set to <green><player.location.simple> <gray>and look point <green><[ray].simple><gray> <gray>for keyframe tick <green><[tick]>t<gray>."
                - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
                - inventory open d:dcutscene_inventory_keyframe_modify_camera
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
        - if <[camera]> != null:
          - if <player.has_flag[dcutscene_camera]>:
            - remove <player.flag[dcutscene_camera]>
            - flag <player> dcutscene_camera:!
          - if <player.has_flag[dcutscene_bars]>:
            - run dcutscene_bars_remove
          - run dcutscene_bars
          - cast INVISIBILITY d:100000000000s hide_particles no_ambient no_icon
          - define uuid <util.random_uuid>
          - spawn dcutscene_camera_entity <player.location> save:<[uuid]>
          - define camera_ent <entry[<[uuid]>].spawned_entity>
          - define m_uuid <util.random_uuid>
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
              - if <[cam_data]> != null && <[cam_count]> < 1:
                - define cam_count:++
                - ~run dcutscene_path_move def:<[cutscene.name]>|<[camera_ent]>|camera
            - else:
              - stop
            - wait 1t
        - else:
          - debug error "Cutscene <[cutscene]> does not have a camera!"
    - else:
      - debug error "Cutscene could not be found."

#Path movement for camera and models
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
      - foreach <[keyframes]> key:c_id as:keyframe:
        - define interpolation <[keyframe.interpolation]>
        - define time_1 <[keyframe.tick]>
        - define loc_1 <location[<[keyframe.location]>]||null>
        - define rotate <[keyframe.rotate]>
        - define eye_loc <[keyframe.eye_loc]>
        - if <[loc_1]> == null:
          - foreach next
        #after
        - foreach <[keyframes]> key:2_id as:2_keyframe:
          - define compare <[2_keyframe.tick].is_more_than[<[time_1]>]>
          - if <[compare].equals[true]>:
            - define time_2 <[2_keyframe.tick]>
            - define loc_2 <location[<[2_keyframe.location]>]||null>
            - foreach stop
        - define loc_2 <[loc_2]||null>
        - if <[loc_2]> == null:
          - foreach next
        - define time <[time_2].sub[<[time_1]>]>
        - choose <[interpolation]>:
          - case linear:
            - repeat <[time]>:
              - if <[entity].is_spawned>:
                - define time_index <[value]>
                - if <[time_index]> < <[time]>:
                  - define time_percent <[time_index].div[<[time]>]>
                  #Lerp calc
                  - define data <[loc_2].as_location.sub[<[loc_1]>].mul[<[time_percent]>].add[<[loc_1]>]>
                - else:
                  - define data <[loc_2].as_location>
                - if <[rotate].equals[false]>:
                  - look <[entity]> <[data]> duration:1t
                  - teleport <[entity]> <[data].with_yaw[<[eye_loc].yaw>].with_pitch[<[eye_loc].pitch>]>
                  - teleport <[mount]> <[data].with_yaw[<[eye_loc].yaw>].with_pitch[<[eye_loc].pitch>].below[2]>
              - else:
                - stop
              - wait 1t
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
                - else:
                  - define data <[loc_2_after].as_location>
                - if <[rotate].equals[false]>:
                  - look <[entity]> <[data]> duration:1t
                  - teleport <[entity]> <[data].with_yaw[<[eye_loc].yaw>].with_pitch[<[eye_loc].pitch>]>
                  - teleport <[mount]> <[data].with_yaw[<[eye_loc].yaw>].with_pitch[<[eye_loc].pitch>].below[2]>
              - else:
                - stop
              - wait 1t
          - default:
            - foreach next
      - run dcutscene_animation_stop

#Stops the animation from processing further
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
dcutscene_path_show:
    type: task
    debug: false
    definitions: cutscene
    script:
    - define data <server.flag[dcutscenes.<[cutscene]>]||null>
    - if <[data]> != null:
      - define keyframes <[data.keyframes.camera]>
      - define dist <script[dcutscenes_config].data_key[config].get[cutscene_path_distance]>
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
            - define path <proc[dcutscene_path_creator].context[<[loc_1]>|<[loc_2]>|linear|<[time]>]>
            - if <[path]> != null:
              - foreach <[path]> as:point:
                #for some optimization it should only play when the player is facing the location and is within range
                - if <player.location.facing[<[point]>].degrees[60]> && <player.location.distance[<[point]>]> <= <[dist].mul[2.5]>:
                  - define p_2 <[path].get[<[loop_index].add[1]>]||<[point]>>
                  - define p_loc <location[<[point]>].points_between[<[p_2]>].distance[1]>
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
            - define path <proc[dcutscene_path_creator].context[<[loc_1]>|<[loc_2]>|smooth|<[time]>|<[loc_1_prev]>|<[loc_2_after]>]||null>
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
    definitions: loc_1|loc_2|type|time|loc_1_prev|loc_2_after
    script:
    - define time <[time]||null>
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
    - [] [] [dcutscene_play_command] [dcutscene_send_time] [] [] [] [] []
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
    - [] [] [] [dcutscene_camera_loc_modify] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [dcutscene_camera_teleport] [] [dcutscene_camera_interp_modify] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [dcutscene_back_page] [] [] [] [dcutscene_camera_remove_modify] [] [] [] [dcutscene_exit]
####################################################

##################################################################################
