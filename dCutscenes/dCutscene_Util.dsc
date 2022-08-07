# Denizen Cutscenes Util
# Utility tasks and procedures for Denizen Cutscenes

## Create a new cutscene ############
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
        - define cutscene.settings
        - flag server dcutscenes.<[arg]>:<[cutscene]>
        - inventory open d:dcutscene_inventory_main
        - run dcutscene_scene_show
        - define text "New cutscene <green><[arg]> <gray>has been created."
        - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"

dcutscene_remove_scene:
    type: task
    debug: false
    definitions: cutscene
    script:
    - define validate <server.flag[dcutscenes.<[cutscene]>]||null>
    - if <[validate]> != null:
      - define new_flag <server.flag[dcutscenes].exclude[<[cutscene]>]>
      - flag server dcutscenes:<[new_flag]>
      - inventory open d:dcutscene_inventory_main
      - run dcutscene_scene_show
      - define text "Scene <green><[cutscene]> <gray>has been deleted."
      - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
    - else:
      - debug error "Invalid cutscene specified in dcutscene_remove_scene"

##Cutscene Command

dcutscene_command:
    type: command
    name: dcutscene
    usage: /dcutscene
    aliases:
    - dscene
    description: Cutscene command for DCutscene
    tab completions:
      1: <list[load|save|open|play|location|animate|sound|material|particle]>
      2: <proc[dcutscene_data_list].context[<player>]>
    permission: op.op
    script:
    - define a_1 <context.args.get[1]||null>
    - define a_2 <context.args.get[2]||null>
    - if <[a_1]> == null || <[a_1]> == open:
      - ~run dcutscene_scene_show
    - else:
      - choose <[a_1]>:
        #Animate the model the player is modifying.
        - case animate:
          - if <player.has_flag[cutscene_modify]> && <[a_2]> != null && <player.flag[cutscene_modify]> != set_model_animation:
            - define data <player.flag[dcutscene_location_editor]||null>
            - if <[data]> != null:
              - define root <[data.root_ent]||null>
              - if <[root]> == null:
                - define text "Could not find model to animate"
                - stop
              - define type <[data.root_type]||null>
              - if <[type]> != null:
                - choose <[type]>:
                  - case player_model:
                    - run pmodels_animate def:<[root]>|<[a_2]>
          - else if <player.has_flag[cutscene_modify]>:
            - if <player.flag[cutscene_modify]> == set_model_animation:
              - define type <player.flag[dcutscene_save_data.type]>
              - choose <[type]>:
                - case player_model:
                  #Validate the animation
                  - define anim_validate <server.flag[pmodels_data.animations_player_model_template_norm.<[a_2]>]||null>
                  - if <[anim_validate]> == null && <[a_2]> != false:
                    - define text "Animation <green><[a_2]> <gray>does not seem to exist."
                    - narrate "<element[DCutscenes].color_gradient[from=blue;to=aqua].bold> <gray><[text]>"
                    - stop
                  - run dcutscene_model_keyframe_edit def:player_model|animate|set_animation|<[a_2]>
        #Open the location tool GUI
        - case location:
          - if <player.has_flag[cutscene_modify]>:
            - inventory clear
            - inventory open d:dcutscene_inventory_location_tool
        #Load dcutscene files
        - case load:
          - if <[a_2]> == null:
            - ~run dcutscene_load_files
          - else:
            - ~run dcutscene_load_files def.cutscene:<[a_2]>
        #Save dcutscene files to a directory
        - case save:
          - if <[a_2]> != null:
            - ~run dcutscene_save_file def.cutscene:<[a_2]>
          - else:
            - ~run dcutscene_save_file
        #Play a cutscene
        - case play:
          - if <[a_2]> != null:
            - run dcutscene_animation_begin def:<[a_2]>
        #Input a new sound
        - case sound:
          - if <player.has_flag[cutscene_modify]>:
            - if <[a_2]> != null && <player.flag[cutscene_modify]> == sound:
              - run dcutscene_animator_keyframe_edit def:sound|create|<[a_2]>
        #Set new material
        - case material:
          - if <player.has_flag[cutscene_modify]>:
            - if <[a_2]> != null:
              - if <player.flag[cutscene_modify]> == fake_block_material:
                - run dcutscene_animator_keyframe_edit def:fake_object|new_fake_block_material_set|<[a_2]>
              - else if <player.flag[cutscene_modify]> == set_fake_block_material:
                - run dcutscene_animator_keyframe_edit def:fake_object|set_fake_block_material|<[a_2]>
        #Set new particle
        - case particle:
          - if <player.has_flag[cutscene_modify]>:
            - if <[a_2]> != null:
              - if <player.flag[cutscene_modify]> == new_particle:
                - run dcutscene_animator_keyframe_edit def:particle|new_particle_loc|<[a_2]>
              - else if <player.flag[cutscene_modify]> == change_particle:
                - run dcutscene_animator_keyframe_edit def:particle|change_particle|<[a_2]>

## Tab Completion Procedures ########

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
          - case animate:
            - if <[player].flag[cutscene_modify]> == set_model_animation:
              - define type <[player].flag[dcutscene_save_data.type]>
            - else:
              - define type <[player].flag[dcutscene_location_editor.root_type]||null>
            - if <[type]> == null:
              - determine <empty>
            - else:
              - choose <[type]>:
                - case player_model:
                  - define anim_list <server.flag[pmodels_data.animations_player_model_template_norm]||null>
                  - if <[anim_list]> == null:
                    - determine <empty>
                  - define anim_tab <empty>
                  - foreach <[anim_list]> key:anim_name as:anim:
                    - define anim_tab:->:<[anim_name]>
                  - determine <[anim_tab]>
          - case material:
            - determine <server.material_types.filter[is_block].parse_tag[<material[<[parse_value]>].name>]>
          - case particle:
            - determine <server.particle_types>
    - else if <server.has_flag[dcutscenes]>:
      - foreach <server.flag[dcutscenes]> key:c_id as:cutscene:
        - define list:->:<[c_id]>
      - determine <[list]>
############################

## Data Operations #########
#Saves a cutscene to a directory
dcutscene_save_file:
    type: task
    debug: false
    definitions: cutscene
    script:
    - if <script[dcutscenes_config].data_key[config].get[cutscene_compress_save_file]||false.is_truthy>:
      - define indent 0
    - else:
      - define indent 4
    - if <server.flag[dcutscenes.<[cutscene.name]>]||null> == null:
      - debug error "Could not find cutscene to save."
    - else:
      - define cutscene_data <server.flag[dcutscenes.<[cutscene.name]>]>
      - define c_id <[cutscene_data.name]>
      - ~filewrite path:data/dcutscenes/scenes/<[c_id]>.dcutscene.json data:<[cutscene].to_json[native_types=true;indent=<[indent]>].utf8_encode>

#Loading cutscene files
dcutscene_load_files:
    type: task
    debug: false
    script:
    - define files <util.list_files[data/dcutscenes/scenes]||null>
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
          - define cutscene.settings <yaml[file_<[file]>].read[settings]||<empty>>
          - flag server dcutscenes.<[name]>:<[cutscene]>
          - ~run dcutscene_sort_data def:<[cutscene.name]>
          - announce to_console "[Denizen Cutscenes] Cutscene <[name]> has been loaded."
        - else:
          - debug error "<[file]> is not a dcutscene file in Denizen/data/dcutscenes/scenes"

#Sort the keyframes
dcutscene_sort_data:
    type: task
    debug: false
    definitions: cutscene
    script:
    #Single Cutscene
    - define cutscene <[cutscene]||null>
    - if <[cutscene]> == null:
      - debug error "DCutscenes There are no cutscenes to sort!"
    - else:
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
      #Models
      - define model <[keyframes.models].sort_by_value[get[tick]]||null>
      - if <[model]> != null:
        - define keyframes.model <[model]>
      #Run Task
      - define run_task <[keyframes.run_task].sort_by_value[get[tick]]||null>
      - if <[run_task]> != null:
        - define keyframes.run_task <[run_task]>
      #Fake Object
      - define fake_object <[keyframes.fake_object].sort_by_value[get[tick]]||null>
      - if <[fake_object]> != null:
        - define keyframes.fake_object <[fake_object]>
      #Particle
      - define particle <[keyframes.particle].sort_by_value[get[tick]]||null>
      - if <[particle]> != null:
        - define keyframes.particle <[particle]>
      #Screeneffect
      - define screeneffect <[keyframes.screeneffect].sort_by_value[get[tick]]||null>
      - if <[screeneffect]> != null:
        - define keyframes.screeneffect <[screeneffect]>
      #Sound
      - define sound <[keyframes.sound].sort_by_value[get[tick]]||null>
      - if <[sound]> != null:
        - define keyframes.sound <[sound]>
      #Title
      - define title <[keyframes.title].sort_by_value[get[tick]]||null>
      - if <[title]> != null:
        - define keyframes.title <[title]>
      #Command
      - define command <[keyframes.command].sort_by_value[get[tick]]||null>
      - if <[command]> != null:
        - define keyframes.command <[command]>
      #Message
      - define message <[keyframes.message].sort_by_value[get[tick]]||null>
      - if <[message]> != null:
        - define keyframes.message <[message]>
      #Time
      - define time <[keyframes.time].sort_by_value[get[tick]]||null>
      - if <[time]> != null:
        - define keyframes.time <[time]>
      #Weather
      - define weather <[keyframes.weather].sort_by_value[get[tick]]||null>
      - if <[weather]> != null:
        - define keyframes.weather <[weather]>
      #Scene Length
      - define ticks <proc[dcutscene_animation_length].context[<[cutscene]>]>
      #Total cutscene length
      - if !<[ticks].is_empty>:
        - define animation_length <duration[<[ticks].highest>t].in_seconds>s
        - define data.length <[animation_length]>
        - flag server dcutscenes.<[name]>.length:<[data.length]>
      - flag server dcutscenes.<[name]>.keyframes:<[keyframes]>

#TODO:
#- Remove this for the cutscene stop system
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
    #Model
    - define model_keyframes <[keyframes.model]||null>
    - if <[model_keyframes]> != null:
      - define highest <[model_keyframes].keys.highest>
      - define ticks:->:<[highest]>
    #Run Task
    - define run_task_keyframes <[keyframes.run_task]||null>
    - if <[run_task_keyframes]> != null:
      - define highest <[run_task_keyframes].keys.highest>
      - define ticks:->:<[highest]>
    #Fake Blocks
    - define fake_block_keyframes <[keyframes.fake_object.fake_block]||null>
    - if <[fake_block_keyframes]> != null:
      - define highest <[fake_block_keyframes].keys.highest>
      - define ticks:->:<[highest]>
    #Fake Schems
    - define fake_schem_keyframes <[keyframes.fake_object.fake_schem]||null>
    - if <[fake_schem_keyframes]> != null:
      - define highest <[fake_schem_keyframes].keys.highest>
      - define ticks:->:<[highest]>
    #Particle
    - define particle_keyframes <[keyframes.particle]||null>
    - if <[particle_keyframes]> != null:
      - define highest <[particle_keyframes].keys.highest>
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
    #Title
    - define title_keyframes <[keyframes.title]||null>
    - if <[title_keyframes]> != null:
      - define highest <[title_keyframes].keys.highest>
      - define ticks:->:<[highest]>
    #Command
    - define command_keyframes <[keyframes.command]||null>
    - if <[command_keyframes]> != null:
      - define highest <[command_keyframes].keys.highest>
      - define ticks:->:<[highest]>
    #Message
    - define message_keyframes <[keyframes.message]||null>
    - if <[message_keyframes]> != null:
      - define highest <[message_keyframes].keys.highest>
      - define ticks:->:<[highest]>
    #Time
    - define time_keyframes <[keyframes.time]||null>
    - if <[time_keyframes]> != null:
      - define highest <[time_keyframes].keys.highest>
      - define ticks:->:<[highest]>
    #Weather
    - define weather_keyframes <[keyframes.weather]||null>
    - if <[weather_keyframes]> != null:
      - define highest <[weather_keyframes].keys.highest>
      - define ticks:->:<[highest]>
    #Stop Point
    - define stop_point <[keyframes.stop]||null>
    - if <[stop_point]> != null:
      - define ticks:->:<[stop_point.tick]>
    - determine <[ticks]>

#TODO:
#- Work on this
#Removes any corrupt data
dcutscene_validate_data:
    type: task
    debug: false
    definitions: cutscene
    script:
    - define data data

##################################################################################

## Utility Example Procedures ############
#See wiki for example usages you can use these for animators that allow location procedures

#Input 1: LocationTag
#Input 2: The axis of rotation x,y,z
#Input 3: The radius or size of the circle
#Input 4: How many points in the circle
dcutscene_circle_proc:
  type: procedure
  debug: false
  definitions: loc|axis|radius|points
  script:
  - define axis <[axis]||y>
  - define radius <[radius]||10>
  - define points <[points]||10>
  - choose <[axis]>:
    - case x:
      - determine <[loc].points_around_x[radius=<[radius]>;points=<[points]>]>
    - case y:
      - determine <[loc].points_around_y[radius=<[radius]>;points=<[points]>]>
    - case z:
      - determine <[loc].points_around_z[radius=<[radius]>;points=<[points]>]>

#Input 1: LocationTag
#Input 2: Vector offset such as 2,5,1
#Input 3: Another vector
dcutscene_cube_proc:
  type: procedure
  debug: false
  definitions: loc|vec|vec_2
  script:
  - define vec <[vec]||10,10,10>
  - define vec_2 <[vec_2]||null>
  - if <[vec_2]> == null:
    - determine <[loc].to_cuboid[<[loc].add[<[vec]>]>].shell>
  - else:
    - determine <[loc].add[<[vec_2]>].to_cuboid[<[loc].add[<[vec]>]>].shell>

#Input 1: LocationTag
#Input 2: Vector offset such as 2,5,1
#Input 3: Another vector
dcutscene_cube_holo_proc:
  type: procedure
  debug: false
  definitions: loc|vec|vec_2
  script:
  - define vec <[vec]||10,10,10>
  - define vec_2 <[vec_2]||null>
  - if <[vec_2]> == null:
    - determine <[loc].to_cuboid[<[loc].add[<[vec]>]>].outline>
  - else:
    - determine <[loc].add[<[vec_2]>].to_cuboid[<[loc].add[<[vec]>]>].outline>

#Input 1: LocationTag
#Input 2: Vector offset such as 5,1,2
dcutscene_sphere_proc:
  type: procedure
  debug: false
  definitions: loc|vector
  script:
  - define vector <[vector]||5,5,5>
  - determine <[loc].to_ellipsoid[<[vector]>].shell>

#Input 1: LocationTag
#Input 2: Vector offset such as 2,4,1
#Input 3: Time it takes to interpolate to the next point
#Input 4: Interpolation method linear or smooth
#Input 5: The offset this is useful for a branch type of structure
#Input 6: Another vector this should be used when interpolation is on smooth
#Input 7: Another vector this should be used when interpolation is on smooth
dcutscene_vector_path:
  type: procedure
  debug: false
  definitions: loc|vec|time|interpolation|offset|vec_2|vec_3
  script:
  - define vec <[vec]||null>
  - if <[vec]> == null:
    - determine <[loc]>
  - else:
    - define offset <[offset]||0,0,0>
    - define interpolation <[interpolation]||linear>
    - define loc_1 <[loc]>
    - define loc_2 <[loc].add[<[vec]>]>
    - choose <[interpolation]>:
      - case linear:
        - repeat <duration[<[time]>].in_ticks||250>:
          - define time_index <[value]>
          - if <[time_index]> < <[time]>:
            - define time_percent <[time_index].div[<[time]>]>
            - define data <[loc_2].as_location.sub[<[loc_1]>].mul[<[time_percent]>].add[<[loc_1]>]>
            - define points:->:<[data].random_offset[<[offset]>]>
        - determine <[points]||<[loc]>>
      - case smooth:
        - define loc_3 <[loc].add[<[vec_2]||0,0,0>]>
        - define loc_4 <[loc].add[<[vec_3]||<[vec]>>]>
        - repeat <duration[<[time]>].in_ticks||250>:
          - define time_index <[value]>
          - if <[time_index]> < <[time]>:
            - define time_percent <[time_index].div[<[time]>]>
            - define data <proc[dcutscene_catmullrom_proc].context[<[loc_3]>|<[loc_1]>|<[loc_2]>|<[loc_4]>|<[time_percent]>]>
            - define points:->:<[data].random_offset[<[offset]>]>
        - determine <[points]||<[loc]>>

######################################
