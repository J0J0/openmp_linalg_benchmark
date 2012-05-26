
program test_it
    use iso_fortran_env, only: ERROR_UNIT
    use omp_lib, only: omp_get_wtime, omp_get_num_procs, omp_get_max_threads
    use Operations
    use Helpers
    real(rk)                                ::  s
    real(rk), dimension(:),   allocatable   ::  x, y, v, w, yy
    real(rk), dimension(:,:), allocatable   ::  A, B, C, D
    
    character(20)       ::  opname
    type(timing_t)      ::  tcpu, treal
    integer             ::  i
    integer, parameter  ::  min_vec_size = 10**6


    character(9)        ::  arg
    integer             ::  n, m    ! n: vector size, m: matrix size
   
    ! IMPORTANT NOTE:
    !
    ! All 'parallel do constructs' have the 'schedule(runtime)' clause,
    ! which means that you _should_ set the environment variable
    ! OMP_SCHEDULE; setting it to "static" yields results as if the 
    ! schedule clause had been omitted.
    ! If OMP_SCHEDULE is not set, gnu's omp defaults to the (in context
    ! of this program) rather wothless setting 'schedule(dynamic,1)'.
    
    ! As an addition to the note above we warn the user about this
    ! issue if the env variable is not set:
    !
    call get_environment_variable( name="OMP_SCHEDULE", status=i )
    if( i == 1 ) &
        write(ERROR_UNIT, *) "WARNING: environment variable ", &
                             "OMP_SCHEDULE not set!", &
                             " (read about consequences in", &
                             " linalg.F90)"
    
    
    ! determine the problem size (vector/matrix);
    ! use first/second cmdline argument if given,
    ! otherwise use a prompt
    !
    if( command_argument_count() == 2 ) then
        call get_command_argument(1, arg)
        read(arg, "(i9)") n
        call get_command_argument(2, arg)
        read(arg, "(i4)") m
    else
        print *, "specify the problem size 'n' (vector):"
        read  "(i9)", n
        print *, "specify the problem size 'm' (matrix):"
        read  "(i4)", m
    endif
    
    
    ! find the actual number of threads that
    ! will run concurrently
    tcpu%ncpus = min( omp_get_max_threads(), omp_get_num_procs() )

    if( n == 0 .and. m == 0 ) then
        
        ! we got nothing to do, so print at least how many
        ! concurrent threads we would expect
        
        print "(a, i2)", "num_threads = ", tcpu%ncpus
    
    else
        
        ! allocate and initialize vectors and matrices
        
        allocate(   x(n), y(n), v(n), w(n), yy(n), &
                    A(m,m), B(m,m), C(m,m), D(m,m)  )
        
        call random_number(s)
        call random_number(x)
        call random_number(y)
        call random_number(A)
        call random_number(B)
        
    end if
    

    !============================================
    ! main part
    
    
    if( n > 0 ) then
        ! begin vector unit
    
        ! prepare the timing factor for vector operations
        if( n < min_vec_size ) then
            tcpu%ntimes = 5 * min_vec_size / n
            tcpu%ntimes = max(tcpu%ntimes, 500)
            treal%ntimes = tcpu%ntimes
        end if
        
        !----------------------
        ! vec_add
        !----------------------
        
        opname = "vec_add_do"
        
        if( tcpu%ntimes == 1 ) then
            call cpu_time(tcpu%t0)
            treal%t0 = omp_get_wtime()
            v = vec_add_do(x, y)
            treal%t1 = omp_get_wtime()
            call cpu_time(tcpu%t1)
        else
            call cpu_time(tcpu%t0)
            treal%t0 = omp_get_wtime()
            do i = 1, tcpu%ntimes
                v = vec_add_do(x, y)
            end do
            treal%t1 = omp_get_wtime()
            call cpu_time(tcpu%t1)
        end if
        w = x + y
        
        call assert( opname, vec_eq(v,w) )
        call print_timing( opname, tcpu, treal )
        
        opname = "vec_add_forall"
        
        if( tcpu%ntimes == 1 ) then
            call cpu_time(tcpu%t0)
            treal%t0 = omp_get_wtime()
            v = vec_add_forall(x, y)
            treal%t1 = omp_get_wtime()
            call cpu_time(tcpu%t1)
        else
            call cpu_time(tcpu%t0)
            treal%t0 = omp_get_wtime()
            do i = 1, tcpu%ntimes
                v = vec_add_forall(x, y)
            end do
            treal%t1 = omp_get_wtime()
            call cpu_time(tcpu%t1)
        end if
        !w = x + y  ! we have that already
        
        call assert( opname, vec_eq(v,w) )
        call print_timing( opname, tcpu, treal )
        
        !----------------------
        ! daypx
        !----------------------
        
        yy = y  ! save y for following measurements
        
        if( tcpu%ntimes > 1 ) then
            ! approximate the overhead we get by y = yy in every loop
            call cpu_time(tcpu%t0)
            treal%t0 = omp_get_wtime()
            do i = 1, tcpu%ntimes
                y = yy
            end do
            treal%t1 = omp_get_wtime()
            call cpu_time(tcpu%t1)

            call  tcpu%set_own_correction()
            call treal%set_own_correction()
            !print *, "overhead correction cpu time: ", tcpu%correction
            !print *, "overhead correction elapsed:  ", treal%correction
        end if
        
        opname = "daypx_do"
        
        if( tcpu%ntimes == 1 ) then
            call cpu_time(tcpu%t0)
            treal%t0 = omp_get_wtime()
            call daypx_do(s, y, x)
            treal%t1 = omp_get_wtime()
            call cpu_time(tcpu%t1)
        else
            call cpu_time(tcpu%t0)
            treal%t0 = omp_get_wtime()
            do i = 1, tcpu%ntimes
                y = yy
                call daypx_do(s, y, x)
            end do
            treal%t1 = omp_get_wtime()
            call cpu_time(tcpu%t1)
        end if
        w = s*yy + x
        
        call assert( opname, vec_eq(y,w) )
        call print_timing( opname, tcpu, treal )
        
        opname = "daypx_forall"
        
        y = yy  ! restore y
        if( tcpu%ntimes == 1 ) then
            call cpu_time(tcpu%t0)
            treal%t0 = omp_get_wtime()
            call daypx_forall(s, y, x)
            treal%t1 = omp_get_wtime()
            call cpu_time(tcpu%t1)
        else
            call cpu_time(tcpu%t0)
            treal%t0 = omp_get_wtime()
            do i = 1, tcpu%ntimes
                y = yy
                call daypx_forall(s, y, x)
            end do
            treal%t1 = omp_get_wtime()
            call cpu_time(tcpu%t1)
        end if
        !w = s*yy + x  ! we have that already
        
        call assert( opname, vec_eq(y,w) )
        call print_timing( opname, tcpu, treal )
        
        
        if( tcpu%ntimes > 1 ) then
            ! if we manipulated these settings reset it now
            tcpu%correction  = 0.0
            treal%correction = 0.0
        end if
        
        ! end vector unit
    end if
    
    ! -----------------------------------------------------
    
    if( m > 0 ) then
        ! begin matrix unit
        
        ! (re)set the timing factor(s) for matrix operations
        tcpu%ntimes  = 1
        treal%ntimes = 1
        
        
        !----------------------
        ! matrix_mult 
        !----------------------
        
        opname = "matrix_mult_do"
        
        call cpu_time(tcpu%t0)
        treal%t0 = omp_get_wtime()
        call matrix_mult_do(A, B, C)
        treal%t1 = omp_get_wtime()
        call cpu_time(tcpu%t1)
        D = matmul(A, B)
        
        call assert( opname, mat_eq(C,D) )
        call print_timing( opname, tcpu, treal )

        opname = "matrix_mult_forall"
        
        call cpu_time(tcpu%t0)
        treal%t0 = omp_get_wtime()
        call matrix_mult_forall(A, B, C)
        treal%t1 = omp_get_wtime()
        call cpu_time(tcpu%t1)
        !D = matmul(A, B)  ! we have that already
        
        call assert( opname, mat_eq(C,D) )
        call print_timing( opname, tcpu, treal )
        
        ! end matrix unit
    end if

end program













