#!/usr/bin/python3
import subprocess
import random
import os

homedir= os.path.expanduser('~/')
conf = homedir+".local/rfilm.conf"
player = ""
filmdir = homedir+"Videos/"
create = 0
try:
    config = open(conf, 'r')
    confc = config.read().split("\n")
    player=confc[0].split("=")[1]
    filmdir=confc[1].split("=")[1]
except FileNotFoundError:
    print("rfilm.conf not found")
    config = open(conf,'w')
    create=1

if create==1:
    player = input('Please input your player. Example: mpv \n')
    filmdir = input('Path to your video collection, by default '+homedir+'Videos/\n')    
    if filmdir=="":        
        filmdir=homedir+"Videos/"
    print("player="+player+"\nfilmdir="+filmdir+"\n",file=config)

files = subprocess.check_output(['ls', filmdir]).splitlines()
fname = filmdir+files[random.randint(0,len(files))].decode('UTF-8')
subprocess.call([player, fname])

