
module Helpers
    use Operations, only: rk
    integer, parameter  ::  rk_timing = 4

    type :: timing_t
        real(rk_timing) ::  t0, t1
        integer         ::  ntimes = 1
        integer         ::  ncpus  = 1
        real(rk_timing) ::  correction = 0.0
    contains
        procedure :: delta_t   => timing_delta_t
        procedure :: t_per_cpu => timing_t_per_cpu
        procedure :: set_own_correction => timing_set_own_correction
    end type
    
contains

    function timing_delta_t(tming, ntimes)
        type(timing_t), intent(in)   ::  tming
        real(rk_timing)              ::  timing_delta_t
        integer, optional            ::  ntimes
        integer                      ::  n
        
        if( present(ntimes) ) then
            n = ntimes
        else
            n = tming%ntimes
        end if
        
        timing_delta_t = (tming%t1 - tming%correction - tming%t0) / n
    end function

    function timing_t_per_cpu(tming)
        type(timing_t), intent(in)   ::  tming
        real(rk_timing)              ::  timing_t_per_cpu

        timing_t_per_cpu = tming%delta_t() / tming%ncpus
    end function
    
    subroutine timing_set_own_correction(tming)
        class(timing_t), intent(inout)  ::  tming
        
        tming%correction = tming%t1 - tming%t0
    end subroutine
    
    function vec_eq(x, y, prec)
        real(rk), intent(in)    ::  x(:), y(:)
        logical                 ::  vec_eq
        real(rk), optional      ::  prec 
        real(rk)                ::  p 

        p = 1e-12
        if(present(prec)) p = prec
        
        vec_eq = .not. any( abs(x-y) > p )
    end function

    function mat_eq(X, Y, prec)
        real(rk), intent(in)    ::  X(:,:), Y(:,:)
        logical                 ::  mat_eq
        real(rk), optional      ::  prec 
        real(rk)                ::  p 

        p = 1e-10
        if(present(prec)) p = prec
        
        mat_eq = .not. any( abs(X-Y) > p )
    end function

    subroutine assert(str, bool)
        character(*), intent(in)    ::  str
        logical,      intent(in)    ::  bool

        if( .not. bool ) then
            print "(x,a,a)", "an operation went wrong, check ", str
            stop 1
        end if
    end subroutine

    subroutine print_timing( str, tcpu, treal )
        character(*),    intent(in)   ::  str
        type(timing_t),  intent(in)   ::  tcpu, treal

        print "(a,3(a,f10.6))", str, &
                            " ||  elapsed time: ", treal%delta_t(), &
                            " ||  total cpu time: ", tcpu%delta_t(), &
                            " ||  time/cpu: ", tcpu%t_per_cpu()
    end subroutine
end module









