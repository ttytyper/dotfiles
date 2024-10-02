#!/usr/bin/env python
import sys
import colorsys

green_level=float(sys.argv[1])
now_level=float(sys.argv[2])
red_level=float(sys.argv[3])

# Clamp now_level between green_level and red_level
now_level=max(now_level,min(green_level, red_level))
now_level=min(now_level,max(green_level, red_level))

# How close or far is now_level to red_level
to_red=abs(now_level-red_level)

# How large is the full range
full_range=abs(green_level-red_level)

# Takes the ratio to figure out how green the output should be, on a scale from 0
# to 1/3, where 0 is completely red and 1/3 is completely green.
hue=to_red/full_range/3

rgb=tuple([z*255 for z in colorsys.hls_to_rgb(hue, 0.5, 1.0)])
# Print the RGB values as HEX
print('#%02X%02X%02X' % (int(rgb[0]), int(rgb[1]), int(rgb[2])))
