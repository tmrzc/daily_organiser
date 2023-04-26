CREATE TABLE toDoList (
    id_todo INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    value_todo TEXT NOT NULL,
    status_todo TEXT NOT NULL
);

CREATE TABLE trackersList (
    id_tracker INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    name_tracker TEXT NOT NULL,
    type_tracker TEXT NOT NULL,
    color_tracker INTEGER NOT NULL,
    range_tracker INTEGER NOT NULL
);

CREATE TABLE trackersStats (
    tracker_id INTEGER NOT NULL,
    date_submitted TEXT NOT NULL,
    value_submitted REAL NOT NULL
);