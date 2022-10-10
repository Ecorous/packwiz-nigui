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

import strutils

type Modloader* = enum # TODO: support other mod loaders
    None, Fabric, Forge, Quilt

type ModSide* = enum
    Server, Client, Both

type ModSource* = enum
    Modrinth, Curseforge

type ModUpdateData* = object
    versionId: string
    projectId: string # can we clean up createpackbutton.onclick lmao, very messy
    mrUrl: string # problem solved
    source: ModSource 

type Mod* = object
    name: string
    side: ModSide
    filename: string
    hashFormat: string
    hash: string 
    updateData: ModUpdateData

type Modpack* = object
    packName*: string
    packAuthor*: string
    packVersion*: string
    mcVersion*: string
    modloader*: Modloader
    mods*: seq[Mod]

type Result* = enum
    Sucess, Fail, Unknown

proc toModLoader*(input: string): Modloader =
    if input.toLowerAscii == "quilt":
        result = Modloader.Quilt
    elif input.toLowerAscii == "fabric":
        result = Modloader.Fabric
    elif input.toLowerAscii == "forge":
        result = Modloader.Forge
    elif input.toLowerAscii == "none" or input.toLowerAscii == "vanilla":
        result = Modloader.None

proc toModSource*(input: string): ModSource =
    if input.toLowerAscii == "modrinth":
        result = ModSource.Modrinth
    elif input.toLowerAscii == "curseforge":
        result = ModSource.Curseforge

proc toModSide*(input: string): ModSide =
    if input.toLowerAscii == "client":
        result = ModSide.Client
    elif input.toLowerAscii == "server":
        result = ModSide.Server
    elif input.toLowerAscii == "both":
        result = ModSide.Both