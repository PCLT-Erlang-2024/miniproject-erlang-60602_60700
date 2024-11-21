-module(task1).
-export([start/3,producer/2,load_truck/4]).


load_truck(MAX_CAPACITY, CAPACITY, TRUCK_ID, N_TRUCKS) ->
    receive
        SIZE when is_number(SIZE) -> 
            NEW_CAPACITY = CAPACITY - SIZE,
            if
                NEW_CAPACITY < 0 ->
                    io:format("Truck ~p is full and was dispatched!~n",[TRUCK_ID]), 
                    io:format("Package with size ~p was loaded onto Truck ~p!~n",[SIZE, TRUCK_ID + N_TRUCKS]),
                    load_truck(MAX_CAPACITY,MAX_CAPACITY-SIZE,TRUCK_ID + N_TRUCKS,N_TRUCKS);

                NEW_CAPACITY == 0 -> 
                    io:format("Package with size ~p was loaded onto Truck ~p!~n",[SIZE, TRUCK_ID]),
                    io:format("Truck ~p is full and was dispatched!~n",[TRUCK_ID]),
                    load_truck(MAX_CAPACITY,MAX_CAPACITY,TRUCK_ID + N_TRUCKS,N_TRUCKS);

                NEW_CAPACITY > 0 -> 
                    io:format("Package with size ~p was loaded onto Truck ~p!~n",[SIZE, TRUCK_ID]),
                    load_truck(MAX_CAPACITY,NEW_CAPACITY,TRUCK_ID,N_TRUCKS)
            end;
        stop -> io:format("Loading Truck ~p stopped!",[TRUCK_ID])
    end
.


producer(CONVEYOR,PCK_SIZE) -> 
    CONVEYOR ! PCK_SIZE,
    producer(CONVEYOR, PCK_SIZE)
.
    

spawner(N_CONVEYORS,N_CONVEYORS,MAX_CAPACITY,PCK_SIZE) -> 0;
spawner(CONVEYOR_ID,N_CONVEYORS,MAX_CAPACITY,PCK_SIZE) ->
    C = spawn(?MODULE,load_truck,[MAX_CAPACITY,MAX_CAPACITY,CONVEYOR_ID,N_CONVEYORS]),
    spawn(?MODULE,producer,[C,PCK_SIZE]),
    spawner(CONVEYOR_ID + 1,N_CONVEYORS, MAX_CAPACITY, PCK_SIZE)
.

start(N_CONVEYORS,MAX_CAPACITY,PCK_SIZE) -> spawner(0, N_CONVEYORS, MAX_CAPACITY, PCK_SIZE).

