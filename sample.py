import json
import sys
import random
limit = float(sys.argv[1])

# PIPED INPUT
for line in sys.stdin:
    if random.random() < limit:
        try:
            j = json.loads(line)
            print(json.dumps(j))
        except:
            continue
