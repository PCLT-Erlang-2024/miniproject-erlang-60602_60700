-module(task2).
-export([start/3, producer/2, load_truck/4]).

load_truck(MAX_CAPACITY, CAPACITY, TRUCK_ID, N_TRUCKS) ->
    receive
        SIZE when is_number(SIZE) -> 
            NEW_CAPACITY = CAPACITY - SIZE,
            if
                MAX_CAPACITY < SIZE -> 
                    io:format("Package with size ~p does not fit any truck in the system. Dropping the package!~n", [SIZE]);
                    load_truck(MAX_CAPACITY, CAPACITY, TRUCK_ID, N_TRUCKS);

                NEW_CAPACITY < 0 ->
                    io:format("Truck ~p is full and was dispatched!~n", [TRUCK_ID]),
                    io:format("Package with size ~p was loaded onto Truck ~p which now has ~p leftover capacity!~n", [SIZE, TRUCK_ID + N_TRUCKS, MAX_CAPACITY - SIZE]),
                    load_truck(MAX_CAPACITY, MAX_CAPACITY - SIZE, TRUCK_ID + N_TRUCKS, N_TRUCKS);

                NEW_CAPACITY == 0 -> 
                    io:format("Package with size ~p was loaded onto Truck ~p which now has ~p leftover capacity!~n", [SIZE, TRUCK_ID, NEW_CAPACITY]),
                    io:format("Truck ~p is full and was dispatched!~n", [TRUCK_ID]),
                    load_truck(MAX_CAPACITY, MAX_CAPACITY, TRUCK_ID + N_TRUCKS, N_TRUCKS);

                NEW_CAPACITY > 0 -> 
                    io:format("Package with size ~p was loaded onto Truck ~p which now has ~p leftover capacity!~n", [SIZE, TRUCK_ID, NEW_CAPACITY]),
                    load_truck(MAX_CAPACITY, NEW_CAPACITY, TRUCK_ID, N_TRUCKS)
            end;
        stop -> io:format("Loading Truck ~p stopped!~n", [TRUCK_ID])
    end
.

producer(CONVEYOR, MAX_PCK_SIZE) ->
    PCK_SIZE = rand:uniform(MAX_PCK_SIZE),
    CONVEYOR ! PCK_SIZE,
    producer(CONVEYOR, MAX_PCK_SIZE)
.

spawner(N_TRUCKS, N_TRUCKS, _, _) -> 
    io:format("All threads have been created!~n");
spawner(TRUCK_ID, N_TRUCKS, MAX_CAPACITY, MAX_PCK_SIZE) ->
    C = spawn(?MODULE, load_truck, [MAX_CAPACITY, MAX_CAPACITY, TRUCK_ID, N_TRUCKS]),
    spawn(?MODULE, producer, [C, MAX_PCK_SIZE]),
    spawner(TRUCK_ID + 1, N_TRUCKS, MAX_CAPACITY, MAX_PCK_SIZE)
.

start(N_TRUCKS, MAX_CAPACITY, MAX_PCK_SIZE) ->
    spawner(0, N_TRUCKS, MAX_CAPACITY, MAX_PCK_SIZE).