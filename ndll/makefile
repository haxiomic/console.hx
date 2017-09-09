HXCPP_INCLUDE := $(shell haxelib path hxcpp | sed -n '1 p')include

wincon-vtt.ndll: wincon-vtt.cpp
	clang wincon-vtt.cpp -shared -o wincon-vtt.ndll -I${HXCPP_INCLUDE}