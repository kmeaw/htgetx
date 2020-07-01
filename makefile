#
# Htget makefile
#
#
# Possible optimizations for 8088 class processors
#
# -oa   Relax alias checking
# -ob   Try to generate straight line code
# -oe - expand user functions inline (-oe=20 is default, adds lots of code)
# -oh   Enable repeated optimizations
# -oi   generate certain lib funcs inline
# -oi+  Set max inline depth (C++ only, use -oi for C)
# -ok   Flowing of register save into function flow graph
# -ol   loop optimizations
# -ol+  loop optimizations plus unrolling
# -or   Reorder for pipelined (486+ procs); not sure if good to use
# -os   Favor space over time
# -ot   Favor time over space
# -ei   Allocate an "int" for all enum types
# -zp2  Allow compiler to add padding to structs
# -zpw  Use with above; make sure you are warning free!
# -0    8088/8086 class code generation
# -s    disable stack overflow checking
# -zmf  put each function in a new code segment; helps with linking

# Make it fast.  But don't use -oe otherwise you'll need large model.

tcp_h_dir = ../../tcpinc/
tcp_c_dir = ../../tcplib/
common_h_dir = ../../include

memory_model = -ml
compile_options = -0 $(memory_model) '-DCFG_H="htget.cfg"' -oh -ok -ot -s -oa -ei -zp2 -zpw -we -ob -ol+ -oi+
c_compile_options = -0 $(memory_model) -oh -ok -ot -s -oa -ei -zp2 -zpw -we -ob
compile_options += -i=$(tcp_h_dir) -i=$(common_h_dir)


tcpobjs = packet.o arp.o eth.o ip.o tcp.o tcpsockm.o udp.o utils.o dns.o timer.o ipasm.o trace.o
objs = htget.o

all : clean htget.exe

clean : .symbolic
  @rm -f htget.exe
  @rm -f *.o
  @rm -f *.map

patch : .symbolic
  ..\..\utils\ptach htget.exe htget.map $(memory_model)

.asm : $(tcp_c_dir)

.cpp : $(tcp_c_dir)

.c.o : 
  wcc $[* $(c_compile_options)

.asm.o :
  wasm -0 $(memory_model) $[*

.cpp.o :
  wpp $[* $(compile_options)


htget.exe: $(tcpobjs) $(objs)
  wlink option verbose system dos option map option eliminate option stack=4096 name $@ file packet.o file arp.o file eth.o file ip.o file tcp.o file tcpsockm.o file udp.o file utils.o file dns.o file timer.o file ipasm.o file trace.o file htget.o
