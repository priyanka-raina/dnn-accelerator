set search_path "$search_path   /tsmc40r/pdk/2019.05.21_TSMC/tcbn40lpbwp_200a/tcbn40lpbwp_200a_nldm/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcbn40lpbwp_200a \
                                /tsmc40r/pdk/2019.05.21_TSMC/tcbn40lpbwp_200a/tcbn40lpbwp_200a_ccs/TSMCHOME/digital/Front_End/timing_power_noise/CCS/tcbn40lpbwp_200a \
                                /tsmc40r/pdk/2019.05.21_TSMC/tcbn40lpbwplvt_200a/tcbn40lpbwplvt_200a_nldm/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcbn40lpbwplvt_200a \
                                /tsmc40r/pdk/2019.05.21_TSMC/tcbn40lpbwplvt_200a/tcbn40lpbwplvt_200a_ccs/TSMCHOME/digital/Front_End/timing_power_noise/CCS/tcbn40lpbwplvt_200a \
                                /tsmc40r/pdk/2019.06.27_TSMC/tphn40lpgv2od3_sl_210b/tphn40lpgv2od3_sl_210b_nldm/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tphn40lpgv2od3_sl_210b \
                                /tsmc40r/pdk/sram_compiler/tsdn40lpa4096x40m4m_130b/NLDM \
                                /tsmc40r/pdk/sram_compiler/tsdn40lpa4096x72m4m_130b/NLDM \
                                /tsmc40r/pdk/sram_compiler/tsdn40lpa256x16m16f_130b/NLDM \
				                /tsmc40r/pdk/sram_compiler/tsdn40lpa256x32m8f_130b/NLDM"

set srams "tsdn40lpa4096x72m4m_130b_ff1p21vm40c.db
tsdn40lpa4096x72m4m_130b_ff1p21v125c.db
tsdn40lpa4096x72m4m_130b_ff1p21v0c.db
tsdn40lpa4096x72m4m_130b_tt1p1v125c.db
tsdn40lpa4096x72m4m_130b_ss0p99vm40c.db
tsdn40lpa4096x72m4m_130b_ss0p99v125c.db
tsdn40lpa4096x72m4m_130b_ss0p99v0c.db
tsdn40lpa4096x72m4m_130b_tt1p1v25c.db
tsdn40lpa4096x40m4m_130b_tt1p1v125c.db
tsdn40lpa4096x40m4m_130b_ff1p21v0c.db
tsdn40lpa4096x40m4m_130b_ff1p21vm40c.db
tsdn40lpa4096x40m4m_130b_ff1p21v125c.db
tsdn40lpa4096x40m4m_130b_tt1p1v25c.db
tsdn40lpa4096x40m4m_130b_ss0p99v0c.db
tsdn40lpa4096x40m4m_130b_ss0p99vm40c.db
tsdn40lpa4096x40m4m_130b_ss0p99v125c.db
tsdn40lpa256x16m16f_130b_ff1p21v125c.db
tsdn40lpa256x16m16f_130b_tt1p1v125c.db
tsdn40lpa256x16m16f_130b_ff1p21vm40c.db
tsdn40lpa256x16m16f_130b_ss0p99v0c.db
tsdn40lpa256x16m16f_130b_tt1p1v25c.db
tsdn40lpa256x16m16f_130b_ss0p99v125c.db
tsdn40lpa256x16m16f_130b_ss0p99vm40c.db
tsdn40lpa256x16m16f_130b_ff1p21v0c.db
tsdn40lpa256x32m8f_130b_ff1p21vm40c.db
tsdn40lpa256x32m8f_130b_ff1p21v125c.db
tsdn40lpa256x32m8f_130b_tt1p1v125c.db
tsdn40lpa256x32m8f_130b_tt1p1v25c.db
tsdn40lpa256x32m8f_130b_ss0p99v0c.db
tsdn40lpa256x32m8f_130b_ss0p99vm40c.db
tsdn40lpa256x32m8f_130b_ss0p99v125c.db
tsdn40lpa256x32m8f_130b_ff1p21v0c.db"

set target_library "tcbn40lpbwptc.db tcbn40lpbwplvttc.db $srams"
set link_library "* tcbn40lpbwptc.db tcbn40lpbwplvttc.db tphn40lpgv2od3_sltc.db $srams"

set mw_reference_libraries "/tsmc40r/pdk/digital/5x1u/libraries/tcbn40lpbwp_200a_apt/TSMCHOME/digital/Back_End/milkyway/tcbn40lpbwp_200a/cell_frame_HVH_0d5_0/tcbn40lpbwp \
                            /tsmc40r/pdk/digital/5x1u/libraries/tcbn40lpbwplvt_200a_apt/TSMCHOME/digital/Back_End/milkyway/tcbn40lpbwplvt_200a/cell_frame_HVH_0d5_0/tcbn40lpbwplvt \
                            /tsmc40r/pdk/digital/5x1u/libraries/tphn40lpgv2od3_sl_210a_aptu7lm/TSMCHOME/digital/Back_End/milkyway/tphn40lpgv2od3_sl_210a/mt_2/7lm/cell_frame/tphn40lpgv2od3_sl \ 
                            /tsmc40r/pdk/digital/5x1u/libraries/tpbn45v_ds_150a_aptcup7m5x1u/TSMCHOME/digital/Back_End/milkyway/tpbn45v_ds_150a/cup/7m/7M_5X1U/cell_frame/tpbn45v_ds"


set tluplus_path /tsmc40r/pdk/2019.10.05_TSMC/RC_TLUplus_crn40ulp_1p7m_5x1u_alrdl_9corners_1.0a/RC_TLUplus_crn40ulp_1p07m+alrdl_5x1u_typical
set max_tluplus $tluplus_path/crn40ulp_1p07m+alrdl_5x1u_typical.tluplus
set tech_file /tsmc40r/pdk/2019.10.05_TSMC/N40G_N40LP_fullset_Syn_v2d0a/N40G_N40LP_fullset_Syn_v2d0a/PR_tech/Synopsys/TechFile/RDL/HVH_0d5_0/tsmcn40_7lm5X1URDL.tf
set map_file /tsmc40r/pdk/2019.05.21_TSMC/tcbn40lpbwp_200a/tcbn40lpbwp_200a_apt/TSMCHOME/digital/Back_End/milkyway/tcbn40lpbwp_200a/techfiles/tluplus/star.map_7M

# routing scripts
set antenna_ratio_script /tsmc40r/pdk/digital/5x1u/libraries/tcbn40lpbwp_200a_apf/TSMCHOME/digital/Back_End/milkyway/tcbn40lpbwp_200a/clf/antennaRule_n40_8lm.tcl
set via_insertion_script ""

set gds_map_layer /tsmc40r/pdk/2019.10.05_TSMC/N40G_N40LP_fullset_Syn_v2d0a/N40G_N40LP_fullset_Syn_v2d0a/PR_tech/Synopsys/GdsOutMap/gdsout_5X1U.map
