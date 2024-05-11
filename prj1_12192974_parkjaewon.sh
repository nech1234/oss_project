if [ $# -ne 3 ]; then
    echo "usage: $0 teams.csv players.csv matches.csv"
    exit 1
fi

teams_file=$1
players_file=$2
matches_file=$3

echo "************OSS1 - Project1************"
echo "* StudentID : 12192974 *"
echo "* Name : Park Jaewon *"
echo "*******************************************"

menu() {
    echo "[MENU]"
    echo "1. Get the data of Heung-Min Son's Current Club, Appearances, Goals, Assists in players.csv"
    echo "2. Get the team data to enter a league position in teams.csv"
    echo "3. Get the Top-3 Attendance matches in mateches.csv"
    echo "4. Get the team's league position and team's top scorer in teams.csv & players.csv"
    echo "5. Get the modified format of date_GMT in matches.csv"
    echo "6. Get the data of the winning team by the largest difference on home stadium in teams.csv & matches.csv"
    echo "7. Exit"
}


son_data() {
    echo "Do you want to get the Heung-Min Son's data? (y/n) :"
    read choice
    if [ "$choice" = "y" ]; then
        grep "Heung-Min Son" "$players_file" | awk -F',' '{print "Team:"$4", Apperance:"$6", Goal:"$7", Assist:"$8}'
    fi
}


team_data() {
    echo "What do you want to get the team data of league_position[1~20] : "
    read position
    team_data=$(awk -F',' -v pos="$position" '$6 == pos {printf("%d %s %.6f\n", $6, $1, $2/($2+$3+$4))}' "$teams_file")
    if [ -z "$team_data" ]; then
        echo "No team found."
    else
        echo "$team_data"
    fi
}


top_attendance() {
    echo "Do you want to know Top-3 attendance data? (y/n) : "
    read choice
    if [ "$choice" = "y" ]; then
        echo "***Top-3 Attendance Match***"
        sort -t',' -k2 -rn "$matches_file" | head -3 | awk -F',' '{
            split($1, date, " - ")
            printf("%s vs %s (%s)\n%s %s\n", $3, $4, $1, $2, $7)
        }'
    fi
}

team_ranking() {
    echo "Do you want to get each team's ranking and the highest-scoring player? (y/n) : "
    read choice
    if [ "$choice" = "y" ]; then
        while IFS=',' read -r team wins draws losses points position rest; do
            echo "$position $team"
            player=$(grep -E "$team" "$players_file" | sort -t',' -k7 -rn | head -1 | cut -d',' -f1)
            goals=$(grep -E "$team" "$players_file" | sort -t',' -k7 -rn | head -1 | cut -d',' -f7)
            echo "$player $goals"
        done < "$teams_file"
    fi
}

date_format() {
    echo "Do you want to modify the format of date? (y/n) : "
    read choice
    if [ "$choice" = "y" ]; then
        sed 's/\([A-Z][a-z][a-z]\) \([0-9]\{1,2\}\) \([0-9]\{4\}\) - \([0-9]\{1,2\}:[0-9]\{2\}\)\([ap]m\)/\3\/\1\/\2 \4\5/g' "$matches_file" | cut -d',' -f1 | tail -n +2 | head -10
    fi
}

home_winning_team() {
    team_names=()
    i=1
    while IFS=',' read -r team_name; do
        team_names+=("$team_name")
        echo "$i) $team_name"
        ((i++))
    done < <(awk -F ',' 'NR>1 {print $1}' "$teams_file")

    read -p "Enter your team number : " team_number
    team_name="${team_names[$((team_number-1))]}"

    team_name_modified=$(echo "$team_name" | sed 's/ /_/g')

    awk -F ',' -v name="$team_name" '
        $3 == name && $5 > $6 {
            diff = $5 - $6
            if (diff > max_diff) {
                max_diff = diff
                results = $1 "\n" $3 " " $5 " vs " $6 " " $4
            } else if (diff == max_diff) {
                results = results "\n" $1 "\n" $3 " " $5 " vs " $6 " " $4
            }
        }
        END {
            if (max_diff > 0) {
                print results
            }
        }
    ' max_diff=0 "$matches_file"

}
while true; do
    menu
    echo "Enter your CHOICE (1~7) : "
    read choice
    case $choice in
        1) son_data ;;
        2) team_data ;;
        3) top_attendance ;;
        4) team_ranking ;;
        5) date_format ;;
        6) home_winning_team ;;
        7) echo "Bye!"; exit 0 ;;
        *) echo "Invalid choice. Please try again." ;;
    esac
done


