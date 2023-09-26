#!/usr/bin/python3
import subprocess

accesslog = "/var/log/nginx/access.log"
errordir = "/var/storage/logs/nginx/"
template = "iptables.gen.conf"
iptablescfg = "/etc/iptables.sh"
candidates = {}

newconf = ""
blocksection = ""

print("reading template\n")

with open(template) as fin:
    for line in fin:
        newconf = newconf + line

# print("template: ")
# print(newconf)

exclusions = ["127.0.0.1"]
with open(accesslog) as fin:
    for line in fin:
        data = line.split(" ")
        if len(data) > 1:
            print("ip: {} response code: {}".format(data[0], data[8]))
            try:
                if int(data[8]) >= 400:
                    if data[0] in candidates:
                        candidates[data[0]] = candidates[data[0]] + 1
                    else:
                        candidates[data[0]] = 1
            except Exception:
                print(data[8] + "is not an int")

print("done\n")
print(candidates)

beginBlock = True
for kv in candidates:
    if (candidates[kv]) > 3 and kv not in exclusions:
        if beginBlock:
            blocksection = blocksection + "#FROM access.log\n"
            beginBlock = False
        print("this one gonna be banned: {}".format(kv))
        blocksection = blocksection + "$IPT -A INPUT -p tcp -s {}/32 -j DROP #banned by log_parser\n".format(kv)

beginBlock = True
clips = []
errlogs = subprocess.check_output(['ls', errordir]).splitlines()
for errlog in errlogs:
    logname = errordir+errlog.decode('UTF-8')
    try:
        entries = subprocess.check_output(['grep', "forbidden by rule", logname]).splitlines()
    except Exception:
        print("skipping {}".format(logname))
        continue
    for entry in entries:
        try:
            clip = entry.decode('UTF-8').split("client: ")[1].split(",")[0]
            if clip not in clips and clip not in exclusions:
                clips.append(clip)
        except Exception:
            print("exception occurrend on extracring client ip from {}:{}".format(logname, entry))

for clip in clips:
    if beginBlock:
        blocksection = blocksection+"#Attempt to access forbidden dirs\n"
        beginBlock = False
    blocksection = blocksection + "$IPT -A INPUT -p tcp -s {}/32 -j DROP #banned by log_parser\n".format(clip)

newconf = newconf.replace("#block section", blocksection)
print("new generated conf is:")
print(newconf)

with open(iptablescfg, 'w') as out:
    out.write(newconf + "\n")

print("new config saved")
exit(0)
