from flask import Flask
import os
import time
import random

array_num = int(os.environ.get('NUM', 20000000))
rands = []
start = time.time()
for i in range(array_num):
    rand = random.randint(0, 10)
    rands.append(rand)
elapsed_time = time.time() - start
#print ("elapsed_time:{0}".format(elapsed_time) + "[sec]")
app = Flask(__name__)

@app.route('/')
def hello_world():
    target = os.environ.get('TARGET', 'World')
    return 'array-init-10 ver 3.{}\nrange = {}, init-time={}[sec]\n'.format(target, array_num, elapsed_time) 

if __name__ == "__main__":
    app.run(debug=True,host='0.0.0.0',port=int(os.environ.get('PORT', 8080)))
