set PROJ_NAME "Funnel_Accelerator"
set WORK_DIR [pwd]

create_project $PROJ_NAME $WORK_DIR/$PROJ_NAME -part xcu280-fsvh2892-2L-e -force

#create_fileset -srcset sources_1

file mkdir $WORK_DIR/$PROJ_NAME/$PROJ_NAME.srcs/sources_1/ip
file mkdir $WORK_DIR/$PROJ_NAME/$PROJ_NAME.srcs/sources_1/new

#create_fileset -constrset constrs_1

file mkdir $WORK_DIR/$PROJ_NAME/$PROJ_NAME.srcs/constrs_1/new

#create_fileset -simset sim_1

file mkdir $WORK_DIR/$PROJ_NAME/$PROJ_NAME.srcs/sim_1/new



import_files -fileset sources_1 -copy_to $WORK_DIR/$PROJ_NAME/$PROJ_NAME.srcs/sources_1/new -force -quiet [glob -nocomplain $WORK_DIR/src/design/*.v]
import_files -fileset sim_1 -copy_to $WORK_DIR/$PROJ_NAME/$PROJ_NAME.srcs/sim_1/new -force -quiet [glob -nocomplain $WORK_DIR/src/tb/*.v]
import_files -fileset constrs_1 -copy_to $WORK_DIR/$PROJ_NAME/$PROJ_NAME.srcs/constrs_1/new -force -quiet [glob -nocomplain $WORK_DIR/src/constrains/*.xdc]
import_files -fileset sources_1 -copy_to $WORK_DIR/$PROJ_NAME/$PROJ_NAME.srcs/sources_1/ip -force -quiet [glob -nocomplain $WORK_DIR/ips/*.xci]

set_property top attention_top [current_fileset]
set_property top attention_top_tb [current_fileset -simset]

#open_project $WORK_DIR/$PROJ_NAME/$PROJ_NAME.xpr
# launch_simulation
# run all
# close_sim

# launch_runs synth_1 -job 4 -quiet
# wait_on_run synth_1
# report_utilization -name utilization_1 -file $WORK_DIR/$PROJ_NAME/Funnel_util.txt 

close_project