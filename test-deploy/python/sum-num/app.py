from flask import Flask
import os
import time
import random
import sys

loop_num = int(os.environ.get('LOOP', 10000000000))
start = time.time()
num = 0
for i in range(loop_num):
    rand = random.randint(0, 1000000000)
    num += rand
end = time.time()
elapsed_time = end - start
#print ("elapsed_time:{0}".format(elapsed_time) + "[sec]")
app = Flask(__name__)

@app.route('/')
def hello_world():
    target = os.environ.get('TARGET', 'World')
    return f'array-init ver 4.{target},\nnum = {num}, \ninit-time = {elapsed_time}[sec],\n' 

if __name__ == "__main__":
    app.run(debug=True,host='0.0.0.0',port=int(os.environ.get('PORT', 8080)))
