import json
import sys
import random
limit = float(sys.argv[1])

for line in sys.stdin:
    if random.random() < limit:
        d = json.loads(line)
        print(d)