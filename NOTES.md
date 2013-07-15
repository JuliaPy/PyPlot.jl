## Working Principles

## Dependencies on IPython

The dependencies of IPython facilities are necessary to

- wrap commands to messages, and retrieve commands execution result.
- create extra GUI loops, thus avoid blocking REPL when displaying
  plots.


Other notes:
  - Set {DY}LD_LIBRARY_PATH to include the directory of the zmq library 
    that the installed pyzmq uses.  This is important because pyzmq will 
    build a local zmq if it cannot find one installed on the system.
