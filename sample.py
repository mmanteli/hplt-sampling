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
            print(json.dumps({"id":j["id"], "text":j["text"]}))  #tested to be faster than .get etc
        except:
            continue
