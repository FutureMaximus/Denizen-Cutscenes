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

##TODO:
#-Remove this shit
happy_task:
  type: task
  definitions: def|def_2
  script:
  - narrate <[def]>
  - narrate <[def_2]>

example_task:
  type: task
  script:
  - narrate "<blue>Look at this place...amazing!"

weird_task:
  type: task
  script:
  - narrate "<blue>Your name is...<player.name> welcome!"

##Cutscene Command

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
        #Animate the model the player is modifying.
        - case animate:
          - if <player.has_flag[cutscene_modify]> && <[a_2]> != n:
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
        #Open the location tool GUI
        - case location:
          - if <player.has_flag[cutscene_modify]>:
            - inventory clear
            - inventory open d:dcutscene_inventory_location_tool
        #Load dcutscene files
        - case load:
          - if <[a_2].equals[n]>:
            - ~run dcutscene_load_files
          - else:
            - ~run dcutscene_load_files def.cutscene:<[a_2]>
        #Save dcutscene files to a directory
        - case save:
          - if !<[a_2].equals[n]>:
            - ~run dcutscene_save_file def.cutscene:<[a_2]>
          - else:
            - ~run dcutscene_save_file
        #Play a cutscene
        - case play:
          - if !<[a_2].equals[n]>:
            - run dcutscene_animation_begin def:<[a_2]>
        #Input a new sound
        - case sound:
          - if !<[a_2].equals[n]> && <player.has_flag[cutscene_modify]> && <player.flag[cutscene_modify]> == sound:
            - run dcutscene_animator_keyframe_edit def:sound|create|<[a_2]>

## Tab Completion Procedures ########
#Tab completion for arguments that can be utilized
dcutscene_command_list:
    type: procedure
    debug: false
    script:
    - define list <list[load|save|open|play|location|animate]>
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

#Loading cutscene files
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
      #Models
      - define player_model <[keyframes.models.]>
      #Run Task
      - define run_task <[keyframes.run_task].sort_by_value[get[tick]]||null>
      - if <[run_task]> != null:
        - define keyframes.run_task <[run_task]>
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
    #All
    - else:
      - if <server.has_flag[dcutscenes]>:
        - foreach <server.flag[dcutscenes]> key:c_id as:cutscene:
          - define ticks:!
          - define keyframes <[cutscene.keyframes]>
          #Camera
          - define camera <[keyframes.camera].sort_by_value[get[tick]]||null>
          - if <[camera]> != null:
            - define keyframes.camera <[camera]>
          #Run Task
          - define run_task <[keyframes.run_task].sort_by_value[get[tick]]||null>
          - if <[run_task]> != null:
            - define keyframes.run_task <[run_task]>
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
    #Run Task
    - define run_task_keyframes <[keyframes.run_task]||null>
    - if <[run_task_keyframes]> != null:
      - define highest <[run_task_keyframes].keys.highest>
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

##################################################################################
