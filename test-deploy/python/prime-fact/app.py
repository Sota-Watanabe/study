from flask import Flask
import os
import time
import random

def factorize(n):
    b = 2
    fct = []
    while b * b <= n:
        while n % b == 0:
            n //= b
            fct.append(b)
        b = b + 1
    if n > 1:
        fct.append(n)
    return fct

start = time.time()
rands = []
for i in range(50000):
    rand = random.randint(100,1000000000)
    rands.append(rand)
    #print(i)
#print(rands)
ans_rands = list(map(factorize, rands))
#print(ans_rands)

elapsed_time = time.time() - start
print ("elapsed_time:{0}".format(elapsed_time) + "[sec]")




app = Flask(__name__)

@app.route('/')
def hello_world():
    target = os.environ.get('TARGET', 'World')
    return 'array-init ver 1.{}\n'.format(target) 

if __name__ == "__main__":
    app.run(debug=True,host='0.0.0.0',port=int(os.environ.get('PORT', 8080)))
