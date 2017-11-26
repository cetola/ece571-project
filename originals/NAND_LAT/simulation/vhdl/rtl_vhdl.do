-- Simulate the design
vsim +access +r nfcm_tb ben -L machxo2 -PL pmi_work
add wave *
run 370 us

