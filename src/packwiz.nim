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
import std/os
import std/osproc
import strutils
import sequtils
import ./logging
import ./types

let logger: Logger = getLogger "packwiz-nigui".createLoggingSource "packwiz"

proc `^&`(packName: string): string =
    return "instances" / packName



proc checkIfPackwiz*(): bool =
    result = "packwiz".findExe != "" or "packwiz.exe".findExe != ""
    if "packwiz.exe".fileExists or "packwiz".fileExists:
        logger.warn "Packwiz in current directory takes priority over packwiz in PATH. Rename or remove the packwiz in current directory to use the packwiz located in PATH"

proc getPackwiz*(): string = 
    when defined windows:
        result = "packwiz.exe"
    else:
        result = "packwiz"
    if not checkIfPackwiz():
        logger.error "No packwiz found. Please install packwiz into your PATH or the current directory. Note that packwiz-nigui will not work without this."

    if fileExists(result):
        result = absolutePath result

proc packwizInit*(packName: string = "TestPack", packAuthor: string = "TestAuthor", packVersion: string = "1.0.0", mcVersion: string = "1.19.2", modloader: Modloader = Modloader.None, modloaderVersion: string = "") = 
    if not dirExists "instances":
        createDir "instances"
    if dirExists(^&packName) and (walkFiles(^&packName / "*").toSeq.len != 0):
        logger.error "Pack directory already exists! Delete " & ^&packName & " or choose a different name"
    else:
        createDir ^&packName
        var args: seq[string] = @["init", "--name", packName, "--author", packAuthor, "--version", packVersion, "--mc-version", mcVersion, "--modloader", toLowerAscii($modloader)]
        if toLowerAscii($modloader) != "none" and toLowerAscii($modloader) != "vanilla":
            logger.debug $modloader
            args.add "--" & toLowerAscii($modloader) & "-version"
            args.add modloaderVersion # w
        var toggleCommandOut: bool = false
        var command: string = ""
        command = command & getPackwiz() & " "
        for arg in args:
            command = command & arg & " "
        if toggleCommandOut:
            logger.debug command
        discard execProcess(getPackwiz(), ^&packName, args, options={poUsePath})