#!/bin/bash

cp -r src deb/opt/vds-games/sokoadventure/
cp -r data deb/opt/vds-games/sokoadventure/
dpkg -b deb sokoadventure-2.1.1.deb
