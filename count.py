import json
import sys
import random
import io


sys.stdin = io.TextIOWrapper(sys.stdin.buffer, encoding='ascii', errors='replace')  # 'replace' handles non-ASCII characters

count_lines = 0
count_words = 0
count_errors = (0,0)
# PIPED INPUT
for line in sys.stdin:
    try:
        j = json.loads(line)
        count_lines+=1
    except:
        count_errors[0] +=1
        continue
    try:
        words = len(str(j["text"]).split(" "))
        count_words += words
    except:
        count_errors[1] += 1
        
print(f"docs: {count_lines} \nwords: {count_words} \nerrors: {count_errors}")
