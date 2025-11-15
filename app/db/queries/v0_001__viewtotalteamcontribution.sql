SELECT 
    player,
    goals,
    assists,
    total_contributions
FROM (
    SELECT 
        CONCAT(p.first_name, ' ', p.last_name) AS player,
        SUM(me.event_type = 'Goal') AS goals,
        SUM(me.event_type = 'Assist') AS assists,
        SUM(me.event_type IN ('Goal', 'Assist')) AS total_contributions,
        p.id AS sort_id
    FROM match_events me
    JOIN players p ON me.player_id = p.id
    WHERE me.team_id = 7
      AND me.event_type IN ('Goal', 'Assist')
    GROUP BY p.id

    UNION ALL

    SELECT
        'TEAM TOTAL' AS player,
        SUM(me.event_type = 'Goal'),
        SUM(me.event_type = 'Assist'),
        SUM(me.event_type IN ('Goal', 'Assist')),
        999999 AS sort_id
    FROM match_events me
    WHERE me.team_id = 7
      AND me.event_type IN ('Goal', 'Assist')
) AS combined
ORDER BY sort_id, total_contributions DESC, goals DESC;
