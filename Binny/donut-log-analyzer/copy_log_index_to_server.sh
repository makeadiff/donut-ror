#!/bin/bash
#To copy the the index file and log file to the server
echo "Deleting files on the server"
ssh makeadiff@makeadiff.in "cd public_html/apps/donut-log-analyzer/ ; rm index.php ; rm production_tail.log ; rm production_tail.log.tgz"
echo "Copying index.php"
scp index.php makeadiff@makeadiff.in:~/public_html/apps/donut-log-analyzer/index.php
echo "Copying log file"
scp production_tail.log.tgz makeadiff@makeadiff.in:~/public_html/apps/donut-log-analyzer/production_tail.log.tgz
echo "Extracting log file in the server"
ssh makeadiff@makeadiff.in "cd public_html/apps/donut-log-analyzer/ ; tar -zxvf production_tail.log.tgz"
echo "Done"

