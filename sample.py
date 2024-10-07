import json
import sys
import random
import io
limit = float(sys.argv[1])

sys.stdin = io.TextIOWrapper(sys.stdin.buffer, encoding='ascii', errors='replace')  # 'replace' handles non-ASCII characters


# PIPED INPUT
for line in sys.stdin:
    if random.random() < limit:
        try:
            j = json.loads(line)
            print(json.dumps(j))
        except:
            continue
