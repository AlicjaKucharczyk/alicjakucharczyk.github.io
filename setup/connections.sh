source .flex
while true
do
   for i in {1..200}; do psql -c "SELECT 1" & done
   sleep 1
done