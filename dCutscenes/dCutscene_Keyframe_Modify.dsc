#################################################
#This script file modifies the animators in the cutscene and keyframes GUI.
#################################################

#=============Keyframe Modifiers ===============

#======== Location Tool =========
#A utility tool used for getting exact locations

dcutscene_location_tool_events:
    type: world
    debug: false
    events:
      on player places block flagged:dcutscene_location_editor:
      - determine cancelled
      on player breaks block flagged:dcutscene_location_editor:
      - determine cancelled
      after player clicks dcutscene_location_tool_item in dcutscene_inventory_location_tool:
      - run dcutscene_location_toolset_inv
      after player clicks dcutscene_location_tool_ray_trace_item in dcutscene_inventory_location_tool:
      - run dcutscene_location_raytrace_inv
      after player right clicks block with:dcutscene_loc_ray_trace:
      - ratelimit <player> 2t
      - if <player.has_flag[cutscene_modify]>:
        - run pmodels_end_animation def:<player.flag[dcutscene_location_editor.root_ent]>
        - run dcutscene_location_ray_trace_update
      after player right clicks entity with:dcutscene_loc_ray_trace:
      - ratelimit <player> 2t
      - if <player.has_flag[cutscene_modify]>:
        - run pmodels_end_animation def:<player.flag[dcutscene_location_editor.root_ent]>
        - run dcutscene_location_ray_trace_update
      after player right clicks block with:dcutscene_loc_ray_trace_dist_add:
      - run dcutscene_location_edit_ray_trace_add_dist
      after player right clicks entity with:dcutscene_loc_ray_trace_dist_add:
      - run dcutscene_location_edit_ray_trace_add_dist
      after player right clicks block with:dcutscene_loc_ray_trace_dist_sub:
      - run dcutscene_location_edit_ray_trace_sub_dist
      after player right clicks entity with:dcutscene_loc_ray_trace_dist_sub:
      - run dcutscene_location_edit_ray_trace_sub_dist
      after player right clicks block with:dcutscene_loc_ray_trace_reverse_model:
      - run dcutscene_location_edit_ray_trace_rotate_model
      after player right clicks entity with:dcutscene_loc_ray_trace_reverse_model:
      - run dcutscene_location_edit_ray_trace_rotate_model
      after player right clicks block with:dcutscene_loc_ray_trace_nonsolids:
      - run dcutscene_location_edit_ray_trace_nonsolids
      after player right clicks entity with:dcutscene_loc_ray_trace_nonsolids:
      - run dcutscene_location_edit_ray_trace_nonsolids
      after player right clicks block with:dcutscene_loc_ray_trace_water:
      - run dcutscene_location_edit_ray_trace_water
      after player right clicks entity with:dcutscene_loc_ray_trace_water:
      - run dcutscene_location_edit_ray_trace_water
      on player right clicks block with:dcutscene_loc_forward:
      - if <player.has_flag[cutscene_modify]>:
        - define offset <player.flag[dcutscene_location_editor.offset]||null>
        - if <[offset]> != null:
          - define offset_mul <player.flag[dcutscene_location_editor.offset_mul]||0>
          - define offset.z <[offset.z].add[1].mul[<[offset_mul]>]>
          - run dcutscene_location_button_change def:<[offset]>
      on player right clicks block with:dcutscene_loc_backward:
      - if <player.has_flag[cutscene_modify]>:
        - define offset <player.flag[dcutscene_location_editor.offset]||null>
        - if <[offset]> != null:
          - define offset_mul <player.flag[dcutscene_location_editor.offset_mul]||0>
          - define offset.z <[offset.z].add[1].mul[<[offset_mul]>]>
          - run dcutscene_location_button_change def:<[offset]>
      on player right clicks block with:dcutscene_loc_up:
      - if <player.has_flag[cutscene_modify]>:
        - define offset <player.flag[dcutscene_location_editor.offset]||null>
        - if <[offset]> != null:
          - define offset_mul <player.flag[dcutscene_location_editor.offset_mul]||0>
          - define offset.y <[offset.y].add[1].mul[<[offset_mul]>]>
          - run dcutscene_location_button_change def:<[offset]>
      on player right clicks block with:dcutscene_loc_down:
      - if <player.has_flag[cutscene_modify]>:
        - define offset <player.flag[dcutscene_location_editor.offset]||null>
        - if <[offset]> != null:
          - define offset_mul <player.flag[dcutscene_location_editor.offset_mul]||0>
          - define offset.y <[offset.y].sub[1].mul[<[offset_mul]>]>
          - run dcutscene_location_button_change def:<[offset]>
      on player right clicks block with:dcutscene_loc_right:
      - if <player.has_flag[cutscene_modify]>:
        - define offset <player.flag[dcutscene_location_editor.offset]||null>
        - if <[offset]> != null:
          - define offset_mul <player.flag[dcutscene_location_editor.offset_mul]||0>
          - define offset.x <[offset.x].sub[1].mul[<[offset_mul]>]>
          - run dcutscene_location_button_change def:<[offset]>
      on player right clicks block with:dcutscene_loc_left:
      - if <player.has_flag[cutscene_modify]>:
        - define offset <player.flag[dcutscene_location_editor.offset]||null>
        - if <[offset]> != null:
          - define offset_mul <player.flag[dcutscene_location_editor.offset_mul]||0>
          - define offset.x <[offset.x].add[1].mul[<[offset_mul]>]>
          - run dcutscene_location_button_change def:<[offset]>
      on player right clicks block with:dcutscene_loc_mul_add:
      - if <player.has_flag[cutscene_modify]>:
        - define data <player.flag[dcutscene_location_editor]||null>
        - if <[data]> != null:
          - define mul_inc <[data.offset_mul].add[0.5]>
          - if <[mul_inc]> < 10.0:
            - flag <player> dcutscene_location_editor.offset_mul:<[mul_inc]>
            - actionbar "<red><bold>Offset Multiplier + <[mul_inc]>"
          - else:
            - flag <player> dcutscene_location_editor.offset_mul:10.0
            - define mul_inc 10.0
            - actionbar "<red><bold>Offset Multiplier Maximum <[mul_inc]>"
      on player right clicks block with:dcutscene_loc_mul_sub:
      - if <player.has_flag[cutscene_modify]>:
        - define data <player.flag[dcutscene_location_editor]||null>
        - if <[data]> != null:
          - define mul_inc <[data.offset_mul].sub[0.5]>
          - if <[mul_inc]> >= 0:
            - flag <player> dcutscene_location_editor.offset_mul:<[mul_inc]>
            - actionbar "<blue><bold>Offset Multiplier - <[mul_inc]>"
          - else:
            - flag <player> dcutscene_location_editor.offset_mul:0.0
            - define mul_inc 0.0
            - actionbar "<blue><bold>Offset Multiplier Minimum <[mul_inc]>"
      on player right clicks block with:dcutscene_loc_use_yaw:
      - if <player.has_flag[cutscene_modify]>:
        - define data <player.flag[dcutscene_location_editor]||null>
        - if <[data]> != null:
          - define use_yaw <[data.use_yaw]>
          - choose <[use_yaw]>:
            - case true:
              - define use_yaw false
            - case false:
              - define use_yaw true
          - flag <player> dcutscene_location_editor.use_yaw:<[use_yaw]>
          - inventory set d:<player.inventory> o:dcutscene_loc_use_yaw slot:9

#Task for changing the location based on the location button tool
dcutscene_location_button_change:
    type: task
    debug: false
    definitions: offset
    script:
    - define data <player.flag[dcutscene_location_editor]||null>
    - define use_yaw <[data.use_yaw]>
    - if <[use_yaw].equals[false]>:
      - define loc <[data.location].with_pitch[0].relative[<[offset.x]>,<[offset.y]>,<[offset.z]>]>
    - else:
      - define loc <[data.location].with_yaw[<player.location.yaw>].with_pitch[0].relative[<[offset.x]>,<[offset.y]>,<[offset.z]>]>
    - define root <[data.root_ent]||null>
    - if <[root]> != null:
      - teleport <[root]> <[loc]>
      - run pmodels_reset_model_position def:<[root]>
    - flag <player> dcutscene_location_editor.location:<[loc]>

#Updates the ray tracer location tool
dcutscene_location_ray_trace_update:
    type: task
    debug: false
    script:
    - define data <player.flag[dcutscene_location_editor]||null>
    - if <[data]> != null:
      - define ray_trace_bool <[data.ray_trace_bool]>
      - choose <[ray_trace_bool]>:
        - case true:
          - define ray_trace_bool false
          - actionbar "<red><bold>Ray Trace Off"
        - case false:
          - define ray_trace_bool true
      - flag <player> dcutscene_location_editor.ray_trace_bool:<[ray_trace_bool]>
      - if <[ray_trace_bool].equals[true]>:
        - actionbar "<gold><bold>Ray Trace On"
        - while <player.flag[dcutscene_location_editor.ray_trace_bool].equals[true]>:
          - run dcutscene_location_edit_ray_trace def:<player.flag[dcutscene_location_editor.ray_trace_range]||5>
          - wait 1t

#Ray traces the location based on the player's cursor
dcutscene_location_edit_ray_trace:
    type: task
    debug: false
    definitions: max_range
    script:
    - define data <player.flag[dcutscene_location_editor]||null>
    - if <[data]> != null:
      - define nonsolid <[data.ray_trace_passable]>
      - define water <[data.ray_trace_water]>
      - define ray_trace <player.eye_location.ray_trace[range=<[max_range]>;default=air;fluids=<[water]>;nonsolids=<[nonsolid]>]||null>
      - if <[ray_trace]> != null:
        - define root <[data.root_ent]||null>
        - if <[root]> != null:
          #Rotate Model
          - choose <player.flag[dcutscene_location_editor.reverse_model]>:
            - case true:
              - define yaw <player.location.rotate_yaw[180].yaw>
            - case false:
              - define yaw <player.location.yaw>
          #TODO:
          #- Remove the previous player model by chunk loading the location and if it is spawned remove it
          #If model cannot be moved in certain conditions
          - if !<[root].is_spawned> || !<[root].location.chunk.is_loaded>:
            - choose <[data.root_type]>:
              - case player_model:
                - run pmodels_spawn_model def:<player.location>|<player>|<player> save:spawned
                - define root <entry[spawned].created_queue.determination.first>
                - flag <player> dcutscene_location_editor.root_ent:<[root]>
          - else if <[root].location.distance[<player.location>].horizontal||0> > <player.world.view_distance.mul[14]> || <[root].location.world> != <player.location.world>:
            - choose <[data.root_type]>:
              - case player_model:
                - run pmodels_spawn_model def:<player.location>|<player>|<player> save:spawned
                - define root <entry[spawned].created_queue.determination.first>
                - flag <player> dcutscene_location_editor.root_ent:<[root]>
          - teleport <[root]> <[ray_trace].with_yaw[<[yaw]>]>
          - run pmodels_reset_model_position def:<[root]>
        - if <[root]> == null:
          - flag <player> dcutscene_location_editor.location:<[ray_trace]>
        - else:
          - flag <player> dcutscene_location_editor.location:<[root].location>

#Increases the distance of the ray trace tool
dcutscene_location_edit_ray_trace_add_dist:
    type: task
    debug: false
    script:
    - if <player.has_flag[cutscene_modify]>:
      - define range <player.flag[dcutscene_location_editor.ray_trace_range]>
      - define config_range <script[dcutscenes_config].data_key[config].get[cutscene_loc_tool_ray_dist]||5>
      - if <[range]> < <[config_range]>:
        - define range <[range].add[0.2]>
        - flag <player> dcutscene_location_editor.ray_trace_range:<[range]>
      - else if <[range]> > <[config_range]>:
        - define range <[config_range]>
        - flag <player> dcutscene_location_editor.ray_trace_range:<[range]>
      - actionbar <red><bold><[range]>
      - run dcutscene_location_edit_ray_trace def:<[range]>

#Decreases the distance of the ray trace tool
dcutscene_location_edit_ray_trace_sub_dist:
    type: task
    debug: false
    script:
    - if <player.has_flag[cutscene_modify]>:
      - define range <player.flag[dcutscene_location_editor.ray_trace_range]>
      - if <[range]> > 0:
        - define range <[range].sub[0.2]>
        - flag <player> dcutscene_location_editor.ray_trace_range:<[range]>
      - else if <[range]> < 0:
        - define range 0.2
        - flag <player> dcutscene_location_editor.ray_trace_range:<[range]>
      - actionbar <blue><bold><[range]>
      - run dcutscene_location_edit_ray_trace def:<[range]>

#Determine if the ray trace tool will ignore passable blocks
dcutscene_location_edit_ray_trace_nonsolids:
    type: task
    debug: false
    script:
    - if <player.has_flag[cutscene_modify]>:
      - define data <player.flag[dcutscene_location_editor]||null>
      - if <[data]> != null:
        - choose <[data.ray_trace_passable]>:
          - case true:
            - define nonsolid false
          - case false:
            - define nonsolid true
        - flag <player> dcutscene_location_editor.ray_trace_passable:<[nonsolid]>
        - inventory set d:<player.inventory> o:dcutscene_loc_ray_trace_nonsolids slot:4

#Determine if the ray trace tool will ignore fluids
dcutscene_location_edit_ray_trace_water:
    type: task
    debug: false
    script:
    - if <player.has_flag[cutscene_modify]>:
      - define data <player.flag[dcutscene_location_editor]||null>
      - if <[data]> != null:
        - choose <[data.ray_trace_water]>:
          - case true:
            - define water false
          - case false:
            - define water true
        - flag <player> dcutscene_location_editor.ray_trace_water:<[water]>
        - inventory set d:<player.inventory> o:dcutscene_loc_ray_trace_water slot:5

#Rotates the model 180 degrees
dcutscene_location_edit_ray_trace_rotate_model:
    type: task
    debug: false
    script:
    - if <player.has_flag[cutscene_modify]>:
      - define data <player.flag[dcutscene_location_editor]||null>
      - if <[data]> != null:
        - define reverse_model <[data.reverse_model]>
        - choose <[reverse_model]>:
          - case true:
            - define reverse_model false
          - case false:
            - define reverse_model true
        - flag <player> dcutscene_location_editor.reverse_model:<[reverse_model]>
        - inventory set d:<player.inventory> o:dcutscene_loc_ray_trace_reverse_model slot:6

#Sets up the player with the data for the location tool
dcutscene_location_tool_give_data:
    type: task
    debug: false
    definitions: loc|root_ent|yaw|type
    script:
    - define loc <location[<[loc]>]||null>
    - if <[loc]> == null:
      - debug error "Must specify location for location tool"
      - stop
    - define root_ent <[root_ent]||null>
    - define type <[type]||null>
    - define offset.x 0.0
    - define offset.y 0.0
    - define offset.z 0.0
    - if <[yaw].exists>:
      - define yaw <[yaw]>
    - else:
      - define yaw 0
    - definemap editor_data offset:<[offset]> offset_mul:1 yaw:<[yaw]> location:<[loc]> use_yaw:true
    - define editor_data.ray_trace_range <script[dcutscenes_config].data_key[config].get[cutscene_loc_tool_ray_dist]||5>
    - define editor_data.ray_trace_bool false
    - define editor_data.ray_trace_solids false
    - define editor_data.ray_trace_passable false
    - define editor_data.ray_trace_water true
    - define editor_data.reverse_model false
    - flag <player> dcutscene_location_editor:<[editor_data]>
    - if <[root_ent]> != null:
      - flag <player> dcutscene_location_editor.root_ent:<[root_ent]>
    - if <[type]> != null:
      - flag <player> dcutscene_location_editor.root_type:<[type]>
    - flag <player> dcutscene_location_editor.inv:<player.inventory.map_slots>

#Location Button Tool Inventory
dcutscene_location_toolset_inv:
    type: task
    debug: false
    script:
    - define inv <player.inventory>
    - inventory set d:<[inv]> o:dcutscene_loc_forward slot:1
    - inventory set d:<[inv]> o:dcutscene_loc_backward slot:2
    - inventory set d:<[inv]> o:dcutscene_loc_up slot:3
    - inventory set d:<[inv]> o:dcutscene_loc_down slot:4
    - inventory set d:<[inv]> o:dcutscene_loc_left slot:5
    - inventory set d:<[inv]> o:dcutscene_loc_right slot:6
    - inventory set d:<[inv]> o:dcutscene_loc_mul_sub slot:7
    - inventory set d:<[inv]> o:dcutscene_loc_mul_add slot:8
    - inventory set d:<[inv]> o:dcutscene_loc_use_yaw slot:9
    - inventory close

#Ray Trace Tool Inventory
dcutscene_location_raytrace_inv:
    type: task
    debug: false
    script:
    - define inv <player.inventory>
    - inventory set d:<[inv]> o:dcutscene_loc_ray_trace slot:1
    - inventory set d:<[inv]> o:dcutscene_loc_ray_trace_dist_add slot:2
    - inventory set d:<[inv]> o:dcutscene_loc_ray_trace_dist_sub slot:3
    - inventory set d:<[inv]> o:dcutscene_loc_ray_trace_nonsolids slot:4
    - inventory set d:<[inv]> o:dcutscene_loc_ray_trace_water slot:5
    - inventory set d:<[inv]> o:dcutscene_loc_ray_trace_reverse_model slot:6
    - inventory close
    - adjust <player> item_slot:1
######################################

#========  Camera Modifier ===========
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
        #=========== New Camera ===========
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
          - define cam_keyframe.eye_loc.location <[ray]>
          - define cam_keyframe.eye_loc.boolean false
          - define cam_keyframe.location <player.location>
          - define cam_keyframe.rotate true
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
          - inventory open d:dcutscene_inventory_sub_keyframe
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
            - adjust <player> gamemode:creative

        #========= Edit the camera keyframe modifier =========
        - case edit:
          - if <[arg]> != null:
            - define inv <player.open_inventory>
            - define data <[arg]>
            - define modify_loc <item[dcutscene_camera_loc_modify]>
            - choose <[arg]>:
              #Preparation for new location in present camera keyframe
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
                - define cam_keyframe <[cam_keyframe].deep_with[eye_loc.location].as[<[ray]>]>
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

              #Prepare for new look location
              - case new_look_location:
                - flag <player> cutscene_modify:create_present_cam_look_loc expire:3m
                - define text "Available Inputs:"
                - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
                - narrate "<gray>Chat <green>confirm <gray>to input your location"
                - narrate "<gray>Chat a valid location tag"
                - narrate "<gray>Right click a block"
                - narrate "<gray>Chat <red>false <gray>to disable look location"
                - inventory close

              #Set new look location
              - case create_look_location:
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
                  - flag <player> cutscene_modify:!
                  - define tick <player.flag[dcutscene_tick_modify]>
                  - define data <player.flag[cutscene_data]>
                  - define keyframes <[data.keyframes]>
                  - define cam_keyframe <[keyframes.camera.<[tick]>]>
                  - if <[loc]> != false:
                    - define cam_keyframe.eye_loc.location <[loc]>
                    - define cam_keyframe.eye_loc.boolean true
                  - else:
                    - define cam_keyframe.eye_loc.boolean false
                  - flag server dcutscenes.<[data.name]>.keyframes.camera.<[tick]>:<[cam_keyframe]>
                  - flag <player> cutscene_data:<server.flag[dcutscenes.<[data.name]>]>
                  - define loc_msg <location[<[loc]>].simple.if_null[null]>
                  - if <[loc_msg]> == null:
                    - define loc_msg false
                  - define text "Camera on tick <green><[tick]>t <gray>look location is now <green><[loc_msg]> <gray>in scene <green><[data.name]><gray>."
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

              #Determine if the camera will interpolate the look rotation
              - case interpolate_look:
                - define arg_2 <[arg_2]||null>
                - define arg_3 <[arg_3]||null>
                - if <[arg_2]> != null:
                  - define item <item[<[arg_2]>]>
                  - define tick <player.flag[dcutscene_tick_modify]>
                  - define data <player.flag[cutscene_data]>
                  - define keyframes <[data.keyframes]>
                  - define cam_keyframe <[keyframes.camera.<[tick]>]>
                  - define interp_look <[cam_keyframe.interpolate_look]||true>
                  - choose <[interp_look]>:
                    - case true:
                      - define new_interp false
                    - case false:
                      - define new_interp true
                  - define cam_keyframe.interpolate_look <[new_interp]>
                  - flag server dcutscenes.<[data.name]>.keyframes.camera.<[tick]>:<[cam_keyframe]>
                  - flag <player> cutscene_data:<server.flag[dcutscenes.<[data.name]>]>
                  - define info_msg "<gray>Determine if the camera will interpolate to the next look point."
                  - define interp_msg "<green><bold>Interpolate Look: <gray><[new_interp]>"
                  - define click "<gray><italic>Click to modify look interpolation for camera"
                  - define lore <list[<empty>|<[info_msg]>|<empty>|<[interp_msg]>|<empty>|<[click]>]>
                  - inventory adjust d:<player.open_inventory> slot:<[arg_3]> lore:<[lore]>

              #Determine if camera will rotate and look
              - case rotate_change:
                - define arg_2 <[arg_2]||null>
                - define arg_3 <[arg_3]||null>
                - if <[arg_2]> != null:
                  - define item <item[<[arg_2]>]>
                  - define tick <player.flag[dcutscene_tick_modify]>
                  - define data <player.flag[cutscene_data]>
                  - define keyframes <[data.keyframes]>
                  - define cam_keyframe <[keyframes.camera.<[tick]>]>
                  - define rotate <[cam_keyframe.rotate]||true>
                  - choose <[rotate]>:
                    - case true:
                      - define new_rot false
                    - case false:
                      - define new_rot true
                  - define cam_keyframe.rotate <[new_rot]>
                  - flag server dcutscenes.<[data.name]>.keyframes.camera.<[tick]>:<[cam_keyframe]>
                  - flag <player> cutscene_data:<server.flag[dcutscenes.<[data.name]>]>
                  - define info_msg_1 "<gray>Determine if the camera will rotate and look"
                  - define info_msg_2 "<gray>at the next look point otherwise it will use"
                  - define info_msg_3 "<gray><gray>the previous pitch and yaw."
                  - define rot_msg "<dark_aqua><bold>Rotation: <gray><[new_rot]>"
                  - define click "<gray><italic>Click to change camera rotate"
                  - define lore <list[<empty>|<[info_msg_1]>|<[info_msg_2]>|<[info_msg_3]>|<empty>|<[rot_msg]>|<empty>|<[click]>]>
                  - inventory adjust d:<player.open_inventory> slot:<[arg_3]> lore:<[lore]>

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

#========== Models and Entity Modifiers ============

#Used to modify models or entities in keyframes
dcutscene_model_keyframe_edit:
    type: task
    debug: false
    definitions: option|arg|arg_2|arg_3
    script:
    - define option <[option]||null>
    - if <[option]> == null:
      - debug error "Something went wrong in dcutscene_model_keyframe_edit"
    - else:
      - define data <player.flag[cutscene_data]>
      - define tick <player.flag[dcutscene_tick_modify]>
      - choose <[option]>:
        #======== Denizen Player Models Modifier =========
        - case player_model:
          - define task_check <script[pmodels_spawn_model]||null>
          - if <[task_check]> != null:
            - choose <[arg]>:
              #New player model
              - case new:
                - define keyframes <[data.keyframes.models]>
                - define prev_models <list>
                #Look for previously made models
                - foreach <[keyframes]> key:time as:model:
                  - if <[time]> < <[tick]>:
                    - define model_data.tick <[time]>
                    - define model_data.data <[model]>
                    - define prev_models:->:<[model_data]>
                #If there are previously created models set them as data items in a GUI
                - if !<[prev_models].is_empty>:
                  - define skull_item <item[player_head]>
                  - adjust <[skull_item]> skull_skin:<player.skull_skin> save:item
                  - define skull_item <entry[item].result>
                  - flag <player> dcutscene_save_data.type:player_model
                  - inventory open d:dcutscene_inventory_keyframe_model_list
                  - define inv <player.open_inventory>
                  - foreach <[prev_models]> as:model:
                    - define model_list <[model.data.model_list]||null>
                    - if <[model_list].is_empty||null>:
                      - foreach next
                    - else:
                      - foreach <[model_list]> as:model_uuid:
                        - define model_data <[model.data.<[model_uuid]>]>
                        #Item set
                        - if <[model_data.type]> == player_model && <[model_data.root]||none> == none:
                          - define slot:++
                          - definemap item_data type:<[model_data.type]> tick:<[model.tick]> uuid:<[model_uuid]> id:<[model_data.id]>
                          - define item <item[<[skull_item]>]>
                          - define display <blue><bold><[model_data.id]>
                          - define l1 "<blue>Type: <gray>Player Model"
                          - define l2 "<blue>Starting Time <gray><[model.tick]>t"
                          - define l3 "<gray><italic>Click to modify player model"
                          - adjust <[item]> display:<[display]> save:item
                          - define item <entry[item].result>
                          - adjust <[item]> lore:<list[<empty>|<[l1]>|<[l2]>|<empty>|<[l3]>]> save:item
                          - define item <entry[item].result>
                          #Input the data so the player can modify this
                          - flag <[item]> model_keyframe_modify:<[item_data]>
                          - inventory set d:<[inv]> o:<[item]> slot:<[slot]>
                #No previous player models created before the time specified
                - else:
                  - flag <player> cutscene_modify:new_player_model_id expire:2m
                  - define text "Chat the name of the player model this will be used as an identifier."
                  - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
                  - inventory close

              #Create new player model
              - case create:
                - define arg_2 <[arg_2]||null>
                - define arg_3 <[arg_3]||null>
                #ID Set
                - if <[arg_2]> == id_set && <[arg_3]> != null:
                  #Check if model has already been set in tick
                  - define model_list <[data.keyframes.models.<[tick]>.model_list]>
                  - foreach <[model_list]> as:model_uuid:
                    - define model_id <[data.keyframes.models.<[tick]>.<[model_uuid]>.id]>
                    - if <[model_id]> == <[arg_3]>:
                      - define text "There is already a player model with the id of <green><[arg_3]> <gray>in tick <green><[tick]>t<gray>."
                      - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua]> <gray><[text]>"
                      - stop
                  #If there is a model present remove it
                  - if <player.has_flag[dcutscene_location_editor]>:
                    - define data <player.flag[dcutscene_location_editor]>
                    - define root_ent <[data.root_ent]>
                    - define root_type <[data.root_type]>
                    - choose <[root_type]>:
                      - case player_model:
                        - if <[root_ent].is_spawned>:
                          - run pmodels_remove_model def:<[root_ent]>
                  - flag <player> cutscene_modify:new_player_model_location
                  #Save data for continuous data input in modifiers
                  - flag <player> dcutscene_save_data.id:<[arg_3]>
                  - run pmodels_spawn_model def:<player.location>|<player>|<player> save:spawned
                  - define root <entry[spawned].created_queue.determination.first>
                  - flag <player> dcutscene_save_data.root:<[root]>
                  - run dcutscene_location_tool_give_data def:<player.location>|<[root]>|<[root].location.yaw>|player_model
                  - define text "After choosing your location for this player model click <green>Confirm Location <gray>in the location GUI or chat <green>confirm <gray>. To re-open the location GUI do /dcutscene location."
                  - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
                  - inventory open d:dcutscene_inventory_location_tool
                #Set Location and create new player model
                - else if <[arg_2]> == location_set && <[arg_3]> != null:
                  - flag <player> cutscene_modify:!
                  - define model_uuid <util.random_uuid>
                  - definemap model_data id:<player.flag[dcutscene_save_data.id]> type:player_model root:none sub_frames:none
                  - define model_data.path.<[tick]>.interpolation linear
                  - define model_data.path.<[tick]>.rotate true
                  - define model_data.path.<[tick]>.move false
                  - define model_data.path.<[tick]>.location <[arg_3]>
                  - narrate <player.flag[dcutscene_location_editor.location]>
                  - define model_data.path.<[tick]>.animation false
                  - define model_data.path.<[tick]>.ray_trace floor
                  - define data.keyframes.models.<[tick]>.<[model_uuid]> <[model_data]>
                  - define data.keyframes.models.<[tick]>.model_list:->:<[model_uuid]>
                  - flag server dcutscenes.<[data.name]>:<[data]>
                  - flag <player> cutscene_data:<server.flag[dcutscenes.<[data.name]>]>
                  - define text "Denizen Player Model has been created for tick <green><[tick]>t <gray>with an ID of <green><player.flag[dcutscene_save_data.id]> <gray>in scene <green><[data.name]><gray>."
                  - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
                  - flag <player> dcutscene_location_editor:!
                  - inventory open d:dcutscene_inventory_sub_keyframe
                  - ~run dcutscene_sub_keyframe_modify def:<player.flag[dcutscene_sub_keyframe_back_data]>
                - else:
                  - debug error "Something went wrong in dcutscene_model_keyframe_edit for player_model modifier"

              #Create new keyframe point for presently created model
              - case create_present:
                - define arg_2 <[arg_2]||null>
                - choose <[arg_2]>:
                  #Prepare for new keyframe
                  - case new_keyframe_prepare:
                    #TODO:
                    #- Ensure the same model id cannot be put in the same tick
                    #Data from items in the models GUI
                    - define root_save <[arg_3]||null>
                    - if <[root_save]> != null:
                      #Get the starting point model data
                      - define root_tick <[root_save.tick]>
                      - define root_uuid <[root_save.uuid]>
                      - define root_data <[data.keyframes.models.<[root_tick]>.<[root_uuid]>]||null>
                      - if <[root_data]> == null:
                        - debug error "Something went wrong in dcutscene_model_keyframe_edit could not find root model keyframe"
                      - else:
                        - flag <player> cutscene_modify:new_player_model_keyframe_point
                        #If there is a present player model remove it
                        - if <player.has_flag[dcutscene_location_editor]>:
                          - define loc_data <player.flag[dcutscene_location_editor]>
                          - define root_ent <[loc_data.root_ent]>
                          - define root_type <[loc_data.root_type]>
                          - choose <[root_type]>:
                            - case player_model:
                              - if <[root_ent].is_spawned>:
                                - run pmodels_remove_model def:<[root_ent]>
                        - define text "After choosing your location for this player model click <green>Confirm Location <gray>in the location GUI or chat <green>confirm <gray>. To re-open the location GUI do /dcutscene location."
                        - flag <player> dcutscene_save_data.data:<[root_save]>
                        - run pmodels_spawn_model def:<player.location>|<player>|<player> save:spawned
                        - define root <entry[spawned].created_queue.determination.first>
                        - flag <player> dcutscene_save_data.root:<[root]>
                        - run dcutscene_location_tool_give_data def:<player.location>|<[root]>|<[root].location.yaw>|player_model
                        - inventory open d:dcutscene_inventory_location_tool
                  #Set the new keyframe point
                  - case new_keyframe_set:
                    - flag <player> cutscene_modify:!
                    - flag <player> dcutscene_location_editor:!
                    - define loc <location[<[arg_3]>]>
                    - define root_save <player.flag[dcutscene_save_data.data]||null>
                    - define root_tick <[root_save.tick]>
                    - define root_uuid <[root_save.uuid]>
                    - define root_id <[root_save.id]>
                    - definemap path_data rotate:true interpolation:linear location:<[loc]> move:false animation:false ray_trace:floor
                    #Update the root data
                    - define path <[data.keyframes.models.<[root_tick]>.<[root_uuid]>.path]>
                    - define path.<[tick]> <[path_data]>
                    #Sort path by time
                    - define path <[path].sort_by_value[get[time]]>
                    - flag server dcutscenes.<[data.name]>.keyframes.models.<[root_tick]>.<[root_uuid]>.path:<[path]>
                    - flag server dcutscenes.<[data.name]>.keyframes.models.<[root_tick]>.<[root_uuid]>.sub_frames.<[tick]>:<[root_uuid]>
                    - define model_uuid <[root_uuid]>
                    - define model_data.id <[root_id]>
                    - define model_data.type player_model
                    - define model_data.path false
                    - define model_data.root.tick <[root_tick]>
                    - define model_data.root.uuid <[root_uuid]>
                    - flag server dcutscenes.<[data.name]>.keyframes.models.<[tick]>.<[model_uuid]>:<[model_data]>
                    - flag server dcutscenes.<[data.name]>.keyframes.models.<[tick]>.model_list:->:<[model_uuid]>
                    - flag <player> cutscene_data:<server.flag[dcutscenes.<[data.name]>]>
                    - inventory open d:dcutscene_inventory_sub_keyframe
                    - ~run dcutscene_sub_keyframe_modify def:<player.flag[dcutscene_sub_keyframe_back_data]>
                    - define text "Player model <green><[model_data.id]> <gray>has been set to tick <green><[tick]>t <gray>in scene <green><[data.name]><gray>."
                    - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"

              #Animation for player model
              - case animate:
                - define arg_2 <[arg_2]||null>
                - if <[arg_2]> != null:
                  - choose <[arg_2]>:
                    #Prepare for new animation
                    - case new_animation_prepare:
                      - flag <player> cutscene_modify:set_model_animation
                      - flag <player> dcutscene_save_data.type:player_model
                      - define text "To set the animation use the command <green>/dcutscene animate my_animation <gray>to prevent an animation from playing put <red>false<gray>."
                      - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
                      - inventory close
                    #Set the animation for the player model keyframe point
                    - case set_animation:
                      - define arg_3 <[arg_3]||null>
                      - if <[arg_3]> != null:
                        - flag <player> cutscene_modify:!
                        - define tick_data <player.flag[dcutscene_tick_modify]>
                        - define tick <[tick_data.tick]>
                        - define uuid <[tick_data.uuid]>
                        - define root_data <[data.keyframes.models.<[tick]>.<[uuid]>.root]||none>
                        #If the model contains a root data model
                        - if <[root_data]> != none:
                          - define root_update <[data.keyframes.models.<[root_data.tick]>.<[root_data.uuid]>]>
                          - define root_update.path.<[tick]>.animation <[arg_3]>
                          - flag server dcutscenes.<[data.name]>.keyframes.models.<[root_data.tick]>.<[root_data.uuid]>:<[root_update]>
                        #If the model is a root model
                        - else:
                          - define root_update <[data.keyframes.models.<[tick]>.<[uuid]>]>
                          - define root_update.path.<[tick]>.animation <[arg_3]>
                          - flag server dcutscenes.<[data.name]>.keyframes.models.<[tick]>.<[uuid]>:<[root_update]>
                        - flag <player> cutscene_data:<server.flag[dcutscenes.<[data.name]>]>
                        - define text "Player Model <green><[root_update.id]> <gray>will now play the animation <green><[arg_3]> <gray>in tick <green><[tick]>t <gray>for scene <green><[data.name]><gray>."
                        - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
                        - inventory open d:dcutscene_inventory_keyframe_modify_player_model

              #Whether the model will move to the next keyframe point
              - case set_move:
                - define arg_2 <[arg_2]||null>
                - if <[arg_2]> != null:
                  - define item <[arg_2]>
                  - define tick_data <player.flag[dcutscene_tick_modify]>
                  - define tick <[tick_data.tick]>
                  - define uuid <[tick_data.uuid]>
                  - define root_data <[data.keyframes.models.<[tick]>.<[uuid]>.root]||none>
                  #If the model contains a root data model
                  - if <[root_data]> != none:
                    - define root_update <[data.keyframes.models.<[root_data.tick]>.<[root_data.uuid]>]>
                    - choose <[root_update.path.<[tick]>.move]>:
                      - case true:
                        - define root_update.path.<[tick]>.move false
                      - case false:
                        - define root_update.path.<[tick]>.move true
                    - flag server dcutscenes.<[data.name]>.keyframes.models.<[root_data.tick]>.<[root_data.uuid]>:<[root_update]>
                  #If the model is a root model
                  - else:
                    - define root_update <[data.keyframes.models.<[tick]>.<[uuid]>]>
                    - choose <[root_update.path.<[tick]>.move]>:
                      - case true:
                        - define root_update.path.<[tick]>.move false
                      - case false:
                        - define root_update.path.<[tick]>.move true
                    - flag server dcutscenes.<[data.name]>.keyframes.models.<[tick]>.<[uuid]>:<[root_update]>
                  - flag <player> cutscene_data:<server.flag[dcutscenes.<[data.name]>]>
                  - define l1 "<gold>Move: <gray><[root_update.path.<[tick]>.move]>"
                  - define l2 "<gray><italic>Click to change player model move"
                  - define lore <list[<empty>|<[l1]>|<empty>|<[l2]>]>
                  - inventory adjust d:<player.open_inventory> slot:<[arg_2]> lore:<[lore]>

              #Ray Trace Modifying
              - case ray_trace:
                - define arg_2 <[arg_2]||null>
                - if <[arg_2]> != null:
                  - choose <[arg_2]>:
                    - case ray_trace_liquid:
                      - define lol

              #New location for player model
              - case location:
                #New Location for Player Model
                #- TODO:
                #- Implement semi-path system in keyframe
                - define arg_2 <[arg_2]||null>
                - if <[arg_2]> != null:
                  - choose <[arg_2]>:
                    - case new_location:
                      - define tick_data <[data.keyframes]>

              #Removes model from tick
              - case remove_tick:
                - define tick_data <player.flag[dcutscene_tick_modify]>
                - define tick <[tick_data.tick]>
                - define uuid <[tick_data.uuid]>
                - define model_data <[data.keyframes.models]>
                - define root_data <[data.keyframes.models.<[tick]>.<[uuid]>.root]||none>
                #If the model has a root data model
                - if <[root_data]> != none:
                  #Update the root data model
                  - define root_update <[data.keyframes.models.<[root_data.tick]>.<[root_data.uuid]>]>
                  - define root_update.sub_frames <[root_update.sub_frames].deep_exclude[<[tick]>]>
                  - define root_update.path <[root_update.path].deep_exclude[<[tick]>]>
                  #check if the updated data has empty maps
                  - if <[root_update.sub_frames].is_empty>:
                    - define root_update.sub_frames none
                  #Remove the specified tick player model
                  - define model_data.<[root_data.tick]>.<[root_data.uuid]> <[root_update]>
                  - define model_data.<[tick]>.model_list:<-:<[uuid]>
                  - define model_data.<[tick]> <[model_data.<[tick]>].exclude[<[uuid]>]>
                  #If the model list is empty remove tick
                  - if <[model_data.<[tick]>.model_list].is_empty>:
                    - define model_data <[model_data].deep_exclude[<[tick]>]>
                  - define text "Player model <green><[data.keyframes.models.<[tick]>.<[uuid]>.id]> <gray>has been removed from tick <green><[tick]>t <gray>in scene <green><[data.name]><gray>."
                  - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
                  - flag server dcutscenes.<[data.name]>.keyframes.models:<[model_data]>
                  - flag <player> cutscene_data:<server.flag[dcutscenes.<[data.name]>]>
                  - inventory open d:dcutscene_inventory_sub_keyframe
                  - ~run dcutscene_sub_keyframe_modify def:<player.flag[dcutscene_sub_keyframe_back_data]>
                #If the model is a root data model
                - else:
                  - inventory close
                  - clickable dcutscene_model_keyframe_edit def:player_model|remove_all save:remove_model
                  - define prefix <element[DCutscenes].color_gradient[from=blue;to=aqua].bold>
                  - define text "This is a starting point player model removing this will remove the player model from the cutscene proceed? <green><bold><element[Yes].on_hover[<[prefix]> <gray>This will permanently remove this player model from this scene.].type[SHOW_TEXT].on_click[<entry[remove_model].command>]>"
                  - narrate "<[prefix]> <gray><[text]>"

              #Removes model from entire cutscene
              - case remove_all:
                - define tick_data <player.flag[dcutscene_tick_modify]>
                - define tick <[tick_data.tick]>
                - define uuid <[tick_data.uuid]>
                - define model_data <[data.keyframes.models]>
                - define root_data <[data.keyframes.models.<[tick]>.<[uuid]>.root]||none>
                #If there is a root data model in the tick
                - if <[root_data]> != none:
                  - define sub_frames <[data.keyframes.models.<[root_data.tick]>.<[root_data.uuid]>.sub_frames]>
                  #Remove sub frames
                  - foreach <[sub_frames]> key:tick_id as:subframe:
                    - define model_data <[model_data.<[tick_id]>].exclude[<[subframe]>]>
                    - define model_data <[model_data.<[tick_id]>.model_list]>:<-:<[subframe]>
                    #If the model list is empty remove the tick
                    - if <[model_data.<[tick_id]>.model_list].is_empty>:
                      - define model_data <[model_data].exclude[<[tick_id]>]>
                  #Remove the root
                  - define model_data <[model_data.<[root_data.tick]>].exclude[<[root_data.uuid]>]>
                  - define model_data <[model_data.<[root_data.tick]>.model_list]>:<-:<[subframe]>
                  #If the model list is empty remove the tick
                  - if <[model_data.<[root_data.tick]>.model_list].is_empty>:
                    - define model_data <[model_data].exclude[<[root_data.tick]>]>
                #If the model is a root data model
                - else:
                  #Remove the root
                  - define model_data <[model_data.<[root_data.tick]>].exclude[<[root_data.uuid]>]>
                  - define model_data <[model_data.<[root_data.tick]>.model_list]>:<-:<[subframe]>
                  #If the model list is empty remove the tick
                  - if <[model_data.<[root_data.tick]>.model_list].is_empty>:
                    - define model_data <[model_data].exclude[<[root_data.tick]>]>
                - define text "Player model <green><[data.keyframes.models.<[tick]>.<[uuid]>.id]> <gray>has been removed from scene <green><[data.name]><gray>."
                - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
                - flag server dcutscenes.<[data.name]>.keyframes.models:<[model_data]>
                - flag <player> cutscene_data:<server.flag[dcutscenes.<[data.name]>]>
                - inventory open d:dcutscene_inventory_sub_keyframe
                - ~run dcutscene_sub_keyframe_modify def:<player.flag[dcutscene_sub_keyframe_back_data]>

          #If the player model script does not exist
          - else:
            - debug error "Could not find Denizen Player Models in dcutscene_model_keyframe_edit"
            - define text "Could not find Denizen Player Models."
            - define text_2 "<gray>Forums: <green><&click[https://forum.denizenscript.com/resources/denizen-player-models.107/].type[OPEN_URL]>click here<&end_click><gray>."
            - define text_3 "<gray>Github: <green><&click[https://github.com/FutureMaximus/Denizen-Player-Models].type[OPEN_URL]>click here<&end_click><gray>."
            - define text_4 "<gray>Wiki: <green><&click[https://github.com/FutureMaximus/Denizen-Player-Models/wiki].type[OPEN_URL]>click here<&end_click><gray>."
            - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
            - narrate <[text_2]>
            - narrate <[text_3]>
            - narrate <[text_4]>
            - inventory close
        #========= Denizen Models Modifier =========
        - case denizen_model:
          - define task_check <script[dmodels_spawn_model]||null>
          - if <[task_check]> != null:
            - choose <[arg]>:
              - case lol:
                - narrate HELLO!
          - else:
            - debug error "Could not find Denizen Models in dcutscene_model_keyframe_edit"
            - define text "Could not find Denizen Models."
            - define text_2 "<gray>Forums: <green><&click[https://forum.denizenscript.com/resources/denizen-models.103/].type[OPEN_URL]>click here<&end_click><gray>."
            - define text_3 "<gray>Github: <green><&click[https://github.com/mcmonkeyprojects/DenizenModels].type[OPEN_URL]>click here<&end_click><gray>."
            - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
            - narrate <[text_2]>
            - narrate <[text_3]>
            - inventory close

#========== Regular Animators Modifiers ============
#List of regular animators (Type List means there can be multiple of the same animator in 1 tick Type Once means there can only be 1 per tick)
#- Sound TYPE: List
#- Particle TYPE: List
#- Title TYPE: Once
#- Cinematic Screeneffect TYPE: Once
#- Fake block or schematic TYPE: List
#- Send command to player or console TYPE: List
#- Run a custom task TYPE: List
#- Set the time for the player TYPE: Once
#- Set the weather for the player TYPE: Once

#TODO:
#- Clean up the code
#Modify regular animators in cutscenes (Regular animators are things that play only once and do not use the path system such as the camera)
dcutscene_animator_keyframe_edit:
    type: task
    debug: false
    definitions: option|arg|arg_2|arg_3
    script:
    - define option <[option]||null>
    - define arg <[arg]||null>
    - if <[option]> == null && <[arg]> == null:
      - debug error "Something went wrong in dcutscene_animator_edit could not determine option"
    - else:
      - define data <player.flag[cutscene_data]>
      - define keyframes <[data.keyframes.elements]>
      - define scene_name <[data.name]>
      - choose <[option]>:
        #======== Run Task Modifier ========
        - case run_task:
          - choose <[arg]>:
            #Prepare for new run task
            - case new:
              - flag <player> cutscene_modify:run_task expire:2m
              - define text "Chat the name of the run task script."
              - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
              - inventory close

            #Create new run task
            - case create:
              - define arg_2 <[arg_2]||null>
              - if <[arg_2]> != null:
                - define script_check <script[<[arg_2]>]||null>
                - if <[script_check]> != null:
                  - flag <player> cutscene_modify:!
                  - define data <player.flag[cutscene_data]>
                  - define tick <player.flag[dcutscene_tick_modify]>
                  - define task_uuid <util.random_uuid>
                  #List of run tasks
                  - define keyframes.run_task.<[tick]>.run_task_list:->:<[task_uuid]>
                  #Script to run
                  - define keyframes.run_task.<[tick]>.<[task_uuid]>.script <[arg_2]>
                  #Definitions to pass through the run task
                  - define keyframes.run_task.<[tick]>.<[task_uuid]>.defs false
                  #Waitable
                  - define keyframes.run_task.<[tick]>.<[task_uuid]>.waitable false
                  #Delay to run script
                  - define keyframes.run_task.<[tick]>.<[task_uuid]>.delay <duration[0s]>
                  #Input the data
                  - flag server dcutscenes.<[scene_name]>.keyframes.elements:<[keyframes]>
                  - flag <player> cutscene_data:<server.flag[dcutscenes.<[scene_name]>]>
                  - ~run dcutscene_sort_data def:<[scene_name]>
                  - inventory open d:dcutscene_inventory_sub_keyframe
                  - ~run dcutscene_sub_keyframe_modify def:<player.flag[dcutscene_sub_keyframe_back_data]>
                  - define text "Run task <green><[arg_2]> <gray>has been created for tick <green><[tick]>t <gray>in scene <green><[data.name]><gray>."
                  - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
                - else:
                  - define text "Could not find script named <green><[arg_2]><gray>."
                  - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"

            #Prepare for new run task
            - case change_task_prepare:
              - flag <player> cutscene_modify:run_task_change expire:2m
              - define text "Chat the name of the run task script."
              - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
              - inventory close

            #Change the task
            - case change_task:
              - define arg_2 <[arg_2]||null>
              - if <[arg_2]> != null:
                - define script_check <script[<[arg_2]>]||null>
                - if <[script_check]> != null:
                  - flag <player> cutscene_modify:!
                  - define data <player.flag[cutscene_data]>
                  - define tick <player.flag[dcutscene_tick_modify.tick]>
                  - define uuid <player.flag[dcutscene_tick_modify.uuid]>
                  - define keyframe <[data.keyframes.elements.run_task.<[tick]>.<[uuid]>]||null>
                  - if <[keyframe]> != null:
                    - define keyframe.script <[arg_2]>
                    - flag server dcutscenes.<[data.name]>.keyframes.elements.run_task.<[tick]>.<[uuid]>:<[keyframe]>
                    - flag <player> cutscene_data:<server.flag[dcutscenes.<[data.name]>]>
                    - inventory open d:dcutscene_inventory_keyframe_modify_run_task
                    - define text "Run task script has been changed to <green><[arg_2]> <gray>for tick <green><[tick]>t <gray>in scene <green><[data.name]><gray>."
                    - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
                - else:
                  - define text "Could not find script named <green><[arg_2]><gray>."
                  - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"

            #Prepare to set new definitions for run task
            - case task_definition:
              - flag <player> cutscene_modify:run_task_def_set expire:2.5m
              - define text "Chat the definition(s) for this run task the input can be any valid tag."
              - define text_2 "Chat <red>false <gray>to disable definitions."
              - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
              - narrate <gray><[text_2]>
              - inventory close

            #Set the definitions for the run task
            - case set_task_definition:
              - define arg_2 <[arg_2]||null>
              - if <[arg_2]> != null:
                  - flag <player> cutscene_modify:!
                  - define data <player.flag[cutscene_data]>
                  - define tick <player.flag[dcutscene_tick_modify.tick]>
                  - define uuid <player.flag[dcutscene_tick_modify.uuid]>
                  - define keyframe <[data.keyframes.elements.run_task.<[tick]>.<[uuid]>]||null>
                  - if <[keyframe]> != null:
                    - define keyframe.defs <[arg_2]>
                    - flag server dcutscenes.<[data.name]>.keyframes.elements.run_task.<[tick]>.<[uuid]>:<[keyframe]>
                    - flag <player> cutscene_data:<server.flag[dcutscenes.<[data.name]>]>
                    - inventory open d:dcutscene_inventory_keyframe_modify_run_task
                    - define text "Run task <green><[keyframe.script]> <gray>definition is set to <green><[arg_2]><gray>."
                    - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"

            #Change run task waitable boolean
            - case change_waitable:
              - define arg_2 <[arg_2]||null>
              - if <[arg_2]> != null:
                - define data <player.flag[cutscene_data]>
                - define tick <player.flag[dcutscene_tick_modify.tick]>
                - define uuid <player.flag[dcutscene_tick_modify.uuid]>
                - define keyframe <[data.keyframes.elements.run_task.<[tick]>.<[uuid]>]||null>
                - define wait_data <[keyframe.waitable]||false>
                - if <[keyframe]> != null:
                  - choose <[wait_data]>:
                    - case true:
                      - define keyframe.waitable false
                    - case false:
                      - define keyframe.waitable true
                  - flag server dcutscenes.<[data.name]>.keyframes.elements.run_task.<[tick]>.<[uuid]>:<[keyframe]>
                  - flag <player> cutscene_data:<server.flag[dcutscenes.<[data.name]>]>
                  - define item <item[<[arg_2]>]||null>
                  - if <[item]> != null:
                    - define inv <player.open_inventory>
                    - define lore "<gold><bold>Waitable <gray><[keyframe.waitable]>"
                    - define click "<gray><italic>Click to change waitable"
                    - adjust <[item]> lore:<list[<empty>|<[lore]>|<empty>|<[click]>]> save:item
                    - define item <entry[item].result>
                    - inventory set d:<[inv]> o:<[item]> slot:<[arg_3]>

            #Prepare for new run task delay
            - case delay_prepare:
              - flag <player> cutscene_modify:run_task_delay expire:2m
              - define text "Chat a duration for the delay in the run task. Example: 1s or 20t"
              - define text_2 "To disable this chat <green>0<gray>."
              - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
              - narrate <gray><[text_2]>
              - inventory close

            #Change delay
            - case change_delay:
              - define arg_2 <duration[<[arg_2]>]||null>
              - narrate <[arg_2]>
              - if <[arg_2]> != null:
                - flag <player> cutscene_modify:!
                - define data <player.flag[cutscene_data]>
                - define tick <player.flag[dcutscene_tick_modify.tick]>
                - define uuid <player.flag[dcutscene_tick_modify.uuid]>
                - define duration <[arg_2]>
                - define keyframe <[data.keyframes.elements.run_task.<[tick]>.<[uuid]>]||null>
                - define keyframe.delay <[duration]>
                - flag server dcutscenes.<[data.name]>.keyframes.elements.run_task.<[tick]>.<[uuid]>:<[keyframe]>
                - flag <player> cutscene_data:<server.flag[dcutscenes.<[data.name]>]>
                - inventory open d:dcutscene_inventory_keyframe_modify_run_task
                - define text "Delay for run task <green><[keyframe.script]> <gray>has been set to <green><[arg_2]> <gray>in scene <green><[data.name]><gray>."
                - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
              - else:
                - define text "<green><[arg_2]> <gray>is not a valid time. Example: 1s or 20t"
                - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"

            #Remove run task
            - case remove:
              - define data <player.flag[cutscene_data]>
              - define tick <player.flag[dcutscene_tick_modify.tick]>
              - define uuid <player.flag[dcutscene_tick_modify.uuid]>
              - define keyframe <[data.keyframes.elements.run_task]>
              - define run_task <[keyframe.<[tick]>]>
              - define run_task_script <[run_task.<[uuid]>.script]>
              - define run_task.run_task_list:<-:<[uuid]>
              - if <[run_task.run_task_list].is_empty>:
                - define new_keyframe <[keyframe].deep_exclude[<[tick]>]>
                - flag server dcutscenes.<[data.name]>.keyframes.elements.run_task:<[new_keyframe]>
              - else:
                - define new_keyframe <[run_task]>
                - define new_keyframe <[new_keyframe].deep_exclude[<[uuid]>]>
                - flag server dcutscenes.<[data.name]>.keyframes.elements.run_task.<[tick]>:<[new_keyframe]>
              - flag <player> cutscene_data:<server.flag[dcutscenes.<[data.name]>]>
              - define text "Run task <green><[run_task_script]> <gray>has been removed from tick <green><[tick]>t <gray>in scene <green><[data.name]><gray>."
              - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
              - inventory open d:dcutscene_inventory_sub_keyframe
              - ~run dcutscene_sub_keyframe_modify def:<player.flag[dcutscene_sub_keyframe_back_data]>

        #======== Cinematic Screeneffect Modifier =========
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

        #============== Sound Modifier ===============
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
                - flag <player> cutscene_modify:!
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
                  - if <[item]> != null:
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

#############################
