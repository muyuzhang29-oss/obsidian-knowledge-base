###########################################################
# compilation options
###########################################################

TB_FILELIST ?= filelist
TB_TOP      ?= tb
COMP_OPTS   =
COMP_PATH   = ../
REG_NAME    = none

MODE    ?= base_fun
PROJECT = SS12

SIM_DIR   = /sin/ind/$(USER)/proj/$(PROJECT)/$(PROJECT)_i2c/$(MODE)
PWD       = $(shell pwd)
VIP_SO    = $(SIM_DIR)/vip_lib/64bit/libcdnvipcuvm.so
LOAD_SV_LIB += -sv_lib $(VIP_SO)
SS11_RTL_BASE ?= /rhome/ind/groups/degr_serdes/proj/SS11/rev0/digital/users/$(USER)/digital_fe/hdl

SC    ?= 0
COV   ?= 0
DUMP  ?= 0
SDF   ?= none
MCL   ?= 1
TOP_MODULE = SS12_CHP
NOVIP  ?= 1

IUS_LIBEXT = -libext .vlib

VIP_DPHY_INTF_DIR  = $(DENALI)/ddvapi/sv
VIP_CS12_EXAMPLES  = $(DENALI)/ddvapi/sv/uvm/csi12/examples
VIP_CS12_TC_EXAMPLES = $(DENALI)/triplecheck/csi12Tc
VIP_COMP_OPTS = \
    -define DENALI_UVM -define DENALI_SV_NC \
    loadpl1 $(DENALI)/lib/viputil.so:cdnVIP:export \
    loadpl1 $(DENALI)/verilog/libcdnvs.so:cdnVIP:export \
    incdir $(DENALI)/ddvapi/sv \
    $(DENALI)/ddvapi/sv/denaliMem.sv \
    $(DV_HOME)/env/ss02_cpi_env/denaliCsi2.sv \
    incdir $(VIP_SV_DIR)/denaliMiphy_acd.sv \
    incdir $(VIP_SV_DIR)/miphy_acd.sv \
    incdir $(VIP_SV_DIR)/uvm/miphy_acd_cdnMiphy_acdUvmTop.sv \
    incdir $(DENALI)/ddvapi/sv/uvm/csi12 \
    $(DENALI)/ddvapi/sv/uvm/csi12/examples/example_common \
    incdir $(CDN_VIP_ROOT)/packages/cdn_mipi_csi12/hdl \
    incdir $(VIP_CS12_EXAMPLES)/using_config_master_ppi/hdl_interfaces \
    $(DENALI)/ddvapi/sv/hdl_interfaces/csi12/cdn_mipi_csi2_ppi_interface_ps.sv \
    $(VIP_DPHY_INTF_DIR)/cdn_miphy_acd_dphy_ddn_active_interface.sv \
    $(VIP_DPHY_INTF_DIR)/cdn_miphy_acd_dphy_ddn_ppi_active_interface.sv \
    $(VIP_DPHY_INTF_DIR)/cdn_miphy_acd_dphy_ddn_power_state_interface.sv \

VIP_TRIPLE_OPTS = \
    incdir $(DENALI)/triplecheck/cdnTc/sv \
    $(DENALI)/triplecheck/cdnTc/nc/runTc.sv \
    -incdir $(OVM_HOME)/test/ss02/test_nc \
    $(OVM_HOME)/test/ss02/test_nc/cdnTcCsi12Top.sv

VIP_COMP_OPTS += $(VIP_TRIPLE_OPTS)

DUT_COMP_OPTS = -ALLOWREDEFINITION -dresolution -rnm_package -define+ANA_FUNCTIONAL -define+SIM -define+MSV_PLL_USING_SIMPLE_MODEL -define+DPHY_SIM -nowarn NSVCER -libext .v -define+ACC_PLL

ifeq ($(SC),1)
IUS_UVM_COMP_OPTS = -ml_uvm -uvmhome CDNS-1.2-ML
SC_COMP_OPTS = -sysc -DSC_INCLUDE_DYNAMIC_PROCESSES -define SYSTEMC
else
IUS_UVM_COMP_OPTS = -uvmhome CDNS-1.2 -define UVM_NO_DEPRECATED
endif

IUS_UVM_COMP_OPTS += -uvmhome CDNS-1.1d -define UVM_NO_DEPRECATED

ifeq ($(NOVIP),1)
IUS_UVM_COMP_OPTS += $(DUT_COMP_OPTS) +define+NO_CDN_PHY_VIP
else
IUS_UVM_COMP_OPTS += $(VIP_COMP_OPTS) $(DUT_COMP_OPTS) +define+NO_CDN_PHY_VIP
endif

ifeq ($(COV),1)
COV_COMP_OPTS = -coverage all -covdut $(TOP_MODULE)
COV_COMP_OPTS += -coverage b:t:e:f -covdut $(TOP)
endif

OVL_OPTS = -define OVL_INIT_MSG \
           -OVL_SVA -define OVL_SVA -define OVL_ASSERT_ON -define OVL_MAX_REPORT_ERROR=5 -define OVL_SVA_INTERFACE -define IAL_OVL_INTERFACE -define IAL_OVCCELLERA

TEST_RGS_IDX ?= none
TEST_DIR     = $(SIM_DIR)/$(TEST)/$(TEST_RGS_IDX)
TEST_DIR     = $(SIM_DIR)/$(TEST)/$(TEST_RGS_IDX)

SEED    ?= random
SIM_OPTS =
UVM_VERBOSITY = UVM_MEDIUM
UVM_SIM_OPTS=+UVM_VERBOSITY=$(UVM_VERBOSITY) +UVM_TESTNAME=$(UVM_TESTNAME) +TEST=$(TEST) +UVM_NO_RELNOTES +UVM_MAX_QUIT_COUNT=10,YES

SC_SIM_OPTS = -sv lib $(shell xmroot)/tools/methodology/UVM/CDNS-1.2-ML/ml/lib64bit/libuvm_sv_ml.so -uvmhome CDNS-1.2-ML

ifeq ($(COV),1)
COV_SIM_OPTS = -coworkdir $(SIM_DIR)/cov_work -coveroverwrite -covtest $(TEST)_$(SEED)
endif

ifeq ($(DUMP),1)
DUMP_WAVEFORM_OPTS = -input $(PMD)/dump_waveform.tcl
endif
DUMPTIME ?= 0ns
export DUMP_START_TIME=$(DUMPTIME)

ifeq ($(SDF),none)
SDF_COMP_OPTS = -nospecify +define+FUNCTIONAL
else
SDF_COMP_OPTS = -define SDF_SIM -define WORST_CASE -sdf_verbose -nodelays -negdelay -neg_tchk -sdfstats sdfstatus.log -nowarn CUVMSP -nowarn SDFNCAP -nowarn SDFNET -tfile $(DV_HOME)/tb/ss02/tb
endif

ifeq ($(SDF),bc)
SDF_COMP_OPTS = -define SDF_SIM -define BEST_CASE -sdf_verbose -nodelays -negdelay -neg_tchk -sdfstats sdfstatus.log -nowarn CUVMSP -nowarn SDFNCAP -nowarn SDFNET -tfile $(DV_HOME)/tb/ss02/tb
endif

TB_FILELIST = filelist_pr

###########################################################
# targets
.PHONY: all debug compile simulate clean pre_comp pre_sim

all: debug

debug:
    simvision -64bit waves6

pre_comp:
    @if [ ! -d $(SIM_DIR) ] ; then \
        mkdir -p $(SIM_DIR); cp -rf ./Makefile $(SIM_DIR)/Makefile;\
    fi
    @if [ ! -d $(MODE) ] ; then \
        ln -s $(SIM_DIR)/$(MODE) $(MODE); \
    fi
    @cp -rf ./Makefile $(SIM_DIR)/Makefile;
    @cp $(TB_FILELIST) $(SIM_DIR)/;

pre_sim:
    @if [ ! -d $(TEST_DIR) ] ; then \
        mkdir -p $(TEST_DIR); \
    fi

ifeq ($(NOVIP),1)
    @cd $(SIM_DIR) && export SS11_RTL_BASE=$(SS11_RTL_BASE) && xrun -64bit -processor 8 -mtdump -mccodegen -mccores 8 -mess -sv \
    -access +rwc -l compile.log $(IUS_UVM_COMP_OPTS) $(COV_COMP_OPTS) $(IUS_LIBEXT) -f $(TB_FILELIST) $(COMP_OPTS) $(SDF_COMP_OPTS) -top $(TB_TOP) -elaborate
else
    @cd $(SIM_DIR) && export SS11_RTL_BASE=$(SS11_RTL_BASE) && xrun -64bit -processor 8 -mtdump -mccodegen -mccores 8 -mess -sv \
    -access +rwc -l compile.log $(IUS_UVM_COMP_OPTS) $(COV_COMP_OPTS) $(IUS_LIBEXT) -f $(TB_FILELIST) $(COMP_OPTS) $(SDF_COMP_OPTS) -top $(TB_TOP) -elaborate
endif

ifeq ($(VIP_SD),1)
    @cd $(SIM_DIR) && $(CDN_VIP_ROOT)/bin/cdn_vip_setup_env -64 -cdnautotest -s xmsim -cdn_vip_root $(CDN_VIP_ROOT) -m sv_uvm -uvmver "1.2" -csh -cdn_vip_lib vip_lib -l
endif

simulate: pre_sim
    @cd $(TEST_DIR) && export LD_LIBRARY_PATH=$(SIM_DIR)/vip_lib/64bit:$(LD_LIBRARY_PATH) \
    && xrun -64bit -mcl $(MCL) -mtdump -mccodegen -mccores $(MCL) -r $(TB_TOP) \
    -xlibdirpath $(SIM_DIR) -nocopyright -l sim_$(SEED).log -svseed $(SEED) \
    $(LOAD_SV_LIB) $(SIM_OPTS) $(UVM_SIM_OPTS) $(DUMP_WAVEFORM_OPTS) $(COV_SIM_OPTS) \
    && touch DONE

clean:
    rm -rf $(SIM_DIR) -rf; rm $(MODE) -f
    rm -rf INCA_libs/ xcelium.d/ waves/ irun.key .history compile.log sim*.log ncsim*.err

help:
    @echo "$(DUMP_START_TIME)"
