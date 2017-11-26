-- simulate the design
-- !!CHANGE THE PATH POINTING TO YOUR SDF FILE!!
vsim +access +r nfcm_tb ben -noglitch -L machxo2 -PL pmi_work +no_tchk_msg  -sdfmax nfcm = "./final_xo2/final_xo2_final_xo2_vho.sdf"
add wave *
run 370 us

