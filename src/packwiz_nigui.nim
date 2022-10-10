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
import parsetoml
import ./packwiz
import ./types
import os
import strutils
import algorithm
import sequtils

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

var createPackButton = newButton "Create a new pack"
var openPackButton = newButton "Open an existing pack"

container.add createPackButton
container.add openPackButton


createPackButton.onClick = proc(event: ClickEvent) =
  var createWindow = newWindow "Create Pack - Packwiz.NiGUI"

  createWindow.iconPath = "assets/packwiz_nigui.png"
  createWindow.width = 300
  createWindow.height = 500

  show createWindow
  # end init window
  var createContainer = newLayoutContainer Layout_Vertical 
  createWindow.add createContainer

  # Pack Name field
  var inputNameContainer = newLayoutContainer Layout_Horizontal
  createContainer.add inputNameContainer

  var nameText = newTextBox()
  var nameLabel = newLabel "Pack Name:"

  inputNameContainer.add nameLabel
  inputNameContainer.add nameText

  # Pack Author field
  var inputAuthorContainer = newLayoutContainer Layout_Horizontal
  createContainer.add inputAuthorContainer

  var authorText = newTextBox()
  var authorLabel = newLabel "Pack Author:"

  inputAuthorContainer.add authorLabel
  inputAuthorContainer.add authorText

  # Pack Version field
  var inputVersionContainer = newLayoutContainer Layout_Horizontal
  createContainer.add inputVersionContainer

  var versionText = newTextBox()
  var versionLabel = newLabel "Pack Version:"

  inputVersionContainer.add versionLabel
  inputVersionContainer.add versionText

  # Minecraft Version field
  var inputMcvContainer = newLayoutContainer Layout_Horizontal

  createContainer.add inputMcvContainer

  var mcvText = newTextBox()
  var mcvLabel = newLabel "Minecraft Version:"

  inputMcvContainer.add mcvLabel
  inputMcvContainer.add mcvText

  # Mod Loader field
  var inputLoaderContainer = newLayoutContainer Layout_Horizontal

  createContainer.add inputLoaderContainer
  var loaders: seq[string] = @[$Modloader.Quilt, $Modloader.Forge, $Modloader.Fabric, $Modloader.None]
  loaders.sort
  var loaderText = newComboBox loaders
  var loaderLabel = newLabel "Mod Loader:"

  inputLoaderContainer.add loaderLabel
  inputLoaderContainer.add loaderText

  var inputLoaderVContainer = newLayoutContainer Layout_Horizontal

  createContainer.add inputLoaderVContainer
  

  var loadervText = newTextBox()
  var loadervLabel = newLabel "Quilt Loader Version:"

  inputLoaderVContainer.add loadervLabel
  inputLoaderVContainer.add loadervText

  var input_submit_container = newLayoutContainer Layout_Vertical
  createContainer.add input_submit_container

  var submit_button = newButton "Submit"
  input_submit_container.add submit_button
  
  submit_button.onClick = proc(event: ClickEvent) =
    if --nameText.text or --authorText.text or --versionText.text or --mcvText.text:
      packwizInit()
    else: 
      packwizInit(nameText.text, authorText.text, versionText.text, mcvText.text, toModLoader(loaderText.options[loaderText.index]), loadervText.text)

    window.alert("Modpack created! Note that this does not account for errors, check the console to see errors.")

  loaderText.onChange = proc(event: ComboBoxChangeEvent) =
    if loaderText.options[loaderText.index].toLowerAscii == "quilt":
      loadervLabel.show
      loadervText.show
      loadervLabel.text = "Quilt Loader Version"

    elif loaderText.options[loaderText.index].toLowerAscii == "forge":
      loadervLabel.show
      loadervText.show
      loadervLabel.text = "Forge Version"

    elif loaderText.options[loaderText.index].toLowerAscii == "fabric":
      loadervLabel.show
      loadervText.show
      loadervLabel.text = "Fabric Loader Version"

    elif loaderText.options[loaderText.index].toLowerAscii == "vanilla":
      loadervLabel.hide
      loadervText.hide

openPackButton.onClick = proc(event: ClickEvent) = 
  var openPackSelectWindow = newWindow "Open Pack - Packwiz-NiGUI"

  openPackSelectWindow.width = 500
  openPackSelectWindow.height = 300
  openPackSelectWindow.iconPath = "assets/packwiz_nigui.png"

  show openPackSelectWindow 

  var openPackSelectContainer = newLayoutContainer Layout_Horizontal
  var paths: seq[string]
  
  for path in walkDir "instances":
    if (path.path.dirExists) and fileExists(path.path / "pack.toml"): 
      paths.add path.path
  
  var packSelectComboBox = newComboBox paths # this is the combo box that the user selects from, we can get the current value by this.options[this.index]
  openPackSelectWindow.add openPackSelectContainer #
  openPackSelectContainer.add packSelectComboBox
  var packSelectButton = newButton "Open Pack"
  openPackSelectContainer.add packSelectButton

  packSelectButton.onClick = proc(event: ClickEvent) =
    var packRoot: string = packSelectComboBox.options[packSelectComboBox.index]
    openPackSelectWindow.dispose() # to make it so that the selection window is closed, otherwise values will break if they alt-tab and change the value
    var packEditWindow = newWindow "Pack Edit - Packwiz-NiGUI"
    packEditWindow.iconPath = "assets/packwiz_nigui.png"
    packEditWindow.show
    var packEditContainer = newLayoutContainer Layout_Vertical
    packEditWindow.add packEditContainer 
    var installModContainer = newLayoutContainer Layout_Horizontal 
    packEditContainer.add installModContainer

    # TODO: Get data from pack.toml and convert to modpack object
    var loader: Modloader = Modloader.None
    let tomlTable = parsetoml.parseFile(packRoot / "pack.toml")
    if tomlTable["versions"].hasKey("quilt"):
      loader = Modloader.Quilt
    elif tomlTable["versions"].hasKey("fabric"):
      loader = Modloader.Fabric
    elif tomlTable["versions"].hasKey("forge"):
      loader = Modloader.Forge

    var mods: seq[Mod] = @[]
    for file in walkFiles(packRoot / "mods" / "*"):
        var toml = parsetoml.parseFile(file.path) # oki
        var versionId: string
        var projectId: string

        var updateData: ModUpdateData = ModUpdateData(
          
        )
        var modToAdd: Mod = Mod(
                                name: toml["name"].getStr(),
                                side: toModSide(toml["side"].getStr()),
                                hashFormat: toml["download"]["hash-format"].getStr(),
                                hash: toml["download"]["hash"].getStr(),
                                
                                ) 

    
    var modpack: Modpack = Modpack(
      packName: tomlTable["name"].getStr("VeryCreativePackName"),
      packAuthor: tomlTable["author"].getStr("VeryCreativeUsername"), # can we check if it exists by handling the error beforehand? and returning a default if it doesn't?
      packVersion: tomlTable["version"].getStr("1.0.0"),
      mcVersion: tomlTable["versions"]["minecraft"].getStr("1.19.2"),
      modloader: loader
    )

    var installModLabel = newLabel "Install Mod:" # uh idk what to do-
    var modSourceCombo = newComboBox @[$ModSource.Modrinth, $ModSource.Curseforge]
    var modTextBox = newTextBox()
    var installModButton = newButton "Install Mod"

    installModContainer.add installModLabel
    installModContainer.add modSourceCombo
    installModContainer.add modTextBox
    installModContainer.add installModButton

    installModButton.onClick = proc(event: ClickEvent) = 
      discard installMod(modpack, toModSource(modSourceCombo.options[modSourceCombo.index]), modTextBox.text)
show window

run app

logger.info "Exiting, goodbye!"


