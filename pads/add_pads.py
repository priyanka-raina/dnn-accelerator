#!/usr/bin/env python
# Usage: add_pads.py file1.v file2.v ...
# Creates wrappers for all modules found in given files
# Dependencies: veriloggen (pip install veriloggen --user), Icarus Verilog (use icarus)

from veriloggen import *

pad_out = StubModule('pad_out')
pad_in = StubModule('pad_in')

def gen_wrapper(mod):
    # create module m as wrapper for mod
    m = Module(mod.name + 'IO')
    m.copy_ports(mod)

    print('Generating wrapper {0} for {1} in {0}.v'.format(m.name, mod.name))

    ports = list(mod.get_ports())
    # instantiate mod in m with all ports as wires
    Submodule(m, mod, name='core', prefix='core_', as_wire=ports)
    # prevent generation of verilog code for mod
    del m.submodule[mod.name]

    # add pad_in and pad_out on all ports
    for port in m.get_ports().values():
        params, ports = {}, {}
        if port.width:
            params['w'] = port.width
        ports['PAD'] = m[port.name]

        if isinstance(port, Input):
            ports['C'] = m['core_' + port.name]
            m.Instance(pad_in, 'pad_' + port.name, params, ports)
        else:
            ports['I'] = m['core_' + port.name]
            m.Instance(pad_out, 'pad_' + port.name, params, ports)

    m.to_verilog(m.name + '.v')

if __name__ == '__main__':
    import sys
    fname = sys.argv[1]

    mod_dict = from_verilog.read_verilog_module(fname)
    for mod in mod_dict.values():
        print("mod", mod)
        #gen_wrapper(mod)
