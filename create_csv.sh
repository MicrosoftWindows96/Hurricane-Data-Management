#!/bin/bash

input_file="$1"
output_file="$2"

echo "Timestamp,Latitude,Longitude,MinSeaLevelPressure,MaxIntensity" > "$output_file"

while IFS= read -r line; do
    if [[ $line =~ "<dtg>" ]]; then
        dtg=$(echo "$line" | sed 's/<[^>]*>//g; s/^[[:space:]]\+//; s/[[:space:]]\+$//')
    elif [[ $line =~ "<lat>" ]]; then
        lat=$(echo "$line" | sed 's/<[^>]*>//g; s/^[[:space:]]\+//; s/[[:space:]]\+$//')
        lat=$(awk -v lat="$lat" 'BEGIN {printf "%.1f %s", lat, (lat >= 0 ? "N" : "S")}')
    elif [[ $line =~ "<lon>" ]]; then
        lon=$(echo "$line" | sed 's/<[^>]*>//g; s/^[[:space:]]\+//; s/[[:space:]]\+$//')
        lon=$(awk -v lon="$lon" 'BEGIN {printf "%.1f %s", lon, (lon >= 0 ? "E" : "W")}')
    elif [[ $line =~ "<minSeaLevelPres>" ]]; then
        pres=$(echo "$line" | sed 's/<minSeaLevelPres>//; s/<\/minSeaLevelPres>//; s/^[[:space:]]\+//; s/[[:space:]]\+$//')
        pres="${pres} mb"
    elif [[ $line =~ "<intensity>" ]]; then
        int=$(echo "$line" | sed 's/<[^>]*>//g; s/^[[:space:]]\+//; s/[[:space:]]\+$//')
        int="${int} knots"
    fi

    if [[ -n $dtg && -n $lat && -n $lon && -n $pres && -n $int ]]; then
        echo "$dtg,$lat,$lon,$pres,$int" >> "$output_file"
        unset dtg lat lon pres int
    fi
done < "$input_file"

echo "Finished processing $(wc -l < "$input_file") lines."