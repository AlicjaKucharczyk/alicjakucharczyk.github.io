source .flex
end=$((SECONDS+60))

while [ $SECONDS -lt $end ]; do
    psql -c "SELECT tempfiles()";
done