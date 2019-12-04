from flask import Flask
import os
import time
import random
import sys

array_num = int(os.environ.get('ARRAY-NUM', 10))
random_num = int(os.environ.get('RANDOM-NUM', 1000))
rands = []
start = time.time()
for i in range(array_num):
    rand = random.randint(0, random_num)
    rands.append(rand)
end = time.time()
rand_size = sys.getsizeof(rands)
print(rand)
elapsed_time = end - start
#print ("elapsed_time:{0}".format(elapsed_time) + "[sec]")
app = Flask(__name__)

@app.route('/')
def hello_world():
    target = os.environ.get('TARGET', 'World')
    return f'array-init ver 4.{target},\nrange = 1-{array_num}, \ninit-time = {elapsed_time}[sec],\
    \nrand-size={rand_size}[B]\n' 

if __name__ == "__main__":
    app.run(debug=True,host='0.0.0.0',port=int(os.environ.get('PORT', 8080)))
