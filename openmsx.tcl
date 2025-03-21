debug set_watchpoint read_io 0x2E

# set Subroutine      allocate memory (adjust BASIC areapointers)
# debug set_bp 0x5ee8


set throttle off
after time 14 {set throttle on}

proc peek_ieee_float32 {addr {debuggable "memory"}} {
    binary scan [debug read_block $debuggable $addr 4] f result
    return $result
}

proc peek_s32 {addr {debuggable "memory"}} {
    binary scan [debug read_block $debuggable $addr 4] i result
    return $result
}