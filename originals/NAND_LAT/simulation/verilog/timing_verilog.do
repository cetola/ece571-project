-- simulate the design
-- !!CHANGE THE PATH POINTING TO YOUR SDF FILE!!
vsim -L ovi_machxo2 -PL pmi_work +access +r nfcm_tb -noglitch +no_tchk_msg -sdfmax nfcm="./final_xo2/final_xo2_final_xo2_vo.sdf"
add wave *
run -all

