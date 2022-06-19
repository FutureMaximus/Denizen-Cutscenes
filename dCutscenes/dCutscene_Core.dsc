#Denizen Cutscenes tasks
#This is required for DCutscenes to function.
##Core Tasks for DCutscenes

#TODO:
# - Implement back page data function in one task

##Cutscene Events#######
dcutscene_events:
    type: world
    debug: true
    events:
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
        ##Option GUI ###########
        #Add a new camera
        after player clicks dcutscene_add_cam in dcutscene_inventory_keyframe_modify:
        - run dcutscene_cam_keyframe_edit def:new
        #New location
        after player clicks dcutscene_camera_loc_modify in dcutscene_inventory_keyframe_modify_camera:
        - run dcutscene_cam_keyframe_edit def:edit|new_location
        #Remove camera
        after player clicks dcutscene_camera_remove_modify in dcutscene_inventory_keyframe_modify_camera:
        - run dcutscene_cam_keyframe_edit def:edit|remove_camera
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
        after player clicks dcutscene_keyframes_list in dcutscene_inventory_scene:
        - ~run dcutscene_keyframe_modify
########################

##Core Tasks#######################################

## Procedures ########
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

## File Operations #########
#Saving cutscenes to a directory
dcutscene_save_file:
    type: task
    debug: false
    definitions: cutscene
    script:
    - define cutscene <[cutscene]||null>
    - define data <server.flag[dcutscenes]>
    - define space " "
    - if <[cutscene]> == null:
      - foreach <[data]> key:c_id as:cutscene:
        - ~filewrite path:data/dcutscenes/scenes/<[c_id]>.dcutscene.json data:<[cutscene].to_json[native_types=true;indent=4].utf8_encode>
    - else:
      - define cutscene <[data.<[cutscene]>]||null>
      - if !<[cutscene].equals[null]>:
        - define c_id <[cutscene.name]>
        - ~filewrite path:data/dcutscenes/scenes/<[c_id]>.dcutscene.json data:<[cutscene].to_json[native_types=true;indent=4].utf8_encode>
      - else:
        - debug error "DCutscenes Invalid cutscene did you type the name correctly?"

#Loading cutscene files in a directory to be usable in other servers
dcutscene_load_files:
    type: task
    debug: false
    script:
    - define files <server.list_files[data/dcutscenes/scenes]||null>
    - if <[files]> != null:
      - foreach <[files]> as:file:
        - ~yaml id:file_<[file]> load:data/dcutscenes/scenes/<[file]>
        - define name <yaml[file_<[file]>].read[name]||null>
        - if <[name]> == null:
          - foreach next
        - define cutscene.name <[name]>
        - define cutscene.name_color <yaml[file_<[file]>].read[name_color]||<empty>>
        - define cutscene.description <yaml[file_<[file]>].read[description]||<empty>>
        - define cutscene.world <yaml[file_<[file]>].read[world]||<empty>>
        - define cutscene.item <yaml[file_<[file]>].read[item]||<empty>>
        - define cutscene.length <yaml[file_<[file]>].read[length]||<empty>>
        - define cutscene.keyframes <yaml[file_<[file]>].read[keyframes]||<empty>>
        - flag server dcutscenes.<[name]>:<[cutscene]>
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

#TODO:
# - Ensure keyframe lore data doesn't show the entire thing if it reaches the limit on lore
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
        - if <[keyframes.camera].contains[<[tick]>]>:
          - define opt_item <item[dcutscene_camera_keyframe]>
          - define cam_data <[keyframes.camera.<[tick]>]>
          - define cam_loc "<aqua>Location: <gray><location[<[cam_data.location]>].simple>"
          - define cam_look "<aqua>Look Location: <gray><location[<[cam_data.eye_loc]>].simple>"
          - define cam_interp "<aqua>Interpolation: <gray><[cam_data.interpolation].to_uppercase>"
          - define cam_rotate "<aqua>Rotate: <gray><[cam_data.rotate]>"
          - define cam_move "<aqua>Move: <gray><[cam_data.move]>"
          - define modify "<gray><italic>Click to modify camera"
          - define cam_lore <list[<empty>|<[cam_loc]>|<[cam_look]>|<[cam_interp]>|<[cam_rotate]>|<[cam_move]>|<empty>|<[modify]>]>
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
    definitions: option|arg
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
          - define cam_keyframe.eye_loc <[ray]>
          - define cam_keyframe.location <player.location>
          - define cam_keyframe.interpolation linear
          - define cam_keyframe.rotate true
          - define cam_keyframe.move true
          - look <[camera]> <[ray]> duration:2t
          - adjust <[camera]> armor_pose:[head=<player.location.pitch.to_radians>,0.0,0.0]
          - define tick <player.flag[dcutscene_tick_modify]>
          - define text "Camera location set to <green><player.location.simple> <gray>and look point <green><[ray].simple><gray> <gray>for keyframe tick <green><[tick]>t<gray>."
          - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
          - adjust <player> spectate:<[camera]>
          - define data <player.flag[cutscene_data]>
          - define name <[data.name]>
          - define data.keyframes.camera.<[tick]>:<[cam_keyframe]>
          - flag server dcutscenes.<[name]>:<[data]>
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
                - define cam_keyframe.eye_loc <[ray]>
                - define cam_keyframe.location <player.location>
                #fallback should they not exist
                - define cam_keyframe.interpolation <[cam_keyframe.interpolation]||linear>
                - define cam_keyframe.rotate <[cam_keyframe.rotate]||true>
                - define cam_keyframe.move <[cam_keyframe.move]||true>
                #final data input
                - define data <player.flag[cutscene_data]>
                - define name <[data.name]>
                - define data.keyframes.camera.<[tick]>:<[cam_keyframe]>
                - flag server dcutscenes.<[name]>:<[data]>
                - define text "Camera location set to <green><player.location.simple> <gray>and look point <green><[ray].simple><gray> <gray>for keyframe tick <green><[tick]>t<gray>."
                - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
                - inventory open d:dcutscene_inventory_keyframe_modify_camera
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
    - [dcutscene_back_page] [] [] [] [] [] [] [] [dcutscene_exit]

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
    - [] [] [] [] [] [] [] [] []
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
    - [] [] [] [dcutscene_camera_loc_modify] [] [dcutscene_camera_remove_modify] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [dcutscene_back_page] [] [] [] [] [] [] [] [dcutscene_exit]
####################################################

##################################################################################
