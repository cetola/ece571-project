-- Simulate the design
vsim -L ovi_machxo2 -PL pmi_work +access +r nfcm_tb
add wave *
run -all

