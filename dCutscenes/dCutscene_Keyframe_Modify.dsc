#################################################
#This script file modifies the animators in the cutscene and keyframes GUI.
#################################################

#Info:
#- <server.flag[dcutscenes]> "All the cutscenes the server has with specific use as <server.flag[dcutscenes.my_scene]>"
#- <player.flag[cutscene_data]> "Returns the cutscene the player is modifying"
#- <player.flag[cutscene_data.keyframes]> "Returns the animators within the cutscene"
#- <player.flag[cutscene_data.name]> "Returns the name of the cutscene"
#- <player.flag[dcutscene_tick_modify]> "Returns the tick the player is modifying without a uuid this is used when creating a new animator"
#- <player.flag[dcutscene_tick_modify.tick]> "Returns the tick if animator uuid is specified as well"
#- <player.flag[dcutscene_tick_modify.uuid]> "Returns the uuid of the animator the player is modifying"
#- <player.flag[dcutscene_save_data]> "Used for multi operation keyframe modifiers in keeping data"
#- <player.flag[cutscene_modify]> "Used for event handlers with a specified key such as change_sound"
#- <player.flag[dcutscene_location_editor]> "Returns the data of the player's location tool"
#Note: To get a better understanding how the data structure is save the cutscene and read the json file.

#=============Keyframe Modifiers ===============

#======== Location Tool =========
#A utility tool used for getting exact locations

dcutscene_location_tool_events:
    type: world
    debug: false
    events:
      on player quits:
      - if <player.has_flag[dcutscene_location_editor]>:
        - define data <player.flag[dcutscene_location_editor]>
        - define root_ent <[data.root_ent]>
        - if <[root_ent].is_spawned>:
          - define root_type <[data.root_type]>
          - choose <[root_type]>:
            - case player_model:
              - if <[root_ent].is_spawned>:
                - run pmodels_remove_model def:<[root_ent]>
        - run dcutscene_location_tool_return_inv
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
                - define skin <player.flag[dcutscene_location_editor.skin]||<player>>
                - run pmodels_spawn_model def:<player.location>|<[skin].parsed>|<player> save:spawned
                - define root <entry[spawned].created_queue.determination.first>
                - flag <player> dcutscene_location_editor.root_ent:<[root]>
          - else if <[root].location.distance[<player.location>].horizontal||0> > <player.world.view_distance.mul[14]> || <[root].location.world> != <player.location.world>:
            - choose <[data.root_type]>:
              - case player_model:
                - define skin <player.flag[dcutscene_location_editor.skin]||<player>>
                - run pmodels_spawn_model def:<player.location>|<[skin].parsed>|<player> save:spawned
                - define root <entry[spawned].created_queue.determination.first>
                - flag <player> dcutscene_location_editor.root_ent:<[root]>
          - teleport <[root]> <[ray_trace].with_yaw[<[yaw]>]>
          - run pmodels_reset_model_position def:<[root]>
        - if <[root]> == null:
          - flag <player> dcutscene_location_editor.location:<[ray_trace]>
          - define tick_data <player.flag[dcutscene_save_data.data]||null>
          - if <[tick_data]> != null:
            - run dcutscene_semi_path_show def:<[ray_trace]>|<[data.root_type]>|<[tick_data.tick]>|<[tick_data.uuid]>
        - else:
          - flag <player> dcutscene_location_editor.location:<[root].location>
          - define tick_data <player.flag[dcutscene_save_data.data]||null>
          - if <[tick_data.uuid]||null> != null:
            - ratelimit <player> <script[dcutscene_config].data_key[config].get[cutscene_semi_path_update_interval]||0.5s>
            - run dcutscene_semi_path_show def:<[ray_trace]>|<[data.root_type]>|<[tick_data.tick]>|<player.flag[dcutscene_tick_modify.tick]||<player.flag[dcutscene_tick_modify]>>|<[tick_data.uuid]>

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
    definitions: loc|root_ent|yaw|type|skin
    script:
    - define loc <location[<[loc]>]||null>
    - if <[loc]> == null:
      - debug error "Must specify location for location tool"
      - stop
    - define root_ent <[root_ent]||null>
    - define type <[type]||null>
    - define skin <[skin]||null>
    - definemap offset x:0.0 y:0.0 z:0.0
    - if <[yaw].exists>:
      - define yaw <[yaw]>
    - else:
      - define yaw 0
    - definemap editor_data offset:<[offset]> offset_mul:1 yaw:<[yaw]> location:<[loc]> use_yaw:true
    - definemap editor_data ray_trace_bool:false ray_trace_solids:false ray_trace_passable:false ray_trace_water:true reverse_model:false
    - define editor_data.ray_trace_range <script[dcutscenes_config].data_key[config].get[cutscene_loc_tool_ray_dist]||5>
    - flag <player> dcutscene_location_editor:<[editor_data]>
    - if <[root_ent]> != null:
      - flag <player> dcutscene_location_editor.root_ent:<[root_ent]>
    - if <[type]> != null:
      - flag <player> dcutscene_location_editor.root_type:<[type]>
    - if <[skin]> != null:
      - flag <player> dcutscene_location_editor.skin:<[skin]>
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

dcutscene_location_tool_return_inv:
    type: task
    debug: false
    script:
    - inventory swap d:<player.inventory> o:<player.flag[dcutscene_location_editor.inv]>

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

#======== Stop Cutscene Modifier ========
dcutscene_stop_scene_keyframe:
    type: task
    debug: false
    definitions: option|arg|arg_2
    script:
    - define data <player.flag[cutscene_data]>
    - define tick <player.flag[dcutscene_tick_modify]>
    - choose <[option]>:
      #New stop scene keyframe
      - case new:
        - define stop_check <[data.keyframes.stop]||null>
        #There can only be 1 stop point
        - if <[stop_check]> != null:
          #TODO:
          #- Clickable that removes the stop point
          - define text "There is already a cutscene stop point at tick <green><[stop_check.tick]>t<gray>."
          - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
        - else:
          - define data.keyframes.stop.tick <[tick]>
          - flag server dcutscenes.<[data.name]>:<[data]>
          - flag <player> cutscene_data:<server.flag[dcutscenes.<[data.name]>]>
          - inventory open d:dcutscene_inventory_sub_keyframe
          - ~run dcutscene_sub_keyframe_modify def:<player.flag[dcutscene_sub_keyframe_back_data]>
          - define text "Cutscene stop point set to tick <green><[tick]>t <gray>for scene <green><[data.name]><gray>."
          - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
          - ~run dcutscene_sort_data def:<[data.name]>

      #Remove stop scene keyframe
      - case remove:
        - define data.keyframes <[data.keyframes].exclude[stop]>
        - flag server dcutscenes.<[data.name]>:<[data]>
        - flag <player> cutscene_data:<server.flag[dcutscenes.<[data.name]>]>
        - define text "Cutscene stop point on tick <green><[tick.tick]>t <gray>has been removed from scene <green><[data.name]><gray>."
        - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
        - inventory open d:dcutscene_inventory_sub_keyframe
        - ~run dcutscene_sub_keyframe_modify def:<player.flag[dcutscene_sub_keyframe_back_data]>

#========  Camera Modifier ===========
#TODO:`
#- Rework this
dcutscene_cam_keyframe_edit:
    type: task
    debug: false
    definitions: option|arg|arg_2|arg_3
    script:
    - define option <[option]||null>
    - define arg <[arg]||null>
    - if <[option]> == null:
      - debug error "Something went wrong in dcutscene_cam_keyframe_edit could not determine option."
    - else:
      - define data <player.flag[cutscene_data]>
      - define camera_data <[data.keyframes.camera]||<empty>>
      - define tick <player.flag[dcutscene_tick_modify]>
      - choose <[option]>:
        #=========== New Camera ===========
        #prepare to create new keyframe modifier
        - case new:
          - define cam_check <[camera_data.<[tick]>]||null>
          - if <[cam_check]> != null:
            - define text "There is already a camera on this tick."
            - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
          - else:
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
          - definemap cam_keyframe location:<player.location> rotate_mul:1.0 interpolation:linear move:true
          - define cam_keyframe.eye_loc.location <[ray]>
          - define cam_keyframe.eye_loc.boolean false
          - define cam_keyframe.tick <[tick]>
          #Reason we're storing the tick is so the sort task has something to sort the map with
          - look <[camera]> <[ray]> duration:2t
          - adjust <[camera]> armor_pose:[head=<player.location.pitch.to_radians>,0.0,0.0]
          - define text "Camera location set to <green><player.location.simple> <gray>and look point <green><[ray].simple><gray> <gray>for keyframe tick <green><[tick]>t <gray>for scene <green><[data.name]><gray>."
          - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
          - define data.keyframes.camera.<[tick]>:<[cam_keyframe]>
          - flag server dcutscenes.<[data.name]>:<[data]>
          #Sort the newly created data
          - ~run dcutscene_sort_data def:<[data.name]>
          #Update the player's cutscene data
          - flag <player> cutscene_data:<server.flag[dcutscenes.<[data.name]>]>
          - inventory open d:dcutscene_inventory_sub_keyframe
          - ~run dcutscene_sub_keyframe_modify def:<player.flag[dcutscene_sub_keyframe_back_data]>

        #teleport to camera location
        - case teleport:
          - define tick <player.flag[dcutscene_tick_modify]>
          - define cam_loc <location[<[camera_data.<[tick]>.location]>]||null>
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
                - define cam_keyframe <[camera_data.<[tick]>]>
                - define cam_keyframe <[cam_keyframe].deep_with[eye_loc.location].as[<[ray]>]>
                #final data input
                - define data.keyframes.camera.<[tick]>:<[cam_keyframe]>
                - flag server dcutscenes.<[data.name]>:<[data]>
                - define text "Camera location set to <green><player.location.simple> <gray>and look point <green><[ray].simple><gray> <gray>for keyframe tick <green><[tick]>t <gray>in scene <green><[data.name]><gray>."
                - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
                #Update the player's cutscene data
                - flag <player> cutscene_data:<server.flag[dcutscenes.<[data.name]>]>
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
                - define keyframes <[data.keyframes]>
                - define cam_keyframe <[keyframes.camera.<[tick]>]>
                - if <[loc]> != false:
                  - define cam_keyframe.eye_loc.location <[loc]>
                  - define cam_keyframe.eye_loc.boolean true
                - else:
                  - define cam_keyframe.eye_loc.boolean false
                - flag server dcutscenes.<[data.name]>.keyframes.camera.<[tick]>:<[cam_keyframe]>
                - flag <player> cutscene_data:<server.flag[dcutscenes.<[data.name]>]>
                - define loc_msg <location[<[loc]>].simple||null>
                - if <[loc_msg]> == null:
                  - define loc_msg false
                - define text "Camera on tick <green><[tick]>t <gray>look location is now <green><[loc_msg]> <gray>in scene <green><[data.name]><gray>."
                - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
                - inventory open d:dcutscene_inventory_keyframe_modify_camera

              #Change interpolation method
              - case interpolation_change:
                - define item <item[<[arg_2]>]>
                - define tick <player.flag[dcutscene_tick_modify]>
                - define cam_keyframe <[camera_data.<[tick]>]>
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

              #Change if the camera will move to the next point
              - case move_change:
                - define item <item[<[arg_2]>]>
                - define tick <player.flag[dcutscene_tick_modify]>
                - define cam_keyframe <[camera_data.<[tick]>]>
                - define move <[cam_keyframe.move]||true>
                - choose <[move]>:
                  - case true:
                    - define move false
                  - case false:
                    - define move true
                - define cam_keyframe.move <[move]>
                - flag server dcutscenes.<[data.name]>.keyframes.camera.<[tick]>:<[cam_keyframe]>
                - flag <player> cutscene_data:<server.flag[dcutscenes.<[data.name]>]>
                - define info_msg "<gray>Determine if the camera will move to the next keyframe point"
                - define interp_msg "<green><bold>Move: <gray><[move]>"
                - define click "<gray><italic>Click to modify movement for camera"
                - define lore <list[<empty>|<[info_msg]>|<empty>|<[interp_msg]>|<empty>|<[click]>]>
                - inventory adjust d:<player.open_inventory> slot:<[arg_3]> lore:<[lore]>

              #Determine if camera look is inverted
              - case invert_camera:
                - define item <item[<[arg_2]>]>
                - define tick <player.flag[dcutscene_tick_modify]>
                - define invert <[camera_data.<[tick]>.invert]||false>
                - choose <[invert]>:
                  - case true:
                    - define invert false
                  - case false:
                    - define invert true
                - define camera_data.<[tick]>.invert <[invert]>
                - flag server dcutscenes.<[data.name]>.keyframes.camera:<[camera_data]>
                - flag <player> cutscene_data:<server.flag[dcutscenes.<[data.name]>]>
                - define info_msg "<dark_purple>Invert: <gray><[invert]>"
                - define click "<gray><italic>Click to change invert look"
                - define lore <list[<empty>|<[info_msg]>|<empty>|<[click]>]>
                - inventory adjust d:<player.open_inventory> slot:<[arg_3]> lore:<[lore]>

              #Determine if the camera will interpolate the look rotation
              - case interpolate_look:
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
                - choose <[arg_2]>:
                  #Prepare for new rotation multipler
                  - case new_mul:
                    - flag <player> cutscene_modify:new_rotation_mul expire:2m
                    - define text "Chat the rotate multiplier the default value is <green>1<gray>. To cancel this chat <red>cancel<gray>."
                    - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
                    - inventory close
                  #Set the new rotation multipler
                  - case set_mul:
                    - if !<[arg_3].is_decimal>:
                      - define text "<green><[arg_3]> <gray>is not a valid number."
                      - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
                      - stop
                    - flag <player> cutscene_modify:!
                    - define tick <player.flag[dcutscene_tick_modify]>
                    - define cam_keyframe <[camera_data.<[tick]>]>
                    - define cam_keyframe.rotate_mul <[arg_3]>
                    - flag server dcutscenes.<[data.name]>.keyframes.camera.<[tick]>:<[cam_keyframe]>
                    - flag <player> cutscene_data:<server.flag[dcutscenes.<[data.name]>]>
                    - define text "<gray>Camera in tick <green><[tick]>t <gray>rotate multiplier is now <green><[arg_3]> <gray>for scene <green><[data.name]><gray>."
                    - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
                    - inventory open d:dcutscene_inventory_keyframe_modify_camera

              #Remove camera from keyframe
              - case remove_camera:
                - define tick <player.flag[dcutscene_tick_modify]>
                - define cam_keyframe <[data.keyframes.camera].deep_exclude[<[tick]>]>
                - define data.keyframes.camera:<[cam_keyframe]>
                - if <[data.keyframes.camera].is_empty>:
                  - define data.keyframes <[data.keyframes].deep_exclude[camera]>
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
      - define scene_name <[data.name]>
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
                          - define skin <[model_data.path.<[model.tick]>.skin].parsed||none>
                          - if <[skin]> == none || <[skin]> == player:
                            - define skin <player.skull_skin>
                          - adjust <[skull_item]> skull_skin:<[skin].skull_skin> save:item
                          - define item <entry[item].result>
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
                  - define tick_data <player.flag[dcutscene_tick_modify]>
                  - define tick <[tick_data.tick]>
                  - define uuid <[tick_data.uuid]>
                  - define skin <proc[dcutscene_determine_player_model_skin].context[<[data.name]>|<[tick]>|<[uuid]>]>
                  - if <[skin]> == none || <[skin]> == player:
                    - define skin <player>
                  - run pmodels_spawn_model def:<player.location>|<[skin]>|<player> save:spawned
                  - define root <entry[spawned].created_queue.determination.first>
                  - flag <player> dcutscene_save_data.root:<[root]>
                  #Give the location tool
                  - run dcutscene_location_tool_give_data def:<player.location>|<[root]>|<[root].location.yaw>|player_model|<[skin]>
                  - define text "After choosing your location for this player model click <green>Confirm Location <gray>in the location GUI or chat <green>confirm <gray>. To re-open the location GUI do /dcutscene location."
                  - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
                  - inventory open d:dcutscene_inventory_location_tool

                #Set location and create new player model
                - else if <[arg_2]> == location_set && <[arg_3]> != null:
                  - flag <player> cutscene_modify:!
                  - define model_uuid <util.random_uuid>
                  - definemap model_data id:<player.flag[dcutscene_save_data.id]> type:player_model root:none sub_frames:none
                  - definemap ray_trace_data direction:floor liquid:false passable:false
                  - definemap path_data interpolation:linear rotate:true move:false location:<[arg_3]> animation:false ray_trace:<[ray_trace_data]> skin:none tick:<[tick]>
                  - define model_data.path.<[tick]> <[path_data]>
                  - define data.keyframes.models.<[tick]>.<[model_uuid]> <[model_data]>
                  - define data.keyframes.models.<[tick]>.model_list:->:<[model_uuid]>
                  - flag server dcutscenes.<[data.name]>:<[data]>
                  - flag <player> cutscene_data:<server.flag[dcutscenes.<[data.name]>]>
                  - define text "Denizen Player Model has been created for tick <green><[tick]>t <gray>with an ID of <green><player.flag[dcutscene_save_data.id]> <gray>in scene <green><[data.name]><gray>."
                  - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
                  - if <player.flag[dcutscene_save_data.root].is_spawned>:
                    - run pmodels_remove_model def.root:<player.flag[dcutscene_save_data.root]>
                  - run dcutscene_location_tool_return_inv
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
                        - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
                        - flag <player> dcutscene_save_data.data:<[root_save]>
                        - define skin <proc[dcutscene_determine_player_model_skin].context[<[data.name]>|<[root_tick]>|<[root_uuid]>]>
                        - if <[skin]> == none || <[skin]> == player:
                          - define skin <player>
                        - run pmodels_spawn_model def:<player.location>|<[skin]>|<player> save:spawned
                        - define root <entry[spawned].created_queue.determination.first>
                        - flag <player> dcutscene_save_data.root:<[root]>
                        - run dcutscene_location_tool_give_data def:<player.location>|<[root]>|<[root].location.yaw>|player_model|<[skin]>
                        - inventory open d:dcutscene_inventory_location_tool

                  #Set the new keyframe point
                  - case new_keyframe_set:
                    - flag <player> cutscene_modify:!
                    - define loc <location[<[arg_3]>]>
                    - define root_save <player.flag[dcutscene_save_data.data]||null>
                    - define root_tick <[root_save.tick]>
                    - define root_uuid <[root_save.uuid]>
                    - define root_id <[root_save.id]>
                    - definemap ray_trace_data direction:floor liquid:false passable:false
                    - definemap path_data rotate:true interpolation:linear location:<[loc]> move:false animation:false ray_trace:<[ray_trace_data]> skin:none tick:<[tick]>
                    #Update the root data
                    - define path <[data.keyframes.models.<[root_tick]>.<[root_uuid]>.path]>
                    - define path.<[tick]> <[path_data]>
                    #Sort path by time
                    - define path <[path].sort_by_value[get[time]]>
                    - flag server dcutscenes.<[data.name]>.keyframes.models.<[root_tick]>.<[root_uuid]>.path:<[path]>
                    - flag server dcutscenes.<[data.name]>.keyframes.models.<[root_tick]>.<[root_uuid]>.sub_frames.<[tick]>:<[root_uuid]>
                    - define model_uuid <[root_uuid]>
                    - definemap model_data id:<[root_id]> type:player_model path:false
                    - define model_data.root.tick <[root_tick]>
                    - define model_data.root.uuid <[root_uuid]>
                    - flag server dcutscenes.<[data.name]>.keyframes.models.<[tick]>.<[model_uuid]>:<[model_data]>
                    - flag server dcutscenes.<[data.name]>.keyframes.models.<[tick]>.model_list:->:<[model_uuid]>
                    - flag <player> cutscene_data:<server.flag[dcutscenes.<[data.name]>]>
                    - if <player.flag[dcutscene_save_data.root].is_spawned>:
                      - run pmodels_remove_model def.root:<player.flag[dcutscene_save_data.root]>
                    - run dcutscene_location_tool_return_inv
                    - flag <player> dcutscene_location_editor:!
                    - inventory open d:dcutscene_inventory_sub_keyframe
                    - ~run dcutscene_sub_keyframe_modify def:<player.flag[dcutscene_sub_keyframe_back_data]>
                    - define text "Player model <green><[model_data.id]> <gray>has been set to tick <green><[tick]>t <gray>in scene <green><[data.name]><gray>."
                    - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"

              #Change id of player model
              - case change_id:
                - define arg_2 <[arg_2]||null>
                - if <[arg_2]> != null:
                  - choose <[arg_2]>:
                    #Prepare for new id
                    - case new_id_prepare:
                      - flag <player> cutscene_modify:set_player_model_id
                      - flag <player> dcutscene_save_data.type:player_model
                      - define text "Chat the new id of the player model."
                      - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
                      - inventory close

                    #Set the player model id
                    - case id_set:
                      - define arg_3 <[arg_3]||null>
                      - if <[arg_3]> != null:
                        - flag <player> cutscene_modify:!
                        - define tick_data <player.flag[dcutscene_tick_modify]>
                        - define tick <[tick_data.tick]>
                        - define uuid <[tick_data.uuid]>
                        - define model_data <[data.keyframes.models]>
                        - define root_data <[model_data.<[tick]>.<[uuid]>.root]||none>
                        #If there is a root update the root and all sub frames
                        - if <[root_data]> != none:
                          - define model_data.<[root_data.tick]>.<[root_data.uuid]>.id <[arg_3]>
                          - define sub_frames <[model_data.<[root_data.tick]>.<[root_data.uuid]>.sub_frames]||none>
                          - if <[sub_frames]> != none:
                            - foreach <[sub_frames]> key:frame_tick as:frame_uuid:
                              - define model_data.<[frame_tick]>.<[frame_uuid]>.id <[arg_3]>
                        #If the model is a root data model update the sub frames should they exist
                        - else:
                          - define model_data.<[tick]>.<[uuid]>.id <[arg_3]>
                          - define sub_frames <[model_data.<[tick]>.<[uuid]>.sub_frames]||none>
                          - if <[sub_frames]> != none:
                            - foreach <[sub_frames]> key:frame_tick as:frame_uuid:
                              - define model_data.<[frame_tick]>.<[frame_uuid]>.id <[arg_3]>
                        - flag server dcutscenes.<[data.name]>.keyframes.models:<[model_data]>
                        - flag <player> cutscene_data:<server.flag[dcutscenes.<[data.name]>]>
                        - define text "Player model ID changed to <green><[arg_3]> <gray>in tick <green><[tick]>t <gray>in scene <green><[data.name]><gray>."
                        - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
                        - inventory open d:dcutscene_inventory_sub_keyframe
                        - ~run dcutscene_sub_keyframe_modify def:<player.flag[dcutscene_sub_keyframe_back_data]>
                - else:
                  - debug error "Could not determine argument for player model ID in dcutscene_model_keyframe_edit"

              #New location for player model
              - case location:
                #New Location for Player Model
                #- TODO:
                #- Implement semi-path system in keyframe
                - define arg_2 <[arg_2]||null>
                - if <[arg_2]> != null:
                  - choose <[arg_2]>:
                    #Preparation for a new player model location
                    - case new_location_prepare:
                      #If there is a present player model remove it
                      - if <player.has_flag[dcutscene_location_editor]>:
                        - define loc_data <player.flag[dcutscene_location_editor]>
                        - define root_ent <[loc_data.root_ent]>
                        - define root_type <[loc_data.root_type]>
                        - choose <[root_type]>:
                          - case player_model:
                            - if <[root_ent].is_spawned>:
                              - run pmodels_remove_model def:<[root_ent]>
                      - define tick_data <player.flag[dcutscene_tick_modify]>
                      - define tick <[tick_data.tick]>
                      - define uuid <[tick_data.uuid]>
                      - define model_data  <[data.keyframes.models]>
                      - define root_save <[model_data.<[tick]>.<[uuid]>.root]||none>
                      - if <[root_save]> == none:
                        - define root_save.tick <[tick]>
                        - define root_save.uuid <[uuid]>
                      - define text "After choosing your location for this player model click <green>Confirm Location <gray>in the location GUI or chat <green>confirm <gray>. To re-open the location GUI do /dcutscene location."
                      - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
                      - flag <player> cutscene_modify:set_new_player_model_location
                      - flag <player> dcutscene_save_data.data:<[root_save]>
                      - define skin <proc[dcutscene_determine_player_model_skin].context[<[data.name]>|<[tick]>|<[uuid]>]>
                      - if <[skin]> == none || <[skin]> == player:
                        - define skin <player>
                      - run pmodels_spawn_model def:<player.location>|<[skin].parsed>|<player> save:spawned
                      - define root <entry[spawned].created_queue.determination.first>
                      - flag <player> dcutscene_save_data.root:<[root]>
                      - run dcutscene_location_tool_give_data def:<player.location>|<[root]>|<[root].location.yaw>|player_model|<[skin]>
                      - inventory open d:dcutscene_inventory_location_tool

                    #Sets the new player model location
                    - case set_location:
                      - flag <player> cutscene_modify:!
                      - define tick_data <player.flag[dcutscene_tick_modify]>
                      - define tick <[tick_data.tick]>
                      - define uuid <[tick_data.uuid]>
                      - define model_data <[data.keyframes.models]>
                      - define root_data <[model_data.<[tick]>.<[uuid]>.root]||none>
                      - if <[root_data]> != none:
                        - define model_data.<[root_data.tick]>.<[root_data.uuid]>.path.<[tick]>.location <[arg_3]>
                      - else:
                        - define model_data.<[tick]>.<[uuid]>.path.<[tick]>.location <[arg_3]>
                      - flag server dcutscenes.<[data.name]>.keyframes.models:<[model_data]>
                      - flag <player> cutscene_data:<server.flag[dcutscenes.<[data.name]>]>
                      - define text "Player Model <green><[model_data.<[tick]>.<[uuid]>.id]> <gray>location is now <green><[arg_3].simple> <gray>in tick <green><[tick]>t <gray>for scene <green><[data.name]><gray>."
                      - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
                      - inventory open d:dcutscene_inventory_keyframe_modify_player_model
                      - define model_root <player.flag[dcutscene_save_data.root]||null>
                      - if <[model_root]> != null || <[model_root].is_spawned>:
                        - run pmodels_remove_model def:<[model_root]>
                      - run dcutscene_location_tool_return_inv
                      - flag <player> dcutscene_location_editor:!
                - else:
                  - debug error "Could not determine argument for player model location in dcutscene_model_keyframe_edit"

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
                        - define model_data <[data.keyframes.models]>
                        - define root_data <[data.keyframes.models.<[tick]>.<[uuid]>.root]||none>
                        #If the model contains a root data model
                        - if <[root_data]> != none:
                          - define model_data.<[root_data.tick]>.<[root_data.uuid]>.path.<[tick]>.animation <[arg_3]>
                        #If the model is a root model
                        - else:
                          - define model_data.<[tick]>.<[uuid]>.path.<[tick]>.animation <[arg_3]>
                        - flag server dcutscenes.<[data.name]>.keyframes.models:<[model_data]>
                        - flag <player> cutscene_data:<server.flag[dcutscenes.<[data.name]>]>
                        - define text "Player Model <green><[model_data.<[tick]>.<[uuid]>.id]> <gray>animation is now <green><[arg_3]> <gray>in tick <green><[tick]>t <gray>for scene <green><[data.name]><gray>."
                        - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
                        - inventory open d:dcutscene_inventory_keyframe_modify_player_model

              #Whether the model will move to the next keyframe point
              - case set_move:
                - define arg_2 <[arg_2]||null>
                - if <[arg_2]> != null:
                  - define tick_data <player.flag[dcutscene_tick_modify]>
                  - define tick <[tick_data.tick]>
                  - define uuid <[tick_data.uuid]>
                  - define model_data <[data.keyframes.models]>
                  - define root_data <[data.keyframes.models.<[tick]>.<[uuid]>.root]||none>
                  #If the model contains a root data model
                  - if <[root_data]> != none:
                    - define move <[model_data.<[root_data.tick]>.<[root_data.uuid]>.path.<[tick]>.move]>
                    - choose <[move]>:
                      - case true:
                        - define model_data.<[root_data.tick]>.<[root_data.uuid]>.path.<[tick]>.move false
                        - define move false
                      - case false:
                        - define model_data.<[root_data.tick]>.<[root_data.uuid]>.path.<[tick]>.move true
                        - define move true
                  #If the model is a root model
                  - else:
                    - define move <[model_data.<[tick]>.<[uuid]>.path.<[tick]>.move]>
                    - choose <[move]>:
                      - case true:
                        - define model_data.<[tick]>.<[uuid]>.path.<[tick]>.move false
                        - define move false
                      - case false:
                        - define model_data.<[tick]>.<[uuid]>.path.<[tick]>.move true
                        - define move true
                  - flag server dcutscenes.<[data.name]>.keyframes.models:<[model_data]>
                  - flag <player> cutscene_data:<server.flag[dcutscenes.<[data.name]>]>
                  - define l1 "<gold>Move: <gray><[move]>"
                  - define l2 "<gray><italic>Click to change player model move"
                  - define lore <list[<empty>|<[l1]>|<empty>|<[l2]>]>
                  - inventory adjust d:<player.open_inventory> slot:<[arg_2]> lore:<[lore]>

              #Ray Trace Modifying
              - case ray_trace:
                - define arg_2 <[arg_2]||null>
                - if <[arg_2]> != null:
                  - define tick_data <player.flag[dcutscene_tick_modify]>
                  - define tick <[tick_data.tick]>
                  - define uuid <[tick_data.uuid]>
                  - define model_data <[data.keyframes.models]>
                  - define root_data <[model_data.<[tick]>.<[uuid]>.root]||none>
                  #Ray Trace Data
                  - if <[root_data]> != none:
                    - define tick_modify <[root_data.tick]>
                    - define uuid_modify <[root_data.uuid]>
                    - define ray_trace <[model_data.<[root_data.tick]>.<[root_data.uuid]>.path.<[tick]>.ray_trace]>
                  - else:
                    - define tick_modify <[tick]>
                    - define uuid_modify <[uuid]>
                    - define ray_trace <[model_data.<[tick]>.<[uuid]>.path.<[tick]>.ray_trace]>
                  - choose <[arg_2]>:
                    #Ray Trace Direction
                    - case ray_trace_direction:
                      - define direction <[ray_trace.direction]||floor>
                      - choose <[direction]>:
                        - case false:
                          - define direction floor
                        - case floor:
                          - define direction ceiling
                        - case ceiling:
                          - define direction false
                      - define l1 "<red>Direction: <gray><[direction]>"
                      - define l2 "<gray><italic>Click to change ray trace direction"
                      - define model_data.<[tick_modify]>.<[uuid_modify]>.path.<[tick_modify]>.ray_trace.direction:<[direction]>
                    #Ray Trace Liquid
                    - case ray_trace_liquid:
                      - define liquid <[ray_trace.liquid]||false>
                      - choose <[liquid]>:
                        - case false:
                          - define liquid true
                        - case true:
                          - define liquid false
                      - define l1 "<blue>Liquid: <gray><[liquid]>"
                      - define l2 "<gray><italic>Click to change ray trace liquid"
                      - define model_data.<[tick_modify]>.<[uuid_modify]>.path.<[tick_modify]>.ray_trace.liquid:<[liquid]>
                    #Ray Trace Passable
                    - case ray_trace_passable:
                      - define passable <[ray_trace.passable]||false>
                      - choose <[passable]>:
                        - case false:
                          - define passable true
                        - case true:
                          - define passable false
                      - define l1 "<green>Passable: <gray><[passable]>"
                      - define l2 "<gray><italic>Click to change ray trace passable"
                      - define model_data.<[tick_modify]>.<[uuid_modify]>.path.<[tick_modify]>.ray_trace.passable:<[passable]>
                  - flag server dcutscenes.<[data.name]>.keyframes.models:<[model_data]>
                  - flag <player> cutscene_data:<server.flag[dcutscenes.<[data.name]>]>
                  - define lore <list[<empty>|<[l1]>|<empty>|<[l2]>]>
                  - inventory adjust d:<player.open_inventory> slot:<[arg_3]> lore:<[lore]>

              #Set the path interpolation method
              - case change_path_interp:
                - define tick_data <player.flag[dcutscene_tick_modify]>
                - define tick <[tick_data.tick]>
                - define uuid <[tick_data.uuid]>
                - define model_data <[data.keyframes.models]>
                - define root_data <[model_data.<[tick]>.<[uuid]>.root]||none>
                #If the model contains a root data model
                - if <[root_data]> != none:
                  - define interp <[model_data.<[root_data.tick]>.<[root_data.uuid]>.path.<[tick]>.interpolation]>
                  - choose <[interp]>:
                    - case linear:
                      - define model_data.<[root_data.tick]>.<[root_data.uuid]>.path.<[tick]>.interpolation smooth
                      - define interp smooth
                    - case smooth:
                      - define model_data.<[root_data.tick]>.<[root_data.uuid]>.path.<[tick]>.interpolation linear
                      - define interp linear
                #If the model is a root data model
                - else:
                  - define interp <[model_data.<[tick]>.<[uuid]>.path.<[tick]>.interpolation]>
                  - choose <[interp]>:
                    - case linear:
                      - define model_data.<[tick]>.<[uuid]>.path.<[tick]>.interpolation smooth
                      - define interp smooth
                    - case smooth:
                      - define model_data.<[tick]>.<[uuid]>.path.<[tick]>.interpolation linear
                      - define interp linear
                - flag server dcutscenes.<[data.name]>.keyframes.models:<[model_data]>
                - flag <player> cutscene_data:<server.flag[dcutscenes.<[data.name]>]>
                - define l1 "<blue>Interpolation: <gray><[interp]>"
                - define l2 "<gray><italic>Click to change path interpolation method"
                - define lore <list[<empty>|<[l1]>|<empty>|<[l2]>]>
                - inventory adjust d:<player.open_inventory> slot:<[arg_2]> lore:<[lore]>

              #Change player model skin
              - case change_skin:
                - choose <[arg_2]>:
                  #Preparation for new skin
                  - case new_skin_prepare:
                    - define text "Chat a valid tag of a player or npc. To use the player's skin chat <green>player <gray>to do nothing chat <green>none<gray>. Chat <red>cancel <gray>to stop."
                    - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
                    - flag <player> cutscene_modify:player_model_change_skin
                    - inventory close
                  #Set the new skin
                  - case set_new_skin:
                    - define arg_3 <[arg_3]||null>
                    - if <[arg_3]> != null:
                      - define tick_data <player.flag[dcutscene_tick_modify]>
                      - define tick <[tick_data.tick]>
                      - define uuid <[tick_data.uuid]>
                      - define model_data <[data.keyframes.models]>
                      - define root_data <[model_data.<[tick]>.<[uuid]>.root]||none>
                      - if <[root_data]> != none:
                        - define tick_modify <[root_data.tick]>
                        - define uuid_modify <[root_data.uuid]>
                      - else:
                        - define tick_modify <[tick]>
                        - define uuid_modify <[uuid]>
                      - define model_data.<[tick_modify]>.<[uuid_modify]>.path.<[tick]>.skin:<[arg_3]>
                      - flag server dcutscenes.<[data.name]>.keyframes.models:<[model_data]>
                      - flag <player> cutscene_data:<server.flag[dcutscenes.<[data.name]>]>
                      - inventory open d:dcutscene_inventory_keyframe_modify_player_model
                      - define text "Player model <green><[model_data.<[tick]>.<[uuid]>.id]> <gray>skin is now <green><[arg_3].parsed||<[arg_3]>> <gray>in tick <green><[tick]>t <gray>in scene <green><[data.name]><gray>."
                      - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"

              #Teleport to player model location
              - case teleport_to:
                - define tick_data <player.flag[dcutscene_tick_modify]>
                - define tick <[tick_data.tick]>
                - define uuid <[tick_data.uuid]>
                - define model_data <[data.keyframes.models]>
                - define root_data <[model_data.<[tick]>.<[uuid]>.root]||none>
                - if <[root_data]> != none:
                  - define tick_mod <[root_data.tick]>
                  - define tick_uuid <[root_data.uuid]>
                - else:
                  - define tick_mod <[tick]>
                  - define tick_uuid <[uuid]>
                - define loc <[model_data.<[tick_mod]>.<[tick_uuid]>.path.<[tick]>.location]||null>
                - if <[loc]> == null:
                  - debug error "Could not find location to teleport to in dcutscene_model_keyframe_edit for player model"
                - else:
                  - teleport <player> <location[<[loc]>]>
                  - define text "You have teleport to player model <green><[model_data.<[tick_mod]>.<[tick_uuid]>.id]> <gray>location in tick <green><[tick]>t <gray>in scene <green><[data.name]><gray>."
                  - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
                  - inventory open d:dcutscene_inventory_keyframe_modify_player_model

              #Removes model from tick
              - case remove_tick:
                - define tick_data <player.flag[dcutscene_tick_modify]>
                - define tick <[tick_data.tick]>
                - define uuid <[tick_data.uuid]>
                - define model_data <[data.keyframes.models]>
                - define root_data <[model_data.<[tick]>.<[uuid]>.root]||none>
                #If the model has a root data model
                - if <[root_data]> != none:
                  #Update the root data model
                  - define root_update <[model_data.<[root_data.tick]>.<[root_data.uuid]>]>
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

              #TODO:
              #- Ensure this removes the specified model and not every single one in the cutscene
              #Removes model from entire cutscene
              - case remove_all:
                - define tick_data <player.flag[dcutscene_tick_modify]>
                - define tick <[tick_data.tick]>
                - define uuid <[tick_data.uuid]>
                - define model_data <[data.keyframes.models]>
                - define root_data <[model_data.<[tick]>.<[uuid]>.root]||none>
                #If there is a root data model in the tick
                - if <[root_data]> != none:
                  - define sub_frames <[model_data.<[root_data.tick]>.<[root_data.uuid]>.sub_frames]>
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

#Used to determine the previous skin in the player model keyframe
dcutscene_determine_player_model_skin:
    type: procedure
    definitions: scene|tick|uuid
    debug: false
    script:
    - define data <server.flag[dcutscenes.<[scene]>]||null>
    - if <[data]> != null:
      - define model_data <[data.keyframes.models]>
      - define root_data <[model_data.<[tick]>.<[uuid]>.root]||none>
      - if <[root_data]> != none:
        - define skin_check <[model_data.<[root_data.tick]>.<[root_data.uuid]>.path.<[tick]>.skin]||none>
        - if <[skin_check]> != none:
          - determine <[skin_check]>
        - define path <[model_data.<[root_data.tick]>.<[root_data.uuid]>.path]||<list>>
      - else:
        - define skin_check <[model_data.<[tick]>.<[uuid]>.path.<[tick]>.skin]||none>
        - if <[skin_check]> != none:
          - determine <[skin_check]>
        - define path <[model_data.<[tick]>.<[uuid]>.path]||<list>>
      - foreach <[path]> key:tick_id as:path:
        - define compare <[tick_id].is_less_than[<[tick]>]>
        - if <[compare].is_truthy>:
          - define skin <[path.skin]||none>
          - if <[skin]> != none:
            - define list:->:<[path]>
      - define list <[list]||null>
      - if <[list]> == null:
        - determine <[model_data.<[tick]>.<[uuid]>.path.<[tick]>.skin]||none>
      - else:
        - determine <[list].last.get[skin]||none>
    - else:
      - debug error "Could not find scene in dcutscene_determine_player_model_skin"
      - determine none

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
      - define tick <player.flag[dcutscene_tick_modify]>
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
                  - define tick <player.flag[dcutscene_tick_modify.tick]>
                  - define uuid <player.flag[dcutscene_tick_modify.uuid]>
                  - define keyframe <[keyframes.run_task.<[tick]>.<[uuid]>]||null>
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
                  - define tick <player.flag[dcutscene_tick_modify.tick]>
                  - define uuid <player.flag[dcutscene_tick_modify.uuid]>
                  - define keyframe <[keyframes.run_task.<[tick]>.<[uuid]>]||null>
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
                - define tick <player.flag[dcutscene_tick_modify.tick]>
                - define uuid <player.flag[dcutscene_tick_modify.uuid]>
                - define keyframe <[keyframes.run_task.<[tick]>.<[uuid]>]||null>
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
              - if <[arg_2]> != null:
                - flag <player> cutscene_modify:!
                - define tick <player.flag[dcutscene_tick_modify.tick]>
                - define uuid <player.flag[dcutscene_tick_modify.uuid]>
                - define duration <[arg_2]>
                - define keyframe <[keyframes.run_task.<[tick]>.<[uuid]>]||null>
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
              - define tick <player.flag[dcutscene_tick_modify.tick]>
              - define uuid <player.flag[dcutscene_tick_modify.uuid]>
              - define keyframe <[keyframes.run_task]>
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
              - define effect_check <[keyframes.screeneffect.<[tick]>]||null>
              - if <[effect_check]> != null:
                - define text "There is already a cinematic screeneffect on tick <green><[tick]>t <gray>in scene <green><[data.name]><gray>."
                - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
              - else:
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
                  - define keyframe <[keyframes.screeneffect.<[tick]>]>
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
                  - define keyframe <[keyframes.screeneffect.<[tick]>]>
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
              - define keyframe <[keyframes.screeneffect].deep_exclude[<[tick]>]>
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
              - define text "To add a sound to this keyframe do /dcutscene sound <green>my_sound<gray>. To stop chat <red>cancel<gray>."
              - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
              - inventory close

            #Create new sound
            - case create:
              - define arg_2 <[arg_2]||null>
              - if <[arg_2]> != null:
                - flag <player> cutscene_modify:!
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
                - define keyframe <[keyframes.sound.<[tick]>.<[uuid]>]||null>
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
                - define keyframe <[keyframes.sound.<[tick]>.<[uuid]>]||null>
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
                - define keyframe <[keyframes.sound.<[tick]>.<[uuid]>]||null>
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
                - define keyframe <[keyframes.sound.<[tick]>.<[uuid]>]||null>
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
              - define sound <[keyframes.sound.<[tick]>.<[uuid]>.sound]>
              - define keyframe <[keyframes.sound]>
              #New modified data with sound removed
              - define new_keyframe <[keyframe.<[tick]>].deep_exclude[<[uuid]>]>
              - define new_keyframe.sounds:<-:<[uuid]>
              #If the animator list is empty for the tick remove the tick
              - if <[new_keyframe.sounds].is_empty>:
                #Keyframe with tick removed
                - define keyframe <[keyframes.sound].deep_exclude[<[tick]>]>
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

        #============ Fake Block or Schematic Modifier =============
        - case fake_object:
          - choose <[arg]>:
            #====== Fake Block =======
            #Preparation for new fake block material
            - case new_fake_block_material:
              - define text "Input a material with /dcutscene material <green>example_block<gray>. Chat <red>cancel <gray>to stop."
              - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
              - flag <player> cutscene_modify:fake_block_material expire:3m
              - inventory close

            #Prepare for new location
            - case new_fake_block_material_set:
              - define arg_2 <material[<[arg_2]>]||null>
              - define mat_check <material[<[arg_2]>].is_block||false>
              - if <[arg_2]> != null || <[mat_check].is_truthy>:
                - flag <player> dcutscene_save_data.block:<[arg_2]>
                - define text "Right click on the block you'd like to fake show to or chat a valid location tag. Chat <red>cancel <gray>to stop."
                - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
                - flag <player> cutscene_modify:fake_block_location expire:5m
              - else:
                - define text "<green><[arg_2]> <gray>is not a valid material."
                - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"

            #Set the new block and input the fake block into the keyframe modifier
            - case new_fake_block_loc:
              - define arg_2 <location[<[arg_2]>]||null>
              - if <[arg_2]> != null:
                - flag <player> cutscene_modify:!
                - define uuid <util.random_uuid>
                - define keyframes.fake_object.fake_block.<[tick]>.fake_blocks:->:<[uuid]>
                - definemap proc_data script:none defs:none
                - definemap fake_block_data loc:<[arg_2]> block:<player.flag[dcutscene_save_data.block]> procedure:<[proc_data]> duration:10s
                - define keyframes.fake_object.fake_block.<[tick]>.<[uuid]> <[fake_block_data]>
                - flag server dcutscenes.<[data.name]>.keyframes.elements:<[keyframes]>
                - flag <player> cutscene_data:<server.flag[dcutscenes.<[data.name]>]>
                - ~run dcutscene_sort_data def:<[scene_name]>
                - define text "Fake block <green><player.flag[dcutscene_save_data.block].name> <gray>set at location <green><[arg_2].simple> <gray>in tick <green><[tick]>t <gray>in scene <green><[data.name]><gray>."
                - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
                - inventory open d:dcutscene_inventory_sub_keyframe
                - ~run dcutscene_sub_keyframe_modify def:<player.flag[dcutscene_sub_keyframe_back_data]>
              - else:
                - define text "<green><[arg_2]> <gray>is not a valid location."
                - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"

            #Preparation for setting a new fake block location
            - case set_fake_block_prepare:
              - define text "Right click on the block you'd like to fake show to or chat a valid location tag. Chat <red>cancel <gray>to stop."
              - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
              - flag <player> cutscene_modify:set_fake_block_location expire:5m
              - inventory close

            #Set a new fake block location in the already created keyframe
            - case set_fake_block_loc:
              - define arg_2 <location[<[arg_2]>]||null>
              - if <[arg_2]> != null:
                - flag <player> cutscene_modify:!
                - define tick <player.flag[dcutscene_tick_modify.tick]>
                - define uuid <player.flag[dcutscene_tick_modify.uuid]>
                - define fake_block <[keyframes.fake_object.fake_block.<[tick]>.<[uuid]>]>
                - define fake_block.loc <[arg_2]>
                - flag server dcutscenes.<[data.name]>.keyframes.elements.fake_object.fake_block.<[tick]>.<[uuid]>:<[fake_block]>
                - flag <player> cutscene_data:<server.flag[dcutscenes.<[data.name]>]>
                - inventory open d:dcutscene_inventory_fake_object_block_modify
                - define text "Fake block <green><[fake_block.block].name> <gray>on tick <green><[tick]>t <gray>location has been changed to <green><[arg_2].simple> <gray>in scene <green><[data.name]><gray>."
                - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
              - else:
                - define text "<green><[arg_2]> <gray>is not a valid location."

            #Preparation for setting a new fake block material
            - case set_fake_block_material_prep:
              - define text "Input a material with /dcutscene material <green>example_block<gray>. Chat <red>cancel <gray>to stop."
              - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
              - flag <player> cutscene_modify:set_fake_block_material expire:3m
              - inventory close

            #Set the new fake block material
            - case set_fake_block_material:
              - define arg_2 <material[<[arg_2]>]||null>
              - define mat_check <material[<[arg_2]>].is_block||false>
              - if <[arg_2]> != null || <[mat_check].is_truthy>:
                - flag <player> cutscene_modify:!
                - define tick <player.flag[dcutscene_tick_modify.tick]>
                - define uuid <player.flag[dcutscene_tick_modify.uuid]>
                - define fake_block <[keyframes.fake_object.fake_block.<[tick]>.<[uuid]>]>
                - define fake_block.block <[arg_2]>
                - flag server dcutscenes.<[data.name]>.keyframes.elements.fake_object.fake_block.<[tick]>.<[uuid]>:<[fake_block]>
                - flag <player> cutscene_data:<server.flag[dcutscenes.<[data.name]>]>
                - inventory open d:dcutscene_inventory_fake_object_block_modify
                - define text "Fake block <[fake_block.block].name> on tick <green><[tick]>t <gray>material has been changed to <green><[arg_2].name> <gray>in scene <green><[data.name]><gray>."
                - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
              - else:
                - define text "<green><[arg_2]> <gray>is not a valid material."
                - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"

            #Procedure script preparation
            - case set_fake_block_proc_prepare:
              - define text "Chat the name of the procedure script. Chat <red>cancel <gray>to stop."
              - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
              - flag <player> cutscene_modify:fake_block_proc_script expire:2m
              - inventory close

            #Set procedure script
            - case set_fake_block_proc:
              - define proc_check <player.location.proc[<[arg_2]>]||null>
              - if <[proc_check]> != null:
                - flag <player> cutscene_modify:!
                - define tick <player.flag[dcutscene_tick_modify.tick]>
                - define uuid <player.flag[dcutscene_tick_modify.uuid]>
                - define fake_block <[keyframes.fake_object.fake_block.<[tick]>.<[uuid]>]>
                - define fake_block.procedure.script <[arg_2]>
                - flag server dcutscenes.<[data.name]>.keyframes.elements.fake_object.fake_block.<[tick]>.<[uuid]>:<[fake_block]>
                - flag <player> cutscene_data:<server.flag[dcutscenes.<[data.name]>]>
                - inventory open d:dcutscene_inventory_fake_object_block_modify
                - define text "Fake block <green><[fake_block.block].name> <gray>on tick <green><[tick]>t <gray>procedure script is now <green><[arg_2]> <gray>in scene <green><[data.name]><gray>."
                - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
              - else:
                - define text "<green><[arg_2]> <gray>is not a valid procedure script."
                - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"

            #Procedure definition preparation
            - case set_fake_block_proc_def_prepare:
              - define text "Chat the definitions for the procedure script. Chat <red>cancel <gray>to stop."
              - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
              - flag <player> cutscene_modify:fake_block_proc_def expire:5m
              - inventory close

            #Set the procedure definitions
            - case set_fake_block_proc_def:
              - flag <player> cutscene_modify:!
              - define tick <player.flag[dcutscene_tick_modify.tick]>
              - define uuid <player.flag[dcutscene_tick_modify.uuid]>
              - define fake_block <[keyframes.fake_object.fake_block.<[tick]>.<[uuid]>]>
              - define fake_block.procedure.defs <[arg_2]>
              - flag server dcutscenes.<[data.name]>.keyframes.elements.fake_object.fake_block.<[tick]>.<[uuid]>:<[fake_block]>
              - flag <player> cutscene_data:<server.flag[dcutscenes.<[data.name]>]>
              - inventory open d:dcutscene_inventory_fake_object_block_modify
              - define text "Fake block <green><[fake_block.block].name> <gray>on tick <green><[tick]>t <gray>procedure definition is now <green><[arg_2]> <gray>in scene <green><[data.name]><gray>."
              - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"

            #Fake block duration
            - case set_fake_block_duration_prepare:
              - define text "Chat the duration of the fake block. Chat <red>cancel <gray>to stop."
              - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
              - flag <player> cutscene_modify:fake_block_duration expire:2m
              - inventory close

            #Set fake block duration
            - case set_fake_block_duration:
              - define duration_check <duration[<[arg_2]>]||null>
              - if <[duration_check]> != null:
                - flag <player> cutscene_modify:!
                - define tick <player.flag[dcutscene_tick_modify.tick]>
                - define uuid <player.flag[dcutscene_tick_modify.uuid]>
                - define fake_block <[keyframes.fake_object.fake_block.<[tick]>.<[uuid]>]>
                - define fake_block.duration <duration[<[arg_2]>]>
                - flag server dcutscenes.<[data.name]>.keyframes.elements.fake_object.fake_block.<[tick]>.<[uuid]>:<[fake_block]>
                - flag <player> cutscene_data:<server.flag[dcutscenes.<[data.name]>]>
                - inventory open d:dcutscene_inventory_fake_object_block_modify
                - define text "Fake block <green><[fake_block.block].name> <gray>on tick <green><[tick]>t <gray>duration is now <green><duration[<[arg_2]>].formatted> <gray>in scene <green><[data.name]><gray>."
                - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
              - else:
                - define text "<green><[arg_2]> <gray>is not a valid duration."
                - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"

            #Teleport to location
            - case teleport_to_fake_block:
              - define tick <player.flag[dcutscene_tick_modify.tick]>
              - define uuid <player.flag[dcutscene_tick_modify.uuid]>
              - define loc <[keyframes.fake_object.fake_block.<[tick]>.<[uuid]>.loc]>
              - teleport <player> <[loc]>
              - define text "You have teleported to fake block location <green><[loc].simple> <gray>in tick <green><[tick]>t <gray>in scene <green><[data.name]><gray>."
              - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
              - inventory open d:dcutscene_inventory_fake_object_block_modify

            #Remove the fake block
            - case remove_fake_block:
              - define tick <player.flag[dcutscene_tick_modify.tick]>
              - define uuid <player.flag[dcutscene_tick_modify.uuid]>
              #Data
              - define fake_object <[keyframes.fake_object]>
              #Block name
              - define fake_block <[fake_object.fake_block.<[tick]>.<[uuid]>.block].name>
              #Remove uuid from list
              - define fake_object.fake_block.<[tick]>.fake_blocks:<-:<[uuid]>
              #Remove the uuid
              - define fake_object.fake_block.<[tick]> <[fake_object.fake_block.<[tick]>].deep_exclude[<[uuid]>]>
              #If list is empty remove tick
              - if <[fake_object.fake_block.<[tick]>.fake_blocks].is_empty>:
                - define fake_object.fake_block <[fake_object.fake_block].deep_exclude[<[tick]>]>
              - flag server dcutscenes.<[data.name]>.keyframes.elements.fake_object:<[fake_object]>
              - flag <player> cutscene_data:<server.flag[dcutscenes.<[data.name]>]>
              - inventory open d:dcutscene_inventory_sub_keyframe
              - ~run dcutscene_sub_keyframe_modify def:<player.flag[dcutscene_sub_keyframe_back_data]>
              - define text "Fake block <green><[fake_block]> <gray>has been removed from tick <green><[tick]>t <gray>in scene <green><[data.name]><gray>."
              - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
            #=================================

            #======== Fake Schematic =========
            #Preparation for schematic
            - case new_schem_name:
              - define text "Chat the name of the schematic. To stop chat <red>cancel<gray>."
              - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
              - flag <player> cutscene_modify:new_fake_schem_name expire:2m
              - inventory close

            #Input schematic name
            - case new_schem_loc:
              - if <schematic[<[arg_2]>].exists>:
                - flag <player> cutscene_modify:new_fake_schem_loc expire:5m
                - flag <player> dcutscene_save_data.schem_name:<[arg_2]>
                - define text "Right click on the block you'd like to paste this schematic or chat a valid location tag the location's center will automatically be parsed. Chat <red>cancel <gray>to stop."
                - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
              - else:
                - define text "Could not find schematic <green><[arg_2]><gray>."
                - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"

            #Set the new fake schematic
            - case new_schem_create:
              - if <location[<[arg_2]>]||null> != null:
                - flag <player> cutscene_modify:!
                - definemap fake_schem_data schem:<player.flag[dcutscene_save_data.schem_name]> loc:<[arg_2]> duration:10s noair:true waitable:false angle:forward mask:false
                - define uuid <util.random_uuid>
                - define keyframes.fake_object.fake_schem.<[tick]>.fake_schems:->:<[uuid]>
                - define keyframes.fake_object.fake_schem.<[tick]>.<[uuid]> <[fake_schem_data]>
                - flag server dcutscenes.<[data.name]>.keyframes.elements:<[keyframes]>
                - flag <player> cutscene_data:<server.flag[dcutscenes.<[data.name]>]>
                - ~run dcutscene_sort_data def:<[scene_name]>
                - define text "Fake schematic <green><player.flag[dcutscene_save_data.schem_name]> <gray>set at location <green><[arg_2].simple> <gray>in tick <green><[tick]>t <gray>in scene <green><[data.name]><gray>."
                - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
                - inventory open d:dcutscene_inventory_sub_keyframe
                - ~run dcutscene_sub_keyframe_modify def:<player.flag[dcutscene_sub_keyframe_back_data]>
              - else:
                - define text "<green><[arg_2]> <gray>is not a valid location."
                - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"

            #Name change prepare
            - case change_schem_name_prep:
              - define text "Chat the name of the new schematic. Chat <red>cancel <gray>to stop."
              - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
              - flag <player> cutscene_modify:change_fake_schem_name expire:2m
              - inventory close

            #Change schem name
            - case change_schem_name:
              - if <schematic[<[arg_2]>].exists>:
                - flag <player> cutscene_modify:!
                - define tick <player.flag[dcutscene_tick_modify.tick]>
                - define uuid <player.flag[dcutscene_tick_modify.uuid]>
                - define fake_schem <[keyframes.fake_object.fake_schem.<[tick]>.<[uuid]>]>
                - define pre_name <[fake_schem.schem]>
                - define fake_schem.schem <[arg_2]>
                - flag server dcutscenes.<[data.name]>.keyframes.elements.fake_object.fake_schem.<[tick]>.<[uuid]>:<[fake_schem]>
                - flag <player> cutscene_data:<server.flag[dcutscenes.<[data.name]>]>
                - inventory open d:dcutscene_inventory_fake_object_schem_modify
                - define text "Fake schematic <green><[pre_name]> <gray>name is now <green><[fake_schem.schem]> <gray>in tick <green><[tick]>t <gray>for scene <green><[data.name]><gray>."
                - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
              - else:
                - define text "Could not find schematic <green><[arg_2]><gray>."
                - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"

            #Change Schem Location Prepare
            - case change_schem_loc_prep:
              - define text "Right click on the block you'd like to paste this schematic or chat a valid location tag the location's center will automatically be parsed. Chat <red>cancel <gray>to stop."
              - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
              - flag <player> cutscene_modify:change_fake_schem_loc expire:5m
              - inventory close

            #Change Schem Location
            - case change_schem_loc:
              - if <location[<[arg_2]>]||null> != null:
                - flag <player> cutscene_modify:!
                - define tick <player.flag[dcutscene_tick_modify.tick]>
                - define uuid <player.flag[dcutscene_tick_modify.uuid]>
                - define fake_schem <[keyframes.fake_object.fake_schem.<[tick]>.<[uuid]>]>
                - define fake_schem.loc <location[<[arg_2]>]>
                - flag server dcutscenes.<[data.name]>.keyframes.elements.fake_object.fake_schem.<[tick]>.<[uuid]>:<[fake_schem]>
                - flag <player> cutscene_data:<server.flag[dcutscenes.<[data.name]>]>
                - inventory open d:dcutscene_inventory_fake_object_schem_modify
                - define text "Fake schematic <green><[fake_schem.schem]> <gray>location is now <green><[arg_2].simple> <gray>in tick <green><[tick]>t <gray>for scene <green><[data.name]><gray>."
                - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
              - else:
                - define text "<green><[arg_2]> <gray>is not a valid location."
                - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"

            #Change Schem Duration Prep
            - case change_schem_duration_prep:
              - define text "Chat the duration this schematic will appear for. Chat <red>cancel <gray>to stop."
              - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
              - flag <player> cutscene_modify:change_fake_schem_duration expire:2.5m
              - inventory close

            #Change Schem Duration
            - case change_schem_duration:
              - define duration_check <duration[<[arg_2]>]||null>
              - if <[duration_check]> != null:
                - flag <player> cutscene_modify:!
                - define tick <player.flag[dcutscene_tick_modify.tick]>
                - define uuid <player.flag[dcutscene_tick_modify.uuid]>
                - define fake_schem <[keyframes.fake_object.fake_schem.<[tick]>.<[uuid]>]>
                - define fake_schem.duration <duration[<[arg_2]>]>
                - flag server dcutscenes.<[data.name]>.keyframes.elements.fake_object.fake_schem.<[tick]>.<[uuid]>:<[fake_schem]>
                - flag <player> cutscene_data:<server.flag[dcutscenes.<[data.name]>]>
                - inventory open d:dcutscene_inventory_fake_object_schem_modify
                - define text "Fake schematic <green><[fake_schem.schem]> <gray>duration is now <green><duration[<[arg_2]>].formatted> <gray>in tick <green><[tick]>t <gray>for scene <green><[data.name]><gray>."
                - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
              - else:
                - define text "<green><[arg_2]> <gray>is not a valid duration."
                - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"

            #Change Schem Noair
            - case change_schem_noair:
              - define tick <player.flag[dcutscene_tick_modify.tick]>
              - define uuid <player.flag[dcutscene_tick_modify.uuid]>
              - define fake_schem <[keyframes.fake_object.fake_schem.<[tick]>.<[uuid]>]>
              - choose <[fake_schem.noair]>:
                - case true:
                  - define fake_schem.noair false
                - case false:
                  - define fake_schem.noair true
              - flag server dcutscenes.<[data.name]>.keyframes.elements.fake_object.fake_schem.<[tick]>.<[uuid]>:<[fake_schem]>
              - flag <player> cutscene_data:<server.flag[dcutscenes.<[data.name]>]>
              - define l1 "<aqua>No air: <gray><[fake_schem.noair]>"
              - define click "<gray><italic>Click to change schematic noair"
              - define lore <list[<empty>|<[l1]>|<empty>|<[click]>]>
              - inventory adjust d:<player.open_inventory> slot:<[arg_2]> lore:<[lore]>

            #Change schem waitable
            - case change_schem_waitable:
              - define tick <player.flag[dcutscene_tick_modify.tick]>
              - define uuid <player.flag[dcutscene_tick_modify.uuid]>
              - define fake_schem <[keyframes.fake_object.fake_schem.<[tick]>.<[uuid]>]>
              - choose <[fake_schem.waitable]>:
                - case true:
                  - define fake_schem.waitable false
                - case false:
                  - define fake_schem.waitable true
              - flag server dcutscenes.<[data.name]>.keyframes.elements.fake_object.fake_schem.<[tick]>.<[uuid]>:<[fake_schem]>
              - flag <player> cutscene_data:<server.flag[dcutscenes.<[data.name]>]>
              - define l1 "<gold>Waitable: <gray><[fake_schem.waitable]>"
              - define click "<gray><italic>Click to change schematic waitable"
              - define lore <list[<empty>|<[l1]>|<empty>|<[click]>]>
              - inventory adjust d:<player.open_inventory> slot:<[arg_2]> lore:<[lore]>

            #Change schem direction
            - case change_schem_direction:
              - define tick <player.flag[dcutscene_tick_modify.tick]>
              - define uuid <player.flag[dcutscene_tick_modify.uuid]>
              - define fake_schem <[keyframes.fake_object.fake_schem.<[tick]>.<[uuid]>]>
              - choose <[fake_schem.angle]||forward>:
                - case forward:
                  - define fake_schem.angle backward
                - case backward:
                  - define fake_schem.angle right
                - case right:
                  - define fake_schem.angle left
                - case left:
                  - define fake_schem.angle forward
              - flag server dcutscenes.<[data.name]>.keyframes.elements.fake_object.fake_schem.<[tick]>.<[uuid]>:<[fake_schem]>
              - flag <player> cutscene_data:<server.flag[dcutscenes.<[data.name]>]>
              - define l1 "<dark_blue>Direction: <gray><[fake_schem.angle]>"
              - define click "<gray><italic>Click to change schematic paste direction"
              - define lore <list[<empty>|<[l1]>|<empty>|<[click]>]>
              - inventory adjust d:<player.open_inventory> slot:<[arg_2]> lore:<[lore]>

            #Teleport to fake schem location
            - case teleport_to_fake_schem:
              - define tick <player.flag[dcutscene_tick_modify.tick]>
              - define uuid <player.flag[dcutscene_tick_modify.uuid]>
              - define fake_schem <[keyframes.fake_object.fake_schem.<[tick]>.<[uuid]>]>
              - teleport <player> <[fake_schem.loc]>
              - define text "You have teleported to fake schematic location <green><[fake_schem.loc].simple> <gray>in tick <green><[tick]>t <gray>in scene <green><[data.name]><gray>."
              - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
              - inventory open d:dcutscene_inventory_fake_object_schem_modify

            #Remove fake schem
            - case remove_fake_schem:
              - define tick <player.flag[dcutscene_tick_modify.tick]>
              - define uuid <player.flag[dcutscene_tick_modify.uuid]>
              #Data
              - define fake_object <[keyframes.fake_object]>
              #Schem name
              - define fake_schem <[fake_object.fake_schem.<[tick]>.<[uuid]>.schem]>
              #Remove uuid from list
              - define fake_object.fake_schem.<[tick]>.fake_schems:<-:<[uuid]>
              #Remove the uuid
              - define fake_object.fake_schem.<[tick]> <[fake_object.fake_schem.<[tick]>].deep_exclude[<[uuid]>]>
              #If list is empty remove tick
              - if <[fake_object.fake_schem.<[tick]>.fake_schems].is_empty>:
                - define fake_object.fake_schem <[fake_object.fake_schem].deep_exclude[<[tick]>]>
              - flag server dcutscenes.<[data.name]>.keyframes.elements.fake_object:<[fake_object]>
              - flag <player> cutscene_data:<server.flag[dcutscenes.<[data.name]>]>
              - inventory open d:dcutscene_inventory_sub_keyframe
              - ~run dcutscene_sub_keyframe_modify def:<player.flag[dcutscene_sub_keyframe_back_data]>
              - define text "Fake schematic <green><[fake_schem]> <gray>has been removed from tick <green><[tick]>t <gray>in scene <green><[data.name]><gray>."
              - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
            #============================
            #===========================================

        #============= Particle Modifier ===============
        - case particle:
          - choose <[arg]>:
            #Preparation for new particle
            - case new_particle_prep:
              - define text "To add a new particle use the command /dcutscene particle <green>my_particle<gray>."
              - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
              - flag <player> cutscene_modify:new_particle expire:5m
              - inventory close

            #Set the new particle and prepare for new location
            - case new_particle_loc:
              - if <server.particle_types.contains[<[arg_2]>]>:
                - flag <player> dcutscene_save_data.particle:<[arg_2]>
                - flag <player> cutscene_modify:new_particle_loc expire:5m
                - define text "Right click on the block you'd like this particle to be at or chat a valid LocationTag. Chat <red>cancel <gray>to stop."
                - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
              - else:
                - define text "<green><[arg_2]> <gray>is not a valid particle."
                - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"

            #Create new particle
            - case new_particle:
              - if <location[<[arg_2]>]||null> != null:
                - flag <player> cutscene_modify:!
                - definemap particle_proc script:none defs:none
                - definemap particle_data particle:<player.flag[dcutscene_save_data.particle]> loc:<location[<[arg_2]>]> range:100 quantity:1 offset:0,0,0 repeat:1 repeat_interval:0 velocity:false data:false special_data:false procedure:<[particle_proc]>
                - define uuid <util.random_uuid>
                - define keyframes.particle.<[tick]>.particle_list:->:<[uuid]>
                - define keyframes.particle.<[tick]>.<[uuid]> <[particle_data]>
                - flag server dcutscenes.<[data.name]>.keyframes.elements:<[keyframes]>
                - flag <player> cutscene_data:<server.flag[dcutscenes.<[data.name]>]>
                - ~run dcutscene_sort_data def:<[scene_name]>
                - define text "Particle <green><player.flag[dcutscene_save_data.particle]> <gray>set at location <green><[arg_2].simple> <gray>in tick <green><[tick]>t <gray>in scene <green><[data.name]><gray>."
                - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
                - inventory open d:dcutscene_inventory_sub_keyframe
                - ~run dcutscene_sub_keyframe_modify def:<player.flag[dcutscene_sub_keyframe_back_data]>
              - else:
                - define text "<green><[arg_2]> <gray>is not a valid location."
                - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"

#############################
