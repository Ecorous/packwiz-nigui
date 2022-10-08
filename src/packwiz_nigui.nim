# Copyright 2022 Ecorous System
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import nigui
import logging
import ./packwiz
import ./types
import os
import strutils
import algorithm

proc `--`(check: string): bool = 
  return check == ""

app.init()
let logger: Logger = getLogger "packwiz-nigui".createLoggingSource "main"
var window = newWindow "Packwiz.NiGUI"
logger.info "Starting packwiz-nigui!"
window.width = 600.scaleToDpi
window.height = 400.scaleToDpi

window.iconPath = "assets/packwiz_nigui.png"

var container = newLayoutContainer Layout_Vertical

window.add(container)

var create_pack_button = newButton "Create a new pack"
var open_pack_button = newButton "Open an existing pack"

container.add create_pack_button
container.add open_pack_button


create_pack_button.onClick = proc(event: ClickEvent) =
  var create_window = newWindow "Create Pack - Packwiz.NiGUI"

  create_window.iconPath = "assets/packwiz_nigui.png"
  create_window.width = 300
  create_window.height = 500

  show create_window
  # end init window
  var create_container = newLayoutContainer Layout_Vertical 
  create_window.add create_container

  # Pack Name field
  var input_name_container = newLayoutContainer Layout_Horizontal
  create_container.add input_name_container

  var name_text = newTextBox()
  var name_label = newLabel "Pack Name:"

  input_name_container.add name_label
  input_name_container.add name_text

  # Pack Author field
  var input_author_container = newLayoutContainer Layout_Horizontal
  create_container.add input_author_container

  var author_text = newTextBox()
  var author_label = newLabel "Pack Author:"

  input_author_container.add author_label
  input_author_container.add author_text

  # Pack Version field
  var input_version_container = newLayoutContainer Layout_Horizontal
  create_container.add input_version_container

  var version_text = newTextBox()
  var version_label = newLabel "Pack Version:"

  input_version_container.add version_label
  input_version_container.add version_text

  # Minecraft Version field
  var input_mcv_container = newLayoutContainer Layout_Horizontal

  create_container.add input_mcv_container

  var mcv_text = newTextBox()
  var mcv_label = newLabel "Minecraft Version:"

  input_mcv_container.add mcv_label
  input_mcv_container.add mcv_text

  # Mod Loader field
  var input_loader_container = newLayoutContainer Layout_Horizontal

  create_container.add input_loader_container
  var loaders: seq[string] = @[$Modloader.Quilt, $Modloader.Forge, $Modloader.Fabric, $Modloader.None]
  loaders.sort
  var loader_text = newComboBox loaders
  var loader_label = newLabel "Mod Loader:"

  input_loader_container.add loader_label
  input_loader_container.add loader_text

  var input_loaderv_container = newLayoutContainer Layout_Horizontal

  create_container.add input_loaderv_container

  var loaderv_text = newTextBox()
  var loaderv_label = newLabel "Quilt Loader Version:"

  input_loaderv_container.add loaderv_label
  input_loaderv_container.add loaderv_text

  var input_submit_container = newLayoutContainer Layout_Vertical
  create_container.add input_submit_container

  var submit_button = newButton "Submit"
  input_submit_container.add submit_button
  
  submit_button.onClick = proc(event: ClickEvent) =
    if --name_text.text or --author_text.text or --version_text.text or --mcv_text.text:
      packwizInit()
    else: 
      packwizInit(name_text.text, author_text.text, version_text.text, mcv_text.text, toModLoader(loader_text.options[loader_text.index]), loaderv_text.text)

    window.alert("Modpack created! Note that this does not account for errors, check the console to see errors.")

  loader_text.onChange = proc(event: ComboBoxChangeEvent) =
    if loader_text.options[loader_text.index] == "quilt":
      loaderv_label.show
      loaderv_text.show
      loaderv_label.text = "Quilt Loader Version"

    elif loader_text.options[loader_text.index] == "forge":
      loaderv_label.show
      loaderv_text.show
      loaderv_label.text = "Forge Version"

    elif loader_text.options[loader_text.index] == "fabric":
      loaderv_label.show
      loaderv_text.show
      loaderv_label.text = "Fabric Loader Version"

    elif loader_text.options[loader_text.index] == "vanilla":
      loaderv_label.hide
      loaderv_text.hide

open_pack_button.onClick = proc(event: ClickEvent) = 
  var open_pack_select_window = newWindow "Open Pack - Packwiz-NiGUI"

  open_pack_select_window.width = 500
  open_pack_select_window.height = 300
  open_pack_select_window.iconPath = "assets/packwiz_nigui.png"

  show open_pack_select_window 

  var open_pack_select_container = newLayoutContainer Layout_Horizontal
  var paths: seq[string]
  
  for path in walkDir "instances":
    if (path.path.dirExists) and fileExists(path.path / "pack.toml"): 
      paths.add path.path
  
  var packSelectComboBox = newComboBox paths
  open_pack_select_window.add open_pack_select_container #
  open_pack_select_container.add packSelectComboBox
  var packSelectButton = newButton "Open Pack"
  open_pack_select_container.add packSelectButton

  packSelectButton.onClick = proc(event: ClickEvent) =



show window

run app

logger.info "Exiting, goodbye!"


