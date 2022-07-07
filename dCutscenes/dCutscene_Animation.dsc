# Denizen Cutscenes Animation

##Camera ################

#The Camera
dcutscene_camera_entity:
    type: entity
    debug: false
    entity_type: armor_stand
    mechanisms:
        marker: false
        visible: false
        is_small: false
        invulnerable: true
        gravity: false

###################################################

#========= Cutscene Animator Tasks and Procedures =========

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
        #Models in keyframes
        - define models <[keyframes.models]||null>
        #Elements in keyframe
        - define elements <[keyframes.elements]||null>
        - if <[camera]> != null:
          #Chunks must be loaded to begin cutscene
          - define first <[camera].keys.first>
          - define first_loc <location[<[camera.<[first]>.location]>]||null>
          - if <[first_loc]> != null:
            - teleport <player> <[first_loc]>
            #TODO:
            #- Only delay if player is not near the location
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
              #=Camera Check
              - if <[cam_data]> != null && <[cam_count]> < 1:
                - define cam_count 1
                - run dcutscene_path_move def:<[cutscene.name]>|<[camera_ent]>|camera
              #=Model Check
              - define model <[models.<[tick]>]||null>
              - if <[model]> != null:
                - define model_list <[model.model_list]>
                - foreach <[model_list]> as:model_uuid:
                  #If the model is already spawned skip
                  - define spawned_check <player.flag[dcutscene_spawned_models.<[model_uuid]>]||null>
                  - if <[spawned_check]> != null:
                    - foreach next
                  - define model_data <[model.<[model_uuid]>]||null>
                  - if <[model_data]> != null:
                    - define type <[model_data.type]>
                    - define path <[model_data.path]>
                    - define spawn_loc <[path].keys.first.get[location]>
                    - choose <[type]>:
                      - case player_model:
                        - define script <script[pmodels_spawn_model]||null>
                        - define defs <list[<[spawn_loc]>|<player>|<player>]>
                        - if <[script]> == null:
                          - foreach next
                      - default:
                        - foreach next
                    - run <[script]> def:<[defs]> save:spawned
                    - define root <entry[spawned].created_queue.determination.first>
                    #Track spawned model
                    - flag <player> dcutscene_spawned_models.<[model_uuid]>.root:<[root]>
                    - flag <player> dcutscene_spawned_models.<[model_uuid]>.type:<[type]>
                    - run dcutscene_path_move def:<[cutscene.name]>|<[root]>|<[type]>|<[tick]>
              #=Regular Animators===
              - if <[elements]> != null:
                #=Run task check
                - define run_tasks <[elements.run_task.<[tick]>.run_task_list]||null>
                - if <[run_tasks]> != null:
                  - foreach <[run_tasks]> as:task_id:
                    - define data <[elements.run_task.<[tick]>.<[task_id]>]||null>
                    - if <[data]> != null:
                      - run dcutscene_run_task_animator_task def:<[data]>
                #=Sound check
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
                #=screeneffect check
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
          - debug error "Could not start cutscene <[cutscene]> as it does not have a camera"
    - else:
      - debug error "Cutscene could not be found."

#Running it here ensures the cutscene animator does not get delayed due to waitable task
dcutscene_run_task_animator_task:
    type: task
    debug: false
    definitions: task
    script:
    - define script <[task.script]||null>
    - if <[task.script]> != null:
      - define waitable <[task.waitable]>
      - define defs <[task.defs]>
      - if <[defs].equals[false]>:
        - define defs <empty>
      - else:
        - define defs <[defs].parsed>
      - define path <[task.path]>
      - define delay <duration[<[task.delay]>].in_seconds>s
      - choose <[waitable]>:
        - case true:
          - if <[path].equals[true]>:
            - ~run <[script]> path:<[path]> def:<[defs]> delay:<[delay]>
          - else:
            - ~run <[script]> def:<[defs]> delay:<[delay]>
        - case false:
          - if <[path].equals[true]>:
            - run <[script]> path:<[path]> def:<[defs]> delay:<[delay]>
          - else:
            - run <[script]> def:<[defs]> delay:<[delay]>
    - else:
      - debug error "Could not run the task in dcutscene_run_task_animator_task"

#========= Path movement for camera, models, and entities ========
dcutscene_path_move:
    type: task
    debug: false
    definitions: cutscene|entity|type|data
    script:
    - define cutscene <server.flag[dcutscenes.<[cutscene]>]||null>
    - if <[cutscene]> != null:
      - define type <[type]||null>
      - if <[type]> != null:
        - choose <[type]>:
          #======================= Camera Path Move ===========================
          - case camera:
            - define mount <player.flag[dcutscene_mount]>
            - define keyframes <[cutscene.keyframes.camera]>
            #before
            - foreach <[keyframes]> key:c_id as:keyframe:
              - define interpolation <[keyframe.interpolation]>
              - define time_1 <[keyframe.tick]>
              - define loc_1 <location[<[keyframe.location]>]||null>
              - define rotate <[keyframe.rotate]>
              - define interp_look <[keyframe.interpolate_look]||true>
              - define move <[keyframe.move]>
              - if <[rotate].equals[false]>:
                - define eye_loc <[entity].eye_location>
                - define eye_loc_bool false
              - else:
                - define eye_loc <[keyframe.eye_loc.location]>
                - define eye_loc_bool <[keyframe.eye_loc.boolean]||false>
              - if <[loc_1]> == null:
                - foreach next
              #TODO:
              #- Chunk load the after location and after extra location
              #after
              - foreach <[keyframes]> key:2_id as:2_keyframe:
                - define compare <[2_keyframe.tick].is_more_than[<[time_1]>]>
                - if <[compare].equals[true]>:
                  - define time_2 <[2_keyframe.tick]>
                  - define loc_2 <location[<[2_keyframe.location]>]||null>
                  - define eye_loc_2 <location[<[2_keyframe.eye_loc.location]>]||null>
                  - foreach stop
              - define loc_2 <[loc_2]||null>
              - if <[loc_2]> == null:
                - foreach next
              #after extra
              - foreach <[keyframes]> key:a_e_id as:a_e_keyframe:
                - define compare <[a_e_keyframe.tick].is_more_than[<[time_2]>]>
                - if <[compare].equals[true]>:
                  - define loc_2_after <[a_e_keyframe.location]>
                  - foreach stop
              - define loc_2_after <[loc_2_after]||<[loc_2]>>
              - define time <[time_2].sub[<[time_1]>]>
              #To ensure non moving cameras can go here
              - chunkload <[loc_2].chunk> duration:<[time].add[60]>t
              - chunkload <[loc_2_after].chunk> duration:<[time].add[60]>t
              - choose <[interpolation]>:

                #======== Linear Interpolation ========
                - case linear:
                  - repeat <[time]>:
                    - if <[entity].is_spawned>:
                      - define time_index <[value]>
                      - define time_percent <[time_index].div[<[time]>]>
                      #Move true
                      - if <[move].equals[true]>:
                        - if <[time_index]> < <[time]>:
                          #Path Lerp
                          - define data <[loc_2].as_location.sub[<[loc_1]>].mul[<[time_percent]>].add[<[loc_1]>]>
                          #Interp Look True
                          - if <[interp_look].equals[true]>:
                            #Eye location interp
                            - define yaw <[eye_loc_2].yaw.sub[<[eye_loc].yaw>].mul[<[time_percent]>].add[<[eye_loc].yaw>]>
                            - define pitch <[eye_loc_2].pitch.sub[<[eye_loc].pitch>].mul[<[time_percent]>].add[<[eye_loc].pitch>]>
                          #Interp Look False
                          - else:
                            #Location 1 yaw and pitch
                            - define yaw <[eye_loc_2].yaw>
                            - define pitch <[eye_loc_2].pitch>
                        - else:
                          - define data <[loc_2]>
                          - define yaw <[eye_loc_2].yaw>
                          - define pitch <[eye_loc_2].pitch>
                      #Move false
                      - else:
                        - define data <[loc_1]>
                        - if <[interp_look].equals[true]>:
                          #Eye location interp
                          - if <[time_index]> < <[time]>:
                            - define yaw <[eye_loc_2].yaw.sub[<[eye_loc].yaw>].mul[<[time_percent]>].add[<[eye_loc].yaw>]>
                            - define pitch <[eye_loc_2].pitch.sub[<[eye_loc].pitch>].mul[<[time_percent]>].add[<[eye_loc].pitch>]>
                          - else:
                            - define yaw <[eye_loc_2].yaw>
                            - define pitch <[eye_loc_2].pitch>
                        - else:
                          - define yaw <[eye_loc].yaw>
                          - define pitch <[eye_loc].pitch>
                      #If a look location has been set
                      - if <[eye_loc_bool].equals[true]>:
                        - look <player> <[eye_loc]> duration:1t
                        - define yaw <player.location.yaw>
                        - define pitch <player.location.pitch>
                      - teleport <[mount]> <[data].with_yaw[<[eye_loc].yaw>].below[2]>
                      - teleport <[entity]> <[data].with_yaw[<[yaw]>].with_pitch[<[pitch]>]>
                    - else:
                      - stop
                    - wait 1t

                #=========== Smooth Interpolation ============
                - case smooth:
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
                      - define time_percent <[time_index].div[<[time]>]>
                      - if <[move].equals[true]>:
                        - if <[time_index]> < <[time]>:
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
                      - else:
                        - define data <[loc_1]>
                        - if <[interp_look].equals[true]>:
                          #Eye location interp
                          - if <[time_index]> < <[time]>:
                            - define yaw <[eye_loc_2].yaw.sub[<[eye_loc].yaw>].mul[<[time_percent]>].add[<[eye_loc].yaw>]>
                            - define pitch <[eye_loc_2].pitch.sub[<[eye_loc].pitch>].mul[<[time_percent]>].add[<[eye_loc].pitch>]>
                          - else:
                            - define yaw <[eye_loc_2].yaw>
                            - define pitch <[eye_loc_2].pitch>
                        - else:
                          - define yaw <[eye_loc].yaw>
                          - define pitch <[eye_loc].pitch>
                      #If a look location has been set
                      - if <[eye_loc_bool].equals[true]>:
                        - look <player> <[eye_loc]> duration:1t
                        - define yaw <player.location.yaw>
                        - define pitch <player.location.pitch>
                      - teleport <[mount]> <[data].with_yaw[<[eye_loc].yaw>].below[2]>
                      - teleport <[entity]> <[data].with_yaw[<[yaw]>].with_pitch[<[pitch]>]>
                    - else:
                      - stop
                    - wait 1t
                - default:
                  - foreach next
            - run dcutscene_animation_stop

          #====================== Player Model Path Move =======================
          - case player_model:
            - define keyframes lol

#====== Cutscene Stop =======
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
    - flag <player> dcutscene_spawned_models:!

#======= Cutscene Path Shower =======
dcutscene_path_show_interval:
    type: task
    debug: false
    definitions: type
    script:
    - define script <script[dcutscenes_config].data_key[config].get[cutscene_path_update_interval]||4s>
    - define duration <duration[<[script]>]||3s>
    - define data <player.flag[cutscene_data]>
    - choose <[type]>:
      - case camera:
        - define text "Showing camera path for scene <green><[data.name]><gray>."
        - define text "To stop showing the path chat <red>stop<gray>."
        - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
        - flag <player> cutscene_modify:camera_path expire:30m
        - while <player.flag[cutscene_modify]||> == camera_path:
          - run dcutscene_path_show def:<[data.name]>
          - wait <[duration]>

#TODO:
#- Use this for model or entity paths
#- Implement ray tracing floor hit detection for models
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
                        - playeffect effect:block_marker special_data:<material[<script[dcutscenes_config].data_key[config].get[cutscene_path_material]>]||<material[barrier]>> at:<[p_b]> offset:0,0,0 visibility:<[dist]> targets:<player>
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
                  - playeffect effect:block_marker special_data:<material[<script[dcutscenes_config].data_key[config].get[cutscene_path_material]>]||<material[barrier]>> at:<[point]> offset:0,0,0 visibility:<[dist]> targets:<player>
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
    # Procedure by DModels created by mcmonkey https://github.com/mcmonkeyprojects/DenizenModels
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