from matplotlib import pyplot as plt
import seaborn as sns

import pandas as pd

columns = ["system.cpu.numCycles", ]

def nametable(x):
    if x == "-aes-gcm":
        return "AES GCM"
    if x == "-rsa":
        return "RSA"
    if x in ["shared", "adaptive", "symmetric", "partitioned"]:
        x = x[0].upper() + x[1:]
        return x
    else:
        return x[:-3] # remove js suffix
records = []
from glob import glob
for fn in glob("*/stat-file.txt"):
    # print(fn)
    descriptor, suffix = fn.split("/")
    arch, cryptobench, jsbench = descriptor.split("__")
    arch = nametable(arch)
    cryptobench = nametable(cryptobench)
    jsbench = nametable(jsbench)

    # print(f"arch: {arch}, cryptobench: {cryptobench}, jsbench: {jsbench}")


    d = {}
    with open(fn, 'r') as f:
        for line in f:
            if line == "\n":
                # print("skipping empty")
                continue
            if "---------- End Simulation Statistics   ----------" in line:
                # print("skipping last line")
                continue
            if "---------- Begin Simulation Statistics ----------" in line:
                # print("skipping first line")
                continue
            arr = line.split()
            k = arr[0]
            v = arr[1]
            d[k] = v
    dd = {} # filtered dict


    record = {
        "arch": arch,
        "cryptobench": cryptobench,
        "jsbench": jsbench,
    }
    for k in columns:
        # print(k, d[k])
        record[k] = float(d[k])
#     print(record)
    records.append(record)

df = pd.DataFrame.from_records(records)

archs = set(df.arch)

cryptobenchs = set(df.cryptobench)

jsbenchs=set(df.jsbench)

archs

cryptobenchs

jsbenchs





tidy = df[df.cryptobench=="RSA"]
tidy = df
# fig, ax1 = plt.subplots(figsize=(10, 10))
#tidy = df.melt(id_vars='Factor').rename(columns=str.title)
sns.set(rc={'figure.figsize':(20,8.27)})
g = sns.catplot(
    col='cryptobench',
    x='jsbench',
    hue='arch',
    y='system.cpu.numCycles',
    data=tidy, kind="bar",
    palette=("PuBu"),linewidth=1,)
g.set_xticklabels(rotation=15)
plt.savefig("browserlike.pdf")
