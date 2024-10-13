import subprocess
import sys
import json

def getsrcname(binpath):
    src = []
    for c in reversed(binpath):
        if c == "_":
            break
        src.append(c)
    return "".join(reversed(src))

exe = sys.argv[1]

verbose = 0

try:
    verbose = sys.argv[2]
except:
    pass

name = exe.replace(".\bin", "").replace("bin/", "").replace('"\"', "").replace(".exe", "")
src = getsrcname(name)
name = name.replace(f"_{src}", "")
test_path = f"./{src}/{name}.test.json"
test = None

try:
    with open(test_path) as test_file:
        test = json.load(test_file)
except:
    print("Error while opening test file!")
    sys.exit(1)


def run(inp):
    process = subprocess.Popen([exe], stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    output, _ = process.communicate(input=inp.encode())
    return output.decode().strip()

def normalize(output):
    lines = output.strip().split('\n')
    return '\n'.join(line.strip() for line in lines)

test_path_f = test_path.removeprefix("'./'")
is_verbose_str = " in verbose mode." if (int(verbose) == 1) else ""
print(f"Running binary at {exe} using {test_path_f}{is_verbose_str}")
casePassed = 0
for i, case in enumerate(test["cases"]):
    inp = case["input"]
    exp = normalize(case["expect"].strip())
    res = normalize(run(inp))
    if res != exp:
        print(f"Error on case {i+1}: Expected {exp}, got {res}")
        continue
    if int(verbose) == 1:
        print(f"\nTesting Case {i+1}: ")
        print(res)
    casePassed += 1

print(f"Case passed: {casePassed}")