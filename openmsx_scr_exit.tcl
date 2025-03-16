set throttle off

after time 18 {set throttle on}
after time 19 {screenshot -doublesize -raw [machine_info config_name]}
after time 20 {exit}