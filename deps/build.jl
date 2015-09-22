using PyCall
import Conda
# If Conda is used as python distribution then add matplotlib
if PyCall.use_conda
    Conda.add("matplotlib")
end
