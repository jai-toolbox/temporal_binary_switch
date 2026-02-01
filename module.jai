/*

A binary switch that tracks temporal transitions between on and off states.
 
Note that throughout these docs ^ will refer to an on signal and v is an off signal.

manual mode is the mode where whenever you manually set the tbs the internal state changes
process synchronized means that the internal state only updates when you call process

 */

Temporal_Binary_Switch :: struct {

    State_Update_Method :: enum {
        MANUAL;
        PROCESS_SYNCHRONIZED;
    }

    State :: enum {
        SUSTAINED_OFF;      // ...vv
        JUST_SWITCHED_ON;   // ...v^
        SUSTAINED_ON;       // ...^^
        JUST_SWITCHED_OFF;  // ...^v
    }

    state_update_method: State_Update_Method = .PROCESS_SYNCHRONIZED;
    current_state: State = .SUSTAINED_OFF;
    state_to_process: bool = false;
    state: bool = false;
}

// I can probably get rid of this.
to_string :: (using tbs: *Temporal_Binary_Switch) -> string {
    if just_switched_on(tbs)  return "just switched on";
    if just_switched_off(tbs) return "just switched off";
    if sustained_on(tbs)      return "sustained on";
    if sustained_off(tbs)     return "sustained off";
    return "unknown";
}

set :: (using tbs: *Temporal_Binary_Switch, value: bool) {
    if #complete state_update_method == {
        case .MANUAL;
            update_state(tbs, value);
        case .PROCESS_SYNCHRONIZED;
            state_to_process = value;
    }
}

update_state :: (using tbs: *Temporal_Binary_Switch, value: bool) {
    if value {
        set_true(tbs);
    } else {
        set_false(tbs);
    }
}

set_true :: (using tbs: *Temporal_Binary_Switch) {
    if !state {
        current_state = .JUST_SWITCHED_ON; // ...v^
    } else {
        current_state = .SUSTAINED_ON;     // ...^^
    }
    state = true;
}

set_false :: (using tbs: *Temporal_Binary_Switch) {
    if state {
        current_state = .JUST_SWITCHED_OFF; // ...^v
    } else {
        current_state = .SUSTAINED_OFF;     // ...vv
    }
    state = false;
}


// when you want to run different logic based on the state you can do a case statement on the result

get_current_state :: (using tbs: Temporal_Binary_Switch) -> Temporal_Binary_Switch.State {
    return current_state;
}

// these functions exist to save you having to run the above and then doing a comparison

is_on :: (using tbs: Temporal_Binary_Switch) -> bool {
    return state;
}

is_off :: (using tbs: Temporal_Binary_Switch) -> bool {
    return !state;
}

just_switched_on :: (using tbs: Temporal_Binary_Switch) -> bool {
    return current_state == .JUST_SWITCHED_ON;
}

just_switched_off :: (using tbs: Temporal_Binary_Switch) -> bool {
    return current_state == .JUST_SWITCHED_OFF;
}

sustained_on :: (using tbs: Temporal_Binary_Switch) -> bool {
    return current_state == .SUSTAINED_ON;
}

sustained_off :: (using tbs: Temporal_Binary_Switch) -> bool {
    return current_state == .SUSTAINED_OFF;
}

process :: (using tbs: *Temporal_Binary_Switch) {
    if #complete state_update_method == {
        case .PROCESS_SYNCHRONIZED;
            update_state(tbs, state_to_process);
        case .MANUAL;
            // do nothing
    }
}
