#!/usr/bin/python3 -u
import cgi
import cgitb
import sys
import os
import time
import datetime
import json
#import pickle
#import numpy as np

#NOTE that "post" now basically refers to an "instance" of the form sending data in, plus the graph that is made from that data (with times).


with open('/var/www/html/hack2021/RUNNING','w') as f:
    f.close()

cgitb.enable()


form = cgi.FieldStorage()

print("Content-Type: text/html\n\n")

def check_for_field(form, field):
    if (field in form.keys()):
        return form[field].value
    else:
        return "Not specified"


speed = float(check_for_field(form,'actVeloc'))
friction = float(check_for_field(form,'recVeloc'))

filename='/var/www/html/hack2021/data'

with open(filename) as infile:
    total_friction=float(infile.readline())
    count_friction=float(infile.readline())
    avg_friction=float(infile.readline())
    current_friction=float(infile.readline())

    total_speed=float(infile.readline())
    count_speed=float(infile.readline())
    avg_speed=float(infile.readline())
    current_speed=float(infile.readline())

total_friction = total_friction + friction
count_friction = count_friction + 1
avg_friction = total_friction / count_friction
current_friction = friction

total_speed = total_speed + speed
count_speed = count_speed + 1
avg_speed = total_speed / count_speed
current_speed = speed


with open(filename, 'w') as outfile:  # Overwrites any existing file.
    outfile.write(str(total_friction) + '\n')
    outfile.write(str(count_friction) + '\n')
    outfile.write(str(avg_friction) + '\n')
    outfile.write(str(current_friction) + '\n')
    outfile.write(str(total_speed) + '\n')
    outfile.write(str(count_speed) + '\n')
    outfile.write(str(avg_speed) + '\n')
    outfile.write(str(current_speed) + '\n')
    


