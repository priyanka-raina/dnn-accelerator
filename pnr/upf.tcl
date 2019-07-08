# VDD is our net name for the logic supply.
derive_pg_connection -power_net VDD -power_pin VDD -create_ports top
# VSS is our net name for the global VSS. 
derive_pg_connection -ground_net VSS -ground_pin VSS -create_ports top
# VDDPST is our net name for the pad ring 1.8 I/O supply. Pad cells connect to this net through the ring internally.
derive_pg_connection -power_net VDDPST -power_pin VDDPST -create_ports top
# VSSPST is our net name for the pad ring 1.8 I/O supply. Pad cells connect to this net through the ring internally.
derive_pg_connection -ground_net VSSPST -ground_pin VSSPST -create_ports top
# POC (power on control) is a net internal to the pad ring, not a port
derive_pg_connection -power_net POC -power_pin POC -create_ports none
