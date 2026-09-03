# Create waveform database
if { [info exists ::env(DUMP_DELTA_EVENT)] } {
    database -open waves -shm -into waves -default -event
} else {
    database -open waves -shm -into waves -default
}

# Top level
probe -database waves -create $env(TOP) -all -depth all

# SS01 instances (CHP0 ~ CHP3)
for {set i 0} {$i < 4} {incr i} {
    probe -database waves -create tb.u_SS01_CHP${i} -all -depth all
}

# SS02
probe -database waves -create tb.u_SS02_CHP -all -depth all

# SS02 core + key submodules
probe -database waves -create tb.u_SS02_CHP.u_ss02_wop.u_ss02_cor -all -depth all
probe -database waves -create tb.u_SS02_CHP.u_ss02_wop.u_ss02_cor.u_video_pipe -all -depth all
probe -database waves -create tb.u_SS02_CHP.u_ss02_wop.u_ss02_cor.u_ppi_ctrl_top -all -depth all

# SS01 core + key submodules
for {set i 0} {$i < 4} {incr i} {
    probe -database waves -create tb.u_SS01_CHP${i}.u_ss01_wop.u_ss01_cor -all -depth all
}

# Subsystem cor instances (0~3) — deep probe key modules
foreach inst {0 1 2 3} {
    set base "tb.u_SS02_CHP.u_ss02_wop.u_ss02_cor.subsystem_cor_inst[${inst}].u_subsystem_cor"
    probe -database waves -create ${base}.u_sep2csi -all -depth all
    probe -database waves -create ${base}.u_cs12_packet_parse_top_scd -all -depth all
}
