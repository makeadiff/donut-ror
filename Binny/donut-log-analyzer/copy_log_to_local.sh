#!/bin/bash
#To copy the donut production log file(excluding the first 5lakh lines) to the localhost
ssh makeadiff@makeadiff.in "cd makeadifference/webapp/makeadiff/log/; rm production_tail.log.tgz; 
tail -n +1000000 production.log > production_tail.log; tar -zcvf production_tail.log.tgz production_tail.log; rm production_tail.log"
rm production_tail.log.tgz
rm production_tail.log
echo -n "Importing log from server"
scp makeadiff@makeadiff.in:~/makeadifference/webapp/makeadiff/log/production_tail.log.tgz ./production_tail.log.tgz
tar -zxvf production_tail.log.tgz
echo "Done"
