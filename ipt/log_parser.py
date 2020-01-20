#!/usr/bin/python3

filename = "/var/log/nginx/access.log"
template = "iptables.gen.conf"
iptablescfg = "/etc/iptables.conf"
candidates = {}

newconf = ""
blocksection = ""

print("reading template\n")

with open(template) as fin:
    for line in fin:
        newconf = newconf + line

with open(filename) as fin:
    for line in fin:
        data = line.split(" ")
        if len(data) > 1:
            print("ip: {} response code: {}".format(data[0], data[8]))
            if int(data[8]) >= 400:
                if data[0] in candidates:
                    candidates[data[0]] = candidates[data[0]] + 1
                else:
                    candidates[data[0]] = 1

print("done\n")
print(candidates)

for kv in candidates:
    if candidates[kv] > 3:
        print("this one gonna be banned: {}".format(kv))
        blocksection = blocksection + "$IPT -A INPUT -p tcp -s {}/32 -j DROP\n".format(kv)

newconf = newconf.replace("#block section", blocksection)
print("new generated conf is:")
print(newconf)

with open(iptablescfg, 'w') as out:
    out.write(newconf + "\n")

print("new config saved")
exit(0)
