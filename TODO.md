## TODO

* Send code directly to ipython/python kernel from Julia. The problems
are
    * ipython kernel: the ZMQ message should be encrypted.
    * python kernel: kernel get frozen when `ion()` or `show()` due to GUI main loop.
* Reveal traceback message in python
* Wait for Julia ipython kernel
