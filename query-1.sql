select
    courses_of_token.id AS token_id,
    courses_of_token.student_id,
    courses_of_token.completed_in_order,
    courses_of_token.deadline_at,
    course.id as id,
    course.name as name,
    (
        SELECT
            COUNT(*)
        FROM
            developer_journey_tutorials modules
        WHERE
                modules.status = '1'
          AND modules.developer_journey_id = courses_of_token.course_id
    ) AS active_modules,
    (
        SELECT
            COUNT(*)
        FROM
            developer_journey_tutorials modules
        WHERE
                modules.developer_journey_id = courses_of_token.course_id
          AND modules.status = '1'
          AND modules.id IN (
            SELECT
                DISTINCT trackings.tutorial_id
            FROM
                developer_journey_trackings trackings
            WHERE
                    trackings.journey_id = courses_of_token.course_id
              AND trackings.status = 1
              AND trackings.developer_id = courses_of_token.student_id
        )
    ) AS completed,
    EXISTS(
        SELECT
            id
        FROM
            developer_journey_completions AS completions
        WHERE
                completions.journey_id = courses_of_token.course_id
          AND completions.user_id = courses_of_token.student_id
    ) AS has_graduated,
    EXISTS(
        SELECT
            id
        FROM
            developer_journey_tutorials AS modules
        WHERE
                modules.developer_journey_id = courses_of_token.course_id
          AND modules.type = 'quiz'
          AND modules.status = '1'
    ) AS has_submissions
from
    (
        SELECT
            token.id,
            token.completed_in_order,
            token.deadline_at,
            courses.course_id,
            token.student_id
        FROM
            multi_course_tokens AS token
                JOIN multi_course_token_courses AS courses ON token.id = courses.multi_course_token_id
        WHERE
                token.id = '1659170'
    ) AS courses_of_token
        inner join `developer_journeys` as `course` on `courses_of_token`.`course_id` = `course`.`id`;
