#[
 Copyright 2022 Ecorous System
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
     http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License. 
]#
import logging # prolly most important stuff
import nigui
import std/os
import std/osproc
let logger: Logger = getLogger "packwiz-nigui".createLoggingSource "packwiz"

proc `^&`(packName: string): string =
    return "instances" / packName # ahhhh ty!

# `/` is a built-in Nim function for the separator, so it works better and is cleaner
proc checkIfPackwiz*(): bool = # also have a nice little warning there. 
    var bool1: bool = "packwiz".findExe != "" or "packwiz.exe".findExe != ""
    if "packwiz.exe".fileExists or "packwiz".fileExists:
        logger.warn "Packwiz in current directory takes priority over packwiz in PATH. Rename or remove the packwiz in current directory to use the packwiz located in PATH"
    return bool1 

proc getPackwiz*(): string =
    var pw: string
    when defined windows:
        pw = "packwiz.exe"
    else:
        pw = "packwiz"
    var packwiz: string = ""
    if not checkIfPackwiz():
        logger.error "No packwiz found. Please install packwiz into your PATH or the current directory. Note that packwiz-nigui will not work without this."
    
    if fileExists(pw):
        packwiz = absolutePath pw 
    else:
        packwiz = pw
    return packwiz

proc packwizInit*(packName: string = "TestPack", packAuthor: string = "TestAuthor", packVersion: string = "1.0.0", mcVersion: string = "1.19.2", modloader: string = "vanilla", modloaderVersion: string = ""): ClickProc = 
    if not dirExists "instances":
        createDir "instances"
    if dirExists ^&packName:
        logger.error "Pack directory already exists! Delete " & ^&packName & " or choose a different name"
    else:
        createDir ^&packName
        var args: seq[string] = @["init", "--name", packName, "--author", packAuthor, "--version", packVersion, "--mc-version", mcVersion, "--modloader", modloader]
        if modloader != "vanilla":
            args.add "--" & modloader & "-version"
            args.add modloaderVersion
        discard execProcess(getPackwiz(), ^&packName, args, options={poUsePath})