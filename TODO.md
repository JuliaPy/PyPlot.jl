## TODO

* Send code directly to ipython/python kernel using ZMQ binding from
  Julia. The problems is that
    * ipython kernel: ZMQ message is encrypted.
    * python kernel: kernel get suspended when no tty attached.
* Reveal traceback message in python
