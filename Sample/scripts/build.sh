#!/bin/bash
echo "--Clean-up--"
if [ -d ../build ]; then
	rm -r ../build
fi

echo "--Configuration--"
cmake --preset Debug -S ..
cmake --preset RelWithDebInfo -S ..
cmake --preset Release -S ..
cmake --preset MinSizeRel -S ..



echo "--Building--"
cmake --build --preset Debug
cmake --build --preset RelWithDebInfo
cmake --build --preset Release
cmake --build --preset MinSizeRel







