# Package

version       = "0.1.0"
author        = "ExoPlant"
description   = "Packwiz Graphic User Interface using NiGUI"
license       = "Apache-2.0"
srcDir        = "src"
bin           = @["packwiz_nigui"]


# Dependencies

requires "nim >= 1.6.6"
requires "nigui >= 0.2.6"
requires "parsetoml"