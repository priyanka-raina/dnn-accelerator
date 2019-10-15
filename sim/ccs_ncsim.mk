
# Caller must set
#  VHDL_SRC = list of VHDL src files
#  VLOG_SRC = list of Verilog src files
#  CXX_SRC = list of C++ src files
#  CXX_INCLUDES = list of user include directories (not system includes or SystemC includes)
#
# Available targets:
#    build - compile and link
#    sim - invoke simulator
#    simgui - invoke simulator
#    clean
#    help

INVOKE_ARGS   = $(SCVerify_INVOKE_ARGS)

NC_ROOT           = $(NCSim_NC_ROOT)
ifeq "$(NCSIM_GCCVERSION)" ""
NCSIM_GCCVERSION  = $(NCSim_NCSIM_GCCVERSION)
endif
NCSIM_TIMESCALE   = $(NCSim_NCSIM_TIMESCALE)
NCVHDL_OPTS       = $(NCSim_NCVHDL_OPTS)
NCVLOG_OPTS       = $(NCSim_NCVLOG_OPTS)
NCSC_CXX_OPTS     = $(NCSim_NCSC_CXX_OPTS)
NCSC_OPTS         = $(NCSim_NCSC_OPTS)
NCELAB_OPTS       = $(NCSim_NCELAB_OPTS)
NCSIM_OPTS        = $(NCSim_NCSIM_OPTS)
FORCE_32BIT       = $(NCSim_FORCE_32BIT)
GCC_HOME          = $(NCSim_GCC_HOME)
NCSIM_DOFILE      = $(NCSim_NCSIM_DOFILE)

# Begin: Options for using Novas FSDB writer
NOVAS_INST_DIR    = $(Novas_NOVAS_INST_DIR)
NOVAS_PLATFORM    = $(Novas_NOVAS_PLATFORM)
# End: Options for using Novas FSDB writer

ifeq "$(NC_ROOT)" ""
   $(error The NC_ROOT must be set to use this makefile)
endif
ifeq "$(NCSC_MAKE)" ""
   export NCSC_MAKE = $(MAKE)
endif

export CCS_VCD_FILE

ifeq "$(NCSIM_GCCVERSION)" ""
# Use the NCSim gcc default
GCC_VERSION =
GCC_VER_DIR =
GCC_VER_ARG =
else
# Use a specific gcc version from the NCSim installation
GCC_VERSION = $(NCSIM_GCCVERSION)
GCC_VER_DIR = /$(NCSIM_GCCVERSION)
GCC_VER_ARG = -GCC_VERS $(NCSIM_GCCVERSION)
endif

ifneq "$(NCSim_GCC_HOME)" ""
  $(warning Setting for GCC_HOME is deprecated. NCSIM_GCCVERSION is used to derive GCC_HOME)
endif

# Check for 64-bit option
PLAT = $(shell uname)
ifneq "$(PLAT)" "Linux"
   $(error This makefile 'ccs_ncsim.mk' is only supported on Linux platforms)
endif

# Determine if user's environment forces 64-bit NCSim
ifneq "$(INCA_64BIT)" ""
  INCA_64BIT_SET = 1
else
  ifneq "$(findstring INCA,$(CDS_AUTO_64BIT))" ""
    INCA_64BIT_SET = 1
  else
    ifneq "$(findstring ALL,$(CDS_AUTO_64BIT))" ""
      INCA_64BIT_SET = 1
    else
      INCA_64BIT_SET = 0
    endif
  endif
endif

ifeq "$(NCSIM_TARGET_MODE)" "32"
  FORCE_32BIT = yes
endif

PLAT_ARCH = $(shell uname -i)
ifeq "$(PLAT_ARCH)" "x86_64"
  # Running on a 64-bit machine
  ifeq "$(INCA_64BIT_SET)" "1"
    USE_NCSIM_64BIT = 1
  else
    ifeq "$(FORCE_32BIT)" "yes"
      USE_NCSIM_64BIT = 0
    else
      USE_NCSIM_64BIT = 1
    endif
  endif
else
  USE_NCSIM_64BIT = 0
endif

NCVER_TXT = $(shell $(NC_ROOT)/tools/bin/ncvhdl -VERSION)
NCVER = $(firstword $(subst ., ,$(strip $(word 3,$(NCVER_TXT)))))
export NCVER
PRE10 = 0
ifeq "$(NCVER)" "09"
  PRE10 = 1
endif

# for -m32/-m64
ifeq "$(PRE10):::$(USE_NCSIM_64BIT):::$(PLAT_ARCH)" "0:::0:::x86_64"
  GCC_MOPT = -m32
  ifeq "$(NOVAS_EXECUTABLE_ARCH)" ""
    NOVAS_EXECUTABLE_ARCH := 32
    export NOVAS_EXECUTABLE_ARCH
  endif
else
  GCC_MOPT =
endif

# Backwards compatibility hook to allow user on a 32-bit platform to supply a 32-bit gcc installation
ifneq "$(PLAT_ARCH)" "x86_64"
  NCVER_GE_11 := $(shell [ "$(NCVER)" -ge 11 ] 2>/dev/null && echo true)
  ifeq "$(NCVER_GE_11)" "true"
    ifneq "$(NC_GCC_32BIT)" ""
      GCC_HOME := $(NC_GCC_32BIT)
    else
      $(error NCSim 11 or later does not provide a 32-bit gcc compiler installation - set NC_GCC_32BIT to point to a 32-bit gcc)
    endif
  endif
endif

# Add in compiler path:
ifeq "$(USE_NCSIM_64BIT)" "1"
 # 64-bit mode
 ifeq "$(PRE10)" "1"
   ifneq "$(GCC_VER_DIR)" ""
     GCC_HOME  := $(NC_ROOT)/tools/systemc/gcc$(GCC_VER_DIR)-x86_64/install
   else
     $(error NCSim 9 and earlier require a gcc version setting for 64bit compilation - set NCSIM_GCCVERSION to a valid 64-bit gcc version)
   endif
 else
   GCC_HOME    := $(NC_ROOT)/tools/cdsgcc/gcc$(GCC_VER_DIR)/install
 endif
 PATH        := $(NC_ROOT)/tools/bin/64bit:$(NC_ROOT)/tools/bin:$(GCC_HOME)/bin:$(PATH)
 LIB64       := /64bit
 GCCLIB      := $(GCC_HOME)/lib64:$(GCC_HOME)/lib
else
 # 32-bit mode
 ifeq "$(PRE10)" "1"
   GCC_HOME    := $(NC_ROOT)/tools/systemc/gcc$(GCC_VER_DIR)/install
 else
   GCC_HOME    := $(NC_ROOT)/tools/cdsgcc/gcc$(GCC_VER_DIR)/install
 endif
 PATH        := $(NC_ROOT)/tools/bin:$(GCC_HOME)/bin:$(PATH)
 LIB64       := 
 GCCLIB      := $(GCC_HOME)/lib:$(GCC_HOME)/lib64
endif
export PATH

GCC_COMPILER := $(GCC_HOME)/bin/g++

NORMAL_SOLNDIR := $(subst \,/,$(SOLNDIR))
DUTINSTINFOFILE := $(PROJ2WORK)/.dut_inst_info.tcl
NCELAB_LOG := $(PROJ2WORK)/$(TARGET)/ncelab.log 
SIM_LOG := $(PROJ2WORK)/$(TARGET)/sim.log 

VLOG_INCDIR_OPT = $(foreach id,$(VLOG_INCDIRS),-INCDIR $(id))
VLOG_DEFS_OPT = $(foreach d,$(VLOG_DEFS),-DEFINE $(d))

# optional variable to modify the executable filename when FSDB library is linked in 
PWR_EXE_EXT :=

#===============================================================================
# NCSim executables
NCVHDL = ncvhdl
NCVLOG = ncvlog
NCSC   = ncsc
NCSDFC = ncsdfc
NCELAB = ncelab
NCSIM  = ncsim

SC_ARGS = $(foreach i,$(INVOKE_ARGS),+systemc_args+$(i))

# Set up NC configuration switchs. NC_CFG_ARGS for use when compiling from the solution directory,
# NC_CFG_ARGS1 for use when executing the simulation from the project home.
NC_CFG_ARGS = -cdslib $(TARGET)/cds.lib -hdlvar $(TARGET)/hdl.var
NC_CFG_ARGS1 = -cdslib $(PROJ2WORK)/$(TARGET)/cds.lib -hdlvar $(PROJ2WORK)/$(TARGET)/hdl.var

# ifeq "$(STAGE)" "gate"
NCELAB_OPTS += -timescale '$(NCSIM_TIMESCALE)'
# endif

NCSC_LD_ARGS = -L$(NC_ROOT)/tools/lib$(LIB64)
NCSC_LD_ARGS += -L$(NC_ROOT)/tools/tbsc/lib$(LIB64)
NCSC_LD_ARGS += -L$(NC_ROOT)/tools/tbsc/lib$(LIB64)/gnu$(GCC_VER_DIR)
NCSC_LD_ARGS += -ltbsc -lscv
NCSC_LD_ARGS += -L$(NC_ROOT)/tools/systemc/lib$(LIB64)/gnu$(GCC_VER_DIR) -lsystemc_sh -lncscCoSim_sh -lncscCoroutines_sh

ifeq "$(CXX_OS)" "Linux"
LINKER_SHARED_LIB_OPT += -Wl,-G 
LINKER_SHARED_LIB_OPT += -shared 
endif

ifneq "$(CCS_VCD_FILE)" ""
ifeq "$(USE_FSDB)" ""
VCD_FILETYPE = $(suffix $(CCS_VCD_FILE))
ifeq "$(VCD_FILETYPE)" ".fsdb"
USE_FSDB = true
endif
endif
endif

ifneq "$(USE_FSDB)" ""
PWR_EXE_EXT := pwr

  ifeq "$(NOVAS_INST_DIR)" ""
     $(warning Warning: The NOVAS_INST_DIR environment variable must be set to use this makefile)
  endif

  NOVAS_PLATFORM = $(shell NOVAS_EXECUTABLE_ARCH=$(NOVAS_EXECUTABLE_ARCH) $(NOVAS_INST_DIR)/bin/novas_plat)

  VHDL_SRC += $(NOVAS_INST_DIR)/share/PLI/IUS/$(NOVAS_PLATFORM)/novas.vhd/novas.vhd.vhdlts
  $(TARGET)/novas.vhd.vhdlts: $(NOVAS_INST_DIR)/share/PLI/IUS/$(NOVAS_PLATFORM)/novas.vhd
  $(TARGET)/novas.vhd.vhdlts: HDL_LIB=work

  LINK_LIBPATHS += $(NOVAS_INST_DIR)/share/PLI/IUS/$(NOVAS_PLATFORM)
  LINK_LIBNAMES += fsdbSC
  OPTIONAL_DU = work.novas
  NCELAB_PLI_ARGS = -access +r -loadpli1 debpli:novas_pli_boot:export
  NCSIM_PLI_ARGS = -loadcfc debcfc:novas_cfc_boot -loadfmi debfmi:novas_fmi_boot
  LD_LIBRARY_PATH      := $(NOVAS_INST_DIR)/share/PLI/IUS/$(NOVAS_PLATFORM):$(NOVAS_INST_DIR)/share/PLI/IUS/$(NOVAS_PLATFORM)/boot:$(GCC_HOME)/lib:$(NC_ROOT)/tools/systemc/lib$(LIB64):$(NC_ROOT)/tools/lib$(LIB64):$(NC_ROOT)/tools/tbsc/lib$(LIB64)/gnu$(GCC_VER_DIR):$(LD_LIBRARY_PATH)

else

  ifeq "$(PRE10)" "0"
    LD_LIBRARY_PATH      := $(GCCLIB):$(NC_ROOT)/tools/systemc/lib$(LIB64):$(NC_ROOT)/tools/lib$(LIB64):$(NC_ROOT)/tools/tbsc/lib$(LIB64)/gnu$(GCC_VER_DIR):$(LD_LIBRARY_PATH)
  else
    LD_LIBRARY_PATH      := $(GCCLIB):$(NC_ROOT)/tools/lib$(LIB64):$(NC_ROOT)/tools/systemc/lib$(LIB64):$(NC_ROOT)/tools/tbsc/lib$(LIB64)/gnu$(GCC_VER_DIR):$(LD_LIBRARY_PATH)
  endif

endif
export LD_LIBRARY_PATH


# NCSim always use GNU C++ compiler
CXX_TYPE   = gcc

# C++ Compile options
F_COMP     = -c
F_INCDIR   = -I
F_DBG      = -g
F_LIBDIR   = -L
LIB_PREFIX = -l
LIB_EXT    = .a
OBJ_EXT    = .o
ifeq "$(SCVerify_OPTIMIZE_WRAPPERS)" "true"
F_WRAP_OPT = -O2
else
F_WRAP_OPT =
endif

ifeq "$(Option_CppStandard)" "c++11"
$(warning Warning: Applying the gcc option for the C++11 language standard)
# CXXFLAGS += -std=gnu++11
endif

ADDED_LIBPATHS := $(foreach lp,$(LINK_LIBPATHS),$(F_LIBDIR) $(lp))
ADDED_LIBNAMES := $(foreach ln,$(LINK_LIBNAMES),$(LIB_PREFIX)$(ln))

# SDF Simulation support
ifneq "$(VNDR_SDFINST)" ""
ifneq "$(SDF_FNAME)" ""
SDF_OPT = -sdfmax $(VNDR_SDFINST)=$(PROJ2SOLN)/$(SDF_FNAME)
else
# compatibility with the flows that do not set the SDF_FNAME (and assume its name to be $(TARGET)/scverify_gate.sdf)
SDF_OPT = -sdfmax $(VNDR_SDFINST)=$(PROJ2SOLN)/$(TARGET)/scverify_gate.$(NETLIST).sdf
endif
endif

# Build up include directory path
CXX_INCLUDES += $(INCL_DIRS)
CXX_INCLUDES += ../../include
# CXX_INCLUDES += $(NC_ROOT)/tools/systemc/include
CXX_INCLUDES += $(NC_ROOT)/tools/tbsc/include
CXX_INCLUDES += $(NC_ROOT)/tools/vic/include
# CXX_INCLUDES += $(MGC_HOME)/shared/include
CXX_INCLUDES += $(MGC_HOME)/pkgs/hls_pkgs/src
CXX_INCLUDES += $(MGC_HOME)/pkgs/siflibs
CXX_INCLUDES += $(MGC_HOME)/pkgs/hls_pkgs/mgc_comps_src
CXX_INC += $(foreach idir,$(CXX_INCLUDES),$(F_INCDIR)$(idir))

# Modify SUFFIX then prefix TARGET (preserve order of files)
TMP_VLOG_SRC := $(foreach hdlfile,$(VLOG_SRC),$(TARGET)/$(notdir $(hdlfile)))
TMP_VHDL_SRC := $(foreach hdlfile,$(VHDL_SRC),$(TARGET)/$(notdir $(hdlfile)))
TMP_CXX_SRC := $(foreach hdlfile,$(CXX_SRC),$(TARGET)/$(notdir $(hdlfile)))
TMP_CXX_OBJ := $(foreach hdlfile,$(CXX_SRC),$(TARGET)/$(notdir $(hdlfile))$(OBJ_EXT))
TMP_SDF_SRC := $(foreach sdffile,$(SDF_FILE),$(TARGET)/$(notdir $(sdffile)).X)

# Custom time-stamp dependencies for scverify_top.cpp/mc_testbench.cpp
$(TARGET)/scverify_top.cpp.cxxts: .ccs_env_opts/SCVerify_OPTIMIZE_WRAPPERS.ts
$(TARGET)/mc_testbench.cpp.cxxts: .ccs_env_opts/SCVerify_OPTIMIZE_WRAPPERS.ts

# Translate rule to compile VHDL with NCSim
#ncsc_run $(NC_CFG_ARGS) -STOP HDL_COMP $(foreach o,-linedebug -work $(HDL_LIB) -v93 $(NCVHDL_OPTS),-ncvhdl_args,$(o)) $<
$(TARGET)/%.vhdlts :
	-@echo "============================================"
	-@echo "Compiling VHDL file: $<"
	$(NCVHDL) -work $(HDL_LIB) $(NC_CFG_ARGS) $(NCVHDL_OPTS) $<
	$(TIMESTAMP)

# Translate rule to compile Verilog with NCSim
#ncsc_run $(NC_CFG_ARGS) -STOP HDL_COMP $(foreach o,-linedebug -work $(HDL_LIB) -v93 $(NCVLOG_OPTS),-ncvlog_args,$(o)) $<
$(TARGET)/%.vts :
	-@echo "============================================"
	-@echo "Compiling Verilog file: $<"
	$(NCVLOG) -work $(HDL_LIB) $(NC_CFG_ARGS) $(NCVLOG_OPTS) $(NCVLOG_F_OPTS) $(VLOG_DEFS_OPT) $(VLOG_INCDIR_OPT) $<
	$(TIMESTAMP)

# Translate rule to compile SystemC with NCSim
$(TARGET)/%.cxxts :
	-@echo "============================================"
	-@echo "Compiling C++ file: $<"
	$(NCSC) $(GCC_VER_ARG) -COMPILER $(GCC_COMPILER) $(NC_CFG_ARGS) $(NCSC_OPTS) -CFLAGS "$(GCC_MOPT) -fPIC -o $@.o $(CXX_INC) -DNCSC -c $(NCSC_CXX_OPTS) $(CXXFLAGS) $(CXX_OPTS)" $<
	$(TIMESTAMP)

# Translate rule to compile SDF file with NCSim
$(SDF_FILE).X : $(SDF_FILE)
	-@echo "============================================"
	-@echo "Compiling SDF file: $<"
	$(NCSDFC) -messages -output $@ $<
	-@echo "COMPILED_SDF_FILE = \"./$(SOLNDIR)/$@\";" >$@.cmd
	-@echo "SCOPE = :$(subst /,:,$(VNDR_SDFINST));" >>$@.cmd
	-@echo "LOG_FILE = \"sdf_annotate.log\";" >>$@.cmd
	-@echo "MTM_CONTROL = \"TYPICAL\";" >>$@.cmd

# Expand out the list of logical libraries to create
# Path to physical lib is relative to location of cds.lib
$(foreach lib,$(HDL_LIB_NAMES),$(TARGET)/$(lib).libts): 
	$(MKDIR) $(subst .libts,,$@)
	$(ECHO) "define $(subst .libts,,$(notdir $@)) ./$(subst .libts,,$(notdir $@))" >>$(TARGET)/cds.lib
	$(TIMESTAMP)

# Create the target directory
$(TARGET)/make_dir: 
	@-$(ECHO) "============================================"
	@-$(ECHO) "Creating simulation directory '$(subst /,$(PATHSEP),$(TARGET))'"
	$(MKDIR) $(subst /,$(PATHSEP),$(TARGET))
	$(TIMESTAMP)

# Create the initial cds.lib file
# This must preceed any actual HDL compilation
$(TARGET)/cds.lib: $(TARGET)/make_dir
	$(ECHO) "include $(NC_ROOT)/tools/inca/files/cds.lib" >$@
	$(ECHO) "define work worklib" >$(TARGET)/hdl.var

# Targets start here
$(TARGET)/make_libs : $(TARGET)/make_dir $(TARGET)/cds.lib $(foreach lib,$(HDL_LIB_NAMES),$(TARGET)/$(lib).libts)
	$(TIMESTAMP)

$(TARGET)/$(TOP_DU)$(PWR_EXE_EXT)ts: $(TMP_SDF_SRC) $(TMP_VHDL_SRC) $(TMP_VLOG_SRC) $(TMP_CXX_SRC)
ifneq "$(CXX_SRC)" ""
	-@echo "============================================"
	-@echo "Linking executable"
	$(GCC_COMPILER) $(TMP_CXX_OBJ) $(LINKER_SHARED_LIB_OPT) $(GCC_MOPT) $(NCSC_LD_ARGS) $(ADDED_LIBPATHS) $(ADDED_LIBNAMES) -o $(TARGET)/lib$(TOP_DU)$(PWR_EXE_EXT).so
	-@echo "============================================"
ifneq "$(VNDR_SDFINST)" ""
	-@echo "Elaborating design with SDF back annotation"
	$(CD) $(WORK2PROJ)$(;) $(NCELAB) +tb_rc_dir+$(PROJ2WORK)/$(TARGET) +tb_run_dir+. +tb_trans_record -access +R $(NCELAB_PLI_ARGS) -log $(NCELAB_LOG) -work work $(SC_ARGS) $(NC_CFG_ARGS1) -loadsc $(PROJ2WORK)/$(TARGET)/lib$(TOP_DU)$(PWR_EXE_EXT).so $(NCELAB_OPTS) $(TOP_DU) -sdf_cmd_file $(PROJ2WORK)/$(SDF_FILE).X.cmd
else
	-@echo "Elaborating design"
	$(CD) $(WORK2PROJ)$(;) $(NCELAB) +tb_rc_dir+$(PROJ2WORK)/$(TARGET) +tb_run_dir+. +tb_trans_record -access +R $(NCELAB_PLI_ARGS) -log $(NCELAB_LOG) -work work $(SC_ARGS) $(NC_CFG_ARGS1) -loadsc $(PROJ2WORK)/$(TARGET)/lib$(TOP_DU)$(PWR_EXE_EXT).so $(NCELAB_OPTS) $(TOP_DU)
endif
endif      
	$(TIMESTAMP)

$(TARGET)/scverify_ncsim_gui.tcl: $(WORK2SOLN)/scverify/ccs_wave_signals.dat
	-@echo "============================================"
	-@echo "Creating NCSim TCL file '$@' from '$<'"
	$(TCLSH_CMD) $(MGC_HOME)/pkgs/sif/userware/En_na/flows/app_ncsim.flo create_ncsim_wave $(PROJ2SOLN)/scverify/ccs_wave_signals.dat $@ $(DUTINSTINFOFILE) $(NCSIM_DOFILE) 0

build: $(TARGET)/make_libs $(TARGET)/$(TOP_DU)$(PWR_EXE_EXT)ts $(TARGET)/scverify_ncsim_gui.tcl

# Export special env var to indicate batch or gui mode
sim:    CCS_SIM_MODE=batch
simgui: CCS_SIM_MODE=gui
export  CCS_SIM_MODE

sim: build
	-@echo "============================================"
ifneq "$(CCS_VCD_FILE)" ""
	-@echo "Simulating design entity: $(TOP_DU) to produce Switching Activity File: $(CCS_VCD_FILE)"
else
	-@echo "Simulating design entity: $(TOP_DU)"
endif
	$(CD) $(WORK2PROJ)$(;) $(NCSIM) $(NCSIM_OPTS) $(NCSIM_PLI_ARGS) -log $(SIM_LOG) +tb_rc_dir+$(PROJ2WORK)/$(TARGET) +tb_run_dir+. +tb_trans_record -input $(PROJ2WORK)/$(TARGET)/scverify_ncsim_gui.tcl $(SC_ARGS) $(NC_CFG_ARGS1) $(TOP_DU)

simgui: build
	-@echo "============================================"
ifneq "$(CCS_VCD_FILE)" ""
	-@echo "Simulating design entity: $(TOP_DU) to produce Switching Activity File: $(CCS_VCD_FILE)"
else
	-@echo "Simulating design entity: $(TOP_DU)"
endif
	$(CD) $(WORK2PROJ)$(;) $(NCSIM) -gui $(NCSIM_OPTS) $(NCSIM_PLI_ARGS) -log $(SIM_LOG) -key $(PROJ2WORK)/$(TARGET)/ncsim.key +tb_rc_dir+$(PROJ2WORK)/$(TARGET) +tb_run_dir+. +tb_trans_record -input $(PROJ2WORK)/$(TARGET)/scverify_ncsim_gui.tcl $(SC_ARGS) $(NC_CFG_ARGS1) $(TOP_DU)

.PHONY: clean
clean:
	@-$(ECHO) "============================================"
	@-$(ECHO) "Removing working directory $(TARGET)"
	-$(RMDIR) $(subst /,$(PATHSEP),$(TARGET))

.PHONY : help
help: helptext dumpsysvars dump_ncsim_vars
	@-$(ECHO) "   SCVerify flow options:"
	@-$(ECHO) "     INVOKE_ARGS           = $(INVOKE_ARGS)"
	@-$(ECHO) "     INCL_DIRS             = $(INCL_DIRS)"
	@-$(ECHO) "     ADDED_LIBPATHS        = $(ADDED_LIBPATHS)"
	@-$(ECHO) "     ADDED_LIBNAMES        = $(ADDED_LIBNAMES)"
	@-$(ECHO) "     CCS_VCD_FILE          = $(CCS_VCD_FILE)"
	@-$(ECHO) "     VNDR_HDL_LIBS         = $(VNDR_HDL_LIBS)"

helptext:
	@-$(ECHO) "NCSim Makefile"
	@-$(ECHO) "The valid targets are:"
	@-$(ECHO) "   simgui     Compile and Execute the simulation using the"
	@-$(ECHO) "              interactive mode of the simulator (if available)"
	@-$(ECHO) "   sim        Compile and Execute the simulation using the"
	@-$(ECHO) "              batch mode of the simulator"
	@-$(ECHO) "   build      Compile the models only"
	@-$(ECHO) "   clean      Remove all compiled objects"
	@-$(ECHO) "   help       Show this help text"
	@-$(ECHO) ""
	@-$(ECHO) "The current variables settings are:"

.PHONY : dumpvars
dumpvars: dump_ncsim_vars

dump_ncsim_vars:
	@-$(ECHO) "   NCSim flow options:"
	@-$(ECHO) "     NC_ROOT               = $(NC_ROOT)"
	@-$(ECHO) "     NCVER                 = $(NCVER)"
	@-$(ECHO) "     GCC_HOME              = $(GCC_HOME)"
	@-$(ECHO) "     FORCE_32BIT           = $(FORCE_32BIT)"
	@-$(ECHO) "     NCVHDL_OPTS           = $(NCVHDL_OPTS)"
	@-$(ECHO) "     NCVLOG_OPTS           = $(NCVLOG_OPTS)"
	@-$(ECHO) "     NCSC_OPTS             = $(NCSC_OPTS)"
	@-$(ECHO) "     NCSC_CXX_OPTS         = $(NCSC_CXX_OPTS)"
	@-$(ECHO) "     NCELAB_OPTS           = $(NCELAB_OPTS)"
	@-$(ECHO) "     NCSIM_OPTS            = $(NCSIM_OPTS)"
	@-$(ECHO) "     NCSIM_TIMESCALE       = $(NCSIM_TIMESCALE)"
ifeq "$(NCSIM_GCCVERSION)" ""
	@-$(ECHO) "     NCSIM_GCCVERSION      = NCSim default"
else
	@-$(ECHO) "     NCSIM_GCCVERSION      = $(NCSIM_GCCVERSION)"
endif
	@-$(ECHO) "     CDS_LIC_FILE          = $(CDS_LIC_FILE)"
	@-$(ECHO) "     LD_LIBRARY_PATH       = $(LD_LIBRARY_PATH)"
	@-$(ECHO) "     NCELAB_PLI_ARGS       = $(NCELAB_PLI_ARGS)"
	@-$(ECHO) "     VLOG_INCDIR_OPT       = $(VLOG_INCDIR_OPT)"
	@-$(ECHO) "     VLOG_DEFS_OPT         = $(VLOG_DEFS_OPT)"
	@-$(ECHO) "     NCSIM_DOFILE          = $(NCSIM_DOFILE)"
ifneq "$(USE_FSDB)" ""
	@-$(ECHO) "   Novas flow options:"
	@-$(ECHO) "     NOVAS_INST_DIR        = $(NOVAS_INST_DIR)"
	@-$(ECHO) "     NOVAS_PLATFORM        = $(NOVAS_PLATFORM)"
endif


